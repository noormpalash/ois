<?php
session_start();

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Check if user is logged in and has appropriate role
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    http_response_code(401);
    echo json_encode(['error' => true, 'message' => 'Authentication required']);
    exit;
}

// Check if user has admin or super_admin role (export restricted to admins only)
$admin_role = $_SESSION['admin_role'] ?? '';
if (!in_array($admin_role, ['admin', 'super_admin'])) {
    http_response_code(403);
    echo json_encode(['error' => true, 'message' => 'Access denied. Export functionality is restricted to administrators only.']);
    exit;
}

require_once '../config/database.php';
require_once '../lib/XLSXGenerator.php';

// Create database connection
$database = new Database();
$db = $database->getConnection();

if (!$db) {
    http_response_code(500);
    echo json_encode(['error' => true, 'message' => 'Database connection failed']);
    exit;
}

// Get request parameters
$action = $_GET['action'] ?? '';
$format = $_GET['format'] ?? 'csv'; // csv, excel, pdf
$filters = [];

// Parse filters from GET parameters
$filters['search'] = $_GET['search'] ?? '';
$filters['formation'] = $_GET['formation'] ?? '';
$filters['cores'] = $_GET['cores'] ?? '';
$filters['exercise'] = $_GET['exercise'] ?? '';
$filters['rank'] = $_GET['rank'] ?? '';
$filters['special_note'] = $_GET['special_note'] ?? '';
$filters['unit'] = $_GET['unit'] ?? '';
$filters['date_from'] = $_GET['date_from'] ?? '';
$filters['date_to'] = $_GET['date_to'] ?? '';
$filters['report_type'] = $_GET['report_type'] ?? '';
$filters['selected_ids'] = $_GET['selected_ids'] ?? '';
$filters['selected_fields'] = $_GET['selected_fields'] ?? '';

try {
    switch ($action) {
        case 'operators':
            exportOperators($db, $filters, $format);
            break;
        case 'analytics':
            exportAnalytics($db, $filters, $format);
            break;
        case 'filtered_results':
            exportFilteredResults($db, $filters, $format);
            break;
        default:
            http_response_code(400);
            echo json_encode(['error' => true, 'message' => 'Invalid action']);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => true, 'message' => $e->getMessage()]);
}

