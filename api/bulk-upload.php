<?php
// Disable error display for clean JSON responses
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

session_start();
header('Content-Type: application/json');

// Catch any fatal errors and return JSON
function handleFatalError() {
    $error = error_get_last();
    if ($error && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Server error occurred: ' . $error['message']
        ]);
        exit();
    }
}
register_shutdown_function('handleFatalError');

// Check if user is logged in
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized access']);
    exit();
}

require_once '../config/database.php';
require_once '../lib/XLSXGenerator.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Database connection failed");
    }
    
    $action = $_GET['action'] ?? '';
    
    switch ($action) {
        case 'template':
            $format = $_GET['format'] ?? 'csv';
            generateTemplate($format);
            break;
            
        case 'sample':
            generateSampleData();
            break;
            
        case 'upload':
            handleBulkUpload($db);
            break;
            
        default:
            throw new Exception("Invalid action");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}

function generateTemplate($format = 'csv') {
    global $db;
    
    // Get all dropdown options from database
    $dropdownOptions = getDropdownOptions($db);
    
    $headers = [
        'personal_no',
        'rank',
        'name',
        'cores_id',
        'unit_id',
        'course_cadre_name',
        'formation_id',
        'special_notes',
        'exercises',
        'med_category_id',
        'mobile_personal',
        'mobile_family',
        'birth_date',
        'admission_date',
        'joining_date_awgc',
        'worked_in_awgc',
        'civil_edu',
        'course',
        'cadre',
        'permanent_address',
        'present_address',
        'expertise_area',
        'punishment'
    ];
    
    // Add instruction row
    $instructionRow = [
        'Enter unique personal number (e.g., PA-12345)',
        'Rank (preferred order: Snk, LCpl, Cpl, Sgt, WO, SWO - others auto-registered)',
        'Full name of operator',
        'Corps name (existing or new - will be auto-registered)',
        'Unit name (existing or new - will be auto-registered)',
        'OP Qualifying Course/Cadre',
        'Formation name (existing or new - will be auto-registered)',
        'Special notes (comma-separated, new ones auto-registered)',
        'Exercises (comma-separated, new ones auto-registered)',
        'Medical category (existing or new - will be auto-registered)',
        '01XXXXXXXXX (personal mobile)',
        '01XXXXXXXXX (family mobile)',
        'Date formats: YYYY-MM-DD, DD/MM/YYYY, MM/DD/YYYY (birth date)',
        'Date formats: YYYY-MM-DD, DD/MM/YYYY, MM/DD/YYYY (admission date)',
        'Date formats: YYYY-MM-DD, DD/MM/YYYY, MM/DD/YYYY (joining date AWGC)',
        'Previous work experience in AWGC',
        'Civil education background',
        'Courses completed',
        'Cadre information',
        'Permanent address',
        'Present address',
        'Area of expertise',
        'Punishment details if any'
    ];
    
    if ($format === 'xlsx') {
        generateExcelTemplate($headers, $instructionRow);
    } else {
        generateCSVTemplate($headers, $instructionRow);
    }
}

function generateCSVTemplate($headers, $instructionRow) {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="operator_template.csv"');
    
    $output = fopen('php://output', 'w');
    fputcsv($output, $headers);
    fputcsv($output, $instructionRow);
    fclose($output);
    exit();
}

function generateExcelTemplate($headers, $instructionRow) {
    try {
        $xlsx = new XLSXGenerator();
        
        // Add header row with header style
        $xlsx->addRow($headers, 'header');
        
        // Add instruction row with instruction style
        $xlsx->addRow($instructionRow, 'instruction');
        
        // Generate and download the file
        $xlsx->generate('operator_template.xlsx');
        
    } catch (Exception $e) {
        // Fallback to CSV if XLSX generation fails
        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="operator_template.csv"');
        
        $output = fopen('php://output', 'w');
        fputcsv($output, $headers);
        fputcsv($output, $instructionRow);
        fclose($output);
        exit();
    }
}


