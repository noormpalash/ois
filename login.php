<?php
session_start();

// Check for remember me cookie and auto-login
if (!isset($_SESSION['admin_logged_in']) && isset($_COOKIE['admin_remember'])) {
    require_once 'config/database.php';
    
    try {
        $database = new Database();
        $pdo = $database->getConnection();
        
        if ($pdo) {
            $cookie_data = base64_decode($_COOKIE['admin_remember']);
            $parts = explode(':', $cookie_data);
            
            if (count($parts) === 3) {
                $user_id = $parts[0];
                $username = $parts[1];
                $password_hash = $parts[2];
                
                // Verify the cookie data against database
                $stmt = $pdo->prepare("SELECT id, username, password, role FROM admin_users WHERE id = ? AND username = ?");
                $stmt->execute([$user_id, $username]);
                $user = $stmt->fetch();
                
                if ($user && hash('sha256', $user['password']) === $password_hash) {
                    // Valid remember me cookie - auto login
                    $_SESSION['admin_logged_in'] = true;
                    $_SESSION['admin_id'] = $user['id'];
                    $_SESSION['admin_username'] = $user['username'];
                    $_SESSION['admin_role'] = $user['role'];
                    $_SESSION['login_time'] = time();
                    
                    // Update last login time
                    $update_stmt = $pdo->prepare("UPDATE admin_users SET last_login = NOW() WHERE id = ?");
                    $update_stmt->execute([$user['id']]);
                    
                    header('Location: admin.php');
                    exit();
                } else {
                    // Invalid cookie - clear it
                    setcookie('admin_remember', '', time() - 3600, '/', '', false, true);
                }
            }
        }
    } catch (Exception $e) {
        // Error with cookie - clear it
        setcookie('admin_remember', '', time() - 3600, '/', '', false, true);
    }
}

// If already logged in via session, redirect to admin panel
if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header('Location: admin.php');
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Operator Information System</title>
    
    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="assets/favicon/favicon.svg">
    <link rel="icon" type="image/x-icon" href="assets/favicon/favicon.ico">
    <link rel="apple-touch-icon" href="assets/favicon/apple-touch-icon.svg">
    <link rel="manifest" href="assets/favicon/site.webmanifest">
    
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/login.css?v=<?php echo time(); ?>">
</head>
<body>
    <div class="login-wrapper">
        <div class="login-container">
            <!-- Left Side - Branding -->
            <div class="login-left">
                <div class="brand-section">
                    <div class="logo">
                        <img src="assets/logo.svg" alt="OIS Logo" class="logo-image">
                        <h1>OIS Admin</h1>
                        <p>Operator Information System</p>
                    </div>
                    <div class="welcome-text">
                        <h2>Welcome Back!</h2>
                        <p>Please sign in to access the admin panel and manage operator information efficiently.</p>
                    </div>
                    <div class="features">
                        <div class="feature-item">
                            <i class="fas fa-users"></i>
                            <span>Manage Operators</span>
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-chart-bar"></i>
                            <span>View Analytics</span>
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-cog"></i>
                            <span>System Settings</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Right Side - Login Form -->
            <div class="login-right">
                <div class="login-form-container">
                    <div class="form-header">
                        <h2><i class="fas fa-lock"></i> Admin Login</h2>
                        <p>Enter your credentials to continue</p>
                    </div>
                    
                    <form id="login-form" class="login-form">
                        <div id="login-alert" class="alert" style="display: none;"></div>
                        
                        <div class="form-group">
                            <label for="username">
                                <i class="fas fa-user"></i> Username
                            </label>
                            <input type="text" id="username" name="username" required autocomplete="username" placeholder="Enter your username">
                        </div>
                        
                        <div class="form-group">
                            <label for="password">
                                <i class="fas fa-lock"></i> Password
                            </label>
                            <div class="password-input">
                                <input type="password" id="password" name="password" required autocomplete="current-password" placeholder="Enter your password">
                                <button type="button" class="password-toggle" onclick="togglePassword()">
                                    <i class="fas fa-eye" id="password-eye"></i>
                                </button>
                            </div>
                        </div>
                        
                        <div class="form-options">
                            <label class="checkbox-label">
                                <input type="checkbox" id="remember_me" name="remember_me">
                                <span class="checkmark"></span>
                                Remember me
                            </label>
                        </div>
                        
                        <button type="submit" class="login-btn">
                            <i class="fas fa-sign-in-alt"></i> Login to Dashboard
                            <div class="login-spinner" style="display: none;">
                                <i class="fas fa-spinner fa-spin"></i>
                            </div>
                        </button>
                    </form>
                    
                    <div class="login-footer">
                        <div class="back-link">
                            <a href="index.php"><i class="fas fa-home"></i> Back to Main Site</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <footer class="login-page-footer">
        <p>&copy; <?php echo date('Y'); ?> Operator Information System. All rights reserved.</p>
        <p class="build-credit">OIS Build by Cpl Noor Mohammad Palash, EB</p>
    </footer>
    
    <script src="js/login.js?v=<?php echo time(); ?>"></script>
</body>
</html>
