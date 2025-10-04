<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config/database.php';

// Start session to check user role
session_start();

$database = new Database();
$db = $database->getConnection();
$method = $_SERVER['REQUEST_METHOD'];

// Check authentication for non-GET requests
$isAuthenticated = isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true;
$user_role = $_SESSION['admin_role'] ?? 'admin';

switch($method) {
    case 'GET':
        // Allow public read access for GET requests (frontend needs this)
        if(isset($_GET['id'])) {
            getOperatorById($db, $_GET['id']);
        } else {
            getAllOperators($db);
        }
        break;
    case 'POST':
        // Check authentication for POST requests
        if (!$isAuthenticated) {
            http_response_code(401);
            echo json_encode(['error' => 'Unauthorized access']);
            exit();
        }
        // All authenticated roles can create operators
        createOperator($db);
        break;
    case 'PUT':
        // Check authentication for PUT requests
        if (!$isAuthenticated) {
            http_response_code(401);
            echo json_encode(['error' => 'Unauthorized access']);
            exit();
        }
        // add_op role cannot update operators
        if ($user_role === 'add_op') {
            http_response_code(403);
            echo json_encode(['error' => 'Access denied. You can only add new operators.']);
            exit();
        }
        updateOperator($db);
        break;
    case 'DELETE':
        // Check authentication for DELETE requests
        if (!$isAuthenticated) {
            http_response_code(401);
            echo json_encode(['error' => 'Unauthorized access']);
            exit();
        }
        // add_op role cannot delete operators
        if ($user_role === 'add_op') {
            http_response_code(403);
            echo json_encode(['error' => 'Access denied. You can only add new operators.']);
            exit();
        }
        deleteOperator($db);
        break;
}

