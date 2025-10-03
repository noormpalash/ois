<?php
/**
 * Admin Users Management API
 * Handles CRUD operations for admin users
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

session_start();

// Check if user is logged in
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Unauthorized access. Please login first.'
    ]);
    exit();
}

require_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Database connection failed");
    }
    
    $method = $_SERVER['REQUEST_METHOD'];
    $action = $_GET['action'] ?? '';
    
    switch ($method) {
        case 'GET':
            if ($action === 'list') {
                getAdminUsers($db);
            } elseif ($action === 'get' && isset($_GET['id'])) {
                getAdminUser($db, $_GET['id']);
            } elseif ($action === 'login_logs') {
                getLoginLogs($db);
            } else {
                getAdminUsers($db);
            }
            break;
            
        case 'POST':
            if ($action === 'create') {
                createAdminUser($db);
            } elseif ($action === 'change_password') {
                changePassword($db);
            } elseif ($action === 'clear_logs') {
                clearLoginLogs($db);
            } else {
                createAdminUser($db);
            }
            break;
            
        case 'PUT':
            if ($action === 'update' && isset($_GET['id'])) {
                updateAdminUser($db, $_GET['id']);
            } else {
                throw new Exception("Invalid update request");
            }
            break;
            
        case 'DELETE':
            if ($action === 'delete' && isset($_GET['id'])) {
                deleteAdminUser($db, $_GET['id']);
            } else {
                throw new Exception("Invalid delete request");
            }
            break;
            
        default:
            throw new Exception("Method not allowed");
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}

function getAdminUsers($db) {
    try {
        $stmt = $db->query("
            SELECT 
                id, username, email, full_name, role, status, 
                created_at, updated_at, last_login,
                (SELECT full_name FROM admin_users au2 WHERE au2.id = admin_users.created_by) as created_by_name
            FROM admin_users 
            ORDER BY created_at DESC
        ");
        
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $users,
            'count' => count($users)
        ]);
        
    } catch (Exception $e) {
        throw new Exception("Failed to fetch admin users: " . $e->getMessage());
    }
}

function getAdminUser($db, $id) {
    try {
        $stmt = $db->prepare("
            SELECT 
                id, username, email, full_name, role, status, 
                created_at, updated_at, last_login,
                (SELECT full_name FROM admin_users au2 WHERE au2.id = admin_users.created_by) as created_by_name
            FROM admin_users 
            WHERE id = ?
        ");
        $stmt->execute([$id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Admin user not found'
            ]);
            return;
        }
        
        echo json_encode([
            'success' => true,
            'data' => $user
        ]);
        
    } catch (Exception $e) {
        throw new Exception("Failed to fetch admin user: " . $e->getMessage());
    }
}

function createAdminUser($db) {
    // Only super_admin can create new admin users
    if ($_SESSION['admin_role'] !== 'super_admin') {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'Only super administrators can create new admin users'
        ]);
        return;
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) {
        $input = $_POST;
    }
    
    $username = trim($input['username'] ?? '');
    $email = trim($input['email'] ?? '');
    $password = $input['password'] ?? '';
    $full_name = trim($input['full_name'] ?? '');
    $role = $input['role'] ?? 'admin';
    $status = $input['status'] ?? 'active';
    
    // Validate input
    $errors = [];
    
    if (empty($username)) {
        $errors[] = 'Username is required';
    } elseif (strlen($username) < 3) {
        $errors[] = 'Username must be at least 3 characters long';
    }
    
    if (empty($email)) {
        $errors[] = 'Email is required';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Invalid email format';
    }
    
    if (empty($password)) {
        $errors[] = 'Password is required';
    } elseif (strlen($password) < 6) {
        $errors[] = 'Password must be at least 6 characters long';
    }
    
    if (empty($full_name)) {
        $errors[] = 'Full name is required';
    }
    
    if (!in_array($role, ['admin', 'super_admin', 'add_op'])) {
        $errors[] = 'Invalid role specified';
    }
    
    if (!in_array($status, ['active', 'inactive'])) {
        $errors[] = 'Invalid status specified';
    }
    
    if (!empty($errors)) {
        echo json_encode([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ]);
        return;
    }
    
    try {
        // Check if username or email already exists
        $checkStmt = $db->prepare("SELECT COUNT(*) FROM admin_users WHERE username = ? OR email = ?");
        $checkStmt->execute([$username, $email]);
        
        if ($checkStmt->fetchColumn() > 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Username or email already exists'
            ]);
            return;
        }
        
        // Hash password
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        
        // Insert new admin user
        $stmt = $db->prepare("
            INSERT INTO admin_users (username, email, password, full_name, role, status, created_by) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $username,
            $email,
            $hashedPassword,
            $full_name,
            $role,
            $status,
            $_SESSION['admin_id']
        ]);
        
        $newUserId = $db->lastInsertId();
        
        // Get the created user data
        $getUser = $db->prepare("
            SELECT id, username, email, full_name, role, status, created_at 
            FROM admin_users 
            WHERE id = ?
        ");
        $getUser->execute([$newUserId]);
        $newUser = $getUser->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Admin user created successfully',
            'data' => $newUser
        ]);
        
    } catch (Exception $e) {
        throw new Exception("Failed to create admin user: " . $e->getMessage());
    }
}

function updateAdminUser($db, $id) {
    // Users can only update their own profile unless they're super_admin
    if ($_SESSION['admin_role'] !== 'super_admin' && $_SESSION['admin_id'] != $id) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'You can only update your own profile'
        ]);
        return;
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) {
        parse_str(file_get_contents('php://input'), $input);
    }
    
    $email = trim($input['email'] ?? '');
    $full_name = trim($input['full_name'] ?? '');
    $role = $input['role'] ?? '';
    $status = $input['status'] ?? '';
    
    // Validate input
    $errors = [];
    
    if (empty($email)) {
        $errors[] = 'Email is required';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Invalid email format';
    }
    
    if (empty($full_name)) {
        $errors[] = 'Full name is required';
    }
    
    // Only super_admin can change role and status
    if ($_SESSION['admin_role'] === 'super_admin') {
        if (!empty($role) && !in_array($role, ['admin', 'super_admin', 'add_op'])) {
            $errors[] = 'Invalid role specified';
        }
        
        if (!empty($status) && !in_array($status, ['active', 'inactive'])) {
            $errors[] = 'Invalid status specified';
        }
    }
    
    if (!empty($errors)) {
        echo json_encode([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ]);
        return;
    }
    
    try {
        // Check if user exists
        $checkStmt = $db->prepare("SELECT id, username FROM admin_users WHERE id = ?");
        $checkStmt->execute([$id]);
        $existingUser = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$existingUser) {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Admin user not found'
            ]);
            return;
        }
        
        // Check if email already exists for another user
        $emailCheckStmt = $db->prepare("SELECT COUNT(*) FROM admin_users WHERE email = ? AND id != ?");
        $emailCheckStmt->execute([$email, $id]);
        
        if ($emailCheckStmt->fetchColumn() > 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Email already exists for another user'
            ]);
            return;
        }
        
        // Build update query
        $updateFields = ['email = ?', 'full_name = ?'];
        $updateValues = [$email, $full_name];
        
        if ($_SESSION['admin_role'] === 'super_admin') {
            if (!empty($role)) {
                $updateFields[] = 'role = ?';
                $updateValues[] = $role;
            }
            if (!empty($status)) {
                $updateFields[] = 'status = ?';
                $updateValues[] = $status;
            }
        }
        
        $updateValues[] = $id;
        
        $updateSQL = "UPDATE admin_users SET " . implode(', ', $updateFields) . " WHERE id = ?";
        $stmt = $db->prepare($updateSQL);
        $stmt->execute($updateValues);
        
        // Get updated user data
        $getUser = $db->prepare("
            SELECT id, username, email, full_name, role, status, updated_at 
            FROM admin_users 
            WHERE id = ?
        ");
        $getUser->execute([$id]);
        $updatedUser = $getUser->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Admin user updated successfully',
            'data' => $updatedUser
        ]);
        
    } catch (Exception $e) {
        throw new Exception("Failed to update admin user: " . $e->getMessage());
    }
}

function deleteAdminUser($db, $id) {
    // Only super_admin can delete users
    if ($_SESSION['admin_role'] !== 'super_admin') {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'Only super administrators can delete admin users'
        ]);
        return;
    }
    
    // Prevent deleting self
    if ($_SESSION['admin_id'] == $id) {
        echo json_encode([
            'success' => false,
            'message' => 'You cannot delete your own account'
        ]);
        return;
    }
    
    try {
        // Check if user exists
        $checkStmt = $db->prepare("SELECT username FROM admin_users WHERE id = ?");
        $checkStmt->execute([$id]);
        $user = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Admin user not found'
            ]);
            return;
        }
        
        // Delete user
        $deleteStmt = $db->prepare("DELETE FROM admin_users WHERE id = ?");
        $deleteStmt->execute([$id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Admin user deleted successfully',
            'deleted_user' => $user['username']
        ]);
        
    } catch (Exception $e) {
        throw new Exception("Failed to delete admin user: " . $e->getMessage());
    }
}

function changePassword($db) {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) {
        $input = $_POST;
    }
    
    $user_id = $input['user_id'] ?? $_SESSION['admin_id'];
    $current_password = $input['current_password'] ?? '';
    $new_password = $input['new_password'] ?? '';
    $confirm_password = $input['confirm_password'] ?? '';
    
    // Users can only change their own password unless they're super_admin
    if ($_SESSION['admin_role'] !== 'super_admin' && $_SESSION['admin_id'] != $user_id) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'You can only change your own password'
        ]);
        return;
    }
    
    // Validate input
    $errors = [];
    
    if (empty($new_password)) {
        $errors[] = 'New password is required';
    } elseif (strlen($new_password) < 6) {
        $errors[] = 'New password must be at least 6 characters long';
    }
    
    if ($new_password !== $confirm_password) {
        $errors[] = 'Password confirmation does not match';
    }
    
    // Current password is required unless super_admin is changing another user's password
    if ($_SESSION['admin_id'] == $user_id && empty($current_password)) {
        $errors[] = 'Current password is required';
    }
    
    if (!empty($errors)) {
        echo json_encode([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ]);
        return;
    }
    
    try {
        // Get current user data
        $stmt = $db->prepare("SELECT password, username FROM admin_users WHERE id = ?");
        $stmt->execute([$user_id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'User not found'
            ]);
            return;
        }
        
        // Verify current password if changing own password
        if ($_SESSION['admin_id'] == $user_id) {
            if (!password_verify($current_password, $user['password'])) {
                echo json_encode([
                    'success' => false,
                    'message' => 'Current password is incorrect'
                ]);
                return;
            }
        }
        
        // Hash new password
        $hashedPassword = password_hash($new_password, PASSWORD_DEFAULT);
        
        // Update password
        $updateStmt = $db->prepare("UPDATE admin_users SET password = ? WHERE id = ?");
        $updateStmt->execute([$hashedPassword, $user_id]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Password changed successfully',
            'username' => $user['username']
        ]);
        
    } catch (Exception $e) {
        throw new Exception("Failed to change password: " . $e->getMessage());
    }
}

function getLoginLogs($db) {
    try {
        // Get pagination parameters
        $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
        $limit = isset($_GET['limit']) ? max(1, min(100, (int)$_GET['limit'])) : 50;
        $offset = ($page - 1) * $limit;
        $username = $_GET['username'] ?? '';
        
        // Build query with optional username filter
        $whereClause = '';
        $params = [];
        
        if (!empty($username)) {
            $whereClause = 'WHERE username = ?';
            $params[] = $username;
        }
        
        // Get total count
        $countQuery = "SELECT COUNT(*) as total FROM admin_login_log $whereClause";
        $countStmt = $db->prepare($countQuery);
        $countStmt->execute($params);
        $countResult = $countStmt->fetch(PDO::FETCH_ASSOC);
        $totalRecords = $countResult ? (int)$countResult['total'] : 0;
        
        // Get login logs
        $query = "SELECT id, username, success, ip_address, user_agent, details, created_at 
                  FROM admin_login_log 
                  $whereClause 
                  ORDER BY created_at DESC 
                  LIMIT " . intval($limit) . " OFFSET " . intval($offset);
        
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Calculate pagination
        $totalPages = $totalRecords > 0 ? ceil($totalRecords / $limit) : 1;
        
        echo json_encode([
            'success' => true,
            'data' => $logs,
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
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to fetch login logs: ' . $e->getMessage()
        ]);
    }
}

function clearLoginLogs($db) {
    try {
        // Only super admins can clear logs
        if (!isset($_SESSION['admin_role']) || $_SESSION['admin_role'] !== 'super_admin') {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'Access denied. Only super admins can clear login logs.'
            ]);
            return;
        }
        
        $input = file_get_contents("php://input");
        $data = json_decode($input, true);
        
        $clearType = $data['type'] ?? 'all';
        $username = $data['username'] ?? '';
        $daysOld = isset($data['days_old']) ? (int)$data['days_old'] : 0;
        
        $query = "DELETE FROM admin_login_log";
        $params = [];
        $conditions = [];
        
        // Build WHERE clause based on clear type
        if ($clearType === 'user' && !empty($username)) {
            $conditions[] = "username = ?";
            $params[] = $username;
        } elseif ($clearType === 'failed') {
            $conditions[] = "success = 0";
        } elseif ($clearType === 'older_than' && $daysOld > 0) {
            $conditions[] = "created_at < DATE_SUB(NOW(), INTERVAL ? DAY)";
            $params[] = $daysOld;
        }
        // For 'all' type, no conditions needed
        
        if (!empty($conditions)) {
            $query .= " WHERE " . implode(" AND ", $conditions);
        }
        
        $stmt = $db->prepare($query);
        $result = $stmt->execute($params);
        
        if ($result) {
            $deletedCount = $stmt->rowCount();
            
            // Log this action
            $logStmt = $db->prepare("
                INSERT INTO admin_login_log (username, success, ip_address, user_agent, details, created_at) 
                VALUES (?, 1, ?, ?, ?, NOW())
            ");
            $logStmt->execute([
                $_SESSION['admin_username'],
                $_SERVER['REMOTE_ADDR'] ?? 'unknown',
                $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
                "Cleared {$deletedCount} login log entries (type: {$clearType})"
            ]);
            
            echo json_encode([
                'success' => true,
                'message' => "Successfully cleared {$deletedCount} login log entries.",
                'deleted_count' => $deletedCount
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to clear login logs.'
            ]);
        }
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to clear login logs: ' . $e->getMessage()
        ]);
    }
}
?>