function getDropdownOptions($db) {
    $options = [];
    
    // Get all dropdown options
    $tables = ['cores', 'units', 'formations', 'med_categories', 'special_notes', 'exercises'];
    
    foreach ($tables as $table) {
        try {
            $stmt = $db->query("SELECT id, name FROM $table ORDER BY name");
            $options[$table] = $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            $options[$table] = [];
        }
    }
    
    // Add ranks with custom ordering
    try {
        $options['ranks'] = getRanksDataForBulk($db);
    } catch (Exception $e) {
        $options['ranks'] = [];
    }
    
    return $options;
}

function getRanksDataForBulk($db) {
    // Define the custom rank order
    $rankOrder = ['Snk', 'LCpl', 'Cpl', 'Sgt', 'WO', 'SWO'];
    
    // Get all ranks from database
    $stmt = $db->prepare("SELECT id, name FROM ranks");
    $stmt->execute();
    $allRanks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Create arrays for ordered and unordered ranks
    $orderedRanks = [];
    $otherRanks = [];
    
    // Separate ranks based on the predefined order
    foreach ($allRanks as $rank) {
        $orderIndex = array_search($rank['name'], $rankOrder);
        if ($orderIndex !== false) {
            $orderedRanks[$orderIndex] = $rank;
        } else {
            $otherRanks[] = $rank;
        }
    }
    
    // Sort ordered ranks by their index
    ksort($orderedRanks);
    
    // Sort other ranks alphabetically
    usort($otherRanks, function($a, $b) {
        return strcmp($a['name'], $b['name']);
    });
    
    // Combine ordered ranks first, then other ranks
    return array_merge(array_values($orderedRanks), $otherRanks);
}

function generateSampleData() {
    global $db;
    $dropdownOptions = getDropdownOptions($db);
    
    echo json_encode([
        'success' => true,
        'data' => [
            [
                'personal_no' => 'PA-12345',
                'rank' => 'Cpl',
                'name' => 'John Doe',
                'cores_id' => !empty($dropdownOptions['cores']) ? $dropdownOptions['cores'][0]['name'] : 'Infantry (EB)',
                'unit_id' => !empty($dropdownOptions['units']) ? $dropdownOptions['units'][0]['name'] : 'Alpha Company',
                'course_cadre_name' => 'Basic Commando Course',
                'formation_id' => !empty($dropdownOptions['formations']) ? $dropdownOptions['formations'][0]['name'] : '1st Infantry Division',
                'special_notes' => !empty($dropdownOptions['special_notes']) ? $dropdownOptions['special_notes'][0]['name'] : 'Instructor',
                'exercises' => !empty($dropdownOptions['exercises']) ? implode(', ', array_slice(array_column($dropdownOptions['exercises'], 'name'), 0, 2)) : 'Exercise Alpha, Exercise Bravo',
                'med_category_id' => !empty($dropdownOptions['med_categories']) ? $dropdownOptions['med_categories'][0]['name'] : 'A',
                'mobile_personal' => '01712345678',
                'mobile_family' => '01812345678',
                'birth_date' => '1990-05-15',
                'admission_date' => '2020-01-10',
                'joining_date_awgc' => '2020-02-01',
                'worked_in_awgc' => 'Instructor at Basic Training Wing',
                'civil_edu' => 'BSc in Computer Science',
                'course' => 'Advanced Leadership Course, Tactical Operations',
                'cadre' => 'Regular Commission',
                'permanent_address' => '123 Main Street, Dhaka-1000',
                'present_address' => 'AWGC Officers Mess, Dhaka Cantonment',
                'expertise_area' => 'Combat Training, Leadership Development',
                'punishment' => ''
            ],
            [
                'personal_no' => 'PA-12346',
                'rank' => 'Sgt',
                'name' => 'Jane Smith',
                'cores_id' => 'Artillery',
                'unit_id' => 'Bravo Company',
                'course_cadre_name' => 'Artillery Officers Course',
                'formation_id' => '3rd Artillery Regiment',
                'special_notes' => 'AWGC Prohibited',
                'exercises' => 'Exercise Charlie, Exercise Delta',
                'med_category_id' => 'B',
                'mobile_personal' => '01712345679',
                'mobile_family' => '01812345679',
                'birth_date' => '1988-08-22',
                'admission_date' => '2019-06-15',
                'joining_date_awgc' => '2019-07-01',
                'worked_in_awgc' => 'Training Officer at Weapons Wing',
                'civil_edu' => 'MSc in Military Science',
                'course' => 'Staff Course, Artillery Advanced Course',
                'cadre' => 'Regular Commission',
                'permanent_address' => '456 Park Avenue, Chittagong-4000',
                'present_address' => 'AWGC Family Quarters, Dhaka Cantonment',
                'expertise_area' => 'Artillery Operations, Training Management',
                'punishment' => 'Minor disciplinary action - 2020'
            ],
            [
                'personal_no' => 'PA-12347',
                'rank' => 'WO',
                'name' => 'Mike Johnson',
                'cores_id' => 'Special Forces',
                'unit_id' => 'Special Operations Unit',
                'course_cadre_name' => 'Special Forces Training',
                'formation_id' => 'Special Operations Command',
                'special_notes' => 'Elite Operator, Medical Officer',
                'exercises' => 'Operation Thunder, Exercise Viper, Urban Warfare Training',
                'med_category_id' => 'A+',
                'mobile_personal' => '01712345680',
                'mobile_family' => '01812345680',
                'birth_date' => '1985-12-03',
                'admission_date' => '2018-03-20',
                'joining_date_awgc' => '2018-04-15',
                'worked_in_awgc' => 'Senior Instructor at Advanced Combat Wing',
                'civil_edu' => 'Masters in Strategic Studies',
                'course' => 'Special Forces Course, Advanced Tactics, Medical Training',
                'cadre' => 'Special Commission',
                'permanent_address' => '789 Elite Street, Sylhet-3100',
                'present_address' => 'AWGC Senior Staff Quarters, Dhaka Cantonment',
                'expertise_area' => 'Special Operations, Medical Support, Advanced Combat',
                'punishment' => ''
            ]
        ]
    ]);
}