function exportOperators($db, $filters, $format) {
    // Define available fields and their corresponding SQL columns (ordered for export)
    $availableFields = [
        'personal_no' => 'o.personal_no',
        'rank' => 'o.rank',
        'name' => 'o.name',
        'birth_date' => 'o.birth_date',
        'permanent_address' => 'o.permanent_address',
        'present_address' => 'o.present_address',
        'course_cadre_name' => 'o.course_cadre_name',
        'civil_edu' => 'o.civil_edu',
        'course' => 'o.course',
        'cadre' => 'o.cadre',
        'admission_date' => 'o.admission_date',
        'joining_date_awgc' => 'o.joining_date_awgc',
        'worked_in_awgc' => 'o.worked_in_awgc',
        'expertise_area' => 'o.expertise_area',
        'punishment' => 'o.punishment',
        'formation_name' => 'f.name as formation_name',
        'cores_name' => 'c.name as cores_name',
        'unit_name' => 'u.name as unit_name',
        'med_category_name' => 'mc.name as med_category_name',
        'created_at' => 'o.created_at',
        'updated_at' => 'o.updated_at',
        // Mobile fields at the end to ensure they appear last in exports
        'mobile_family' => 'o.mobile_family',
        'mobile_personal' => 'o.mobile_personal'
    ];
    
    // Get selected fields or use all fields if none specified
    $selectedFields = [];
    if (!empty($filters['selected_fields'])) {
        $requestedFields = explode(',', $filters['selected_fields']);
        
        // Order fields properly with mobile fields at the end
        $orderedFields = [];
        $mobileFields = [];
        
        foreach ($requestedFields as $field) {
            $field = trim($field);
            if (isset($availableFields[$field])) {
                // Separate mobile fields to put them at the end
                if (strpos($field, 'mobile_') === 0) {
                    $mobileFields[$field] = $availableFields[$field];
                } else {
                    $orderedFields[$field] = $availableFields[$field];
                }
            }
        }
        
        // Combine ordered fields with mobile fields at the end
        $selectedFields = array_merge($orderedFields, $mobileFields);
    }
    
    // If no valid fields selected, use default essential fields
    if (empty($selectedFields)) {
        $defaultFields = ['personal_no', 'rank', 'name', 'cores_name', 'mobile_personal'];
        foreach ($defaultFields as $field) {
            $selectedFields[$field] = $availableFields[$field];
        }
    }
    
    // Always include ID for internal processing
    $selectClause = 'o.id, ' . implode(', ', $selectedFields);
    
    // Build query with selected fields
    $query = "SELECT $selectClause
    FROM operators o
    LEFT JOIN formations f ON o.formation_id = f.id
    LEFT JOIN cores c ON o.cores_id = c.id
    LEFT JOIN units u ON o.unit_id = u.id
    LEFT JOIN med_categories mc ON o.med_category_id = mc.id
    WHERE 1=1";
    
    $params = [];
    
    // Apply filters
    // Handle selected IDs first (highest priority)
    if (!empty($filters['selected_ids'])) {
        $selectedIds = explode(',', $filters['selected_ids']);
        $selectedIds = array_map('intval', $selectedIds); // Sanitize IDs
        $placeholders = str_repeat('?,', count($selectedIds) - 1) . '?';
        $query .= " AND o.id IN ($placeholders)";
        $params = array_merge($params, $selectedIds);
    } else {
        // Apply other filters only if no specific IDs are selected
        if (!empty($filters['search'])) {
            $query .= " AND (o.name LIKE ? OR o.personal_no LIKE ? OR o.rank LIKE ?)";
            $searchTerm = '%' . $filters['search'] . '%';
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }
    }
    
    if (!empty($filters['formation'])) {
        $query .= " AND o.formation_id = ?";
        $params[] = $filters['formation'];
    }
    
    if (!empty($filters['cores'])) {
        $query .= " AND o.cores_id = ?";
        $params[] = $filters['cores'];
    }
    
    if (!empty($filters['rank'])) {
        $query .= " AND o.rank = ?";
        $params[] = $filters['rank'];
    }
    
    if (!empty($filters['unit'])) {
        $query .= " AND o.unit_id = ?";
        $params[] = $filters['unit'];
    }
    
    if (!empty($filters['date_from'])) {
        $query .= " AND o.created_at >= ?";
        $params[] = $filters['date_from'];
    }
    
    if (!empty($filters['date_to'])) {
        $query .= " AND o.created_at <= ?";
        $params[] = $filters['date_to'];
    }
    
    // Handle special note filter
    if (!empty($filters['special_note'])) {
        $query .= " AND EXISTS (
            SELECT 1 FROM operator_special_notes osn 
            WHERE osn.operator_id = o.id AND osn.special_note_id = ?
        )";
        $params[] = $filters['special_note'];
    }
    
    // Handle exercise filter  
    if (!empty($filters['exercise'])) {
        $query .= " AND EXISTS (
            SELECT 1 FROM operator_exercises oe 
            WHERE oe.operator_id = o.id AND oe.exercise_id = ?
        )";
        $params[] = $filters['exercise'];
    }
    
    $query .= " ORDER BY o.name ASC";
    
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    $operators = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get exercises and special notes only if they were requested
    $needsExercises = isset($selectedFields['exercises']);
    $needsSpecialNotes = isset($selectedFields['special_notes']);
    
    if ($needsExercises || $needsSpecialNotes) {
        foreach ($operators as &$operator) {
            if ($needsExercises) {
                $exerciseQuery = "SELECT e.name 
                                 FROM exercises e 
                                 INNER JOIN operator_exercises oe ON e.id = oe.exercise_id 
                                 WHERE oe.operator_id = ?";
                $exerciseStmt = $db->prepare($exerciseQuery);
                $exerciseStmt->execute([$operator['id']]);
                $exercises = $exerciseStmt->fetchAll(PDO::FETCH_COLUMN);
                $operator['exercises'] = implode(', ', $exercises);
            }
            
            if ($needsSpecialNotes) {
                $noteQuery = "SELECT sn.name 
                             FROM special_notes sn 
                             INNER JOIN operator_special_notes osn ON sn.id = osn.special_note_id 
                             WHERE osn.operator_id = ?";
                $noteStmt = $db->prepare($noteQuery);
                $noteStmt->execute([$operator['id']]);
                $notes = $noteStmt->fetchAll(PDO::FETCH_COLUMN);
                $operator['special_notes'] = implode(', ', $notes);
            }
        }
    }
    
    switch ($format) {
        case 'csv':
            outputCSV($operators, 'operators_export');
            break;
        case 'excel':
            outputExcel($operators, 'operators_export');
            break;
        case 'pdf':
            outputPDF($operators, 'Operators Export');
            break;
        default:
            echo json_encode(['error' => true, 'message' => 'Invalid format']);
    }
}

