<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Cache-Control: no-cache, no-store, must-revalidate");
header("Pragma: no-cache");
header("Expires: 0");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'POST':
        createOption($db);
        break;
    case 'PUT':
        updateOption($db);
        break;
    case 'DELETE':
        deleteOption($db);
        break;
    default:
        echo json_encode(["message" => "Method not allowed", "success" => false]);
        break;
}

function createOption($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if (empty($data->type) || empty($data->name)) {
        echo json_encode(["message" => "Type and name are required", "success" => false]);
        return;
    }
    
    $validTypes = ['formations', 'med_categories', 'cores', 'exercises', 'units', 'ranks', 'special_notes'];
    if (!in_array($data->type, $validTypes)) {
        echo json_encode(["message" => "Invalid option type", "success" => false]);
        return;
    }
    
    try {
        $query = "INSERT INTO {$data->type} (name) VALUES (?)";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([$data->name]);
        
        if ($result) {
            echo json_encode([
                "message" => "Option created successfully",
                "id" => $db->lastInsertId(),
                "success" => true
            ]);
        } else {
            echo json_encode([
                "message" => "Failed to create option",
                "success" => false
            ]);
        }
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate entry') !== false) {
            echo json_encode([
                "message" => "This option already exists",
                "success" => false
            ]);
        } else {
            echo json_encode([
                "message" => "Database error: " . $e->getMessage(),
                "success" => false
            ]);
        }
    }
}

function updateOption($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if (empty($data->type) || empty($data->name) || empty($data->id)) {
        echo json_encode(["message" => "Type, name, and ID are required", "success" => false]);
        return;
    }
    
    $validTypes = ['formations', 'med_categories', 'cores', 'exercises', 'units', 'ranks', 'special_notes'];
    if (!in_array($data->type, $validTypes)) {
        echo json_encode(["message" => "Invalid option type", "success" => false]);
        return;
    }
    
    try {
        $query = "UPDATE {$data->type} SET name = ? WHERE id = ?";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([$data->name, $data->id]);
        
        if ($result) {
            echo json_encode([
                "message" => "Option updated successfully",
                "success" => true
            ]);
        } else {
            echo json_encode([
                "message" => "Failed to update option",
                "success" => false
            ]);
        }
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate entry') !== false) {
            echo json_encode([
                "message" => "This option name already exists",
                "success" => false
            ]);
        } else {
            echo json_encode([
                "message" => "Database error: " . $e->getMessage(),
                "success" => false
            ]);
        }
    }
}

function deleteOption($db) {
    $data = json_decode(file_get_contents("php://input"));
    
    if (empty($data->type) || empty($data->id)) {
        echo json_encode(["message" => "Type and ID are required", "success" => false]);
        return;
    }
    
    $validTypes = ['formations', 'med_categories', 'cores', 'exercises', 'units', 'ranks', 'special_notes'];
    if (!in_array($data->type, $validTypes)) {
        echo json_encode(["message" => "Invalid option type", "success" => false]);
        return;
    }
    
    try {
        // Check if option is being used by any operators
        $checkQuery = getCheckQuery($data->type);
        if ($checkQuery) {
            $checkStmt = $db->prepare($checkQuery);
            $checkStmt->execute([$data->id]);
            $count = $checkStmt->fetchColumn();
            
            if ($count > 0) {
                echo json_encode([
                    "message" => "Cannot delete this option because it is being used by {$count} operator(s)",
                    "success" => false
                ]);
                return;
            }
        }
        
        // Special handling for exercises and special_notes (many-to-many relationships)
        if ($data->type === 'exercises') {
            // Delete from junction table first
            $deleteJunctionStmt = $db->prepare("DELETE FROM operator_exercises WHERE exercise_id = ?");
            $deleteJunctionStmt->execute([$data->id]);
        } elseif ($data->type === 'special_notes') {
            // Delete from junction table first
            $deleteJunctionStmt = $db->prepare("DELETE FROM operator_special_notes WHERE special_note_id = ?");
            $deleteJunctionStmt->execute([$data->id]);
        }
        
        $query = "DELETE FROM {$data->type} WHERE id = ?";
        $stmt = $db->prepare($query);
        $result = $stmt->execute([$data->id]);
        
        if ($result) {
            echo json_encode([
                "message" => "Option deleted successfully",
                "success" => true
            ]);
        } else {
            echo json_encode([
                "message" => "Failed to delete option",
                "success" => false
            ]);
        }
    } catch (PDOException $e) {
        echo json_encode([
            "message" => "Database error: " . $e->getMessage(),
            "success" => false
        ]);
    }
}

function getCheckQuery($type) {
    $queries = [
        'formations' => "SELECT COUNT(*) FROM operators WHERE formation_id = ?",
        'med_categories' => "SELECT COUNT(*) FROM operators WHERE med_category_id = ?",
        'cores' => "SELECT COUNT(*) FROM operators WHERE cores_id = ?",
        'exercises' => "SELECT COUNT(*) FROM operator_exercises WHERE exercise_id = ?",
        'units' => "SELECT COUNT(*) FROM operators WHERE unit_id = ?",
        'ranks' => "SELECT COUNT(*) FROM operators WHERE rank = (SELECT name FROM ranks WHERE id = ?)",
        'special_notes' => "SELECT COUNT(*) FROM operator_special_notes WHERE special_note_id = ?"
    ];
    
    return $queries[$type] ?? null;
}
?>