function handleBulkUpload($db) {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception("Only POST method allowed");
    }
    
    // Get JSON data from request body
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception("JSON decode error: " . json_last_error_msg());
    }
    
    if (!$data || !isset($data['operators']) || !is_array($data['operators'])) {
        throw new Exception("Invalid data format. Expected 'operators' array.");
    }
    
    $operators = $data['operators'];
    $results = [
        'total' => count($operators),
        'successful' => 0,
        'failed' => 0,
        'errors' => [],
        'auto_registered' => [
            'formations' => [],
            'cores' => [],
            'units' => [],
            'ranks' => [],
            'exercises' => [],
            'special_notes' => [],
            'med_categories' => []
        ]
    ];
    
    // Begin transaction
    $db->beginTransaction();
    
    try {
        $stmt = $db->prepare("
            INSERT INTO operators (
                personal_no, `rank`, name, cores_id, unit_id, course_cadre_name, 
                formation_id, special_note, med_category_id,
                mobile_personal, mobile_family, birth_date, admission_date, 
                joining_date_awgc, worked_in_awgc, civil_edu, course, cadre, 
                permanent_address, present_address, expertise_area, punishment, created_at
            ) VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW()
            )
        ");
        
        foreach ($operators as $index => $operator) {
            try {
                // Validate required fields
                $requiredFields = ['personal_no', 'rank', 'name'];
                foreach ($requiredFields as $field) {
                    if (empty($operator[$field])) {
                        throw new Exception("Missing required field: $field");
                    }
                }
                
                // Check if personal_no already exists
                $checkStmt = $db->prepare("SELECT COUNT(*) FROM operators WHERE personal_no = ?");
                $checkStmt->execute([$operator['personal_no']]);
                if ($checkStmt->fetchColumn() > 0) {
                    throw new Exception("Personal number already exists: " . $operator['personal_no']);
                }
                
                // Validate and normalize date formats
                $dateFields = ['birth_date', 'admission_date', 'joining_date_awgc'];
                foreach ($dateFields as $field) {
                    if (!empty($operator[$field])) {
                        $normalizedDate = normalizeDate($operator[$field]);
                        if ($normalizedDate === false) {
                            throw new Exception("Invalid date format for $field. Supported formats: YYYY-MM-DD, DD/MM/YYYY, MM/DD/YYYY, DD-MM-YYYY, MM-DD-YYYY");
                        }
                        $operator[$field] = $normalizedDate;
                    }
                }
                
                // Convert dropdown names to IDs and track auto-registered items
                $processedOperator = processDropdownFields($db, $operator, $results['auto_registered']);
                
                // Execute insert
                $stmt->execute([
                    $processedOperator['personal_no'] ?? '',
                    $processedOperator['rank'] ?? '',
                    $processedOperator['name'] ?? '',
                    $processedOperator['cores_id'] ?? null,
                    $processedOperator['unit_id'] ?? null,
                    $processedOperator['course_cadre_name'] ?? '',
                    $processedOperator['formation_id'] ?? null,
                    $processedOperator['special_note'] ?? '',
                    $processedOperator['med_category_id'] ?? null,
                    $processedOperator['mobile_personal'] ?? '',
                    $processedOperator['mobile_family'] ?? '',
                    $processedOperator['birth_date'] ?? null,
                    $processedOperator['admission_date'] ?? null,
                    $processedOperator['joining_date_awgc'] ?? null,
                    $processedOperator['worked_in_awgc'] ?? '',
                    $processedOperator['civil_edu'] ?? '',
                    $processedOperator['course'] ?? '',
                    $processedOperator['cadre'] ?? '',
                    $processedOperator['permanent_address'] ?? '',
                    $processedOperator['present_address'] ?? '',
                    $processedOperator['expertise_area'] ?? '',
                    $processedOperator['punishment'] ?? ''
                ]);
                
                $operatorId = $db->lastInsertId();
                
                // Handle exercises (many-to-many relationship)
                if (!empty($processedOperator['exercises'])) {
                    $exerciseNames = array_map('trim', explode(',', $processedOperator['exercises']));
                    foreach ($exerciseNames as $exerciseName) {
                        if (!empty($exerciseName)) {
                            // Find or create exercise
                            $exerciseStmt = $db->prepare("SELECT id FROM exercises WHERE name = ? LIMIT 1");
                            $exerciseStmt->execute([$exerciseName]);
                            $exerciseId = $exerciseStmt->fetchColumn();
                            
                            if (!$exerciseId) {
                                // Create new exercise and track it
                                $insertExerciseStmt = $db->prepare("INSERT INTO exercises (name) VALUES (?)");
                                $insertExerciseStmt->execute([$exerciseName]);
                                $exerciseId = $db->lastInsertId();
                                
                                if (!in_array($exerciseName, $results['auto_registered']['exercises'])) {
                                    $results['auto_registered']['exercises'][] = $exerciseName;
                                }
                            }
                            
                            // Link exercise to operator
                            $linkStmt = $db->prepare("INSERT IGNORE INTO operator_exercises (operator_id, exercise_id) VALUES (?, ?)");
                            $linkStmt->execute([$operatorId, $exerciseId]);
                        }
                    }
                }
                
                // Handle special notes (many-to-many relationship)
                if (!empty($processedOperator['special_notes_list'])) {
                    foreach ($processedOperator['special_notes_list'] as $specialNoteData) {
                        if (!empty($specialNoteData['id'])) {
                            // Link special note to operator
                            $linkStmt = $db->prepare("INSERT IGNORE INTO operator_special_notes (operator_id, special_note_id) VALUES (?, ?)");
                            $linkStmt->execute([$operatorId, $specialNoteData['id']]);
                        }
                    }
                }
                
                $results['successful']++;
                
            } catch (Exception $e) {
                $results['failed']++;
                $results['errors'][] = [
                    'row' => $index + 1,
                    'personal_no' => $operator['personal_no'] ?? 'Unknown',
                    'error' => $e->getMessage()
                ];
            }
        }
        
        // Commit transaction
        $db->commit();
        
        echo json_encode([
            'success' => true,
            'message' => "Bulk upload completed",
            'results' => $results
        ]);
        
    } catch (Exception $e) {
        $db->rollback();
        throw $e;
    }
}