function exportAnalytics($db, $filters, $format) {
    $reportType = $filters['report_type'] ?? 'overview';
    
    switch ($reportType) {
        case 'rank-distribution':
            $data = getRankDistribution($db, $filters);
            $filename = 'rank_distribution_report';
            $title = 'Rank Distribution Report';
            break;
        case 'formation-analysis':
            $data = getFormationAnalysis($db, $filters);
            $filename = 'formation_analysis_report';
            $title = 'Formation Analysis Report';
            break;
        case 'unit-breakdown':
            $data = getUnitBreakdown($db, $filters);
            $filename = 'unit_breakdown_report';
            $title = 'Unit Breakdown Report';
            break;
        case 'exercise-participation':
            $data = getExerciseParticipation($db, $filters);
            $filename = 'exercise_participation_report';
            $title = 'Exercise Participation Report';
            break;
        default:
            $data = getOverviewReport($db, $filters);
            $filename = 'overview_report';
            $title = 'Overview Report';
            break;
    }
    
    switch ($format) {
        case 'csv':
            outputCSV($data, $filename);
            break;
        case 'excel':
            outputExcel($data, $filename);
            break;
        case 'pdf':
            outputPDF($data, $title);
            break;
        default:
            echo json_encode(['error' => true, 'message' => 'Invalid format']);
    }
}

function exportFilteredResults($db, $filters, $format) {
    // This is for exporting current filtered results from frontend
    exportOperators($db, $filters, $format);
}

