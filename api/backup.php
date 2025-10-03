<?php
// Disable error display for clean JSON responses
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

// Set JSON headers first
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
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

// Check authentication - only admin and super_admin can access backup/restore
$isAuthenticated = isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true;
$user_role = $_SESSION['admin_role'] ?? '';

if (!$isAuthenticated || ($user_role !== 'admin' && $user_role !== 'super_admin')) {
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
        if ($action === 'backup') {
            createBackup($db);
        } elseif ($action === 'list') {
            listBackups();
        } elseif ($action === 'download') {
            downloadBackup();
        } elseif ($action === 'test') {
            // Simple test endpoint
            echo json_encode([
                'success' => true,
                'message' => 'Backup API is working',
                'data' => [
                    'authenticated' => $isAuthenticated,
                    'role' => $user_role,
                    'database_connected' => $db ? true : false,
                    'backups_dir_exists' => file_exists('../backups/'),
                    'backups_dir_writable' => is_writable('../backups/'),
                    'timestamp' => date('Y-m-d H:i:s')
                ]
            ]);
        } else {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid action']);
        }
        break;
    case 'POST':
        if ($action === 'restore') {
            restoreBackup($db);
        } elseif ($action === 'delete') {
            deleteBackup();
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

function createBackup($db) {
    try {
        // Validate database connection
        if (!$db) {
            throw new Exception('Database connection not available');
        }
        
        // Create backups directory if it doesn't exist
        $backupDir = '../backups/';
        if (!file_exists($backupDir)) {
            if (!mkdir($backupDir, 0777, true)) {
                throw new Exception('Failed to create backups directory');
            }
        }
        
        // Check if directory is writable and try to fix permissions
        if (!is_writable($backupDir)) {
            // Try to fix permissions
            @chmod($backupDir, 0777);
            
            // Check again
            if (!is_writable($backupDir)) {
                throw new Exception('Backups directory is not writable. Please set permissions to 777 for: ' . realpath($backupDir));
            }
        }
        
        // Generate backup filename with timestamp
        $timestamp = date('Y-m-d_H-i-s');
        $filename = "ois_backup_{$timestamp}.sql";
        $filepath = $backupDir . $filename;
        
        // Try PHP-based backup first (more reliable in XAMPP environment)
        $success = createPHPBackup($db, $filepath);
        
        if (!$success) {
            // If PHP backup fails, try mysqldump as fallback
            $host = "localhost";
            $dbname = "operator_info_system";
            $username = "root";
            $password = "";
            
            // Create mysqldump command (only if mysqldump is available)
            if (commandExists('mysqldump')) {
                $command = sprintf(
                    'mysqldump --host=%s --user=%s %s --single-transaction --routines --triggers %s > %s 2>&1',
                    escapeshellarg($host),
                    escapeshellarg($username),
                    $password ? '--password=' . escapeshellarg($password) : '',
                    escapeshellarg($dbname),
                    escapeshellarg($filepath)
                );
                
                $output = [];
                $returnVar = 0;
                exec($command, $output, $returnVar);
                
                if ($returnVar !== 0) {
                    throw new Exception('Both PHP backup and mysqldump failed. Error: ' . implode("\n", $output));
                }
            } else {
                throw new Exception('PHP backup failed and mysqldump is not available');
            }
        }
        
        // Verify backup file was created and has content
        if (!file_exists($filepath)) {
            throw new Exception('Backup file was not created');
        }
        
        if (filesize($filepath) == 0) {
            unlink($filepath); // Remove empty file
            throw new Exception('Backup file is empty');
        }
        
        // Get file size for response
        $filesize = filesize($filepath);
        $filesizeFormatted = formatBytes($filesize);
        
        // Log backup creation
        logBackupActivity('BACKUP_CREATED', $filename, $_SESSION['admin_username'] ?? 'unknown');
        
        echo json_encode([
            'success' => true,
            'message' => 'Backup created successfully',
            'data' => [
                'filename' => $filename,
                'filepath' => $filepath,
                'size' => $filesize,
                'size_formatted' => $filesizeFormatted,
                'created_at' => date('Y-m-d H:i:s')
            ]
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Backup failed: ' . $e->getMessage()
        ]);
    }
}

function commandExists($command) {
    $whereIsCommand = (PHP_OS == 'WINNT') ? 'where' : 'which';
    $process = proc_open(
        "$whereIsCommand $command",
        array(
            0 => array("pipe", "r"), // stdin
            1 => array("pipe", "w"), // stdout
            2 => array("pipe", "w"), // stderr
        ),
        $pipes
    );
    if ($process !== false) {
        $stdout = stream_get_contents($pipes[1]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        proc_close($process);
        return !empty($stdout);
    }
    return false;
}

function createPHPBackup($db, $filepath) {
    try {
        // Validate database connection
        if (!$db) {
            return false;
        }
        
        $sql = "-- OIS Database Backup\n";
        $sql .= "-- Generated on: " . date('Y-m-d H:i:s') . "\n";
        $sql .= "-- Database: operator_info_system\n\n";
        
        $sql .= "SET FOREIGN_KEY_CHECKS = 0;\n";
        $sql .= "SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';\n";
        $sql .= "SET time_zone = '+00:00';\n\n";
        
        // Get all tables
        $tables = [];
        $result = $db->query("SHOW TABLES");
        if (!$result) {
            return false;
        }
        
        while ($row = $result->fetch(PDO::FETCH_NUM)) {
            $tables[] = $row[0];
        }
        
        if (empty($tables)) {
            return false;
        }
        
        // Export each table
        foreach ($tables as $table) {
            $sql .= "-- Table structure for table `{$table}`\n";
            $sql .= "DROP TABLE IF EXISTS `{$table}`;\n";
            
            // Get CREATE TABLE statement
            $result = $db->query("SHOW CREATE TABLE `{$table}`");
            if (!$result) {
                continue;
            }
            
            $row = $result->fetch(PDO::FETCH_NUM);
            if ($row && isset($row[1])) {
                $sql .= $row[1] . ";\n\n";
            }
            
            // Get table data
            $sql .= "-- Dumping data for table `{$table}`\n";
            $result = $db->query("SELECT * FROM `{$table}`");
            
            if ($result) {
                while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
                    $columns = array_keys($row);
                    $sql .= "INSERT INTO `{$table}` (`" . implode('`, `', $columns) . "`) VALUES (";
                    $values = [];
                    foreach ($row as $value) {
                        if ($value === null) {
                            $values[] = 'NULL';
                        } else {
                            $values[] = $db->quote($value);
                        }
                    }
                    $sql .= implode(', ', $values) . ");\n";
                }
            }
            $sql .= "\n";
        }
        
        $sql .= "SET FOREIGN_KEY_CHECKS = 1;\n";
        
        $result = file_put_contents($filepath, $sql);
        return $result !== false && $result > 0;
        
    } catch (Exception $e) {
        error_log("PHP Backup Error: " . $e->getMessage());
        return false;
    }
}

function listBackups() {
    try {
        $backupDir = '../backups/';
        $backups = [];
        
        if (is_dir($backupDir)) {
            $files = scandir($backupDir);
            foreach ($files as $file) {
                if ($file != '.' && $file != '..' && pathinfo($file, PATHINFO_EXTENSION) === 'sql') {
                    $filepath = $backupDir . $file;
                    $backups[] = [
                        'filename' => $file,
                        'size' => filesize($filepath),
                        'size_formatted' => formatBytes(filesize($filepath)),
                        'created_at' => date('Y-m-d H:i:s', filemtime($filepath)),
                        'age' => timeAgo(filemtime($filepath))
                    ];
                }
            }
        }
        
        // Sort by creation time (newest first)
        usort($backups, function($a, $b) {
            return strcmp($b['created_at'], $a['created_at']);
        });
        
        echo json_encode([
            'success' => true,
            'data' => $backups,
            'count' => count($backups)
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to list backups: ' . $e->getMessage()
        ]);
    }
}

function downloadBackup() {
    try {
        $filename = $_GET['filename'] ?? '';
        if (empty($filename)) {
            throw new Exception('Filename not provided');
        }
        
        $filepath = '../backups/' . basename($filename);
        
        if (!file_exists($filepath)) {
            throw new Exception('Backup file not found');
        }
        
        // Log download activity
        logBackupActivity('BACKUP_DOWNLOADED', $filename, $_SESSION['admin_username']);
        
        // Set headers for file download
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Content-Length: ' . filesize($filepath));
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        
        // Output file content
        readfile($filepath);
        exit();
        
    } catch (Exception $e) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Download failed: ' . $e->getMessage()
        ]);
    }
}

