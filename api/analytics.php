<?php
session_start();
header('Content-Type: application/json');

// Check if user is logged in
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized access']);
    exit();
}

require_once '../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if (!$db) {
        throw new Exception("Database connection failed");
    }
    
    $action = $_GET['action'] ?? '';
    $reportType = $_GET['type'] ?? 'overview';
    $dateFilter = $_GET['date_filter'] ?? 'all';
    
    switch ($action) {
        case 'summary':
            getSummaryData($db);
            break;
            
        case 'report':
            getReportData($db, $reportType, $dateFilter);
            break;
            
        case 'export':
            $format = $_GET['format'] ?? 'csv';
            exportReport($db, $reportType, $dateFilter, $format);
            break;
            
        default:
            // Handle type-based requests when no action is specified
            if ($reportType === 'corps_distribution') {
                getCorpsDistribution($db);
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

function getSummaryData($db) {
    try {
        // Get total operators
        $totalOperators = $db->query("SELECT COUNT(*) FROM operators")->fetchColumn();
        
        // Get total formations
        $totalFormations = $db->query("SELECT COUNT(*) FROM formations")->fetchColumn();
        
        // Get total units
        $totalUnits = $db->query("SELECT COUNT(*) FROM units")->fetchColumn();
        
        // Get total exercises
        $totalExercises = $db->query("SELECT COUNT(*) FROM exercises")->fetchColumn();
        
        // Get counts for all existing special notes dynamically
        $specialNotesQuery = "SELECT sn.name, COUNT(DISTINCT o.id) as count 
                             FROM special_notes sn 
                             LEFT JOIN operator_special_notes osn ON sn.id = osn.special_note_id 
                             LEFT JOIN operators o ON osn.operator_id = o.id 
                             GROUP BY sn.id, sn.name 
                             ORDER BY sn.name";
        $specialNotesStmt = $db->query($specialNotesQuery);
        $specialNotesData = $specialNotesStmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Get recent additions (last 30 days)
        $recentOperators = $db->query("SELECT COUNT(*) FROM operators WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)")->fetchColumn();
        
        // Get Trg NCO count based on special notes (not ranks)
        // Count operators who have "Trg NCO" or similar special note
        $trgNcoQuery = "SELECT COUNT(DISTINCT o.id) 
                       FROM operators o 
                       INNER JOIN operator_special_notes osn ON o.id = osn.operator_id 
                       INNER JOIN special_notes sn ON osn.special_note_id = sn.id 
                       WHERE sn.name LIKE '%Trg NCO%' OR 
                             sn.name LIKE '%Training NCO%' OR 
                             sn.name LIKE '%TRG NCO%' OR
                             sn.name LIKE '%Trg%NCO%' OR
                             sn.name = 'Trg NCO'";
        $trgNcoCount = $db->query($trgNcoQuery)->fetchColumn();
        
        // Get all special note names for debugging
        $specialNoteNamesQuery = "SELECT DISTINCT name FROM special_notes ORDER BY name";
        $specialNoteNamesStmt = $db->query($specialNoteNamesQuery);
        $allSpecialNoteNames = $specialNoteNamesStmt->fetchAll(PDO::FETCH_COLUMN);
        
        // Build response data
        $responseData = [
            'total_operators' => (int)$totalOperators,
            'total_formations' => (int)$totalFormations,
            'total_units' => (int)$totalUnits,
            'total_exercises' => (int)$totalExercises,
            'recent_operators' => (int)$recentOperators,
            'trg_nco' => (int)$trgNcoCount,
            'special_notes' => $specialNotesData,
            'debug_special_note_names' => $allSpecialNoteNames // For debugging - shows all special note names
        ];
        
        echo json_encode([
            'success' => true,
            'data' => $responseData
        ]);
        
    } catch (Exception $e) {
        throw new Exception("Error getting summary data: " . $e->getMessage());
    }
}


function getReportData($db, $reportType, $dateFilter) {
    try {
        $dateCondition = getDateCondition($dateFilter);
        
        switch ($reportType) {
            case 'overview':
                getOverviewReport($db, $dateCondition);
                break;
                
            case 'rank-distribution':
                getRankDistribution($db, $dateCondition);
                break;
                
            case 'formation-analysis':
                getFormationAnalysis($db, $dateCondition);
                break;
                
            case 'unit-breakdown':
                getUnitBreakdown($db, $dateCondition);
                break;
                
            case 'exercise-participation':
                getExerciseParticipation($db, $dateCondition);
                break;
                
            case 'medical-categories':
                getMedicalCategories($db, $dateCondition);
                break;
                
            case 'age-demographics':
                getAgeDemographics($db, $dateCondition);
                break;
                
            case 'service-length':
                getServiceLength($db, $dateCondition);
                break;
                
            default:
                throw new Exception("Invalid report type");
        }
        
    } catch (Exception $e) {
        throw new Exception("Error generating report: " . $e->getMessage());
    }
}

function getDateCondition($dateFilter) {
    switch ($dateFilter) {
        case 'last-30':
            return "WHERE o.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
        case 'last-90':
            return "WHERE o.created_at >= DATE_SUB(NOW(), INTERVAL 90 DAY)";
        case 'last-year':
            return "WHERE o.created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR)";
        case 'current-year':
            return "WHERE YEAR(o.created_at) = YEAR(NOW())";
        default:
            return "";
    }
}

function getOverviewReport($db, $dateCondition) {
    // Get rank distribution
    $rankQuery = "SELECT o.`rank`, COUNT(*) as count FROM operators o $dateCondition GROUP BY o.`rank` ORDER BY count DESC";
    $rankStmt = $db->query($rankQuery);
    $rankData = $rankStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get formation distribution
    $formationQuery = "SELECT f.name, COUNT(*) as count FROM operators o 
                      LEFT JOIN formations f ON o.formation_id = f.id 
                      $dateCondition GROUP BY f.name ORDER BY count DESC LIMIT 10";
    $formationStmt = $db->query($formationQuery);
    $formationData = $formationStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get recent activity
    $activityQuery = "SELECT DATE(created_at) as date, COUNT(*) as count 
                     FROM operators 
                     WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) 
                     GROUP BY DATE(created_at) 
                     ORDER BY date DESC";
    $activityStmt = $db->query($activityQuery);
    $activityData = $activityStmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'rank_distribution' => $rankData,
            'formation_distribution' => $formationData,
            'recent_activity' => $activityData,
            'chart_type' => 'mixed'
        ]
    ]);
}

