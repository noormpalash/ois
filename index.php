<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Operator Information System</title>
    
    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="assets/favicon/favicon.svg">
    <link rel="icon" type="image/x-icon" href="assets/favicon/favicon.ico">
    <link rel="apple-touch-icon" href="assets/favicon/apple-touch-icon.svg">
    <link rel="manifest" href="assets/favicon/site.webmanifest">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/frontend.css?v=<?php echo time(); ?>">
    <link rel="stylesheet" href="css/print.css?v=<?php echo time(); ?>" media="print">
</head>
<body>
    <div class="hero-section">
        <div class="hero-content">
            <div class="hero-header">
                <img src="assets/logo.svg" alt="OIS Logo" class="hero-logo">
                <div class="hero-text">
                    <h1>Operator Information System</h1>
                </div>
            </div>
            
            <div class="search-container">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="search-input" placeholder="Search by name, personal number, or rank...">
                    <button id="search-btn" class="search-btn">Search</button>
                </div>
            </div>
        </div>
        
        <!-- Corps Statistics Section -->
        <div class="stats-section">
            <div class="stats-container">
                <div class="stats-overview">
                    <div class="total-operators-card">
                        <div class="total-card-bg">
                            <div class="total-card-content">
                                <div class="total-icon-wrapper">
                                    <div class="total-icon">
                                        <i class="fas fa-users"></i>
                                    </div>
                                    <div class="total-icon-glow"></div>
                                </div>
                                <div class="total-info">
                                    <div class="total-number" id="total-operators">-</div>
                                    <div class="total-label">Total Operators</div>
                                </div>
                            </div>
                            <div class="total-card-decoration">
                                <div class="decoration-circle"></div>
                                <div class="decoration-circle"></div>
                                <div class="decoration-circle"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="corps-marquee-container">
                        <div id="corps-stats-container" class="corps-stats-marquee">
                            <div class="stats-loading">
                                <div class="spinner"></div>
                                <span>Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Military Patrol Section -->
    <div class="military-patrol-container">
        <div class="patrol-scene">
            <div class="soldier soldier-1" id="soldier1">
                <div class="soldier-body">
                    <div class="helmet"></div>
                    <div class="head"></div>
                    <div class="torso"></div>
                    <div class="arm-left"></div>
                    <div class="arm-right"></div>
                    <div class="rifle rifle-assault" id="rifle1"></div>
                    <div class="leg-left"></div>
                    <div class="leg-right"></div>
                </div>
            </div>
            
            <div class="soldier soldier-2" id="soldier2">
                <div class="soldier-body">
                    <div class="helmet"></div>
                    <div class="head"></div>
                    <div class="torso"></div>
                    <div class="arm-left"></div>
                    <div class="arm-right"></div>
                    <div class="rifle rifle-sniper" id="rifle2"></div>
                    <div class="leg-left"></div>
                    <div class="leg-right"></div>
                </div>
            </div>
            
            <div class="soldier soldier-3" id="soldier3">
                <div class="soldier-body">
                    <div class="helmet"></div>
                    <div class="head"></div>
                    <div class="torso"></div>
                    <div class="arm-left"></div>
                    <div class="arm-right"></div>
                    <div class="rifle rifle-mg" id="rifle3"></div>
                    <div class="leg-left"></div>
                    <div class="leg-right"></div>
                </div>
            </div>
            
            <div class="soldier soldier-4" id="soldier4">
                <div class="soldier-body">
                    <div class="helmet"></div>
                    <div class="head"></div>
                    <div class="torso"></div>
                    <div class="arm-left"></div>
                    <div class="arm-right"></div>
                    <div class="rifle rifle-assault" id="rifle4"></div>
                    <div class="leg-left"></div>
                    <div class="leg-right"></div>
                </div>
            </div>
            
            <!-- Environmental elements -->
            <div class="terrain">
                <div class="grass-patch grass-1"></div>
                <div class="grass-patch grass-2"></div>
                <div class="grass-patch grass-3"></div>
                <div class="rock rock-1"></div>
                <div class="rock rock-2"></div>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="filters-section">
            <h3>Filter Results</h3>
            <div class="filters-grid">
                <select id="filter-formation">
                    <option value="">All Formations</option>
                </select>
                <select id="filter-cores">
                    <option value="">All Corps</option>
                </select>
                <select id="filter-exercise">
                    <option value="">All Exercises</option>
                </select>
                <select id="filter-rank">
                    <option value="">All Ranks</option>
                </select>
                <button id="clear-filters" class="btn btn-secondary">Clear Filters</button>
            </div>
        </div>

        <div class="results-section">
            <div class="results-header">
                <h3 id="results-title">All Operators</h3>
            </div>

            <div id="results-container">
                <div class="loading">
                    <div class="spinner"></div>
                    <p>Loading operators...</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Operator Detail Modal -->
    <div id="operator-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modal-title">Operator Details</h2>
                <span class="close">&times;</span>
            </div>
            <div class="modal-body" id="modal-body">
                <!-- Operator details will be loaded here -->
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-container">
            <p>&copy; <span id="current-year"></span> <i class="fas fa-shield-alt footer-ois-icon"></i> Operator Information System. All rights reserved.</p>
            <a href="admin.php" class="admin-link">
                <i class="fas fa-cog"></i> Admin Panel
            </a>
            <p class="build-credit">OIS Build by Cpl Noor Mohammad Palash, EB</p>
        </div>
    </footer>

    <!-- Floating Admin Panel Button -->
    <div id="floating-admin-btn" class="floating-admin-btn">
        <a href="admin.php" title="Admin Panel">
            <i class="fas fa-cog"></i>
        </a>
    </div>

    <!-- Buzzing OIS Drone -->
    <div class="buzzing-ois-icon">
        <!-- Wave Layers -->
        <div class="drone-wave wave-layer-1"></div>
        <div class="drone-wave wave-layer-2"></div>
        <div class="drone-wave wave-layer-3"></div>
        
        <!-- Scanning Text (Moves with Drone) -->
        <div class="drone-scanning-text">SCANNING...</div>
        
        <!-- Operator Info Display (Moves with Drone) -->
        <div class="operator-info-container">
            <div class="operator-rank"></div>
            <div class="operator-name"></div>
            <div class="operator-unit"></div>
        </div>
        
        <div class="custom-drone" title="OIS Reconnaissance Drone">
            <!-- Drone Body -->
            <div class="drone-body">
                <div class="drone-center"></div>
                <div class="drone-camera"></div>
            </div>
            <!-- Drone Arms -->
            <div class="drone-arm arm-1"></div>
            <div class="drone-arm arm-2"></div>
            <div class="drone-arm arm-3"></div>
            <div class="drone-arm arm-4"></div>
            <!-- Rotors -->
            <div class="rotor rotor-1">
                <div class="rotor-blade blade-1"></div>
                <div class="rotor-blade blade-2"></div>
            </div>
            <div class="rotor rotor-2">
                <div class="rotor-blade blade-1"></div>
                <div class="rotor-blade blade-2"></div>
            </div>
            <div class="rotor rotor-3">
                <div class="rotor-blade blade-1"></div>
                <div class="rotor-blade blade-2"></div>
            </div>
            <div class="rotor rotor-4">
                <div class="rotor-blade blade-1"></div>
                <div class="rotor-blade blade-2"></div>
            </div>
            <!-- LED Lights -->
            <div class="drone-led led-front"></div>
            <div class="drone-led led-back"></div>
            <div class="drone-led led-left"></div>
            <div class="drone-led led-right"></div>
        </div>
    </div>

    <script src="js/frontend.js?v=<?php echo time(); ?>"></script>
</body>
</html>