function processDropdownFields($db, $operator, &$autoRegistered) {
    $processed = $operator;
    
    // Map dropdown fields to their table names
    $dropdownMappings = [
        'cores_id' => 'cores',
        'unit_id' => 'units', 
        'formation_id' => 'formations',
        'med_category_id' => 'med_categories'
    ];
    
    // Process each dropdown field
    foreach ($dropdownMappings as $field => $table) {
        if (!empty($operator[$field])) {
            $value = trim($operator[$field]);
            
            // Check if it's already an ID (numeric)
            if (is_numeric($value)) {
                $processed[$field] = (int)$value;
            } else {
                // Try to find ID by name
                try {
                    $stmt = $db->prepare("SELECT id FROM $table WHERE name = ? LIMIT 1");
                    $stmt->execute([$value]);
                    $result = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if ($result) {
                        $processed[$field] = $result['id'];
                    } else {
                        // If not found, create new entry and track it
                        $insertStmt = $db->prepare("INSERT INTO $table (name) VALUES (?)");
                        $insertStmt->execute([$value]);
                        $processed[$field] = $db->lastInsertId();
                        
                        // Track auto-registered item
                        $tableKey = rtrim($table, 's'); // Remove 's' for consistency
                        if ($table === 'med_categories') $tableKey = 'med_categories';
                        
                        // Ensure the array key exists
                        if (!isset($autoRegistered[$tableKey]) || !is_array($autoRegistered[$tableKey])) {
                            $autoRegistered[$tableKey] = [];
                        }
                        
                        if (!in_array($value, $autoRegistered[$tableKey])) {
                            $autoRegistered[$tableKey][] = $value;
                        }
                    }
                } catch (Exception $e) {
                    // If table doesn't exist or other error, set to null
                    $processed[$field] = null;
                }
            }
        }
    }
    
    // Process rank field (handle auto-registration)
    if (!empty($operator['rank'])) {
        $rankValue = trim($operator['rank']);
        
        // Check if rank exists
        $stmt = $db->prepare("SELECT name FROM ranks WHERE name = ? LIMIT 1");
        $stmt->execute([$rankValue]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$result) {
            // Create new rank and track it
            try {
                $insertStmt = $db->prepare("INSERT INTO ranks (name) VALUES (?)");
                $insertStmt->execute([$rankValue]);
                
                // Ensure the ranks array exists
                if (!isset($autoRegistered['ranks']) || !is_array($autoRegistered['ranks'])) {
                    $autoRegistered['ranks'] = [];
                }
                
                if (!in_array($rankValue, $autoRegistered['ranks'])) {
                    $autoRegistered['ranks'][] = $rankValue;
                }
            } catch (Exception $e) {
                // Rank might already exist due to concurrent inserts, ignore error
            }
        }
        
        $processed['rank'] = $rankValue;
    }
    
    // Process special notes (comma-separated values)
    if (!empty($operator['special_notes'])) {
        $processed['special_notes_list'] = processMultiSelectField($db, 'special_notes', $operator['special_notes'], $autoRegistered, 'special_notes');
        $processed['special_note'] = implode(', ', array_column($processed['special_notes_list'], 'name'));
    }
    
    if (!empty($operator['exercises'])) {
        $processed['exercises'] = processMultiSelectField($db, 'exercises', $operator['exercises'], $autoRegistered, 'exercises', true);
    }
    
    return $processed;
}

