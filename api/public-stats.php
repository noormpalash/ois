<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Database connection failed");
    }
    
    $action = $_GET['action'] ?? 'stats';
    
    switch ($action) {
        case 'stats':
            getPublicStats($db);
            break;
        case 'corps':
            getCorpsDistribution($db);
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

function getPublicStats($db) {
    try {
        // Get total operators
        $totalOperators = $db->query("SELECT COUNT(*) FROM operators")->fetchColumn();
        
        // Get corps distribution
        $corpsQuery = "SELECT c.name, COUNT(o.id) as count 
                      FROM cores c 
                      LEFT JOIN operators o ON c.id = o.cores_id 
                      GROUP BY c.id, c.name 
                      ORDER BY count DESC, c.name";
        
        $corpsStmt = $db->prepare($corpsQuery);
        $corpsStmt->execute();
        $corpsData = $corpsStmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Convert count to integer and calculate percentages
        $totalWithCorps = array_sum(array_column($corpsData, 'count'));
        foreach ($corpsData as &$corps) {
            $corps['count'] = (int)$corps['count'];
            $corps['percentage'] = $totalWithCorps > 0 ? round(($corps['count'] / $totalWithCorps) * 100, 1) : 0;
        }
        
        echo json_encode([
            'success' => true,
            'data' => [
                'total_operators' => (int)$totalOperators,
                'corps_distribution' => $corpsData,
                'total_with_corps' => $totalWithCorps
            ]
        ]);
        
    } catch (Exception $e) {
        throw new Exception("Error getting public stats: " . $e->getMessage());
    }
}

function getCorpsDistribution($db) {
    try {
        $query = "SELECT c.name, COUNT(o.id) as count 
                  FROM cores c 
                  LEFT JOIN operators o ON c.id = o.cores_id 
                  GROUP BY c.id, c.name 
                  ORDER BY count DESC, c.name";
        
        $stmt = $db->prepare($query);
        $stmt->execute();
        $corpsData = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Convert count to integer and calculate percentages
        $totalWithCorps = array_sum(array_column($corpsData, 'count'));
        foreach ($corpsData as &$corps) {
            $corps['count'] = (int)$corps['count'];
            $corps['percentage'] = $totalWithCorps > 0 ? round(($corps['count'] / $totalWithCorps) * 100, 1) : 0;
        }
        
        echo json_encode([
            'success' => true,
            'data' => $corpsData,
            'total' => $totalWithCorps
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error retrieving corps distribution: ' . $e->getMessage()
        ]);
    }
}
?>