function getRankDistribution($db, $dateCondition) {
    $query = "SELECT o.`rank`, COUNT(*) as count, 
              ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM operators o2 $dateCondition)), 2) as percentage
              FROM operators o $dateCondition 
              GROUP BY o.`rank` 
              ORDER BY count DESC";
    
    $stmt = $db->query($query);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'distribution' => $data,
            'chart_type' => 'pie',
            'title' => 'Rank Distribution'
        ]
    ]);
}

function getFormationAnalysis($db, $dateCondition) {
    $query = "SELECT f.name as formation, COUNT(*) as count,
              AVG(DATEDIFF(NOW(), o.birth_date) / 365.25) as avg_age,
              COUNT(DISTINCT o.unit_id) as units_count
              FROM operators o 
              LEFT JOIN formations f ON o.formation_id = f.id 
              $dateCondition
              GROUP BY f.id, f.name 
              ORDER BY count DESC";
    
    $stmt = $db->query($query);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format average age
    foreach ($data as &$row) {
        $row['avg_age'] = round($row['avg_age'], 1);
    }
    
    echo json_encode([
        'success' => true,
        'data' => [
            'formations' => $data,
            'chart_type' => 'bar',
            'title' => 'Formation Analysis'
        ]
    ]);
}

function getUnitBreakdown($db, $dateCondition) {
    $query = "SELECT u.name as unit, f.name as formation, COUNT(*) as count
              FROM operators o 
              LEFT JOIN units u ON o.unit_id = u.id 
              LEFT JOIN formations f ON o.formation_id = f.id 
              $dateCondition
              GROUP BY u.id, u.name, f.name 
              ORDER BY count DESC";
    
    $stmt = $db->query($query);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'units' => $data,
            'chart_type' => 'horizontal-bar',
            'title' => 'Unit Breakdown'
        ]
    ]);
}