function restoreBackup($db) {
    try {
        // Check if file was uploaded
        if (!isset($_FILES['backup_file']) || $_FILES['backup_file']['error'] !== UPLOAD_ERR_OK) {
            throw new Exception('No backup file uploaded or upload error');
        }
        
        $uploadedFile = $_FILES['backup_file'];
        $filename = $uploadedFile['name'];
        $tmpPath = $uploadedFile['tmp_name'];
        
        // Validate file extension
        if (pathinfo($filename, PATHINFO_EXTENSION) !== 'sql') {
            throw new Exception('Invalid file type. Only .sql files are allowed');
        }
        
        // Read and validate SQL content
        $sqlContent = file_get_contents($tmpPath);
        if (empty($sqlContent)) {
            throw new Exception('Backup file is empty');
        }
        
        // Basic validation - check if it looks like a SQL dump
        if (!preg_match('/CREATE TABLE|INSERT INTO|DROP TABLE/i', $sqlContent)) {
            throw new Exception('File does not appear to be a valid SQL backup');
        }
        
        // Additional validation - check for potentially dangerous statements
        if (preg_match('/DROP DATABASE|CREATE DATABASE/i', $sqlContent)) {
            throw new Exception('Backup file contains dangerous database operations');
        }
        
        // Log restore start
        error_log("Starting backup restore for file: " . $filename);
        
        // Note: MySQL DDL statements (CREATE TABLE, DROP TABLE) cause implicit commits
        // So we'll execute the restore without transactions for DDL, but with error handling
        
        try {
            // Disable foreign key checks
            $db->exec("SET FOREIGN_KEY_CHECKS = 0");
            
            // Get all existing tables to drop them first
            $existingTables = [];
            $result = $db->query("SHOW TABLES");
            if ($result) {
                while ($row = $result->fetch(PDO::FETCH_NUM)) {
                    $existingTables[] = $row[0];
                }
            }
            
            // Drop all existing tables to ensure clean restore
            error_log("Dropping " . count($existingTables) . " existing tables");
            foreach ($existingTables as $table) {
                $db->exec("DROP TABLE IF EXISTS `{$table}`");
            }
            
            // Split SQL into individual statements (handle multi-line statements better)
            $statements = preg_split('/;\s*$/m', $sqlContent);
            
            $executedStatements = 0;
            $ddlStatements = 0;
            $dmlStatements = 0;
            
            foreach ($statements as $statement) {
                $statement = trim($statement);
                
                // Skip empty statements and comments
                if (empty($statement) || preg_match('/^--/', $statement) || preg_match('/^\/\*/', $statement)) {
                    continue;
                }
                
                // Skip SET statements that might cause issues
                if (preg_match('/^SET\s+(FOREIGN_KEY_CHECKS|SQL_MODE|time_zone)/i', $statement)) {
                    continue;
                }
                
                try {
                    // Check if this is a DDL or DML statement
                    $isDDL = preg_match('/^(CREATE|DROP|ALTER)\s+/i', $statement);
                    $isDML = preg_match('/^(INSERT|UPDATE|DELETE)\s+/i', $statement);
                    
                    $db->exec($statement);
                    $executedStatements++;
                    
                    if ($isDDL) {
                        $ddlStatements++;
                    } elseif ($isDML) {
                        $dmlStatements++;
                    }
                    
                } catch (PDOException $e) {
                    // Log the problematic statement for debugging
                    error_log("SQL Statement Error: " . $e->getMessage() . " - Statement: " . substr($statement, 0, 200));
                    throw new Exception("SQL execution failed at statement #" . ($executedStatements + 1) . ": " . $e->getMessage());
                }
            }
            
            // Verify that we executed some statements
            if ($executedStatements === 0) {
                throw new Exception("No valid SQL statements found in backup file");
            }
            
            error_log("Successfully executed " . $executedStatements . " SQL statements (DDL: $ddlStatements, DML: $dmlStatements)");
            
            // Ensure required animation settings exist after restore
            ensureAnimationSettings($db);
            
            // Re-enable foreign key checks
            $db->exec("SET FOREIGN_KEY_CHECKS = 1");
            
            error_log("Backup restore completed successfully for: " . $filename);
            
            // Log restore activity
            logBackupActivity('BACKUP_RESTORED', $filename, $_SESSION['admin_username']);
            
            echo json_encode([
                'success' => true,
                'message' => 'Database restored successfully from: ' . $filename
            ]);
            
        } catch (Exception $e) {
            error_log("Restore error occurred: " . $e->getMessage());
            
            // Re-enable foreign key checks in case of error
            try {
                $db->exec("SET FOREIGN_KEY_CHECKS = 1");
            } catch (Exception $fkError) {
                error_log("Failed to re-enable foreign key checks: " . $fkError->getMessage());
            }
            
            throw new Exception('Restore failed: ' . $e->getMessage());
        }
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => $e->getMessage()
        ]);
    }
}