function getRankDistribution($db, $filters) {
    $query = "SELECT 
        o.rank,
        COUNT(*) as count,
        ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM operators)), 2) as percentage
    FROM operators o
    WHERE 1=1";
    
    $params = [];
    
    // Apply date filters if provided
    if (!empty($filters['date_from'])) {
        $query .= " AND o.created_at >= ?";
        $params[] = $filters['date_from'];
    }
    
    if (!empty($filters['date_to'])) {
        $query .= " AND o.created_at <= ?";
        $params[] = $filters['date_to'];
    }
    
    $query .= " GROUP BY o.rank ORDER BY count DESC";
    
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function getFormationAnalysis($db, $filters) {
    $query = "SELECT 
        f.name as formation_name,
        COUNT(o.id) as operator_count,
        ROUND((COUNT(o.id) * 100.0 / (SELECT COUNT(*) FROM operators)), 2) as percentage
    FROM formations f
    LEFT JOIN operators o ON f.id = o.formation_id
    WHERE 1=1";
    
    $params = [];
    
    if (!empty($filters['date_from'])) {
        $query .= " AND o.created_at >= ?";
        $params[] = $filters['date_from'];
    }
    
    if (!empty($filters['date_to'])) {
        $query .= " AND o.created_at <= ?";
        $params[] = $filters['date_to'];
    }
    
    $query .= " GROUP BY f.id, f.name ORDER BY operator_count DESC";
    
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function getUnitBreakdown($db, $filters) {
    $query = "SELECT 
        u.name as unit_name,
        c.name as corps_name,
        COUNT(o.id) as operator_count
    FROM units u
    LEFT JOIN operators o ON u.id = o.unit_id
    LEFT JOIN cores c ON u.cores_id = c.id
    WHERE 1=1";
    
    $params = [];
    
    if (!empty($filters['date_from'])) {
        $query .= " AND o.created_at >= ?";
        $params[] = $filters['date_from'];
    }
    
    if (!empty($filters['date_to'])) {
        $query .= " AND o.created_at <= ?";
        $params[] = $filters['date_to'];
    }
    
    $query .= " GROUP BY u.id, u.name, c.name ORDER BY operator_count DESC";
    
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function getExerciseParticipation($db, $filters) {
    $query = "SELECT 
        e.name as exercise_name,
        COUNT(oe.operator_id) as participant_count,
        ROUND((COUNT(oe.operator_id) * 100.0 / (SELECT COUNT(*) FROM operators)), 2) as participation_rate
    FROM exercises e
    LEFT JOIN operator_exercises oe ON e.id = oe.exercise_id
    LEFT JOIN operators o ON oe.operator_id = o.id
    WHERE 1=1";
    
    $params = [];
    
    if (!empty($filters['date_from'])) {
        $query .= " AND o.created_at >= ?";
        $params[] = $filters['date_from'];
    }
    
    if (!empty($filters['date_to'])) {
        $query .= " AND o.created_at <= ?";
        $params[] = $filters['date_to'];
    }
    
    $query .= " GROUP BY e.id, e.name ORDER BY participant_count DESC";
    
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function getOverviewReport($db, $filters) {
    $data = [];
    
    // Total operators
    $query = "SELECT COUNT(*) as total FROM operators";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $data[] = ['Metric' => 'Total Operators', 'Value' => $stmt->fetchColumn()];
    
    // By rank
    $query = "SELECT rank, COUNT(*) as count FROM operators GROUP BY rank ORDER BY count DESC LIMIT 5";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $ranks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($ranks as $rank) {
        $data[] = ['Metric' => 'Rank: ' . $rank['rank'], 'Value' => $rank['count']];
    }
    
    // By corps
    $query = "SELECT c.name, COUNT(o.id) as count FROM cores c LEFT JOIN operators o ON c.id = o.cores_id GROUP BY c.id, c.name ORDER BY count DESC LIMIT 5";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $corps = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($corps as $corp) {
        $data[] = ['Metric' => 'Corps: ' . $corp['name'], 'Value' => $corp['count']];
    }
    
    return $data;
}

function outputCSV($data, $filename) {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="' . $filename . '_' . date('Y-m-d_H-i-s') . '.csv"');
    
    if (empty($data)) {
        echo "No data available\n";
        return;
    }
    
    $output = fopen('php://output', 'w');
    
    // Write headers
    fputcsv($output, array_keys($data[0]));
    
    // Write data
    foreach ($data as $row) {
        fputcsv($output, $row);
    }
    
    fclose($output);
}

function outputExcel($data, $filename) {
    if (empty($data)) {
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment; filename="' . $filename . '_' . date('Y-m-d_H-i-s') . '.xls"');
        echo "No data available for export";
        return;
    }
    
    // Set proper headers for Excel XML format
    header('Content-Type: application/vnd.ms-excel');
    header('Content-Disposition: attachment; filename="' . $filename . '_' . date('Y-m-d_H-i-s') . '.xls"');
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: 0');
    
    // Create proper Excel XML format
    echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    echo '<?mso-application progid="Excel.Sheet"?>' . "\n";
    echo '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' . "\n";
    echo ' xmlns:o="urn:schemas-microsoft-com:office:office"' . "\n";
    echo ' xmlns:x="urn:schemas-microsoft-com:office:excel"' . "\n";
    echo ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' . "\n";
    echo ' xmlns:html="http://www.w3.org/TR/REC-html40">' . "\n";
    
    echo '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' . "\n";
    echo '<Title>' . htmlspecialchars($filename) . '</Title>' . "\n";
    echo '<Author>Operator Information System</Author>' . "\n";
    echo '<Created>' . date('Y-m-d\TH:i:s\Z') . '</Created>' . "\n";
    echo '</DocumentProperties>' . "\n";
    
    echo '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">' . "\n";
    echo '<WindowHeight>12000</WindowHeight>' . "\n";
    echo '<WindowWidth>15000</WindowWidth>' . "\n";
    echo '<WindowTopX>480</WindowTopX>' . "\n";
    echo '<WindowTopY>60</WindowTopY>' . "\n";
    echo '<ProtectStructure>False</ProtectStructure>' . "\n";
    echo '<ProtectWindows>False</ProtectWindows>' . "\n";
    echo '</ExcelWorkbook>' . "\n";
    
    echo '<Styles>' . "\n";
    echo '<Style ss:ID="Default" ss:Name="Normal">' . "\n";
    echo '<Alignment ss:Vertical="Bottom"/>' . "\n";
    echo '<Borders/>' . "\n";
    echo '<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="10"/>' . "\n";
    echo '<Interior/>' . "\n";
    echo '<NumberFormat/>' . "\n";
    echo '<Protection/>' . "\n";
    echo '</Style>' . "\n";
    echo '<Style ss:ID="Header">' . "\n";
    echo '<Alignment ss:Vertical="Bottom"/>' . "\n";
    echo '<Borders>' . "\n";
    echo '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '</Borders>' . "\n";
    echo '<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="10" ss:Bold="1"/>' . "\n";
    echo '<Interior ss:Color="#E0E0E0" ss:Pattern="Solid"/>' . "\n";
    echo '</Style>' . "\n";
    echo '<Style ss:ID="Data">' . "\n";
    echo '<Alignment ss:Vertical="Bottom"/>' . "\n";
    echo '<Borders>' . "\n";
    echo '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '</Borders>' . "\n";
    echo '<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="10"/>' . "\n";
    echo '</Style>' . "\n";
    echo '</Styles>' . "\n";
    
    echo '<Worksheet ss:Name="' . htmlspecialchars($filename) . '">' . "\n";
    echo '<Table>' . "\n";
    
    // Write header row
    echo '<Row>' . "\n";
    foreach (array_keys($data[0]) as $header) {
        $displayHeader = ucwords(str_replace('_', ' ', $header));
        echo '<Cell ss:StyleID="Header"><Data ss:Type="String">' . htmlspecialchars($displayHeader) . '</Data></Cell>' . "\n";
    }
    echo '</Row>' . "\n";
    
    // Write data rows
    foreach ($data as $row) {
        echo '<Row>' . "\n";
        foreach ($row as $cell) {
            $cellValue = htmlspecialchars($cell ?? '');
            $dataType = is_numeric($cell) ? 'Number' : 'String';
            echo '<Cell ss:StyleID="Data"><Data ss:Type="' . $dataType . '">' . $cellValue . '</Data></Cell>' . "\n";
        }
        echo '</Row>' . "\n";
    }
    
    echo '</Table>' . "\n";
    echo '</Worksheet>' . "\n";
    echo '</Workbook>' . "\n";
}

function outputPDF($data, $title) {
    // Output as HTML that can be printed to PDF by the browser
    header('Content-Type: text/html; charset=UTF-8');
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Sat, 26 Jul 1997 05:00:00 GMT');
    
    echo '<!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>' . htmlspecialchars($title) . '</title>
        <style>
            * { box-sizing: border-box; }
            body { 
                font-family: Arial, sans-serif; 
                margin: 0; 
                padding: 20px;
                font-size: 11px;
                line-height: 1.3;
                color: #333;
            }
            .pdf-header {
                text-align: center;
                border-bottom: 2px solid #007bff;
                padding-bottom: 15px;
                margin-bottom: 20px;
            }
            .pdf-header h1 {
                color: #007bff;
                margin: 0;
                font-size: 24px;
            }
            .export-info { 
                font-size: 11px; 
                color: #666; 
                margin-bottom: 20px;
                text-align: center;
            }
            table { 
                width: 100%; 
                border-collapse: collapse; 
                margin-top: 10px;
                font-size: 9px;
            }
            th, td { 
                border: 1px solid #333; 
                padding: 4px 3px; 
                text-align: left;
                vertical-align: top;
                word-wrap: break-word;
            }
            th { 
                background-color: #f0f0f0; 
                font-weight: bold;
                font-size: 8px;
                text-transform: uppercase;
                padding: 5px 3px;
            }
            tr:nth-child(even) { 
                background-color: #f9f9f9; 
            }
            .no-data {
                text-align: center;
                padding: 40px;
                color: #666;
                font-style: italic;
            }
            @media print {
                body { margin: 0; padding: 10px; }
                .no-print { display: none !important; }
                table { page-break-inside: auto; }
                tr { page-break-inside: avoid; }
                th { page-break-after: avoid; }
            }
            @page {
                margin: 0.75in;
                size: A4 portrait;
            }
        </style>
    </head>
    <body>
        <div class="pdf-header">
            <h1>' . htmlspecialchars($title) . '</h1>
        </div>
        <div class="export-info">
            Generated on: ' . date('Y-m-d H:i:s') . ' | 
            Total Records: ' . count($data) . '
        </div>';
    
    if (!empty($data)) {
        echo '<table>
                <thead>
                    <tr>';
        
        foreach (array_keys($data[0]) as $header) {
            $displayHeader = ucwords(str_replace('_', ' ', $header));
            echo '<th>' . htmlspecialchars($displayHeader) . '</th>';
        }
        
        echo '    </tr>
                </thead>
                <tbody>';
        
        foreach ($data as $row) {
            echo '<tr>';
            foreach ($row as $cell) {
                $cellValue = $cell ?? '';
                // Truncate very long text for A4 portrait PDF display
                if (strlen($cellValue) > 30) {
                    $cellValue = substr($cellValue, 0, 27) . '...';
                }
                echo '<td>' . htmlspecialchars($cellValue) . '</td>';
            }
            echo '</tr>';
        }
        
        echo '</tbody>
            </table>';
    } else {
        echo '<div class="no-data">No data available for export.</div>';
    }
    
    echo '
        <div class="no-print" style="position: fixed; top: 10px; right: 10px; background: #007bff; color: white; padding: 10px; border-radius: 5px; z-index: 1000;">
            <button onclick="window.print()" style="background: white; color: #007bff; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer;">
                Print to PDF
            </button>
            <button onclick="window.close()" style="background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; margin-left: 5px;">
                Close
            </button>
        </div>
        <script>
            // Auto-focus for immediate printing
            window.onload = function() {
                // Give user option to print manually
                console.log("PDF view ready. Use Print to PDF button or Ctrl+P");
            };
        </script>
    </body>
    </html>';
}

?>