function getExerciseParticipation($db, $dateCondition) {
    $query = "SELECT e.name as exercise, COUNT(DISTINCT oe.operator_id) as participants
              FROM exercises e
              LEFT JOIN operator_exercises oe ON e.id = oe.exercise_id
              LEFT JOIN operators o ON oe.operator_id = o.id
              " . str_replace('WHERE', 'WHERE oe.operator_id IS NOT NULL AND', $dateCondition) . "
              GROUP BY e.id, e.name 
              ORDER BY participants DESC";
    
    $stmt = $db->query($query);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'exercises' => $data,
            'chart_type' => 'doughnut',
            'title' => 'Exercise Participation'
        ]
    ]);
}

function getMedicalCategories($db, $dateCondition) {
    $query = "SELECT mc.name as category, COUNT(*) as count
              FROM operators o 
              LEFT JOIN med_categories mc ON o.med_category_id = mc.id 
              $dateCondition
              GROUP BY mc.id, mc.name 
              ORDER BY count DESC";
    
    $stmt = $db->query($query);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'categories' => $data,
            'chart_type' => 'pie',
            'title' => 'Medical Categories Distribution'
        ]
    ]);
}

function getAgeDemographics($db, $dateCondition) {
    $query = "SELECT 
              CASE 
                WHEN DATEDIFF(NOW(), birth_date) / 365.25 < 25 THEN 'Under 25'
                WHEN DATEDIFF(NOW(), birth_date) / 365.25 < 30 THEN '25-29'
                WHEN DATEDIFF(NOW(), birth_date) / 365.25 < 35 THEN '30-34'
                WHEN DATEDIFF(NOW(), birth_date) / 365.25 < 40 THEN '35-39'
                WHEN DATEDIFF(NOW(), birth_date) / 365.25 < 45 THEN '40-44'
                ELSE '45+'
              END as age_group,
              COUNT(*) as count
              FROM operators o 
              WHERE birth_date IS NOT NULL $dateCondition
              GROUP BY age_group 
              ORDER BY age_group";
    
    $stmt = $db->query($query);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'age_groups' => $data,
            'chart_type' => 'bar',
            'title' => 'Age Demographics'
        ]
    ]);
}

function getServiceLength($db, $dateCondition) {
    $query = "SELECT 
              CASE 
                WHEN DATEDIFF(NOW(), joining_date_awgc) / 365.25 < 1 THEN 'Less than 1 year'
                WHEN DATEDIFF(NOW(), joining_date_awgc) / 365.25 < 3 THEN '1-3 years'
                WHEN DATEDIFF(NOW(), joining_date_awgc) / 365.25 < 5 THEN '3-5 years'
                WHEN DATEDIFF(NOW(), joining_date_awgc) / 365.25 < 10 THEN '5-10 years'
                ELSE '10+ years'
              END as service_length,
              COUNT(*) as count
              FROM operators o 
              WHERE joining_date_awgc IS NOT NULL $dateCondition
              GROUP BY service_length 
              ORDER BY service_length";
    
    $stmt = $db->query($query);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'service_lengths' => $data,
            'chart_type' => 'doughnut',
            'title' => 'Service Length Distribution'
        ]
    ]);
}


