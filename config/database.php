<?php
class Database {
    private $host = "localhost"; // Change to your server IP for remote access
    private $db_name = "operator_info_system";
    private $username = "root"; // Use 'remote_user' for external connections
    private $password = ""; // XAMPP default MySQL password (empty) - set password for remote_user
    private $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4", $this->username, $this->password);
            $this->conn->exec("set names utf8mb4 COLLATE utf8mb4_unicode_ci");
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            
            // Set SQL mode for better compatibility
            $this->conn->exec("SET sql_mode = 'TRADITIONAL'");
            
        } catch(PDOException $exception) {
            echo "Connection error: " . $exception->getMessage();
        }
        return $this->conn;
    }
}
?>
