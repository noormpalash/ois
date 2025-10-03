<?php
session_start();

// Check for remember me cookie if not logged in via session
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

// Check if user is logged in
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header('Location: login.php');
    exit();
}

// Get user info for display
$admin_username = $_SESSION['admin_username'] ?? 'Admin';
$admin_full_name = $_SESSION['admin_full_name'] ?? 'Administrator';
$admin_role = $_SESSION['admin_role'] ?? 'admin';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Operator Information System</title>
    
    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="assets/favicon/favicon.svg">
    <link rel="icon" type="image/x-icon" href="assets/favicon/favicon.ico">
    <link rel="apple-touch-icon" href="assets/favicon/apple-touch-icon.svg">
    <link rel="manifest" href="assets/favicon/site.webmanifest">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/admin.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/print.css?v=<?php echo time(); ?>" media="print">
</head>
<body>
    <div class="container">
        <header class="header">
            <div class="header-content">
                <div class="header-text">
                    <h1><img src="assets/logo.svg" alt="OIS Logo" class="header-logo"> Operator Information System <span class="admin-panel-badge">Admin Panel</span></h1>
                </div>
                <div class="header-actions">
                    <div class="user-info">
                        <span class="user-name">
                            <i class="fas fa-user"></i> <?php echo htmlspecialchars($admin_full_name); ?>
                            <?php if ($admin_role === 'super_admin'): ?>
                                <span class="role-badge">Super Admin</span>
                            <?php elseif ($admin_role === 'add_op'): ?>
                                <span class="role-badge add-op-badge">Add OP</span>
                            <?php else: ?>
                                <span class="role-badge admin-badge">Admin</span>
                            <?php endif; ?>
                        </span>
                    </div>
                    <div class="header-buttons">
                        <a href="index.php" class="home-btn">
                            <i class="fas fa-home"></i> Home
                        </a>
                        <button onclick="logout()" class="logout-btn">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </button>
                    </div>
                </div>
            </div>
        </header>

        <nav class="nav-tabs">
            <button class="nav-tab active" onclick="showTab('add')">➕ Add Operator</button>
            <?php if ($admin_role !== 'add_op'): ?>
            <button class="nav-tab" onclick="showTab('manage')">👥 Manage</button>
            <button class="nav-tab" onclick="showTab('bulk-upload')">📤 Bulk Upload</button>
            <button class="nav-tab" onclick="showTab('analytics')">📊 Analytics</button>
            <button class="nav-tab" onclick="showTab('dashboard')">⚙️ Settings</button>
            <button class="nav-tab" onclick="showTab('backup')">💾 Backup/Restore</button>
            <?php endif; ?>
            <?php if ($admin_role === 'super_admin'): ?>
            <button class="nav-tab" onclick="showTab('admin-users')">👤 Admin Users</button>
            <?php endif; ?>
        </nav>

        <div id="add" class="tab-content active">
            <div id="alert"></div>
            <form id="operator-form">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="personal_no">Personal No *</label>
                        <input type="text" id="personal_no" name="personal_no" autocomplete="off" required>
                    </div>
                    <div class="form-group">
                        <label for="rank">Rank *</label>
                        <select name="rank" id="rank" autocomplete="organization-title" required>
                            <option value="">Select Rank...</option>
                            <!-- Ranks will be populated dynamically by JavaScript -->
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="name">Name *</label>
                        <input type="text" id="name" name="name" autocomplete="name" required>
                    </div>
                    <div class="form-group">
                        <label for="cores">Corps</label>
                        <select name="cores_id" id="cores" autocomplete="off"></select>
                    </div>
                    <div class="form-group">
                        <label for="units">Unit</label>
                        <select name="unit_id" id="units" autocomplete="off"></select>
                    </div>
                    <div class="form-group">
                        <label for="course_cadre_name">OP Qualifying Course/Cader</label>
                        <input type="text" id="course_cadre_name" name="course_cadre_name" autocomplete="off">
                    </div>
                    <div class="form-group">
                        <label for="formations">Formation</label>
                        <select name="formation_id" id="formations" autocomplete="off"></select>
                    </div>
                    <div class="form-group">
                        <label>Special Notes</label>
                        <div id="special-notes" class="checkbox-group">
                            <!-- Special notes checkboxes will be populated by JavaScript -->
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Exercises</label>
                        <div id="exercises" class="checkbox-group">
                            <!-- Exercise checkboxes will be populated by JavaScript -->
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="med-categories">Med Category</label>
                        <select name="med_category_id" id="med-categories" autocomplete="off"></select>
                    </div>
                    <div class="form-group">
                        <label for="mobile_personal">Mobile (Personal)</label>
                        <input type="tel" id="mobile_personal" name="mobile_personal" autocomplete="tel">
                    </div>
                    <div class="form-group">
                        <label for="mobile_family">Mobile (Family)</label>
                        <input type="tel" id="mobile_family" name="mobile_family" autocomplete="tel">
                    </div>
                    <div class="form-group">
                        <label for="birth_date">Birth Date</label>
                        <input type="date" id="birth_date" name="birth_date" autocomplete="bday">
                    </div>
                    <div class="form-group">
                        <label for="admission_date">Admission Date</label>
                        <input type="date" id="admission_date" name="admission_date" autocomplete="off">
                    </div>
                    <div class="form-group">
                        <label for="joining_date_awgc">Joining Date AWGC</label>
                        <input type="date" id="joining_date_awgc" name="joining_date_awgc" autocomplete="off">
                    </div>
                    <div class="form-group">
                        <label for="worked_in_awgc">Worked in AWGC</label>
                        <textarea id="worked_in_awgc" name="worked_in_awgc" rows="3" autocomplete="off"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="civil_edu">Civil Education</label>
                        <input type="text" id="civil_edu" name="civil_edu" autocomplete="off">
                    </div>
                    <div class="form-group">
                        <label for="course">Course</label>
                        <textarea id="course" name="course" rows="3" autocomplete="off"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="cadre">Cadre</label>
                        <textarea id="cadre" name="cadre" rows="3" autocomplete="off"></textarea>
                    </div>
                </div>
                
                <div class="form-grid-2">
                    <div class="form-group">
                        <label for="permanent_address">Permanent Address</label>
                        <textarea id="permanent_address" name="permanent_address" rows="3" autocomplete="street-address"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="present_address">Present Address</label>
                        <textarea id="present_address" name="present_address" rows="3" autocomplete="street-address"></textarea>
                    </div>
                </div>
                
                <div class="form-grid-2">
                    <div class="form-group">
                        <label for="expertise_area">Expertise Area</label>
                        <textarea id="expertise_area" name="expertise_area" rows="3" autocomplete="off"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="punishment">Punishment</label>
                        <textarea id="punishment" name="punishment" rows="3" autocomplete="off"></textarea>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Save Operator
                </button>
                <button type="reset" class="btn btn-secondary">
                    <i class="fas fa-undo"></i> Reset
                </button>
            </form>
        </div>

        <?php if ($admin_role !== 'add_op'): ?>
        <div id="manage" class="tab-content">
            <div class="manage-header">
                <h3><i class="fas fa-users-cog"></i> Operator Management</h3>
            </div>
            
            <div class="search-section">
                <input type="text" id="search-operators" class="search-box" placeholder="Search operators by name, personal no, or rank..." autocomplete="off">
                <button class="btn btn-primary" onclick="handleSearchButton()">
                    <i class="fas fa-search"></i> Search
                </button>
                <div class="admin-export-actions">
                    <button class="field-selection-btn" onclick="openFieldSelectionModal()">
                        <i class="fas fa-columns"></i> Select Fields
                    </button>
                    <div class="export-dropdown">
                        <button class="export-btn" id="admin-export-dropdown-btn">
                            <i class="fas fa-download"></i> Export
                            <i class="fas fa-chevron-down"></i>
                        </button>
                        <div class="export-menu" id="admin-export-menu">
                            <button onclick="exportAdminResults('csv')">
                                <i class="fas fa-file-csv"></i> Export as CSV
                            </button>
                            <button onclick="exportAdminResults('excel')">
                                <i class="fas fa-file-excel"></i> Export as Excel
                            </button>
                            <button onclick="exportAdminResults('pdf')">
                                <i class="fas fa-file-pdf"></i> Export as PDF
                            </button>
                        </div>
                    </div>
                    <button class="print-btn" onclick="printAdminResults()">
                        <i class="fas fa-print"></i> Print
                    </button>
                </div>
            </div>
            
            <!-- Advanced Filters Section -->
            <div class="admin-filters-section">
                <div class="filters-header">
                    <h4><i class="fas fa-filter"></i> Advanced Filters</h4>
                    <button class="toggle-filters-btn" id="toggle-filters-btn" onclick="toggleFilters()">
                        <i class="fas fa-chevron-down"></i> Show Filters
                    </button>
                </div>
                <div class="filters-content" id="filters-content" style="display: none;">
                    <div class="admin-filters-grid">
                        <div class="filter-group">
                            <label for="admin-filter-rank">
                                <i class="fas fa-star"></i> Rank
                            </label>
                            <select id="admin-filter-rank" onchange="applyAdminFilters()">
                                <option value="">All Ranks</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="admin-filter-corps">
                                <i class="fas fa-shield-alt"></i> Corps
                            </label>
                            <select id="admin-filter-corps" onchange="applyAdminFilters()">
                                <option value="">All Corps</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="admin-filter-exercise">
                                <i class="fas fa-dumbbell"></i> Exercise
                            </label>
                            <select id="admin-filter-exercise" onchange="applyAdminFilters()">
                                <option value="">All Exercises</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="admin-filter-special-note">
                                <i class="fas fa-flag"></i> Special Note
                            </label>
                            <select id="admin-filter-special-note" onchange="applyAdminFilters()">
                                <option value="">All Special Notes</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="admin-filter-formation">
                                <i class="fas fa-building"></i> Formation
                            </label>
                            <select id="admin-filter-formation" onchange="applyAdminFilters()">
                                <option value="">All Formations</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="admin-filter-unit">
                                <i class="fas fa-users"></i> Unit
                            </label>
                            <select id="admin-filter-unit" onchange="applyAdminFilters()">
                                <option value="">All Units</option>
                            </select>
                        </div>
                    </div>
                    <div class="filter-actions">
                        <button class="btn btn-secondary" onclick="clearAdminFilters()">
                            <i class="fas fa-times"></i> Clear Filters
                        </button>
                        <div class="filter-summary" id="filter-summary">
                            No filters applied
                        </div>
                    </div>
                </div>
            </div>
            
            <div id="operators-list">
                <div class="loading">Loading operators...</div>
            </div>
        </div>

        <!-- Bulk Upload Tab -->
        <div id="bulk-upload" class="tab-content">
            <div class="bulk-upload-header">
                <h3><i class="fas fa-cloud-upload-alt"></i> Bulk Data Import</h3>
                <p>Import multiple operators efficiently using CSV or Excel files</p>
            </div>
            
            <div class="bulk-upload-content">
                <!-- Instructions Section -->
                <div class="upload-instructions">
                    <h4><i class="fas fa-info-circle"></i> Instructions</h4>
                    <ol>
                        <li>Download the CSV or Excel template below</li>
                        <li>Fill in your operator data following the format</li>
                        <li>Save as CSV or Excel file and upload it here</li>
                        <li>Review the preview and confirm upload</li>
                    </ol>
                    
                    <div class="template-download">
                        <button class="btn btn-secondary" onclick="downloadTemplate('csv')">
                            <i class="fas fa-file-csv"></i> Download CSV Template
                        </button>
                        <button class="btn btn-success" onclick="downloadTemplate('xlsx')">
                            <i class="fas fa-file-excel"></i> Download Excel Template
                        </button>
                        <button class="btn btn-info" onclick="showSampleData()">
                            <i class="fas fa-eye"></i> View Sample Data
                        </button>
                    </div>
                </div>
                
                <!-- Upload Section -->
                <div class="upload-section">
                    <h4><i class="fas fa-cloud-upload-alt"></i> Upload File</h4>
                    
                    <div class="file-upload-area" id="file-upload-area">
                        <div class="upload-placeholder">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <p>Drag and drop your CSV or Excel file here or click to browse</p>
                            <input type="file" id="bulk-file-input" accept=".csv,.xlsx,.xls" style="display: none;">
                            <button class="btn btn-primary" id="choose-file-btn">
                                <i class="fas fa-folder-open"></i> Choose File
                            </button>
                        </div>
                    </div>
                    
                    <div class="file-info" id="file-info" style="display: none;">
                        <div class="file-details">
                            <i class="fas fa-file-csv"></i>
                            <span id="file-name"></span>
                            <span id="file-size"></span>
                            <button class="btn btn-sm btn-danger" onclick="clearFile()">
                                <i class="fas fa-times"></i> Remove
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Preview Section -->
                <div class="preview-section" id="preview-section" style="display: none;">
                    <h4><i class="fas fa-table"></i> Data Preview</h4>
                    <div class="preview-stats" id="preview-stats"></div>
                    <div class="preview-table-container">
                        <table class="preview-table" id="preview-table">
                            <thead id="preview-thead"></thead>
                            <tbody id="preview-tbody"></tbody>
                        </table>
                    </div>
                    
                    <div class="preview-actions">
                        <button class="btn btn-success" onclick="processBulkUpload()" id="upload-btn">
                            <i class="fas fa-check"></i> Upload All Data
                        </button>
                        <button class="btn btn-secondary" onclick="clearPreview()">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                    </div>
                </div>
                
                <!-- Results Section -->
                <div class="upload-results" id="upload-results" style="display: none;">
                    <h4><i class="fas fa-chart-pie"></i> Upload Results</h4>
                    <div class="results-summary" id="results-summary"></div>
                    <div class="results-details" id="results-details"></div>
                </div>
            </div>
        </div>

        <!-- Analytics Tab -->
        <div id="analytics" class="tab-content">
            <!-- Modern Analytics Header -->
            <div class="modern-analytics-header">
                <div class="header-content">
                    <div class="header-text">
                        <h2><i class="fas fa-chart-line"></i> Analytics Dashboard</h2>
                        <p>Real-time insights and comprehensive data visualization</p>
                    </div>
                    <div class="header-stats">
                        <div class="quick-stat">
                            <div class="stat-icon">
                                <i class="fas fa-users"></i>
                            </div>
                            <div class="stat-content">
                                <span class="stat-value" id="quick-total-operators">-</span>
                                <span class="stat-label">Total Operators</span>
                            </div>
                        </div>
                        <div class="quick-stat">
                            <div class="stat-icon">
                                <i class="fas fa-user-tie"></i>
                            </div>
                            <div class="stat-content">
                                <span class="stat-value" id="quick-trg-nco">-</span>
                                <span class="stat-label">Trg NCO</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Modern Report Controls -->
            <div class="modern-report-controls">
                <div class="controls-container">
                    <div class="control-section">
                        <div class="modern-control-group">
                            <label for="report-type">
                                <i class="fas fa-chart-bar"></i>
                                Report Type
                            </label>
                            <select id="report-type" onchange="loadReport()" class="modern-select">
                                <option value="overview">📊 Overview Summary</option>
                                <option value="rank-distribution">🎖️ Rank Distribution</option>
                                <option value="formation-analysis">🏢 Formation Analysis</option>
                                <option value="unit-breakdown">🛡️ Unit Breakdown</option>
                                <option value="exercise-participation">🎯 Exercise Participation</option>
                                <option value="medical-categories">🏥 Medical Categories</option>
                                <option value="age-demographics">👥 Age Demographics</option>
                                <option value="service-length">⏱️ Service Length Analysis</option>
                            </select>
                        </div>
                        
                        <div class="modern-control-group">
                            <label for="date-filter">
                                <i class="fas fa-calendar-alt"></i>
                                Date Range
                            </label>
                            <select id="date-filter" onchange="loadReport()" class="modern-select">
                                <option value="all">🌐 All Time</option>
                                <option value="last-30">📅 Last 30 Days</option>
                                <option value="last-90">📆 Last 90 Days</option>
                                <option value="last-year">🗓️ Last Year</option>
                                <option value="current-year">📊 Current Year</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="action-buttons">
                        <div class="export-dropdown">
                            <button class="export-btn" id="analytics-export-dropdown-btn">
                                <i class="fas fa-download"></i> Export
                                <i class="fas fa-chevron-down"></i>
                            </button>
                            <div class="export-menu" id="analytics-export-menu">
                                <button onclick="exportReport('csv')">
                                    <i class="fas fa-file-csv"></i> Export as CSV
                                </button>
                                <button onclick="exportReport('excel')">
                                    <i class="fas fa-file-excel"></i> Export as Excel
                                </button>
                                <button onclick="exportReport('pdf')">
                                    <i class="fas fa-file-pdf"></i> Export as PDF
                                </button>
                            </div>
                        </div>
                        <button class="modern-btn refresh-btn" onclick="loadReport()">
                            <i class="fas fa-sync-alt"></i>
                            <span>Refresh</span>
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Modern Report Content -->
            <div class="modern-report-content">
                <!-- Enhanced Summary Cards -->
                <div class="modern-summary-section">
                    <div class="section-header">
                        <h3><i class="fas fa-tachometer-alt"></i> Key Metrics</h3>
                        <div class="section-actions">
                            <button class="mini-btn" onclick="loadAnalyticsSummary()">
                                <i class="fas fa-refresh"></i>
                            </button>
                        </div>
                    </div>
                    <div class="modern-summary-cards" id="summary-cards">
                        <div class="modern-summary-card" data-metric="operators">
                            <div class="card-background"></div>
                            <div class="card-icon">
                                <i class="fas fa-users"></i>
                            </div>
                            <div class="card-content">
                                <h4 id="total-operators">-</h4>
                                <p>Total Operators</p>
                                <div class="card-trend">
                                    <i class="fas fa-user-check"></i>
                                    <span>Active Personnel</span>
                                </div>
                            </div>
                        </div>
                        <div class="modern-summary-card" data-metric="formations">
                            <div class="card-background"></div>
                            <div class="card-icon">
                                <i class="fas fa-sitemap"></i>
                            </div>
                            <div class="card-content">
                                <h4 id="total-formations">-</h4>
                                <p>Formations</p>
                                <div class="card-trend">
                                    <i class="fas fa-network-wired"></i>
                                    <span>Organized</span>
                                </div>
                            </div>
                        </div>
                        <div class="modern-summary-card" data-metric="units">
                            <div class="card-background"></div>
                            <div class="card-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <div class="card-content">
                                <h4 id="total-units">-</h4>
                                <p>Units</p>
                                <div class="card-trend">
                                    <i class="fas fa-users-cog"></i>
                                    <span>Operational</span>
                                </div>
                            </div>
                        </div>
                        <div class="modern-summary-card" data-metric="exercises">
                            <div class="card-background"></div>
                            <div class="card-icon">
                                <i class="fas fa-desktop"></i>
                            </div>
                            <div class="card-content">
                                <h4 id="total-exercises">-</h4>
                                <p>Exercises</p>
                                <div class="card-trend">
                                    <i class="fas fa-play-circle"></i>
                                    <span>Available</span>
                                </div>
                            </div>
                        </div>
                        <!-- Dynamic special notes cards will be inserted here by JavaScript -->
                    </div>
                </div>
                
                <!-- Corps Distribution Section -->
                <div class="modern-summary-section">
                    <div class="section-header">
                        <h3><i class="fas fa-shield-alt"></i> Corps Distribution</h3>
                        <div class="section-actions">
                            <button class="mini-btn" onclick="loadCorpsMetrics()">
                                <i class="fas fa-refresh"></i>
                            </button>
                        </div>
                    </div>
                    <div class="corps-metrics-cards" id="corps-cards">
                        <!-- Corps cards will be populated by JavaScript -->
                        <div class="loading-corps">
                            <i class="fas fa-spinner fa-spin"></i>
                            <span>Loading corps data...</span>
                        </div>
                    </div>
                </div>
                
                <!-- Enhanced Charts Section -->
                <div class="modern-charts-section">
                    <div class="section-header">
                        <h3><i class="fas fa-chart-area"></i> Data Visualization</h3>
                        <div class="chart-controls">
                            <button class="chart-toggle active" data-view="dual">
                                <i class="fas fa-columns"></i> Dual View
                            </button>
                            <button class="chart-toggle" data-view="single">
                                <i class="fas fa-expand"></i> Single View
                            </button>
                        </div>
                    </div>
                    <div class="charts-grid" id="charts-grid">
                        <div class="modern-chart-container primary-chart">
                            <div class="chart-header">
                                <h4 id="chart-title">Report Data</h4>
                                <div class="chart-actions">
                                    <button class="chart-btn" onclick="downloadChart('main')">
                                        <i class="fas fa-download"></i>
                                    </button>
                                    <button class="chart-btn" onclick="fullscreenChart('main')">
                                        <i class="fas fa-expand"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="chart-content">
                                <canvas id="main-chart"></canvas>
                                <div class="chart-loading">
                                    <i class="fas fa-spinner fa-spin"></i>
                                    <span>Loading chart data...</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="modern-chart-container secondary-chart">
                            <div class="chart-header">
                                <h4 id="secondary-chart-title">Additional Analysis</h4>
                                <div class="chart-actions">
                                    <button class="chart-btn" onclick="downloadChart('secondary')">
                                        <i class="fas fa-download"></i>
                                    </button>
                                    <button class="chart-btn" onclick="fullscreenChart('secondary')">
                                        <i class="fas fa-expand"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="chart-content">
                                <canvas id="secondary-chart"></canvas>
                                <div class="chart-loading">
                                    <i class="fas fa-spinner fa-spin"></i>
                                    <span>Loading additional data...</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Enhanced Data Table -->
                <div class="modern-data-section">
                    <div class="section-header">
                        <h3><i class="fas fa-table"></i> Detailed Data</h3>
                        <div class="table-controls">
                            <div class="search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" id="table-search" placeholder="Search data..." onkeyup="filterReportTable()">
                            </div>
                            <button class="table-btn" onclick="exportTableData()">
                                <i class="fas fa-file-csv"></i> Export CSV
                            </button>
                        </div>
                    </div>
                    <div class="modern-table-container">
                        <table class="modern-report-table" id="report-table">
                            <thead id="report-table-head">
                                <tr><th>Loading...</th></tr>
                            </thead>
                            <tbody id="report-table-body">
                                <tr><td class="loading-cell">
                                    <i class="fas fa-spinner fa-spin"></i>
                                    Loading report data...
                                </td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div id="dashboard" class="tab-content">
            <div class="dashboard-header">
                <h3><i class="fas fa-cogs"></i> System Settings</h3>
                <p>Configure dropdown options and system preferences</p>
            </div>
            
            <div class="dashboard-grid">
                <!-- Formations Management -->
                <div class="option-card">
                    <div class="option-header">
                        <h4><i class="fas fa-building"></i> Formations</h4>
                        <button class="btn btn-primary btn-sm" onclick="addNewOption('formations')">
                            <i class="fas fa-plus"></i> Add New
                        </button>
                    </div>
                    <div class="option-list" id="formations-list">
                        <div class="loading">Loading...</div>
                    </div>
                </div>

                <!-- Corps Management -->
                <div class="option-card">
                    <div class="option-header">
                        <h4><i class="fas fa-shield-alt"></i> Corps</h4>
                        <button class="btn btn-primary btn-sm" onclick="addNewOption('cores')">
                            <i class="fas fa-plus"></i> Add New
                        </button>
                    </div>
                    <div class="option-list" id="cores-list">
                        <div class="loading">Loading...</div>
                    </div>
                </div>

                <!-- Med Categories Management -->
                <div class="option-card">
                    <div class="option-header">
                        <h4><i class="fas fa-heartbeat"></i> Medical</h4>
                        <button class="btn btn-primary btn-sm" onclick="addNewOption('med_categories')">
                            <i class="fas fa-plus"></i> Add New
                        </button>
                    </div>
                    <div class="option-list" id="med_categories-list">
                        <div class="loading">Loading...</div>
                    </div>
                </div>

                <!-- Units Management -->
                <div class="option-card">
                    <div class="option-header">
                        <h4><i class="fas fa-users"></i> Units</h4>
                        <button class="btn btn-primary btn-sm" onclick="addNewOption('units')">
                            <i class="fas fa-plus"></i> Add New
                        </button>
                    </div>
                    <div class="option-list" id="units-list">
                        <div class="loading">Loading...</div>
                    </div>
                </div>

                <!-- Exercises Management -->
                <div class="option-card">
                    <div class="option-header">
                        <h4><i class="fas fa-desktop"></i> Exercises</h4>
                        <button class="btn btn-primary btn-sm" onclick="addNewOption('exercises')">
                            <i class="fas fa-plus"></i> Add New
                        </button>
                    </div>
                    <div class="option-list" id="exercises-list">
                        <div class="loading">Loading...</div>
                    </div>
                </div>

                <!-- Ranks Management -->
                <div class="option-card">
                    <div class="option-header">
                        <h4><i class="fas fa-star"></i> Ranks</h4>
                        <button class="btn btn-primary btn-sm" onclick="addNewOption('ranks')">
                            <i class="fas fa-plus"></i> Add New
                        </button>
                    </div>
                    <div class="option-list" id="ranks-list">
                        <div class="loading">Loading...</div>
                    </div>
                </div>

                <!-- Special Notes Management -->
                <div class="option-card">
                    <div class="option-header">
                        <h4><i class="fas fa-flag"></i> Special Notes</h4>
                        <button class="btn btn-primary btn-sm" onclick="addNewOption('special_notes')">
                            <i class="fas fa-plus"></i> Add New
                        </button>
                    </div>
                    <div class="option-list" id="special_notes-list">
                        <div class="loading">Loading...</div>
                    </div>
                </div>
                
                <!-- Animation Controls Section -->
                <div class="option-card animation-controls-card">
                    <div class="option-header">
                        <h4><i class="fas fa-magic"></i> Animation Controls</h4>
                        <div class="animation-controls-actions">
                            <button id="save-animation-settings" class="btn btn-primary btn-sm" onclick="saveAnimationSettings()">
                                <i class="fas fa-save"></i> Save Settings
                            </button>
                            <button id="reset-animation-settings" class="btn btn-secondary btn-sm" onclick="resetAnimationSettings()">
                                <i class="fas fa-undo"></i> Reset
                            </button>
                        </div>
                    </div>
                    <div class="option-list">
                        <div class="animation-controls-grid">
                            <div class="animation-control-item">
                                <div class="control-info">
                                    <div class="control-title">
                                        <i class="fas fa-star"></i> Hero Section Animations
                                    </div>
                                    <div class="control-description">Logo rotation, gradient effects, and hero animations</div>
                                </div>
                                <div class="control-toggle">
                                    <label class="toggle-switch">
                                        <input type="checkbox" id="hero-animations-toggle" data-setting="hero_animations">
                                        <span class="toggle-slider"></span>
                                    </label>
                                    <span class="toggle-status" id="hero-animations-status">Loading...</span>
                                </div>
                            </div>
                            
                            <div class="animation-control-item">
                                <div class="control-info">
                                    <div class="control-title">
                                        <i class="fas fa-helicopter"></i> Military Drone Animation
                                    </div>
                                    <div class="control-description">Flying drone, scanning effects, and operator info display</div>
                                </div>
                                <div class="control-toggle">
                                    <label class="toggle-switch">
                                        <input type="checkbox" id="drone-animations-toggle" data-setting="drone_animations">
                                        <span class="toggle-slider"></span>
                                    </label>
                                    <span class="toggle-status" id="drone-animations-status">Loading...</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php endif; ?>

        <!-- Admin Users Tab (Only for Super Admin) -->
        <?php if ($admin_role === 'super_admin'): ?>
        <div id="admin-users" class="tab-content">
            <div class="admin-users-header">
                <h3><i class="fas fa-user-shield"></i> Administrator Management</h3>
                <p>Manage admin accounts, roles, and system permissions</p>
                <div class="admin-header-buttons">
                    <button class="btn btn-primary" onclick="showAddAdminModal()">
                        <i class="fas fa-user-plus"></i> Add New Admin
                    </button>
                    <button class="btn btn-secondary" onclick="showLoginLogsModal()">
                        <i class="fas fa-history"></i> View Login Logs
                    </button>
                </div>
            </div>
            
            <div class="admin-users-content">
                <div class="admin-users-table-container">
                    <table class="admin-users-table" id="admin-users-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Username</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Last Login</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="admin-users-tbody">
                            <tr>
                                <td colspan="8" class="loading">Loading admin users...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <?php endif; ?>

        <!-- Backup/Restore Tab (Admin and Super Admin only) -->
        <?php if ($admin_role !== 'add_op'): ?>
        <div id="backup" class="tab-content">
            <div class="backup-header">
                <h3><i class="fas fa-database"></i> Database Backup & Restore</h3>
                <p>Create backups of your operator database and restore from previous backups</p>
            </div>

            <div class="backup-restore-container">
                <!-- Backup Section -->
                <div class="backup-section">
                    <div class="section-header">
                        <h4><i class="fas fa-download"></i> Create Backup</h4>
                        <p>Generate a complete backup of your operator database</p>
                    </div>
                    
                    <div class="backup-actions">
                        <button id="create-backup-btn" class="btn btn-primary" onclick="createBackup()">
                            <i class="fas fa-database"></i> Create New Backup
                        </button>
                        <div class="backup-info">
                            <small><i class="fas fa-info-circle"></i> Backup includes all operators, admin users, and system settings</small>
                        </div>
                    </div>
                </div>

                <!-- Existing Backups Section -->
                <div class="existing-backups-section">
                    <div class="section-header">
                        <h4><i class="fas fa-archive"></i> Existing Backups</h4>
                        <div class="section-actions">
                            <button class="btn btn-secondary btn-sm" onclick="refreshBackupList()">
                                <i class="fas fa-sync-alt"></i> Refresh
                            </button>
                        </div>
                    </div>
                    
                    <div id="backup-list-container">
                        <div class="loading-backups">
                            <div class="spinner"></div>
                            <p>Loading backups...</p>
                        </div>
                    </div>
                </div>

                <!-- Restore Section -->
                <div class="restore-section">
                    <div class="section-header">
                        <h4><i class="fas fa-upload"></i> Restore from Backup</h4>
                        <p>Upload and restore a backup file</p>
                    </div>
                    
                    <div class="restore-actions">
                        <div class="file-upload-area" id="backup-upload-area">
                            <div class="upload-content">
                                <i class="fas fa-cloud-upload-alt"></i>
                                <p>Drop your backup file here or click to browse</p>
                                <input type="file" id="backup-file-input" accept=".sql" style="display: none;">
                                <button class="btn btn-outline" id="choose-backup-file-btn">
                                    <i class="fas fa-folder-open"></i> Choose File
                                </button>
                            </div>
                        </div>
                        
                        <div class="selected-file-info" id="selected-file-info" style="display: none;">
                            <div class="file-details">
                                <i class="fas fa-file-alt"></i>
                                <span id="selected-file-name"></span>
                                <span id="selected-file-size"></span>
                            </div>
                            <button class="btn btn-danger btn-sm" onclick="clearSelectedFile()">
                                <i class="fas fa-times"></i> Remove
                            </button>
                        </div>
                        
                        <div class="restore-controls" id="restore-controls" style="display: none;">
                            <div class="warning-message">
                                <i class="fas fa-exclamation-triangle"></i>
                                <strong>Warning:</strong> Restoring will replace all current data. This action cannot be undone.
                            </div>
                            <div class="restore-buttons">
                                <button class="btn btn-secondary" onclick="clearSelectedFile()">Cancel</button>
                                <button id="restore-backup-btn" class="btn btn-danger" onclick="restoreBackup()">
                                    <i class="fas fa-database"></i> Restore Database
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php endif; ?>
    </div>

    <!-- Operator Detail Modal -->
    <div id="admin-operator-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="admin-modal-title">Operator Details</h2>
                <span class="close-detail" onclick="closeDetailModal()">&times;</span>
            </div>
            <div class="modal-body" id="admin-modal-body">
                <!-- Operator details will be loaded here -->
            </div>
        </div>
    </div>

    <!-- Update Operator Modal -->
    <div id="update-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Update Operator</h2>
                <span class="close-update" onclick="closeUpdateModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="update-form">
                    <input type="hidden" id="update-id" name="id">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="update-personal-no">Personal No *</label>
                            <input type="text" id="update-personal-no" name="personal_no" autocomplete="off" required>
                        </div>
                        <div class="form-group">
                            <label for="update-rank">Rank *</label>
                            <select id="update-rank" name="rank" autocomplete="organization-title" required>
                                <option value="">Select Rank...</option>
                                <!-- Ranks will be populated dynamically by JavaScript -->
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="update-name">Name *</label>
                            <input type="text" id="update-name" name="name" autocomplete="name" required>
                        </div>
                        <div class="form-group">
                            <label for="update-cores">Corps</label>
                            <select id="update-cores" name="cores_id" autocomplete="off"></select>
                        </div>
                        <div class="form-group">
                            <label for="update-units">Unit</label>
                            <select id="update-units" name="unit_id" autocomplete="off"></select>
                        </div>
                        <div class="form-group">
                            <label for="update-formations">Formation</label>
                            <select id="update-formations" name="formation_id" autocomplete="off"></select>
                        </div>
                        <div class="form-group">
                            <label>Special Notes</label>
                            <div id="update-special-notes" class="checkbox-group">
                                <!-- Special notes checkboxes will be populated by JavaScript -->
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Exercises</label>
                            <div id="update-exercises" class="checkbox-group">
                                <!-- Exercise checkboxes will be populated by JavaScript -->
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="update-med_categories">Med Category</label>
                            <select id="update-med_categories" name="med_category_id" autocomplete="off"></select>
                        </div>
                        <div class="form-group">
                            <label for="update-mobile-personal">Mobile (Personal)</label>
                            <input type="tel" id="update-mobile-personal" name="mobile_personal" autocomplete="tel">
                        </div>
                        <div class="form-group">
                            <label for="update-mobile-family">Mobile (Family)</label>
                            <input type="tel" id="update-mobile-family" name="mobile_family" autocomplete="tel">
                        </div>
                        <div class="form-group">
                            <label for="update-course-cadre-name">OP Qualifying Course/Cader</label>
                            <input type="text" id="update-course-cadre-name" name="course_cadre_name" autocomplete="off">
                        </div>
                        <div class="form-group">
                            <label for="update-birth-date">Birth Date</label>
                            <input type="date" id="update-birth-date" name="birth_date" autocomplete="bday">
                        </div>
                        <div class="form-group">
                            <label for="update-admission-date">Admission Date</label>
                            <input type="date" id="update-admission-date" name="admission_date" autocomplete="off">
                        </div>
                        <div class="form-group">
                            <label for="update-joining-date-awgc">Joining Date AWGC</label>
                            <input type="date" id="update-joining-date-awgc" name="joining_date_awgc" autocomplete="off">
                        </div>
                        <div class="form-group">
                            <label for="update-worked-in-awgc">Worked in AWGC</label>
                            <textarea id="update-worked-in-awgc" name="worked_in_awgc" rows="3" autocomplete="off"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="update-civil-edu">Civil Education</label>
                            <input type="text" id="update-civil-edu" name="civil_edu" autocomplete="off">
                        </div>
                        <div class="form-group">
                            <label for="update-course">Course</label>
                            <textarea id="update-course" name="course" rows="3" autocomplete="off"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="update-cadre">Cadre</label>
                            <textarea id="update-cadre" name="cadre" rows="3" autocomplete="off"></textarea>
                        </div>
                    </div>
                    
                    <div class="form-grid-2">
                        <div class="form-group">
                            <label for="update-permanent-address">Permanent Address</label>
                            <textarea id="update-permanent-address" name="permanent_address" rows="3" autocomplete="street-address"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="update-present-address">Present Address</label>
                            <textarea id="update-present-address" name="present_address" rows="3" autocomplete="street-address"></textarea>
                        </div>
                    </div>
                    
                    <div class="form-grid-2">
                        <div class="form-group">
                            <label for="update-expertise-area">Expertise Area</label>
                            <textarea id="update-expertise-area" name="expertise_area" rows="3" autocomplete="off"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="update-punishment">Punishment</label>
                            <textarea id="update-punishment" name="punishment" rows="3" autocomplete="off"></textarea>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeUpdateModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Update Operator
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Notification Popup Modal -->
    <div id="notification-modal" class="notification-modal">
        <div class="notification-modal-content">
            <div class="notification-header">
                <span class="notification-icon"></span>
                <span class="notification-title"></span>
                <span class="notification-close">&times;</span>
            </div>
            <div class="notification-body">
                <p class="notification-message"></p>
            </div>
            <div class="notification-footer">
                <button class="notification-btn-ok">OK</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div id="delete-confirmation-modal" class="notification-modal">
        <div class="notification-modal-content delete-confirmation">
            <div class="notification-header">
                <span class="notification-icon delete-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </span>
                <span class="notification-title">Confirm Deletion</span>
                <span class="notification-close">&times;</span>
            </div>
            <div class="notification-body">
                <p class="notification-message delete-message"></p>
                <div class="delete-warning">
                    <i class="fas fa-info-circle"></i>
                    <span>This action cannot be undone!</span>
                </div>
            </div>
            <div class="notification-footer delete-actions">
                <button class="notification-btn-cancel">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button class="notification-btn-delete">
                    <i class="fas fa-trash-alt"></i> Delete
                </button>
            </div>
        </div>
    </div>

    <!-- Logout Confirmation Modal -->
    <div id="logout-confirmation-modal" class="notification-modal">
        <div class="notification-modal-content logout-confirmation">
            <div class="notification-header">
                <span class="notification-icon logout-icon">
                    <i class="fas fa-sign-out-alt"></i>
                </span>
                <span class="notification-title">Confirm Logout</span>
                <span class="notification-close">&times;</span>
            </div>
            <div class="notification-body">
                <p class="notification-message">Are you sure you want to logout?</p>
                <div class="logout-warning">
                    <i class="fas fa-info-circle"></i>
                    <span>You will need to login again to access the system</span>
                </div>
            </div>
            <div class="notification-footer logout-actions">
                <button class="notification-btn-cancel">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button class="notification-btn-logout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </div>
        </div>
    </div>

    <!-- Option Management Modal -->
    <div id="option-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="option-modal-title">Add New Option</h2>
                <span class="close" onclick="closeOptionModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="option-form">
                    <input type="hidden" id="option-type" name="type">
                    <input type="hidden" id="option-id" name="id">
                    <div class="form-group">
                        <label for="option-name">Name *</label>
                        <input type="text" id="option-name" name="name" required>
                    </div>
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeOptionModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Save Option
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Add Admin User Modal -->
    <div id="add-admin-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add New Admin User</h2>
                <span class="close" onclick="closeAddAdminModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="add-admin-form">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="admin-username">Username *</label>
                            <input type="text" id="admin-username" name="username" required>
                        </div>
                        <div class="form-group">
                            <label for="admin-email">Email *</label>
                            <input type="email" id="admin-email" name="email" required>
                        </div>
                        <div class="form-group">
                            <label for="admin-full-name">Full Name *</label>
                            <input type="text" id="admin-full-name" name="full_name" required>
                        </div>
                        <div class="form-group">
                            <label for="admin-password">Password *</label>
                            <input type="password" id="admin-password" name="password" required>
                        </div>
                        <div class="form-group">
                            <label for="admin-role">Role *</label>
                            <select id="admin-role" name="role" required>
                                <option value="admin">Admin</option>
                                <option value="add_op">Add OP</option>
                                <option value="super_admin">Super Admin</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="admin-status">Status *</label>
                            <select id="admin-status" name="status" required>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeAddAdminModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-user-plus"></i> Create Admin
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Admin User Modal -->
    <div id="edit-admin-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Admin User</h2>
                <span class="close" onclick="closeEditAdminModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="edit-admin-form">
                    <input type="hidden" id="edit-admin-id" name="id">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="edit-admin-username">Username</label>
                            <input type="text" id="edit-admin-username" name="username" readonly>
                        </div>
                        <div class="form-group">
                            <label for="edit-admin-email">Email *</label>
                            <input type="email" id="edit-admin-email" name="email" required>
                        </div>
                        <div class="form-group">
                            <label for="edit-admin-full-name">Full Name *</label>
                            <input type="text" id="edit-admin-full-name" name="full_name" required>
                        </div>
                        <div class="form-group">
                            <label for="edit-admin-role">Role *</label>
                            <select id="edit-admin-role" name="role" required>
                                <option value="admin">Admin</option>
                                <option value="add_op">Add OP</option>
                                <option value="super_admin">Super Admin</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="edit-admin-status">Status *</label>
                            <select id="edit-admin-status" name="status" required>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeEditAdminModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Update Admin
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div id="change-password-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Change Password</h2>
                <span class="close" onclick="closeChangePasswordModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="change-password-form">
                    <input type="hidden" id="change-password-user-id" name="user_id">
                    <div class="form-group">
                        <label for="current-password">Current Password *</label>
                        <input type="password" id="current-password" name="current_password" required>
                    </div>
                    <div class="form-group">
                        <label for="new-password">New Password *</label>
                        <input type="password" id="new-password" name="new_password" required>
                    </div>
                    <div class="form-group">
                        <label for="confirm-password">Confirm New Password *</label>
                        <input type="password" id="confirm-password" name="confirm_password" required>
                    </div>
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeChangePasswordModal()">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-key"></i> Change Password
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Login Logs Modal -->
    <div id="login-logs-modal" class="modal">
        <div class="modal-content" style="max-width: 1200px;">
            <div class="modal-header">
                <h2><i class="fas fa-history"></i> Admin Login Logs</h2>
                <span class="close" onclick="closeLoginLogsModal()">&times;</span>
            </div>
            <div class="modal-body">
                <div class="login-logs-filters">
                    <div class="form-group">
                        <label for="username-filter">Filter by Username:</label>
                        <select id="username-filter" onchange="loadLoginLogs()">
                            <option value="">All Users</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <button class="btn btn-danger btn-sm" onclick="showClearLogsModal()">
                            <i class="fas fa-trash"></i> Clear Logs
                        </button>
                    </div>
                </div>
                <div class="login-logs-container">
                    <table class="login-logs-table" id="login-logs-table">
                        <thead>
                            <tr>
                                <th>Date/Time</th>
                                <th>Username</th>
                                <th>Status</th>
                                <th>IP Address</th>
                                <th>User Agent</th>
                                <th>Details</th>
                            </tr>
                        </thead>
                        <tbody id="login-logs-tbody">
                            <tr>
                                <td colspan="6" class="loading">Loading login logs...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="login-logs-pagination" class="pagination-container">
                    <!-- Pagination will be loaded here -->
                </div>
            </div>
        </div>
    </div>

    <!-- Clear Login Logs Modal -->
    <div id="clear-logs-modal" class="modal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h2><i class="fas fa-exclamation-triangle"></i> Clear Login Logs</h2>
                <span class="close" onclick="closeClearLogsModal()">&times;</span>
            </div>
            <div class="modal-body">
                <div class="warning-message">
                    <i class="fas fa-exclamation-triangle"></i>
                    <strong>Warning:</strong> This action cannot be undone. Please select what you want to clear:
                </div>
                
                <form id="clear-logs-form">
                    <div class="form-group">
                        <label>
                            <input type="radio" name="clear_type" value="all" checked>
                            <strong>Clear All Logs</strong> - Remove all login log entries
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="radio" name="clear_type" value="failed">
                            <strong>Clear Failed Attempts Only</strong> - Remove only failed login attempts
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="radio" name="clear_type" value="older_than">
                            <strong>Clear Logs Older Than:</strong>
                        </label>
                        <div class="days-input-group">
                            <input type="number" id="days-old" name="days_old" min="1" max="365" value="30" style="width: 80px; margin-left: 10px;">
                            <span>days</span>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>
                            <input type="radio" name="clear_type" value="user">
                            <strong>Clear Logs for Specific User:</strong>
                        </label>
                        <select id="clear-username" name="username" style="margin-left: 10px;">
                            <option value="">Select User...</option>
                        </select>
                    </div>
                    
                    <div id="clear-logs-preview" class="preview-section" style="display: none;">
                        <div class="preview-info">
                            <i class="fas fa-info-circle"></i>
                            <span id="preview-text">This will affect X log entries</span>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn btn-secondary" onclick="closeClearLogsModal()">Cancel</button>
                        <button type="button" class="btn btn-info" onclick="previewClearLogs()">
                            <i class="fas fa-eye"></i> Preview
                        </button>
                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-trash"></i> Clear Selected Logs
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-container">
            <p>&copy; <span id="current-year"></span> <i class="fas fa-shield-alt footer-ois-icon"></i> Operator Information System. All rights reserved.</p>
            <a href="index.php" class="admin-link">
                <i class="fas fa-home"></i> Main Site
            </a>
            <p class="build-credit">OIS Build by Cpl Noor Mohammad Palash, EB</p>
        </div>
    </footer>

    <!-- SheetJS library for Excel support -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    
    <!-- Chart.js library for analytics visualizations -->
    <!-- Field Selection Modal -->
    <div id="field-selection-modal" class="modal">
        <div class="modal-content" style="max-width: 800px;">
            <div class="modal-header">
                <h2><i class="fas fa-columns"></i> Select Fields to Export</h2>
                <span class="close" onclick="closeFieldSelectionModal()">&times;</span>
            </div>
            <div class="modal-body">
                <div class="field-selection-content">
                    <div class="field-selection-header">
                        <p>Choose which operator information fields to include in your export:</p>
                        <div class="field-selection-controls">
                            <button class="btn btn-secondary" onclick="selectAllFields()">
                                <i class="fas fa-check-double"></i> Select All
                            </button>
                            <button class="btn btn-secondary" onclick="deselectAllFields()">
                                <i class="fas fa-times"></i> Deselect All
                            </button>
                            <button class="btn btn-info" onclick="selectEssentialFields()">
                                <i class="fas fa-star"></i> Essential Only
                            </button>
                        </div>
                    </div>
                    
                    <div class="field-categories">
                        <!-- Basic Information -->
                        <div class="field-category">
                            <h4><i class="fas fa-user"></i> Basic Information</h4>
                            <div class="field-grid">
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="personal_no" checked>
                                    <span class="checkmark"></span>
                                    Personal Number
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="rank" checked>
                                    <span class="checkmark"></span>
                                    Rank
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="name" checked>
                                    <span class="checkmark"></span>
                                    Name
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="birth_date">
                                    <span class="checkmark"></span>
                                    Birth Date
                                </label>
                            </div>
                        </div>
                        
                        <!-- Contact Information -->
                        <div class="field-category">
                            <h4><i class="fas fa-phone"></i> Contact Information</h4>
                            <div class="field-grid">
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="mobile_personal" checked>
                                    <span class="checkmark"></span>
                                    Mobile (Personal)
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="mobile_family">
                                    <span class="checkmark"></span>
                                    Mobile (Family)
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="permanent_address">
                                    <span class="checkmark"></span>
                                    Permanent Address
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="present_address">
                                    <span class="checkmark"></span>
                                    Present Address
                                </label>
                            </div>
                        </div>
                        
                        <!-- Organizational Details -->
                        <div class="field-category">
                            <h4><i class="fas fa-building"></i> Organizational Details</h4>
                            <div class="field-grid">
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="formation_name">
                                    <span class="checkmark"></span>
                                    Formation
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="cores_name" checked>
                                    <span class="checkmark"></span>
                                    Corps
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="unit_name">
                                    <span class="checkmark"></span>
                                    Unit
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="med_category_name">
                                    <span class="checkmark"></span>
                                    Medical Category
                                </label>
                            </div>
                        </div>
                        
                        <!-- Academic & Professional -->
                        <div class="field-category">
                            <h4><i class="fas fa-graduation-cap"></i> Academic & Professional</h4>
                            <div class="field-grid">
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="course_cadre_name">
                                    <span class="checkmark"></span>
                                    OP Qualifying Course/Cadre
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="civil_edu">
                                    <span class="checkmark"></span>
                                    Civil Education
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="course">
                                    <span class="checkmark"></span>
                                    Course
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="cadre">
                                    <span class="checkmark"></span>
                                    Cadre
                                </label>
                            </div>
                        </div>
                        
                        <!-- Important Dates -->
                        <div class="field-category">
                            <h4><i class="fas fa-calendar"></i> Important Dates</h4>
                            <div class="field-grid">
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="admission_date">
                                    <span class="checkmark"></span>
                                    Admission Date
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="joining_date_awgc">
                                    <span class="checkmark"></span>
                                    Joining Date AWGC
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="created_at">
                                    <span class="checkmark"></span>
                                    Record Created
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="updated_at">
                                    <span class="checkmark"></span>
                                    Last Updated
                                </label>
                            </div>
                        </div>
                        
                        <!-- Experience & Expertise -->
                        <div class="field-category">
                            <h4><i class="fas fa-briefcase"></i> Experience & Expertise</h4>
                            <div class="field-grid">
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="worked_in_awgc">
                                    <span class="checkmark"></span>
                                    Worked in AWGC
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="expertise_area">
                                    <span class="checkmark"></span>
                                    Expertise Area
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="exercises">
                                    <span class="checkmark"></span>
                                    Exercises
                                </label>
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="special_notes">
                                    <span class="checkmark"></span>
                                    Special Notes
                                </label>
                            </div>
                        </div>
                        
                        <!-- Disciplinary Records -->
                        <div class="field-category">
                            <h4><i class="fas fa-exclamation-triangle"></i> Disciplinary Records</h4>
                            <div class="field-grid">
                                <label class="field-checkbox">
                                    <input type="checkbox" name="export_fields" value="punishment">
                                    <span class="checkmark"></span>
                                    Punishment
                                </label>
                            </div>
                        </div>
                    </div>
                    
                    <div class="field-selection-summary">
                        <span id="selected-fields-count">5</span> fields selected for export
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeFieldSelectionModal()">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button class="btn btn-primary" onclick="applyFieldSelection()">
                    <i class="fas fa-check"></i> Apply Selection
                </button>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    
    <script>
        // Set current admin ID and role for JavaScript access
        window.currentAdminId = <?php echo json_encode($admin_id ?? $_SESSION['admin_id'] ?? null); ?>;
        window.currentAdminRole = <?php echo json_encode($admin_role); ?>;
    </script>
    <script src="js/admin.js?v=<?php echo time(); ?>"></script>
</body>
</html>