function exportReport($db, $reportType, $dateFilter, $format = 'csv') {
    // Get the report data first
    ob_start();
    getReportData($db, $reportType, $dateFilter);
    $jsonData = ob_get_clean();
    
    $data = json_decode($jsonData, true);
    
    if (!$data['success']) {
        header('Content-Type: application/json');
        echo json_encode(['error' => true, 'message' => 'Failed to generate report data']);
        return;
    }
    
    $reportData = $data['data'];
    $exportData = [];
    
    // Prepare data based on report type
    switch ($reportType) {
        case 'rank-distribution':
            $exportData[] = ['Rank', 'Count', 'Percentage'];
            foreach ($reportData['distribution'] as $row) {
                $exportData[] = [$row['rank'], $row['count'], $row['percentage'] . '%'];
            }
            $filename = 'rank_distribution_report';
            $title = 'Rank Distribution Report';
            break;
                
        case 'formation-analysis':
            $exportData[] = ['Formation', 'Count', 'Average Age', 'Units Count'];
            foreach ($reportData['formations'] as $row) {
                $exportData[] = [$row['formation'], $row['count'], $row['avg_age'], $row['units_count']];
            }
            $filename = 'formation_analysis_report';
            $title = 'Formation Analysis Report';
            break;
            
        case 'unit-breakdown':
            $exportData[] = ['Unit', 'Formation', 'Corps', 'Count'];
            foreach ($reportData['units'] as $row) {
                $exportData[] = [$row['unit'], $row['formation'], $row['corps'], $row['count']];
            }
            $filename = 'unit_breakdown_report';
            $title = 'Unit Breakdown Report';
            break;
            
        case 'exercise-participation':
            $exportData[] = ['Exercise', 'Participants', 'Percentage'];
            foreach ($reportData['exercises'] as $row) {
                $exportData[] = [$row['exercise'], $row['participants'], $row['percentage'] . '%'];
            }
            $filename = 'exercise_participation_report';
            $title = 'Exercise Participation Report';
            break;
                
        default:
            $exportData[] = ['Report Type', 'Status'];
            $exportData[] = [$reportType, 'Export not available for this report type'];
            $filename = 'unknown_report';
            $title = 'Unknown Report';
    }
    
    // Convert array data to format expected by export functions
    $formattedData = [];
    
    if (empty($exportData)) {
        $formattedData[] = ['message' => 'No data available for export'];
    } else {
        $headers = array_shift($exportData); // Remove and get headers
        
        foreach ($exportData as $row) {
            $formattedRow = [];
            foreach ($headers as $index => $header) {
                $key = strtolower(str_replace([' ', '-'], '_', $header));
                $formattedRow[$key] = isset($row[$index]) ? $row[$index] : '';
            }
            $formattedData[] = $formattedRow;
        }
    }
    
    // Export the data using local functions
    switch ($format) {
        case 'csv':
            exportAsCSV($formattedData, $filename);
            break;
        case 'excel':
            exportAsExcel($formattedData, $filename);
            break;
        case 'pdf':
            exportAsPDF($formattedData, $title);
            break;
        default:
            header('Content-Type: application/json');
            echo json_encode(['error' => true, 'message' => 'Invalid export format']);
    }
}

function getCorpsDistribution($db) {
    try {
        $query = "SELECT c.name, COUNT(o.id) as count 
                  FROM cores c 
                  LEFT JOIN operators o ON c.id = o.cores_id 
                  GROUP BY c.id, c.name 
                  ORDER BY c.name";
        
        $stmt = $db->prepare($query);
        $stmt->execute();
        $corpsData = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Convert count to integer
        foreach ($corpsData as &$corps) {
            $corps['count'] = (int)$corps['count'];
        }
        
        echo json_encode([
            'success' => true,
            'data' => $corpsData,
            'message' => 'Corps distribution data retrieved successfully'
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error retrieving corps distribution: ' . $e->getMessage()
        ]);
    }
}

// Local export functions for analytics (copied from export.php to avoid session conflicts)
function exportAsCSV($data, $filename) {
    if (empty($data)) {
        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="' . $filename . '_' . date('Y-m-d_H-i-s') . '.csv"');
        echo "No data available for export\n";
        return;
    }
    
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="' . $filename . '_' . date('Y-m-d_H-i-s') . '.csv"');
    
    $output = fopen('php://output', 'w');
    
    // Write UTF-8 BOM
    fprintf($output, chr(0xEF).chr(0xBB).chr(0xBF));
    
    // Write headers
    $headers = [];
    foreach (array_keys($data[0]) as $header) {
        $headers[] = ucwords(str_replace('_', ' ', $header));
    }
    fputcsv($output, $headers);
    
    // Write data
    foreach ($data as $row) {
        fputcsv($output, $row);
    }
    
    fclose($output);
}