function getAllOperators($db) {
    try {
        // Get pagination parameters
        $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
        $limit = isset($_GET['limit']) ? max(1, min(1000, (int)$_GET['limit'])) : 50;
        $offset = ($page - 1) * $limit;
        
        // Get search parameter
        $search = isset($_GET['search']) ? trim($_GET['search']) : '';
        
        // Debug logging
        error_log("Search parameter: " . $search);
        
        // Build WHERE clause for search
        $whereClause = "";
        $searchParams = [];
        
        if (!empty($search)) {
            $whereClause = "WHERE (o.name LIKE ? OR o.personal_no LIKE ? OR o.`rank` LIKE ? OR 
                           f.name LIKE ? OR c.name LIKE ? OR u.name LIKE ?)";
            $searchTerm = '%' . $search . '%';
            $searchParams = [$searchTerm, $searchTerm, $searchTerm, $searchTerm, $searchTerm, $searchTerm];
            error_log("Search WHERE clause: " . $whereClause);
            error_log("Search term: " . $searchTerm);
        }
        
        // Get total count with search
        $countQuery = "SELECT COUNT(*) as total FROM operators o
                      LEFT JOIN formations f ON o.formation_id = f.id
                      LEFT JOIN cores c ON o.cores_id = c.id
                      LEFT JOIN units u ON o.unit_id = u.id
                      LEFT JOIN med_categories mc ON o.med_category_id = mc.id
                      " . $whereClause;
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($searchParams);
        $countResult = $countStmt->fetch(PDO::FETCH_ASSOC);
        $totalRecords = $countResult ? (int)$countResult['total'] : 0;
        
        // Get operators with related table names and search
        $query = "SELECT o.*, 
                         f.name as formation_name,
                         c.name as cores_name,
                         u.name as unit_name,
                         mc.name as med_category_name
                  FROM operators o
                  LEFT JOIN formations f ON o.formation_id = f.id
                  LEFT JOIN cores c ON o.cores_id = c.id
                  LEFT JOIN units u ON o.unit_id = u.id
                  LEFT JOIN med_categories mc ON o.med_category_id = mc.id
                  " . $whereClause . "
                  ORDER BY o.id DESC 
                  LIMIT " . intval($limit) . " OFFSET " . intval($offset);
        $stmt = $db->prepare($query);
        $stmt->execute($searchParams);
        $operators = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Debug logging
        error_log("Query executed. Found " . count($operators) . " operators");
        error_log("Total records from count query: " . $totalRecords);
        
        // Add required fields for frontend compatibility
        foreach ($operators as &$operator) {
            // Handle exercises - get all exercises for this operator
            $exerciseQuery = "SELECT e.id, e.name FROM exercises e 
                             INNER JOIN operator_exercises oe ON e.id = oe.exercise_id 
                             WHERE oe.operator_id = ?";
            $exerciseStmt = $db->prepare($exerciseQuery);
            $exerciseStmt->execute([$operator['id']]);
            $exercises = $exerciseStmt->fetchAll(PDO::FETCH_ASSOC);
            
            if ($exercises) {
                $operator['exercise_ids'] = array_column($exercises, 'id');
                $operator['exercise_names'] = array_column($exercises, 'name');
            } else {
                // Fallback to single exercise_id if no many-to-many records exist
                if (isset($operator['exercise_id']) && $operator['exercise_id']) {
                    $exerciseQuery = "SELECT name FROM exercises WHERE id = ?";
                    $exerciseStmt = $db->prepare($exerciseQuery);
                    $exerciseStmt->execute([$operator['exercise_id']]);
                    $exerciseName = $exerciseStmt->fetchColumn();
                    $operator['exercise_ids'] = [$operator['exercise_id']];
                    $operator['exercise_names'] = $exerciseName ? [$exerciseName] : [];
                } else {
                    $operator['exercise_ids'] = [];
                    $operator['exercise_names'] = [];
                }
            }
            
            // Handle special notes - get all special notes for this operator
            $specialNoteQuery = "SELECT sn.id, sn.name, sn.color FROM special_notes sn 
                               INNER JOIN operator_special_notes osn ON sn.id = osn.special_note_id 
                               WHERE osn.operator_id = ?";
            $specialNoteStmt = $db->prepare($specialNoteQuery);
            $specialNoteStmt->execute([$operator['id']]);
            $specialNotes = $specialNoteStmt->fetchAll(PDO::FETCH_ASSOC);
            
            if ($specialNotes) {
                $operator['special_note_ids'] = array_column($specialNotes, 'id');
                $operator['special_note_names'] = array_column($specialNotes, 'name');
                $operator['special_note_colors'] = array_column($specialNotes, 'color');
            } else {
                // Fallback to single special_note if no many-to-many records exist
                if (isset($operator['special_note']) && $operator['special_note']) {
                    $operator['special_note_ids'] = [];
                    $operator['special_note_names'] = [$operator['special_note']];
                    $operator['special_note_colors'] = [];
                } else {
                    $operator['special_note_ids'] = [];
                    $operator['special_note_names'] = [];
                    $operator['special_note_colors'] = [];
                }
            }
        }
        
        // Calculate pagination
        $totalPages = $totalRecords > 0 ? ceil($totalRecords / $limit) : 1;
        
        echo json_encode([
            'data' => $operators,
            'pagination' => [
                'current_page' => $page,
                'total_pages' => $totalPages,
                'total_records' => $totalRecords,
                'limit' => $limit,
                'has_next' => $page < $totalPages,
                'has_prev' => $page > 1
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'error' => true,
            'message' => $e->getMessage(),
            'line' => $e->getLine(),
            'file' => basename($e->getFile())
        ]);
    }
}

