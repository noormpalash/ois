<?php
/**
 * Simple XLSX Generator using PHP's ZipArchive
 * Creates proper Office Open XML format files
 */
class XLSXGenerator {
    private $data = [];
    private $styles = [];
    
    public function __construct() {
        // Initialize default styles
        $this->styles = [
            'header' => [
                'font' => ['bold' => true],
                'fill' => ['color' => 'E0E0E0']
            ],
            'instruction' => [
                'font' => ['italic' => true, 'color' => '666666'],
                'fill' => ['color' => 'F8F8F8']
            ]
        ];
    }
    
    public function addRow($data, $style = null) {
        $this->data[] = [
            'data' => $data,
            'style' => $style
        ];
    }
    
    public function generate($filename) {
        $zip = new ZipArchive();
        $tempFile = tempnam(sys_get_temp_dir(), 'xlsx');
        
        if ($zip->open($tempFile, ZipArchive::CREATE) !== TRUE) {
            throw new Exception("Cannot create XLSX file");
        }
        
        // Add required files for XLSX format
        $this->addContentTypes($zip);
        $this->addRels($zip);
        $this->addApp($zip);
        $this->addCore($zip);
        $this->addWorkbookRels($zip);
        $this->addWorkbook($zip);
        $this->addWorksheet($zip);
        $this->addStyles($zip);
        
        $zip->close();
        
        // Set headers and output file
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Content-Length: ' . filesize($tempFile));
        header('Cache-Control: max-age=0');
        
        readfile($tempFile);
        unlink($tempFile);
        exit();
    }
    
    private function addContentTypes($zip) {
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n";
        $xml .= '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">';
        $xml .= '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>';
        $xml .= '<Default Extension="xml" ContentType="application/xml"/>';
        $xml .= '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>';
        $xml .= '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>';
        $xml .= '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>';
        $xml .= '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>';
        $xml .= '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>';
        $xml .= '</Types>';
        
        $zip->addFromString('[Content_Types].xml', $xml);
    }
    
    private function addRels($zip) {
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n";
        $xml .= '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">';
        $xml .= '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>';
        $xml .= '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>';
        $xml .= '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>';
        $xml .= '</Relationships>';
        
        $zip->addFromString('_rels/.rels', $xml);
    }
    
    private function addApp($zip) {
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n";
        $xml .= '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">';
        $xml .= '<Application>Operator Information System</Application>';
        $xml .= '<DocSecurity>0</DocSecurity>';
        $xml .= '<ScaleCrop>false</ScaleCrop>';
        $xml .= '<SharedDoc>false</SharedDoc>';
        $xml .= '<HyperlinksChanged>false</HyperlinksChanged>';
        $xml .= '<AppVersion>1.0</AppVersion>';
        $xml .= '</Properties>';
        
        $zip->addFromString('docProps/app.xml', $xml);
    }
    
    private function addCore($zip) {
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n";
        $xml .= '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        $xml .= '<dc:creator>Operator Information System</dc:creator>';
        $xml .= '<dcterms:created xsi:type="dcterms:W3CDTF">' . date('c') . '</dcterms:created>';
        $xml .= '<dc:title>Operator Template</dc:title>';
        $xml .= '</cp:coreProperties>';
        
        $zip->addFromString('docProps/core.xml', $xml);
    }
    
    private function addWorkbookRels($zip) {
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n";
        $xml .= '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">';
        $xml .= '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>';
        $xml .= '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>';
        $xml .= '</Relationships>';
        
        $zip->addFromString('xl/_rels/workbook.xml.rels', $xml);
    }
    
    private function addWorkbook($zip) {
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n";
        $xml .= '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">';
        $xml .= '<sheets>';
        $xml .= '<sheet name="Operator Template" sheetId="1" r:id="rId1"/>';
        $xml .= '</sheets>';
        $xml .= '</workbook>';
        
        $zip->addFromString('xl/workbook.xml', $xml);
    }
    
    private function addWorksheet($zip) {
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n";
        $xml .= '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">';
        $xml .= '<sheetData>';
        
        $rowIndex = 1;
        foreach ($this->data as $row) {
            $xml .= '<row r="' . $rowIndex . '">';
            $colIndex = 1;
            
            foreach ($row['data'] as $cellValue) {
                $cellRef = $this->numberToColumn($colIndex) . $rowIndex;
                $styleId = 0;
                
                // Apply styles
                if ($row['style'] === 'header') {
                    $styleId = 1;
                } elseif ($row['style'] === 'instruction') {
                    $styleId = 2;
                }
                
                $xml .= '<c r="' . $cellRef . '" s="' . $styleId . '" t="inlineStr">';
                $xml .= '<is><t>' . htmlspecialchars($cellValue) . '</t></is>';
                $xml .= '</c>';
                
                $colIndex++;
            }
            
            $xml .= '</row>';
            $rowIndex++;
        }
        
        $xml .= '</sheetData>';
        $xml .= '</worksheet>';
        
        $zip->addFromString('xl/worksheets/sheet1.xml', $xml);
    }
    
    private function addStyles($zip) {
        $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n";
        $xml .= '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">';
        
        // Fonts
        $xml .= '<fonts count="3">';
        $xml .= '<font><sz val="11"/><name val="Calibri"/></font>'; // Default
        $xml .= '<font><b/><sz val="11"/><name val="Calibri"/></font>'; // Bold
        $xml .= '<font><i/><sz val="11"/><name val="Calibri"/><color rgb="FF666666"/></font>'; // Italic gray
        $xml .= '</fonts>';
        
        // Fills
        $xml .= '<fills count="3">';
        $xml .= '<fill><patternFill patternType="none"/></fill>'; // Default
        $xml .= '<fill><patternFill patternType="solid"><fgColor rgb="FFE0E0E0"/></patternFill></fill>'; // Header
        $xml .= '<fill><patternFill patternType="solid"><fgColor rgb="FFF8F8F8"/></patternFill></fill>'; // Instruction
        $xml .= '</fills>';
        
        // Borders
        $xml .= '<borders count="1">';
        $xml .= '<border><left/><right/><top/><bottom/><diagonal/></border>';
        $xml .= '</borders>';
        
        // Cell formats
        $xml .= '<cellXfs count="3">';
        $xml .= '<xf numFmtId="0" fontId="0" fillId="0" borderId="0"/>'; // Default
        $xml .= '<xf numFmtId="0" fontId="1" fillId="1" borderId="0"/>'; // Header
        $xml .= '<xf numFmtId="0" fontId="2" fillId="2" borderId="0"/>'; // Instruction
        $xml .= '</cellXfs>';
        
        $xml .= '</styleSheet>';
        
        $zip->addFromString('xl/styles.xml', $xml);
    }
    
    private function numberToColumn($number) {
        $column = '';
        while ($number > 0) {
            $number--;
            $column = chr(65 + ($number % 26)) . $column;
            $number = intval($number / 26);
        }
        return $column;
    }
}
?>