function exportAsExcel($data, $filename) {
    if (empty($data)) {
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment; filename="' . $filename . '_' . date('Y-m-d_H-i-s') . '.xls"');
        echo "No data available for export";
        return;
    }
    
    // Set proper headers for Excel XML format
    header('Content-Type: application/vnd.ms-excel');
    header('Content-Disposition: attachment; filename="' . $filename . '_' . date('Y-m-d_H-i-s') . '.xls"');
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: 0');
    
    // Create proper Excel XML format
    echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    echo '<?mso-application progid="Excel.Sheet"?>' . "\n";
    echo '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' . "\n";
    echo ' xmlns:o="urn:schemas-microsoft-com:office:office"' . "\n";
    echo ' xmlns:x="urn:schemas-microsoft-com:office:excel"' . "\n";
    echo ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' . "\n";
    echo ' xmlns:html="http://www.w3.org/TR/REC-html40">' . "\n";
    
    echo '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' . "\n";
    echo '<Title>' . htmlspecialchars($filename) . '</Title>' . "\n";
    echo '<Author>Operator Information System</Author>' . "\n";
    echo '<Created>' . date('Y-m-d\TH:i:s\Z') . '</Created>' . "\n";
    echo '</DocumentProperties>' . "\n";
    
    echo '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">' . "\n";
    echo '<WindowHeight>12000</WindowHeight>' . "\n";
    echo '<WindowWidth>15000</WindowWidth>' . "\n";
    echo '<WindowTopX>480</WindowTopX>' . "\n";
    echo '<WindowTopY>60</WindowTopY>' . "\n";
    echo '<ProtectStructure>False</ProtectStructure>' . "\n";
    echo '<ProtectWindows>False</ProtectWindows>' . "\n";
    echo '</ExcelWorkbook>' . "\n";
    
    echo '<Styles>' . "\n";
    echo '<Style ss:ID="Default" ss:Name="Normal">' . "\n";
    echo '<Alignment ss:Vertical="Bottom"/>' . "\n";
    echo '<Borders/>' . "\n";
    echo '<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="10"/>' . "\n";
    echo '<Interior/>' . "\n";
    echo '<NumberFormat/>' . "\n";
    echo '<Protection/>' . "\n";
    echo '</Style>' . "\n";
    echo '<Style ss:ID="Header">' . "\n";
    echo '<Alignment ss:Vertical="Bottom"/>' . "\n";
    echo '<Borders>' . "\n";
    echo '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '</Borders>' . "\n";
    echo '<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="10" ss:Bold="1"/>' . "\n";
    echo '<Interior ss:Color="#E0E0E0" ss:Pattern="Solid"/>' . "\n";
    echo '</Style>' . "\n";
    echo '<Style ss:ID="Data">' . "\n";
    echo '<Alignment ss:Vertical="Bottom"/>' . "\n";
    echo '<Borders>' . "\n";
    echo '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' . "\n";
    echo '</Borders>' . "\n";
    echo '<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="10"/>' . "\n";
    echo '</Style>' . "\n";
    echo '</Styles>' . "\n";
    
    echo '<Worksheet ss:Name="' . htmlspecialchars($filename) . '">' . "\n";
    echo '<Table>' . "\n";
    
    // Write header row
    echo '<Row>' . "\n";
    foreach (array_keys($data[0]) as $header) {
        $displayHeader = ucwords(str_replace('_', ' ', $header));
        echo '<Cell ss:StyleID="Header"><Data ss:Type="String">' . htmlspecialchars($displayHeader) . '</Data></Cell>' . "\n";
    }
    echo '</Row>' . "\n";
    
    // Write data rows
    foreach ($data as $row) {
        echo '<Row>' . "\n";
        foreach ($row as $cell) {
            $cellValue = htmlspecialchars($cell ?? '');
            $dataType = is_numeric($cell) ? 'Number' : 'String';
            echo '<Cell ss:StyleID="Data"><Data ss:Type="' . $dataType . '">' . $cellValue . '</Data></Cell>' . "\n";
        }
        echo '</Row>' . "\n";
    }
    
    echo '</Table>' . "\n";
    echo '</Worksheet>' . "\n";
    echo '</Workbook>' . "\n";
}

