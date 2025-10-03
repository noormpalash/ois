<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

// Use the same database config as other API files
include_once '../config/database.php';

try {
    $database = new Database();
    $pdo = $database->getConnection();
    
    if (!$pdo) {
        throw new Exception("Database connection failed");
    }
    
    // Get random operator with rank, name, and unit information (no formation)
    $sql = "SELECT 
                o.id,
                o.name,
                o.rank,
                u.name as unit_name
            FROM operators o
            LEFT JOIN units u ON o.unit_id = u.id
            WHERE o.name IS NOT NULL 
            AND o.name != ''
            AND o.rank IS NOT NULL 
            AND o.rank != ''
            ORDER BY RAND() 
            LIMIT 1";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $operator = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Debug: Log the query result
    error_log("Random operator query result: " . json_encode($operator));
    
    if ($operator) {
        // Format the unit display (only unit, no formation)
        $unit_display = '';
        if (!empty($operator['unit_name'])) {
            $unit_display = $operator['unit_name'];
        } else {
            $unit_display = 'UNASSIGNED';
        }
        
        $response = [
            'success' => true,
            'data' => [
                'rank' => strtoupper($operator['rank'] ?? 'UNKNOWN'),
                'name' => strtoupper($operator['name'] ?? 'UNKNOWN'),
                'unit' => strtoupper($unit_display)
            ],
            'debug' => $operator // Add debug info
        ];
    } else {
        // Try a simpler query to see if there are any operators at all
        $simpleQuery = "SELECT COUNT(*) as total FROM operators";
        $simpleStmt = $pdo->prepare($simpleQuery);
        $simpleStmt->execute();
        $count = $simpleStmt->fetch(PDO::FETCH_ASSOC);
        
        $response = [
            'success' => false,
            'message' => 'No operators found matching criteria',
            'total_operators' => $count['total'] ?? 0,
            'debug_sql' => $sql
        ];
    }
    
} catch(PDOException $e) {
    $response = [
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ];
}

echo json_encode($response);
?>