function deleteBackup() {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        $filename = $input['filename'] ?? '';
        
        if (empty($filename)) {
            throw new Exception('Filename not provided');
        }
        
        $filepath = '../backups/' . basename($filename);
        
        if (!file_exists($filepath)) {
            throw new Exception('Backup file not found');
        }
        
        if (!unlink($filepath)) {
            throw new Exception('Failed to delete backup file');
        }
        
        // Log delete activity
        logBackupActivity('BACKUP_DELETED', $filename, $_SESSION['admin_username']);
        
        echo json_encode([
            'success' => true,
            'message' => 'Backup deleted successfully: ' . $filename
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Delete failed: ' . $e->getMessage()
        ]);
    }
}

function logBackupActivity($action, $filename, $username) {
    try {
        $logDir = '../logs/';
        if (!file_exists($logDir)) {
            mkdir($logDir, 0755, true);
        }
        
        $logFile = $logDir . 'backup_activity.log';
        $timestamp = date('Y-m-d H:i:s');
        $logEntry = "[{$timestamp}] {$action}: {$filename} by {$username}\n";
        
        file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
    } catch (Exception $e) {
        // Silently fail logging to not interrupt main operations
    }
}

function formatBytes($size, $precision = 2) {
    $units = ['B', 'KB', 'MB', 'GB', 'TB'];
    
    for ($i = 0; $size > 1024 && $i < count($units) - 1; $i++) {
        $size /= 1024;
    }
    
    return round($size, $precision) . ' ' . $units[$i];
}

