# Operator Information System (OIS) - Installation Guide

## Table of Contents
1. [XAMPP Installation](#xampp-installation)
2. [Shared Hosting Installation](#shared-hosting-installation)
3. [Database Setup](#database-setup)
4. [Configuration](#configuration)
5. [First Time Setup](#first-time-setup)
6. [Troubleshooting](#troubleshooting)

---

## XAMPP Installation

### Prerequisites
- XAMPP 8.0+ with PHP 8.0+, MySQL 5.7+, Apache
- Web browser (Chrome, Firefox, Safari, Edge)
- Text editor (optional for configuration)

### Step 1: Download and Setup XAMPP
1. Download XAMPP from [https://www.apachefriends.org/](https://www.apachefriends.org/)
2. Install XAMPP following the installer instructions
3. Start Apache and MySQL services from XAMPP Control Panel

### Step 2: Deploy OIS Files
1. Copy all OIS files to your XAMPP htdocs directory:
   ```
   /Applications/XAMPP/xamppfiles/htdocs/ois/
   ```
   Or on Windows:
   ```
   C:\xampp\htdocs\ois\
   ```

2. Ensure the following directory structure:
   ```
   ois/
   ├── api/
   ├── assets/
   ├── backups/
   ├── css/
   ├── js/
   ├── index.php
   ├── admin.php
   ├── login.php
   └── config.php
   ```

### Step 3: Database Setup
1. Open phpMyAdmin: `http://localhost/phpmyadmin`
2. Create a new database named `ois_database`
3. Import the database structure:
   - Click on `ois_database`
   - Go to "Import" tab
   - Select the provided SQL file (`database_structure.sql`)
   - Click "Go"

### Step 4: Configure Database Connection
1. Open `config.php` in a text editor
2. Update database credentials:
   ```php
   <?php
   $host = 'localhost';
   $dbname = 'ois_database';
   $username = 'root';
   $password = '';  // Usually empty for XAMPP
   ?>
   ```

### Step 5: Set Permissions
1. Ensure the `backups/` directory is writable:
   ```bash
   chmod 755 backups/
   ```

### Step 6: Access the Application
1. Open your browser and navigate to:
   - Public Interface: `http://localhost/ois/`
   - Admin Panel: `http://localhost/ois/admin.php`

---

## Shared Hosting Installation

### Prerequisites
- Shared hosting account with:
  - PHP 7.4+ (8.0+ recommended)
  - MySQL 5.7+ or MariaDB 10.3+
  - At least 100MB storage space
  - File manager or FTP access

### Step 1: Prepare Files
1. Download all OIS files to your local computer
2. Create a ZIP archive of all files for easier upload

### Step 2: Upload Files
**Via File Manager:**
1. Login to your hosting control panel (cPanel, Plesk, etc.)
2. Open File Manager
3. Navigate to `public_html/` or `www/` directory
4. Create a new folder named `ois` (optional - can install in root)
5. Upload and extract all OIS files

**Via FTP:**
1. Use an FTP client (FileZilla, WinSCP, etc.)
2. Connect to your hosting server
3. Navigate to `public_html/` directory
4. Upload all OIS files to desired directory

### Step 3: Database Setup
1. Login to your hosting control panel
2. Find "MySQL Databases" or "Database" section
3. Create a new database (e.g., `yourdomain_ois`)
4. Create a database user with full privileges
5. Note down: database name, username, password, and host

### Step 4: Import Database
1. Open phpMyAdmin from your control panel
2. Select your created database
3. Go to "Import" tab
4. Upload and import the provided SQL file
5. Verify all tables are created successfully

### Step 5: Configure Database Connection
1. Edit `config.php` file:
   ```php
   <?php
   $host = 'localhost';  // Or your hosting provider's DB host
   $dbname = 'yourdomain_ois';  // Your database name
   $username = 'yourdomain_user';  // Your database username
   $password = 'your_secure_password';  // Your database password
   ?>
   ```

### Step 6: Set Directory Permissions
1. Set permissions for the `backups/` directory to 755 or 777
2. Ensure PHP can write to this directory

### Step 7: Test Installation
1. Visit your domain: `https://yourdomain.com/ois/`
2. Check admin access: `https://yourdomain.com/ois/admin.php`

---

## Database Setup

### Required Tables
The system requires the following database tables:
- `operators` - Main operator information
- `formations` - Military formations
- `cores` - Military corps
- `units` - Military units
- `ranks` - Military ranks
- `exercises` - Training exercises
- `special_notes` - Special operator notes
- `med_categories` - Medical categories
- `admin_users` - Admin user accounts
- `animation_settings` - UI animation preferences
- `admin_login_log` - Login audit trail

### Sample Data
The system includes sample data for:
- Default admin user (username: `admin`, password: `admin`)
- Military formations, corps, and units
- Rank structure
- Medical categories
- Special note types

---

## Configuration

### Admin Account Setup
**Default Admin Credentials:**
- Username: `admin`
- Password: `admin`
- **⚠️ IMPORTANT: Change these credentials immediately after installation!**

### Security Configuration
1. **Change Default Passwords:**
   - Login to admin panel
   - Go to Settings → Admin Users
   - Update admin password

2. **File Permissions:**
   - Set `config.php` to 644
   - Set `backups/` directory to 755
   - Ensure sensitive files are not publicly accessible

3. **Database Security:**
   - Use strong database passwords
   - Limit database user privileges
   - Regular database backups

### Optional Configurations
1. **Animation Settings:**
   - Disable animations for better performance
   - Customize UI behavior

2. **Backup Settings:**
   - Configure automatic backup schedules
   - Set backup retention policies

---

## First Time Setup

### Step 1: Login to Admin Panel
1. Navigate to `yourdomain.com/ois/admin.php`
2. Login with default credentials
3. **Immediately change the admin password**

### Step 2: Configure System Settings
1. Go to Settings → Animation Controls
2. Configure UI preferences
3. Set up user roles if needed

### Step 3: Import Initial Data
1. Use Bulk Upload feature to import operator data
2. Or manually add operators through the interface
3. Configure formations, corps, and units as needed

### Step 4: Test Functionality
1. Add a test operator
2. Search and filter functionality
3. Test backup and restore features
4. Verify all modals and forms work correctly

---

## Troubleshooting

### Common Issues

**1. Database Connection Error**
- Check `config.php` credentials
- Verify database server is running
- Confirm database exists and user has privileges

**2. File Permission Errors**
- Set proper permissions on `backups/` directory
- Ensure web server can write to necessary directories

**3. PHP Version Issues**
- Ensure PHP 7.4+ is installed
- Check required PHP extensions are enabled

**4. Missing Features**
- Verify all files were uploaded correctly
- Check browser console for JavaScript errors
- Ensure database tables are properly created

**5. Login Issues**
- Verify admin user exists in database
- Check password hash in database
- Clear browser cache and cookies

### Performance Optimization
1. **Enable PHP OPcache** for better performance
2. **Use HTTPS** for secure connections
3. **Regular database maintenance** and optimization
4. **Monitor server resources** and upgrade if needed

### Support
For technical support or issues:
1. Check server error logs
2. Enable PHP error reporting for debugging
3. Verify all system requirements are met
4. Contact your hosting provider for server-specific issues

---

## Security Best Practices

1. **Regular Updates:**
   - Keep PHP and MySQL updated
   - Monitor for security patches

2. **Access Control:**
   - Use strong passwords
   - Limit admin access
   - Regular password changes

3. **Data Protection:**
   - Regular database backups
   - Secure file permissions
   - Monitor access logs

4. **Network Security:**
   - Use HTTPS/SSL certificates
   - Configure firewall rules
   - Monitor for suspicious activity

---

## Maintenance

### Regular Tasks
1. **Weekly:**
   - Database backups
   - Check system logs
   - Monitor performance

2. **Monthly:**
   - Update passwords
   - Review user access
   - Clean old backup files

3. **Quarterly:**
   - Security audit
   - Performance review
   - System updates

---

*Installation Guide for Operator Information System (OIS)*
*Version 1.0 - Created by Cpl Noor Mohammad Palash, EB*