function getOperatorById($db, $id) {
    try {
        $query = "SELECT o.*, 
                         f.name as formation_name,
                         c.name as cores_name,
                         u.name as unit_name,
                         mc.name as med_category_name
                  FROM operators o
                  LEFT JOIN formations f ON o.formation_id = f.id
                  LEFT JOIN cores c ON o.cores_id = c.id
                  LEFT JOIN units u ON o.unit_id = u.id
                  LEFT JOIN med_categories mc ON o.med_category_id = mc.id
                  WHERE o.id = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$id]);
        $operator = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($operator) {
            // Handle exercises - get all exercises for this operator
            $exerciseQuery = "SELECT e.id, e.name FROM exercises e 
                             INNER JOIN operator_exercises oe ON e.id = oe.exercise_id 
                             WHERE oe.operator_id = ?";
            $exerciseStmt = $db->prepare($exerciseQuery);
            $exerciseStmt->execute([$operator['id']]);
            $exercises = $exerciseStmt->fetchAll(PDO::FETCH_ASSOC);
            
            if ($exercises) {
                $operator['exercise_ids'] = array_column($exercises, 'id');
                $operator['exercise_names'] = array_column($exercises, 'name');
            } else {
                // Fallback to single exercise_id if no many-to-many records exist
                if (isset($operator['exercise_id']) && $operator['exercise_id']) {
                    $exerciseQuery = "SELECT name FROM exercises WHERE id = ?";
                    $exerciseStmt = $db->prepare($exerciseQuery);
                    $exerciseStmt->execute([$operator['exercise_id']]);
                    $exerciseName = $exerciseStmt->fetchColumn();
                    $operator['exercise_ids'] = [$operator['exercise_id']];
                    $operator['exercise_names'] = $exerciseName ? [$exerciseName] : [];
                } else {
                    $operator['exercise_ids'] = [];
                    $operator['exercise_names'] = [];
                }
            }
            
            // Handle special notes - get all special notes for this operator
            $specialNoteQuery = "SELECT sn.id, sn.name, sn.color FROM special_notes sn 
                               INNER JOIN operator_special_notes osn ON sn.id = osn.special_note_id 
                               WHERE osn.operator_id = ?";
            $specialNoteStmt = $db->prepare($specialNoteQuery);
            $specialNoteStmt->execute([$operator['id']]);
            $specialNotes = $specialNoteStmt->fetchAll(PDO::FETCH_ASSOC);
            
            if ($specialNotes) {
                $operator['special_note_ids'] = array_column($specialNotes, 'id');
                $operator['special_note_names'] = array_column($specialNotes, 'name');
                $operator['special_note_colors'] = array_column($specialNotes, 'color');
            } else {
                // Fallback to single special_note if no many-to-many records exist
                if (isset($operator['special_note']) && $operator['special_note']) {
                    $operator['special_note_ids'] = [];
                    $operator['special_note_names'] = [$operator['special_note']];
                    $operator['special_note_colors'] = [];
                } else {
                    $operator['special_note_ids'] = [];
                    $operator['special_note_names'] = [];
                    $operator['special_note_colors'] = [];
                }
            }
            
            echo json_encode($operator);
        } else {
            echo json_encode(["message" => "Operator not found"]);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}

function createOperator($db) {
    try {
        $input = file_get_contents("php://input");
        error_log("Raw input data: " . $input);
        
        $data = json_decode($input);
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception("Invalid JSON data: " . json_last_error_msg());
        }
        
        error_log("Parsed data: " . json_encode($data));
        
        // Validate required fields
        if (empty($data->personal_no)) {
            throw new Exception("Personal number is required");
        }
        if (empty($data->rank)) {
            throw new Exception("Rank is required");
        }
        if (empty($data->name)) {
            throw new Exception("Name is required");
        }
        
        $query = "INSERT INTO operators (personal_no, `rank`, name, cores_id, unit_id, formation_id, 
                  med_category_id, mobile_personal, mobile_family, birth_date, admission_date, 
                  joining_date_awgc, civil_edu, course, cadre, course_cadre_name, permanent_address, 
                  present_address, worked_in_awgc, expertise_area, punishment, special_note) 
                  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $db->prepare($query);
        $result = $stmt->execute([
            $data->personal_no ?? null,
            $data->rank ?? null,
            $data->name ?? null,
            !empty($data->cores_id) ? $data->cores_id : null,
            !empty($data->unit_id) ? $data->unit_id : null,
            !empty($data->formation_id) ? $data->formation_id : null,
            !empty($data->med_category_id) ? $data->med_category_id : null,
            $data->mobile_personal ?? null,
            $data->mobile_family ?? null,
            !empty($data->birth_date) ? $data->birth_date : null,
            !empty($data->admission_date) ? $data->admission_date : null,
            !empty($data->joining_date_awgc) ? $data->joining_date_awgc : null,
            $data->civil_edu ?? null,
            $data->course ?? null,
            $data->cadre ?? null,
            $data->course_cadre_name ?? null,
            $data->permanent_address ?? null,
            $data->present_address ?? null,
            $data->worked_in_awgc ?? null,
            $data->expertise_area ?? null,
            $data->punishment ?? null,
            $data->special_note ?? null
        ]);
        
        if ($result) {
            $operatorId = $db->lastInsertId();
            error_log("Operator created with ID: " . $operatorId);
            
            // Handle exercises (many-to-many relationship)
            if (isset($data->exercise_ids) && is_array($data->exercise_ids) && !empty($data->exercise_ids)) {
                error_log("Processing exercise IDs: " . json_encode($data->exercise_ids));
                // Insert into junction table for multiple exercises
                $insertExerciseQuery = "INSERT INTO operator_exercises (operator_id, exercise_id) VALUES (?, ?)";
                $insertStmt = $db->prepare($insertExerciseQuery);
                
                foreach ($data->exercise_ids as $exerciseId) {
                    if (!empty($exerciseId)) {
                        $insertStmt->execute([$operatorId, $exerciseId]);
                    }
                }
                
                // Also store the first exercise in the exercise_id field for backward compatibility
                $updateExerciseQuery = "UPDATE operators SET exercise_id = ? WHERE id = ?";
                $updateStmt = $db->prepare($updateExerciseQuery);
                $updateStmt->execute([$data->exercise_ids[0], $operatorId]);
            }
            
            // Handle special notes (many-to-many relationship)
            if (isset($data->special_note_ids) && is_array($data->special_note_ids) && !empty($data->special_note_ids)) {
                error_log("Processing special note IDs: " . json_encode($data->special_note_ids));
                // Insert into junction table for multiple special notes
                $insertSpecialNoteQuery = "INSERT INTO operator_special_notes (operator_id, special_note_id) VALUES (?, ?)";
                $insertStmt = $db->prepare($insertSpecialNoteQuery);
                
                foreach ($data->special_note_ids as $specialNoteId) {
                    if (!empty($specialNoteId)) {
                        $insertStmt->execute([$operatorId, $specialNoteId]);
                    }
                }
                
                // Also store the first special note in the special_note field for backward compatibility
                $specialNoteQuery = "SELECT name FROM special_notes WHERE id = ?";
                $specialNoteStmt = $db->prepare($specialNoteQuery);
                $specialNoteStmt->execute([$data->special_note_ids[0]]);
                $specialNoteName = $specialNoteStmt->fetchColumn();
                
                if ($specialNoteName) {
                    $updateSpecialNoteQuery = "UPDATE operators SET special_note = ? WHERE id = ?";
                    $updateStmt = $db->prepare($updateSpecialNoteQuery);
                    $updateStmt->execute([$specialNoteName, $operatorId]);
                }
            }
            
            error_log("Operator creation completed successfully");
            echo json_encode(['success' => true, 'message' => 'Operator created', 'id' => $operatorId]);
        } else {
            $errorInfo = $stmt->errorInfo();
            error_log("Failed to create operator - SQL Error: " . json_encode($errorInfo));
            echo json_encode(['error' => 'Failed to create operator', 'sql_error' => $errorInfo]);
        }
        
    } catch (Exception $e) {
        error_log("Create operator exception: " . $e->getMessage() . " on line " . $e->getLine());
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage(), 'line' => $e->getLine(), 'file' => basename($e->getFile())]);
    }
}

