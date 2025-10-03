<?php
/**
 * Operator Information System (OIS) - Database Configuration
 * 
 * This file contains the database connection settings for the OIS application.
 * Update these settings according to your hosting environment.
 * 
 * @author Cpl Noor Mohammad Palash, EB
 * @version 1.0
 */

// Database Configuration
$host = 'localhost';        // Database host (usually 'localhost')
$dbname = 'ois_database';   // Database name
$username = 'root';         // Database username
$password = '';             // Database password (empty for XAMPP default)

// For shared hosting, update these values:
// $host = 'your_hosting_db_host';
// $dbname = 'your_database_name';
// $username = 'your_db_username';
// $password = 'your_secure_password';

// PDO Connection Options
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    // Create PDO connection
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, $options);
    
    // Set timezone (optional)
    $pdo->exec("SET time_zone = '+06:00'"); // Adjust timezone as needed
    
} catch (PDOException $e) {
    // Log error and show user-friendly message
    error_log("Database connection failed: " . $e->getMessage());
    
    // In production, show generic error message
    if (isset($_SERVER['HTTP_HOST'])) {
        die("Database connection failed. Please check your configuration or contact the administrator.");
    } else {
        die("Database connection failed: " . $e->getMessage());
    }
}

// Application Settings
define('APP_NAME', 'Operator Information System');
define('APP_VERSION', '1.0');
define('APP_AUTHOR', 'Cpl Noor Mohammad Palash, EB');

// Security Settings
define('SESSION_TIMEOUT', 3600); // 1 hour in seconds
define('MAX_LOGIN_ATTEMPTS', 5);
define('LOGIN_LOCKOUT_TIME', 900); // 15 minutes in seconds

// File Upload Settings
define('MAX_FILE_SIZE', 5 * 1024 * 1024); // 5MB
define('ALLOWED_FILE_TYPES', ['csv', 'xlsx', 'xls']);

// Backup Settings
define('BACKUP_DIR', __DIR__ . '/backups/');
define('MAX_BACKUP_FILES', 10); // Keep only 10 most recent backups

// Ensure backup directory exists and is writable
if (!file_exists(BACKUP_DIR)) {
    mkdir(BACKUP_DIR, 0755, true);
}

// Pagination Settings
define('DEFAULT_PAGE_SIZE', 50);
define('MAX_PAGE_SIZE', 100);

// Debug Settings (set to false in production)
define('DEBUG_MODE', false);

if (DEBUG_MODE) {
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
} else {
    ini_set('display_errors', 0);
    error_reporting(0);
}

// Helper function to check if database connection is working
function testDatabaseConnection() {
    global $pdo;
    try {
        $stmt = $pdo->query("SELECT 1");
        return true;
    } catch (PDOException $e) {
        return false;
    }
}

// Helper function to get database info
function getDatabaseInfo() {
    global $pdo;
    try {
        $stmt = $pdo->query("SELECT VERSION() as version");
        $result = $stmt->fetch();
        return $result['version'];
    } catch (PDOException $e) {
        return 'Unknown';
    }
}

?>
