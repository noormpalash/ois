<?php
/**
 * Authentication API
 * Handles login, logout, and session management
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

session_start();

require_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Database connection failed");
    }
    
    $action = $_GET['action'] ?? 'login';
    
    switch ($action) {
        case 'login':
            handleLogin($db);
            break;
            
        case 'logout':
            handleLogout();
            break;
            
        case 'check_session':
            checkSession();
            break;
            
        default:
            if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                handleLogin($db);
            } else {
                throw new Exception("Invalid action");
            }
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}

function handleLogin($db) {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception("Only POST method allowed for login");
    }
    
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';
    $remember_me = isset($_POST['remember_me']);
    
    // Validate input
    if (empty($username) || empty($password)) {
        echo json_encode([
            'success' => false,
            'message' => 'Username and password are required'
        ]);
        return;
    }
    
    try {
        // Get user from database
        $stmt = $db->prepare("
            SELECT id, username, email, password, full_name, role, status 
            FROM admin_users 
            WHERE (username = ? OR email = ?) AND status = 'active'
        ");
        $stmt->execute([$username, $username]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            // Log failed attempt
            logLoginAttempt($db, $username, false, 'User not found or inactive');
            
            echo json_encode([
                'success' => false,
                'message' => 'Invalid username or password'
            ]);
            return;
        }
        
        // Verify password
        if (!password_verify($password, $user['password'])) {
            // Log failed attempt
            logLoginAttempt($db, $username, false, 'Invalid password');
            
            echo json_encode([
                'success' => false,
                'message' => 'Invalid username or password'
            ]);
            return;
        }
        
        // Login successful - create session
        $_SESSION['admin_logged_in'] = true;
        $_SESSION['admin_id'] = $user['id'];
        $_SESSION['admin_username'] = $user['username'];
        $_SESSION['admin_email'] = $user['email'];
        $_SESSION['admin_full_name'] = $user['full_name'];
        $_SESSION['admin_role'] = $user['role'];
        $_SESSION['login_time'] = time();
        
        // Set remember me cookie if requested
        if ($remember_me) {
            $cookie_value = base64_encode($user['id'] . ':' . $user['username'] . ':' . hash('sha256', $user['password']));
            setcookie('admin_remember', $cookie_value, time() + (30 * 24 * 60 * 60), '/', '', false, true); // 30 days
        }
        
        // Update last login time
        $updateLogin = $db->prepare("UPDATE admin_users SET last_login = NOW() WHERE id = ?");
        $updateLogin->execute([$user['id']]);
        
        // Log successful attempt
        logLoginAttempt($db, $username, true, 'Login successful');
        
        echo json_encode([
            'success' => true,
            'message' => 'Login successful',
            'user' => [
                'id' => $user['id'],
                'username' => $user['username'],
                'email' => $user['email'],
                'full_name' => $user['full_name'],
                'role' => $user['role']
            ]
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Login failed: ' . $e->getMessage()
        ]);
    }
}

function handleLogout() {
    // Clear remember me cookie
    if (isset($_COOKIE['admin_remember'])) {
        setcookie('admin_remember', '', time() - 3600, '/', '', false, true);
    }
    
    // Destroy session
    session_unset();
    session_destroy();
    
    echo json_encode([
        'success' => true,
        'message' => 'Logged out successfully'
    ]);
}

function checkSession() {
    $logged_in = isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true;
    
    $response = [
        'logged_in' => $logged_in
    ];
    
    if ($logged_in) {
        $response['user'] = [
            'id' => $_SESSION['admin_id'] ?? null,
            'username' => $_SESSION['admin_username'] ?? null,
            'email' => $_SESSION['admin_email'] ?? null,
            'full_name' => $_SESSION['admin_full_name'] ?? null,
            'role' => $_SESSION['admin_role'] ?? null,
            'login_time' => $_SESSION['login_time'] ?? null
        ];
    }
    
    echo json_encode($response);
}

function logLoginAttempt($db, $username, $success, $details = '') {
    try {
        $stmt = $db->prepare("
            INSERT INTO admin_login_log (username, success, ip_address, user_agent, details, created_at) 
            VALUES (?, ?, ?, ?, ?, NOW())
        ");
        
        $ip_address = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
        
        $stmt->execute([
            $username,
            $success ? 1 : 0,
            $ip_address,
            $user_agent,
            $details
        ]);
    } catch (Exception $e) {
        // Ignore logging errors - don't fail login because of logging issues
        error_log("Failed to log login attempt: " . $e->getMessage());
    }
}

// Create login log table if it doesn't exist
function createLoginLogTable($db) {
    try {
        $createTableSQL = "
        CREATE TABLE IF NOT EXISTS admin_login_log (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) NOT NULL,
            success BOOLEAN NOT NULL,
            ip_address VARCHAR(45) NOT NULL,
            user_agent TEXT,
            details TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_username (username),
            INDEX idx_created_at (created_at),
            INDEX idx_success (success)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        
        $db->exec($createTableSQL);
    } catch (Exception $e) {
        // Ignore table creation errors
        error_log("Failed to create login log table: " . $e->getMessage());
    }
}

// Ensure login log table exists
if (isset($db)) {
    createLoginLogTable($db);
}
?>