function updateOperator($db) {
    try {
        $input = file_get_contents("php://input");
        error_log("Raw update input data: " . $input);
        
        $data = json_decode($input);
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception("Invalid JSON data: " . json_last_error_msg());
        }
        
        if (!$data) {
            throw new Exception("Invalid JSON data received");
        }
        
        if (!isset($data->id) || empty($data->id)) {
            throw new Exception("Operator ID is required for update");
        }
        
        error_log("Update operator data: " . json_encode($data));
        
        $query = "UPDATE operators SET personal_no = ?, `rank` = ?, name = ?, cores_id = ?, 
                  unit_id = ?, formation_id = ?, med_category_id = ?, mobile_personal = ?, 
                  mobile_family = ?, birth_date = ?, admission_date = ?, joining_date_awgc = ?, 
                  civil_edu = ?, course = ?, cadre = ?, course_cadre_name = ?, permanent_address = ?, 
                  present_address = ?, worked_in_awgc = ?, expertise_area = ?, punishment = ?, 
                  special_note = ? WHERE id = ?";
        
        $stmt = $db->prepare($query);
        $result = $stmt->execute([
            $data->personal_no ?? null,
            $data->rank ?? null,
            $data->name ?? null,
            !empty($data->cores_id) ? $data->cores_id : null,
            !empty($data->unit_id) ? $data->unit_id : null,
            !empty($data->formation_id) ? $data->formation_id : null,
            !empty($data->med_category_id) ? $data->med_category_id : null,
            $data->mobile_personal ?? null,
            $data->mobile_family ?? null,
            !empty($data->birth_date) ? $data->birth_date : null,
            !empty($data->admission_date) ? $data->admission_date : null,
            !empty($data->joining_date_awgc) ? $data->joining_date_awgc : null,
            $data->civil_edu ?? null,
            $data->course ?? null,
            $data->cadre ?? null,
            $data->course_cadre_name ?? null,
            $data->permanent_address ?? null,
            $data->present_address ?? null,
            $data->worked_in_awgc ?? null,
            $data->expertise_area ?? null,
            $data->punishment ?? null,
            $data->special_note ?? null,
            $data->id
        ]);
        
        if ($result) {
            // Handle exercises (many-to-many relationship)
            // First, delete existing exercise relationships
            $deleteExercisesQuery = "DELETE FROM operator_exercises WHERE operator_id = ?";
            $deleteStmt = $db->prepare($deleteExercisesQuery);
            $deleteStmt->execute([$data->id]);
            
            if (isset($data->exercise_ids) && is_array($data->exercise_ids) && !empty($data->exercise_ids)) {
                // Insert new exercise relationships
                $insertExerciseQuery = "INSERT INTO operator_exercises (operator_id, exercise_id) VALUES (?, ?)";
                $insertStmt = $db->prepare($insertExerciseQuery);
                
                foreach ($data->exercise_ids as $exerciseId) {
                    if (!empty($exerciseId)) {
                        $insertStmt->execute([$data->id, $exerciseId]);
                    }
                }
                
                // Also store the first exercise in the exercise_id field for backward compatibility
                $updateExerciseQuery = "UPDATE operators SET exercise_id = ? WHERE id = ?";
                $updateStmt = $db->prepare($updateExerciseQuery);
                $updateStmt->execute([$data->exercise_ids[0], $data->id]);
                error_log("Updated exercises: " . implode(', ', $data->exercise_ids));
            } else {
                // Clear exercise if no exercises selected
                $updateExerciseQuery = "UPDATE operators SET exercise_id = NULL WHERE id = ?";
                $updateStmt = $db->prepare($updateExerciseQuery);
                $updateStmt->execute([$data->id]);
                error_log("Cleared all exercises for operator: " . $data->id);
            }
            
            // Handle special notes (many-to-many relationship)
            // First, delete existing special note relationships
            $deleteSpecialNotesQuery = "DELETE FROM operator_special_notes WHERE operator_id = ?";
            $deleteStmt = $db->prepare($deleteSpecialNotesQuery);
            $deleteStmt->execute([$data->id]);
            
            if (isset($data->special_note_ids) && is_array($data->special_note_ids) && !empty($data->special_note_ids)) {
                // Insert new special note relationships
                $insertSpecialNoteQuery = "INSERT INTO operator_special_notes (operator_id, special_note_id) VALUES (?, ?)";
                $insertStmt = $db->prepare($insertSpecialNoteQuery);
                
                foreach ($data->special_note_ids as $specialNoteId) {
                    if (!empty($specialNoteId)) {
                        $insertStmt->execute([$data->id, $specialNoteId]);
                    }
                }
                
                // Also store the first special note in the special_note field for backward compatibility
                $specialNoteQuery = "SELECT name FROM special_notes WHERE id = ?";
                $specialNoteStmt = $db->prepare($specialNoteQuery);
                $specialNoteStmt->execute([$data->special_note_ids[0]]);
                $specialNoteName = $specialNoteStmt->fetchColumn();
                
                if ($specialNoteName) {
                    $updateSpecialNoteQuery = "UPDATE operators SET special_note = ? WHERE id = ?";
                    $updateStmt = $db->prepare($updateSpecialNoteQuery);
                    $updateStmt->execute([$specialNoteName, $data->id]);
                }
                
                error_log("Updated special notes: " . implode(', ', $data->special_note_ids));
            } else {
                // Clear special note if no special notes selected
                $updateSpecialNoteQuery = "UPDATE operators SET special_note = NULL WHERE id = ?";
                $updateStmt = $db->prepare($updateSpecialNoteQuery);
                $updateStmt->execute([$data->id]);
                error_log("Cleared all special notes for operator: " . $data->id);
            }
            
            error_log("Operator updated successfully: " . $data->id);
            echo json_encode(['success' => true, 'message' => 'Updated']);
        } else {
            $errorInfo = $stmt->errorInfo();
            error_log("Update failed - SQL Error: " . json_encode($errorInfo));
            echo json_encode(['error' => 'Failed to update operator', 'sql_error' => $errorInfo]);
        }
        
    } catch (Exception $e) {
        error_log("Update operator exception: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage(), 'line' => $e->getLine()]);
    }
}

function deleteOperator($db) {
    try {
        $data = json_decode(file_get_contents("php://input"));
        
        $query = "DELETE FROM operators WHERE id = ?";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([$data->id]);
        
        if ($result) {
            echo json_encode(['message' => 'Deleted']);
        } else {
            echo json_encode(['error' => 'Failed to delete operator']);
        }
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}
?>
