<?php
// Disable error display for clean JSON responses
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

// Set JSON headers first
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Catch any fatal errors and return JSON
function handleFatalError() {
    $error = error_get_last();
    if ($error && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Server error occurred. Please check server logs.'
        ]);
        exit();
    }
}
register_shutdown_function('handleFatalError');

include_once '../config/database.php';

// Start session to check user role
session_start();

// Check authentication - only admin and super_admin can access animation settings
// Exception: public action is allowed for everyone
$isAuthenticated = isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true;
$user_role = $_SESSION['admin_role'] ?? '';
$action = $_GET['action'] ?? '';

// Allow public access for the 'public' action
if ($action !== 'public' && (!$isAuthenticated || ($user_role !== 'admin' && $user_role !== 'super_admin'))) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized access. Admin privileges required.']);
    exit();
}

$database = new Database();
$db = $database->getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

switch($method) {
    case 'GET':
        if ($action === 'list') {
            getAnimationSettings($db);
        } elseif ($action === 'public') {
            getPublicAnimationSettings($db);
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid action']);
        }
        break;
    case 'POST':
        if ($action === 'update') {
            updateAnimationSettings($db);
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid action']);
        }
        break;
    default:
        http_response_code(405);
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
        break;
}

function getAnimationSettings($db) {
    try {
        $query = "SELECT * FROM animation_settings ORDER BY setting_name ASC";
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $settings = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $settings[] = [
                'id' => $row['id'],
                'name' => $row['setting_name'],
                'value' => (bool)$row['setting_value'],
                'description' => $row['description'],
                'updated_by' => $row['updated_by'],
                'updated_at' => $row['updated_at']
            ];
        }
        
        echo json_encode([
            'success' => true,
            'data' => $settings
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to load animation settings: ' . $e->getMessage()
        ]);
    }
}

function getPublicAnimationSettings($db) {
    try {
        $query = "SELECT setting_name, setting_value FROM animation_settings";
        $stmt = $db->prepare($query);
        $stmt->execute();
        
        $settings = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $settings[$row['setting_name']] = (bool)$row['setting_value'];
        }
        
        echo json_encode([
            'success' => true,
            'data' => $settings
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to load animation settings'
        ]);
    }
}

function updateAnimationSettings($db) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($input['settings']) || !is_array($input['settings'])) {
            throw new Exception('Invalid settings data');
        }
        
        $username = $_SESSION['admin_username'] ?? 'unknown';
        $updatedCount = 0;
        
        $db->beginTransaction();
        
        foreach ($input['settings'] as $setting) {
            if (!isset($setting['name']) || !isset($setting['value'])) {
                continue;
            }
            
            $query = "UPDATE animation_settings SET 
                      setting_value = :value, 
                      updated_by = :username, 
                      updated_at = CURRENT_TIMESTAMP 
                      WHERE setting_name = :name";
            
            $stmt = $db->prepare($query);
            $stmt->bindParam(':value', $setting['value'], PDO::PARAM_BOOL);
            $stmt->bindParam(':username', $username);
            $stmt->bindParam(':name', $setting['name']);
            
            if ($stmt->execute()) {
                $updatedCount++;
            }
        }
        
        $db->commit();
        
        // Log the activity
        logAnimationSettingsActivity($username, $updatedCount);
        
        echo json_encode([
            'success' => true,
            'message' => "Updated {$updatedCount} animation settings successfully",
            'updated_count' => $updatedCount
        ]);
        
    } catch (Exception $e) {
        if ($db->inTransaction()) {
            $db->rollback();
        }
        
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to update animation settings: ' . $e->getMessage()
        ]);
    }
}

function logAnimationSettingsActivity($username, $count) {
    try {
        $logDir = '../logs/';
        if (!file_exists($logDir)) {
            mkdir($logDir, 0755, true);
        }
        
        $logFile = $logDir . 'animation_settings.log';
        $timestamp = date('Y-m-d H:i:s');
        $logEntry = "[{$timestamp}] ANIMATION_SETTINGS_UPDATED: {$count} settings by {$username}\n";
        
        file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
    } catch (Exception $e) {
        // Silently fail logging to not interrupt main operations
    }
}
?>
