// Login page JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('login-form');
    const usernameInput = document.getElementById('username');
    const passwordInput = document.getElementById('password');
    const loginBtn = loginForm.querySelector('.login-btn');
    const loginSpinner = loginForm.querySelector('.login-spinner');
    const alertDiv = document.getElementById('login-alert');
    
    // Focus on username field
    usernameInput.focus();
    
    // Handle form submission
    loginForm.addEventListener('submit', handleLogin);
    
    // Handle Enter key in password field
    passwordInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            handleLogin(e);
        }
    });
    
    // Auto-hide alerts after 5 seconds
    function autoHideAlert() {
        setTimeout(() => {
            if (alertDiv.style.display !== 'none') {
                alertDiv.style.display = 'none';
            }
        }, 5000);
    }
});

function togglePassword() {
    const passwordInput = document.getElementById('password');
    const passwordEye = document.getElementById('password-eye');
    
    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        passwordEye.className = 'fas fa-eye-slash';
    } else {
        passwordInput.type = 'password';
        passwordEye.className = 'fas fa-eye';
    }
}

async function handleLogin(e) {
    e.preventDefault();
    
    const form = e.target;
    const formData = new FormData(form);
    const loginBtn = form.querySelector('.login-btn');
    const loginSpinner = form.querySelector('.login-spinner');
    const alertDiv = document.getElementById('login-alert');
    
    // Show loading state
    loginBtn.disabled = true;
    loginBtn.classList.add('loading');
    loginSpinner.style.display = 'block';
    alertDiv.style.display = 'none';
    
    try {
        const response = await fetch('api/auth.php', {
            method: 'POST',
            body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
            showAlert('success', 'Login successful! Redirecting...', 'fas fa-check-circle');
            
            // Redirect after short delay
            setTimeout(() => {
                window.location.href = 'admin.php';
            }, 1000);
        } else {
            showAlert('error', result.message || 'Login failed. Please try again.', 'fas fa-exclamation-circle');
            
            // Focus back to username if credentials are wrong
            if (result.message && result.message.includes('Invalid')) {
                document.getElementById('username').focus();
                document.getElementById('username').select();
            }
        }
    } catch (error) {
        console.error('Login error:', error);
        showAlert('error', 'Connection error. Please check your internet connection and try again.', 'fas fa-wifi');
    } finally {
        // Hide loading state
        loginBtn.disabled = false;
        loginBtn.classList.remove('loading');
        loginSpinner.style.display = 'none';
    }
}

function showAlert(type, message, icon = '') {
    const alertDiv = document.getElementById('login-alert');
    
    // Set alert class and content
    alertDiv.className = `alert ${type}`;
    alertDiv.innerHTML = `
        ${icon ? `<i class="${icon}"></i>` : ''}
        ${message}
    `;
    
    // Show alert
    alertDiv.style.display = 'flex';
    
    // Auto-hide after 5 seconds for non-error messages
    if (type !== 'error') {
        setTimeout(() => {
            alertDiv.style.display = 'none';
        }, 5000);
    }
    
    // Scroll to top to ensure alert is visible
    alertDiv.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Handle browser back button and session checks
window.addEventListener('pageshow', function(event) {
    // Check if user is already logged in when page is shown
    if (event.persisted) {
        checkLoginStatus();
    }
});

async function checkLoginStatus() {
    try {
        const response = await fetch('api/auth.php?action=check_session');
        const result = await response.json();
        
        if (result.logged_in) {
            window.location.href = 'admin.php';
        }
    } catch (error) {
        // Ignore errors for session check
        console.log('Session check failed:', error);
    }
}

// Prevent form resubmission on page refresh
if (window.history.replaceState) {
    window.history.replaceState(null, null, window.location.href);
}