function timeAgo($timestamp) {
    $time = time() - $timestamp;
    
    if ($time < 60) return 'just now';
    if ($time < 3600) return floor($time/60) . ' minutes ago';
    if ($time < 86400) return floor($time/3600) . ' hours ago';
    if ($time < 2592000) return floor($time/86400) . ' days ago';
    if ($time < 31536000) return floor($time/2592000) . ' months ago';
    
    return floor($time/31536000) . ' years ago';
}

function ensureAnimationSettings($db) {
    try {
        error_log("Ensuring required animation settings exist after restore...");
        
        // Required animation settings with default values (all disabled)
        $requiredSettings = [
            'hero_animations' => [
                'value' => 0,
                'description' => 'Enable/disable hero section animations (logo rotation, gradient effects)'
            ],
            'drone_animations' => [
                'value' => 0,
                'description' => 'Enable/disable military drone animation with scanning effects and operator info display'
            ]
        ];
        
        foreach ($requiredSettings as $settingName => $config) {
            // Check if setting exists
            $stmt = $db->prepare("SELECT COUNT(*) FROM animation_settings WHERE setting_name = ?");
            $stmt->execute([$settingName]);
            $exists = $stmt->fetchColumn() > 0;
            
            if (!$exists) {
                // Insert missing setting
                $insertStmt = $db->prepare("
                    INSERT INTO animation_settings (setting_name, setting_value, description, updated_by, created_at, updated_at) 
                    VALUES (?, ?, ?, 'system', NOW(), NOW())
                ");
                $insertStmt->execute([$settingName, $config['value'], $config['description']]);
                error_log("Added missing animation setting: $settingName");
            }
        }
        
        error_log("Animation settings verification completed");
        
    } catch (Exception $e) {
        error_log("Error ensuring animation settings: " . $e->getMessage());
        // Don't throw exception - this shouldn't fail the entire restore
    }
}