function exportAsPDF($data, $title) {
    if (empty($data)) {
        header('Content-Type: text/html; charset=UTF-8');
        echo '<!DOCTYPE html><html><body><h3>No data available for export</h3></body></html>';
        return;
    }
    
    // Output as HTML that can be printed to PDF by the browser
    header('Content-Type: text/html; charset=UTF-8');
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Sat, 26 Jul 1997 05:00:00 GMT');
    
    echo '<!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>' . htmlspecialchars($title) . '</title>
        <style>
            * { box-sizing: border-box; }
            body { 
                font-family: Arial, sans-serif; 
                margin: 0; 
                padding: 20px;
                font-size: 11px;
                line-height: 1.3;
                color: #333;
            }
            .pdf-header {
                text-align: center;
                border-bottom: 2px solid #007bff;
                padding-bottom: 15px;
                margin-bottom: 20px;
            }
            .pdf-header h1 {
                color: #007bff;
                margin: 0;
                font-size: 24px;
            }
            .export-info { 
                font-size: 11px; 
                color: #666; 
                margin-bottom: 20px;
                text-align: center;
            }
            table { 
                width: 100%; 
                border-collapse: collapse; 
                margin-top: 10px;
                font-size: 9px;
            }
            th, td { 
                border: 1px solid #333; 
                padding: 4px 3px; 
                text-align: left;
                vertical-align: top;
                word-wrap: break-word;
            }
            th { 
                background-color: #f0f0f0; 
                font-weight: bold;
                font-size: 8px;
                text-transform: uppercase;
                padding: 5px 3px;
            }
            tr:nth-child(even) { 
                background-color: #f9f9f9; 
            }
            @media print {
                body { margin: 0; padding: 10px; }
                .no-print { display: none !important; }
                table { page-break-inside: auto; }
                tr { page-break-inside: avoid; }
                th { page-break-after: avoid; }
            }
            @page {
                margin: 0.75in;
                size: A4 portrait;
            }
        </style>
    </head>
    <body>
        <div class="pdf-header">
            <h1>' . htmlspecialchars($title) . '</h1>
        </div>
        <div class="export-info">
            Generated on: ' . date('Y-m-d H:i:s') . ' | 
            Total Records: ' . count($data) . '
        </div>';
    
    echo '<table>
            <thead>
                <tr>';
    
    foreach (array_keys($data[0]) as $header) {
        $displayHeader = ucwords(str_replace('_', ' ', $header));
        echo '<th>' . htmlspecialchars($displayHeader) . '</th>';
    }
    
    echo '    </tr>
            </thead>
            <tbody>';
    
    foreach ($data as $row) {
        echo '<tr>';
        foreach ($row as $cell) {
            $cellValue = $cell ?? '';
            // Truncate very long text for A4 portrait PDF display
            if (strlen($cellValue) > 30) {
                $cellValue = substr($cellValue, 0, 27) . '...';
            }
            echo '<td>' . htmlspecialchars($cellValue) . '</td>';
        }
        echo '</tr>';
    }
    
    echo '</tbody>
        </table>';
    
    echo '
        <div class="no-print" style="position: fixed; top: 10px; right: 10px; background: #007bff; color: white; padding: 10px; border-radius: 5px; z-index: 1000;">
            <button onclick="window.print()" style="background: white; color: #007bff; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer;">
                Print to PDF
            </button>
            <button onclick="window.close()" style="background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; margin-left: 5px;">
                Close
            </button>
        </div>
    </body>
    </html>';
}

?>