function processMultiSelectField($db, $table, $value, &$autoRegistered, $trackingKey, $returnString = false) {
    if (empty($value)) return $returnString ? '' : [];
    
    $items = array_map('trim', explode(',', $value));
    $processedItems = [];
    
    foreach ($items as $item) {
        if (empty($item)) continue;
        
        try {
            // Check if item exists
            if ($table === 'special_notes') {
                $stmt = $db->prepare("SELECT id, name, color FROM $table WHERE name = ? LIMIT 1");
            } else {
                $stmt = $db->prepare("SELECT id, name FROM $table WHERE name = ? LIMIT 1");
            }
            $stmt->execute([$item]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                if ($returnString) {
                    $processedItems[] = $item;
                } else {
                    $processedItems[] = $result;
                }
            } else {
                // Create new entry if it doesn't exist
                if ($table === 'special_notes') {
                    // Special notes need a default color
                    $insertStmt = $db->prepare("INSERT INTO $table (name, color) VALUES (?, ?)");
                    $insertStmt->execute([$item, '#ff4757']); // Default red color
                } else {
                    $insertStmt = $db->prepare("INSERT INTO $table (name) VALUES (?)");
                    $insertStmt->execute([$item]);
                }
                
                $newId = $db->lastInsertId();
                
                // Track auto-registered item
                // Ensure the array key exists
                if (!isset($autoRegistered[$trackingKey]) || !is_array($autoRegistered[$trackingKey])) {
                    $autoRegistered[$trackingKey] = [];
                }
                
                if (!in_array($item, $autoRegistered[$trackingKey])) {
                    $autoRegistered[$trackingKey][] = $item;
                }
                
                if ($returnString) {
                    $processedItems[] = $item;
                } else {
                    $processedItems[] = [
                        'id' => $newId,
                        'name' => $item,
                        'color' => $table === 'special_notes' ? '#ff4757' : null
                    ];
                }
            }
        } catch (Exception $e) {
            // If error, still add the item
            if ($returnString) {
                $processedItems[] = $item;
            } else {
                $processedItems[] = ['id' => null, 'name' => $item];
            }
        }
    }
    
    return $returnString ? implode(', ', $processedItems) : $processedItems;
}

