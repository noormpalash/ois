<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Cache-Control: no-cache, no-store, must-revalidate");
header("Pragma: no-cache");
header("Expires: 0");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if($_SERVER['REQUEST_METHOD'] === 'GET') {
    $type = $_GET['type'] ?? 'all';
    
    switch($type) {
        case 'formations':
            getFormations($db);
            break;
        case 'med_categories':
            getMedCategories($db);
            break;
        case 'cores':
            getCores($db);
            break;
        case 'exercises':
            getExercises($db);
            break;
        case 'units':
            getUnits($db);
            break;
        case 'ranks':
            getRanks($db);
            break;
        case 'special_notes':
            getSpecialNotes($db);
            break;
        case 'all':
        default:
            getAllOptions($db);
            break;
    }
}

function getAllOptions($db) {
    $options = [
        'formations' => getTableData($db, 'formations'),
        'med_categories' => getTableData($db, 'med_categories'),
        'cores' => getTableData($db, 'cores'),
        'exercises' => getTableData($db, 'exercises'),
        'units' => getTableData($db, 'units'),
        'ranks' => getRanksData($db),
        'special_notes' => getTableData($db, 'special_notes')
    ];
    echo json_encode($options);
}

function getFormations($db) {
    echo json_encode(getTableData($db, 'formations'));
}

function getMedCategories($db) {
    echo json_encode(getTableData($db, 'med_categories'));
}

function getCores($db) {
    echo json_encode(getTableData($db, 'cores'));
}

function getExercises($db) {
    echo json_encode(getTableData($db, 'exercises'));
}

function getUnits($db) {
    echo json_encode(getTableData($db, 'units'));
}

function getRanks($db) {
    echo json_encode(getRanksData($db));
}

function getSpecialNotes($db) {
    echo json_encode(getTableData($db, 'special_notes'));
}

function getTableData($db, $table) {
    $stmt = $db->prepare("SELECT id, name FROM {$table} ORDER BY name");
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function getRanksData($db) {
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
?>