function normalizeDate($dateString) {
    if (empty($dateString)) {
        return null;
    }
    
    // Remove extra whitespace
    $dateString = trim($dateString);
    
    // Common date formats to try
    $formats = [
        'Y-m-d',        // 2023-12-25 (ISO format)
        'd/m/Y',        // 25/12/2023 (European format)
        'm/d/Y',        // 12/25/2023 (US format)
        'd-m-Y',        // 25-12-2023
        'm-d-Y',        // 12-25-2023
        'Y/m/d',        // 2023/12/25
        'd.m.Y',        // 25.12.2023
        'm.d.Y',        // 12.25.2023
        'Y.m.d',        // 2023.12.25
        'd M Y',        // 25 Dec 2023
        'M d, Y',       // Dec 25, 2023
        'd F Y',        // 25 December 2023
        'F d, Y',       // December 25, 2023
        'j/n/Y',        // 5/3/2023 (single digits)
        'n/j/Y',        // 3/5/2023 (single digits)
        'j-n-Y',        // 5-3-2023
        'n-j-Y'         // 3-5-2023
    ];
    
    // Try each format
    foreach ($formats as $format) {
        $date = DateTime::createFromFormat($format, $dateString);
        if ($date && $date->format($format) === $dateString) {
            return $date->format('Y-m-d');
        }
    }
    
    // Try to parse with strtotime as fallback
    $timestamp = strtotime($dateString);
    if ($timestamp !== false) {
        $date = new DateTime();
        $date->setTimestamp($timestamp);
        
        // Validate that the parsed date makes sense (not too far in past/future)
        $currentYear = (int)date('Y');
        $dateYear = (int)$date->format('Y');
        
        if ($dateYear >= 1900 && $dateYear <= $currentYear + 10) {
            return $date->format('Y-m-d');
        }
    }
    
    return false;
}
?>
