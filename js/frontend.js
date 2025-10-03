const API_BASE = 'api/';
let allOperators = [];
let searchResults = [];
let filteredOperators = [];
let currentView = 'table';
let currentPage = 1;
let totalPages = 1;
let paginationInfo = null;

document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    loadDropdownOptions();
    loadAllOperators();
    loadCorpsStatistics();
    setCurrentYear();
    setupFloatingAdminBtn();
    initializeDroneScanning();
    loadAnimationSettings();
});

function setupEventListeners() {
    // Add debounced search input listener
    const searchInput = document.getElementById('search-input');
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(handleSearch, 500); // 500ms debounce
        });
        console.log('Frontend: Search input listener attached with debounce');
    }
    
    document.getElementById('search-btn').addEventListener('click', handleSearch);
    document.getElementById('clear-filters').addEventListener('click', clearFilters);
    
    document.getElementById('filter-formation').addEventListener('change', applyFilters);
    document.getElementById('filter-cores').addEventListener('change', applyFilters);
    document.getElementById('filter-exercise').addEventListener('change', applyFilters);
    document.getElementById('filter-rank').addEventListener('change', applyFilters);
    
    document.querySelector('.close').addEventListener('click', closeModal);
}

async function loadDropdownOptions() {
    console.log('Frontend: Loading dropdown options...');
    try {
        const response = await fetch(`${API_BASE}options.php`);
        console.log('Frontend: Response status:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const options = await response.json();
        console.log('Frontend: Options loaded:', options);
        
        populateFilterDropdown('filter-formation', options.formations);
        populateFilterDropdown('filter-cores', options.cores);
        populateFilterDropdown('filter-exercise', options.exercises);
        populateRanksDropdown('filter-rank', options.ranks);
        // Note: filter-unit doesn't exist in index.php, so skip it
        // populateFilterDropdown('filter-unit', options.units);
    } catch (error) {
        console.error('Frontend: Error loading options:', error);
    }
}

function populateFilterDropdown(selectId, options) {
    const select = document.getElementById(selectId);
    if (!select) {
        console.error('Frontend: Select element not found:', selectId);
        return;
    }
    
    const defaultOption = select.querySelector('option');
    select.innerHTML = '';
    select.appendChild(defaultOption);
    
    if (!options || !Array.isArray(options)) {
        console.error('Frontend: Invalid options for', selectId, options);
        return;
    }
    
    options.forEach(option => {
        select.innerHTML += `<option value="${option.id}">${option.name}</option>`;
    });
    console.log(`Frontend: Populated ${selectId} with ${options.length} options`);
}

function populateRanksDropdown(selectId, options) {
    const select = document.getElementById(selectId);
    if (!select) {
        console.error('Frontend: Select element not found:', selectId);
        return;
    }
    
    const defaultOption = select.querySelector('option');
    select.innerHTML = '';
    select.appendChild(defaultOption);
    
    if (!options || !Array.isArray(options)) {
        console.error('Frontend: Invalid options for', selectId, options);
        return;
    }
    
    // For ranks, use name as both value and display text (not id)
    options.forEach(option => {
        select.innerHTML += `<option value="${option.name}">${option.name}</option>`;
    });
    console.log(`Frontend: Populated ${selectId} with ${options.length} rank options`);
}

async function loadAllOperators(page = 1) {
    console.log('Frontend: Starting to load operators...');
    const container = document.getElementById('results-container');
    
    if (!container) {
        console.error('Frontend: results-container element not found!');
        return;
    }
    
    container.innerHTML = '<div class="loading"><div class="spinner"></div><p>Loading...</p></div>';
    
    try {
        console.log('Frontend: Fetching from API...');
        const response = await fetch(`${API_BASE}operators.php?page=${page}&limit=50`);
        console.log('Frontend: Response received:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        console.log('Frontend: Data received:', result);
        
        // Check for API error
        if (result.error) {
            throw new Error(result.message || result.error);
        }
        
        // Handle different response formats
        if (result.data && result.pagination) {
            // New paginated format
            allOperators = result.data;
            paginationInfo = result.pagination;
            currentPage = result.pagination.current_page;
            totalPages = result.pagination.total_pages;
        } else if (result.data && !result.pagination) {
            // Test API format
            allOperators = result.data;
            paginationInfo = null;
            currentPage = 1;
            totalPages = 1;
        } else if (Array.isArray(result)) {
            // Old format (array of operators)
            allOperators = result;
            paginationInfo = null;
            currentPage = 1;
            totalPages = 1;
        } else {
            throw new Error('Unexpected API response format');
        }
        
        console.log('Frontend: Number of operators:', allOperators.length);
        console.log('Frontend: Sample operator data:', allOperators[0]);
        
        searchResults = [...allOperators];
        filteredOperators = [...allOperators];
        
        console.log('Frontend: About to display results...');
        console.log('Frontend: filteredOperators sample:', filteredOperators[0]);
        displayResults();
        displayPagination();
        console.log('Frontend: Display results completed');
        
    } catch (error) {
        console.error('Frontend: Error loading operators:', error);
        container.innerHTML = '<div class="no-results">Error loading operators: ' + error.message + '</div>';
    }
}

function handleSearch() {
    const searchTerm = document.getElementById('search-input').value.trim();
    console.log('Frontend: handleSearch called with term:', searchTerm);
    
    if (searchTerm.length > 0) {
        // Perform server-side search
        console.log('Frontend: Performing server-side search');
        searchOperators(searchTerm);
    } else {
        // If no search term, load all operators
        console.log('Frontend: No search term, loading all operators');
        loadAllOperators();
    }
}

async function searchOperators(searchTerm) {
    console.log('Frontend: Searching for:', searchTerm);
    const container = document.getElementById('results-container');
    
    if (!container) {
        console.error('Frontend: results-container element not found!');
        return;
    }
    
    container.innerHTML = '<div class="loading"><div class="spinner"></div><p>Searching...</p></div>';
    
    try {
        const response = await fetch(`${API_BASE}operators.php?search=${encodeURIComponent(searchTerm)}&limit=100`);
        console.log('Frontend: Search response status:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        console.log('Frontend: Search API response:', result);
        
        // Check for API error
        if (result.error) {
            throw new Error(result.message || result.error);
        }
        
        // Handle different response formats
        if (result.data && result.pagination) {
            // New paginated format
            allOperators = result.data;
            paginationInfo = result.pagination;
            currentPage = result.pagination.current_page;
            totalPages = result.pagination.total_pages;
        } else if (result.data && !result.pagination) {
            // Test API format
            allOperators = result.data;
            paginationInfo = null;
            currentPage = 1;
            totalPages = 1;
        } else if (Array.isArray(result)) {
            // Old format (array of operators)
            allOperators = result;
            paginationInfo = null;
            currentPage = 1;
            totalPages = 1;
        } else {
            throw new Error('Unexpected API response format');
        }
        
        console.log('Frontend: Search results:', allOperators.length, 'operators found');
        
        searchResults = [...allOperators];
        filteredOperators = [...allOperators];
        
        displayResults();
        displayPagination();
        
        if (allOperators.length === 0) {
            container.innerHTML = '<div class="no-results"><h3>No operators found</h3><p>No operators match your search criteria. Try different keywords.</p></div>';
        }
        
    } catch (error) {
        console.error('Frontend: Error searching operators:', error);
        container.innerHTML = '<div class="no-results">Error searching operators: ' + error.message + '</div>';
    }
}

function applyFilters() {
    const formationFilter = document.getElementById('filter-formation').value;
    const coresFilter = document.getElementById('filter-cores').value;
    const exerciseFilter = document.getElementById('filter-exercise').value;
    const rankFilter = document.getElementById('filter-rank').value;
    
    let filtered = [...searchResults];
    
    if (formationFilter) filtered = filtered.filter(o => o.formation_id == formationFilter);
    if (coresFilter) filtered = filtered.filter(o => o.cores_id == coresFilter);
    if (exerciseFilter) filtered = filtered.filter(o => o.exercise_ids && o.exercise_ids.includes(parseInt(exerciseFilter)));
    if (rankFilter) filtered = filtered.filter(o => o.rank == rankFilter);
    
    filteredOperators = filtered;
    displayResults();
}

function clearFilters() {
    console.log('Frontend: Clearing all filters and search');
    
    // Clear all form inputs
    document.getElementById('search-input').value = '';
    document.getElementById('filter-formation').value = '';
    document.getElementById('filter-cores').value = '';
    document.getElementById('filter-exercise').value = '';
    document.getElementById('filter-rank').value = '';
    
    // Reload all operators from database (not just reset to current search results)
    loadAllOperators();
}


function displayResults() {
    console.log('Frontend: displayResults called');
    console.log('Frontend: filteredOperators length:', filteredOperators.length);
    
    const container = document.getElementById('results-container');
    
    if (!filteredOperators || filteredOperators.length === 0) {
        console.log('Frontend: No operators to display');
        container.innerHTML = '<div class="no-results"><h3>No operators found</h3><p>There are currently no operators in the system.</p></div>';
        return;
    }
    
    console.log('Frontend: Displaying table view');
    displayTableView();
}


function displayTableView() {
    const container = document.getElementById('results-container');
    const tableHTML = `
        <table class="operators-table">
            <thead>
                <tr>
                    <th>Personal No</th>
                    <th>Rank</th>
                    <th>Name</th>
                    <th>Corps</th>
                    <th>Mobile</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                ${filteredOperators.map(operator => `
                    <tr>
                        <td>${operator.personal_no || 'N/A'}</td>
                        <td>${operator.rank || 'N/A'}</td>
                        <td>
                            ${operator.name}
                            ${operator.special_note_names && operator.special_note_names.length > 0 ? 
                                `<div class="table-special-note">
                                    <i class="fas fa-flag"></i>
                                    ${operator.special_note_names.join(', ')}
                                </div>` : ''}
                        </td>
                        <td>${operator.cores_name || 'N/A'}</td>
                        <td>${operator.mobile_personal || 'N/A'}</td>
                        <td><button onclick="showOperatorDetails(${operator.id})">View</button></td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    container.innerHTML = tableHTML;
}

async function showOperatorDetails(id) {
    try {
        const response = await fetch(`${API_BASE}operators.php?id=${id}`);
        const operator = await response.json();
        
        console.log('Frontend: Operator details received:', operator);
        
        document.getElementById('modal-title').textContent = operator.name;
        // Create comprehensive operator details display
        const detailsHTML = createOperatorDetailsHTML(operator);
        document.getElementById('modal-body').innerHTML = detailsHTML;
        
        document.getElementById('operator-modal').style.display = 'block';
    } catch (error) {
        console.error('Error loading operator details:', error);
    }
}

function createOperatorDetailsHTML(operator) {
    let html = '<div class="operator-details">';
    
    // Add special note prominently at the top if it exists
    if (operator.special_note_names && operator.special_note_names.length > 0) {
        html += `<div class="special-note-banner">
                    <div class="special-note-icon">
                        <i class="fas fa-flag"></i>
                    </div>
                    <div class="special-note-content">
                        <strong>Special Notes:</strong> ${operator.special_note_names.join(', ')}
                    </div>
                </div>`;
    }
    
    // Define all possible fields with their display names and categories
    const fieldCategories = {
        'Basic Information': {
            'personal_no': 'Personal No',
            'rank': 'Rank',
            'name': 'Name',
            'birth_date': 'Birth Date'
        },
        'Contact Information': {
            'mobile_personal': 'Mobile (Personal)',
            'mobile_family': 'Mobile (Family)'
        },
        'Organizational Details': {
            'formation_name': 'Formation',
            'cores_name': 'Corps',
            'unit_name': 'Unit',
            'med_category_name': 'Med Category'
        },
        'Academic & Professional': {
            'course_cadre_name': 'OP Qualifying Course/Cader',
            'civil_edu': 'Civil Education',
            'course': 'Course',
            'cadre': 'Cadre'
        },
        'Important Dates': {
            'admission_date': 'Admission Date',
            'joining_date_awgc': 'Joining Date AWGC'
        }
    };

    // Full-width fields (textareas)
    const fullWidthFields = {
        'Address Information': {
            'permanent_address': 'Permanent Address',
            'present_address': 'Present Address'
        },
        'Experience & Expertise': {
            'worked_in_awgc': 'Worked in AWGC',
            'expertise_area': 'Expertise Area',
            'exercise_names': 'Exercises'
        },
        'Disciplinary Records': {
            'punishment': 'Punishment'
        }
    };

    // Process regular grid fields
    Object.keys(fieldCategories).forEach(categoryName => {
        const fields = fieldCategories[categoryName];
        const hasData = Object.keys(fields).some(field => operator[field] && operator[field].toString().trim() !== '');
        
        if (hasData) {
            html += `<div class="detail-section">
                        <h4>${categoryName}</h4>
                        <div class="detail-grid">`;
            
            Object.keys(fields).forEach(field => {
                const value = operator[field];
                if (value && value.toString().trim() !== '') {
                    html += `<div class="detail-item">
                                <span class="detail-label">${fields[field]}</span>
                                <span class="detail-value">${value}</span>
                            </div>`;
                }
            });
            
            html += '</div></div>';
        }
    });

    // Process full-width fields
    Object.keys(fullWidthFields).forEach(categoryName => {
        const fields = fullWidthFields[categoryName];
        const hasData = Object.keys(fields).some(field => operator[field] && operator[field].toString().trim() !== '');
        
        if (hasData) {
            html += `<div class="detail-section">
                        <h4>${categoryName}</h4>`;
            
            Object.keys(fields).forEach(field => {
                const value = operator[field];
                if (value && value.toString().trim() !== '') {
                    html += `<div class="detail-item full-width">
                                <span class="detail-label">${fields[field]}</span>
                                <span class="detail-value">${value}</span>
                            </div>`;
                }
            });
            
            html += '</div>';
        }
    });

    // Add any additional fields that might not be in our predefined categories
    const knownFields = new Set();
    Object.values(fieldCategories).forEach(category => {
        Object.keys(category).forEach(field => knownFields.add(field));
    });
    Object.values(fullWidthFields).forEach(category => {
        Object.keys(category).forEach(field => knownFields.add(field));
    });
    
    // Add system fields to ignore
    knownFields.add('id');
    knownFields.add('created_at');
    knownFields.add('updated_at');
    knownFields.add('formation_id');
    knownFields.add('cores_id');
    knownFields.add('unit_id');
    knownFields.add('med_category_id');
    knownFields.add('exercise_id');
    knownFields.add('exercise_ids');
    knownFields.add('special_note');
    knownFields.add('special_note_ids');
    knownFields.add('special_note_names');
    knownFields.add('special_note_colors');

    // Check for any additional fields
    const additionalFields = Object.keys(operator).filter(field => 
        !knownFields.has(field) && 
        operator[field] && 
        operator[field].toString().trim() !== ''
    );

    if (additionalFields.length > 0) {
        html += `<div class="detail-section">
                    <h4>Additional Information</h4>
                    <div class="detail-grid">`;
        
        additionalFields.forEach(field => {
            const displayName = field.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
            html += `<div class="detail-item">
                        <span class="detail-label">${displayName}</span>
                        <span class="detail-value">${operator[field]}</span>
                    </div>`;
        });
        
        html += '</div></div>';
    }

    html += '</div>';
    
    console.log('Frontend: Generated details HTML for operator:', operator.name);
    console.log('Frontend: All operator fields:', Object.keys(operator));
    
    return html;
}

function closeModal() {
    document.getElementById('operator-modal').style.display = 'none';
}

function setCurrentYear() {
    const currentYear = new Date().getFullYear();
    const yearElement = document.getElementById('current-year');
    if (yearElement) {
        yearElement.textContent = currentYear;
    }
}

function displayPagination() {
    if (!paginationInfo || paginationInfo.total_pages <= 1) {
        return; // No pagination needed
    }
    
    const container = document.getElementById('results-container');
    const paginationHTML = `
        <div class="pagination-container">
            <div class="pagination-info">
                Showing page ${paginationInfo.current_page} of ${paginationInfo.total_pages} 
                (${paginationInfo.total_records} total operators)
            </div>
            <div class="pagination-controls">
                <button class="pagination-btn" ${!paginationInfo.has_prev ? 'disabled' : ''} 
                        onclick="changePage(${paginationInfo.current_page - 1})">
                    <i class="fas fa-chevron-left"></i> Previous
                </button>
                
                ${generatePageNumbers()}
                
                <button class="pagination-btn" ${!paginationInfo.has_next ? 'disabled' : ''} 
                        onclick="changePage(${paginationInfo.current_page + 1})">
                    Next <i class="fas fa-chevron-right"></i>
                </button>
            </div>
        </div>
    `;
    
    container.innerHTML += paginationHTML;
}

function generatePageNumbers() {
    let pages = '';
    const current = paginationInfo.current_page;
    const total = paginationInfo.total_pages;
    
    // Show first page
    if (current > 3) {
        pages += `<button class="pagination-btn page-num" onclick="changePage(1)">1</button>`;
        if (current > 4) {
            pages += `<span class="pagination-dots">...</span>`;
        }
    }
    
    // Show pages around current
    for (let i = Math.max(1, current - 2); i <= Math.min(total, current + 2); i++) {
        pages += `<button class="pagination-btn page-num ${i === current ? 'active' : ''}" 
                          onclick="changePage(${i})">${i}</button>`;
    }
    
    // Show last page
    if (current < total - 2) {
        if (current < total - 3) {
            pages += `<span class="pagination-dots">...</span>`;
        }
        pages += `<button class="pagination-btn page-num" onclick="changePage(${total})">${total}</button>`;
    }
    
    return pages;
}

function changePage(page) {
    if (page < 1 || page > totalPages || page === currentPage) {
        return;
    }
    loadAllOperators(page);
}

// Corps Statistics Functions
async function loadCorpsStatistics() {
    console.log('Frontend: Loading corps statistics...');
    const container = document.getElementById('corps-stats-container');
    const totalOperatorsElement = document.getElementById('total-operators');
    
    if (!container) {
        console.error('Frontend: corps-stats-container element not found!');
        return;
    }
    
    // Show loading state
    container.innerHTML = '<div class="stats-loading"><div class="spinner"></div><p>Loading statistics...</p></div>';
    totalOperatorsElement.textContent = '-';
    
    try {
        console.log('Frontend: Fetching corps statistics from API...');
        const response = await fetch(`${API_BASE}public-stats.php?action=stats`);
        console.log('Frontend: Stats response status:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        console.log('Frontend: Corps statistics received:', result);
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to load statistics');
        }
        
        const { total_operators, corps_distribution } = result.data;
        
        // Update total operators
        totalOperatorsElement.textContent = total_operators.toLocaleString();
        
        // Display corps cards
        displayCorpsCards(corps_distribution);
        
        console.log('Frontend: Corps statistics loaded successfully');
        
    } catch (error) {
        console.error('Frontend: Error loading corps statistics:', error);
        showCorpsError(error.message);
    }
}

function displayCorpsCards(corpsData) {
    const container = document.getElementById('corps-stats-container');
    
    if (!corpsData || corpsData.length === 0) {
        container.innerHTML = '<div class="stats-error"><i class="fas fa-exclamation-triangle"></i><h3>No Corps Data</h3><p>No corps information available.</p></div>';
        return;
    }
    
    // Define corps icons mapping
    const corpsIcons = {
        'Air Defence': 'fas fa-shield-alt',
        'Armoured': 'fas fa-shield-alt',
        'Artillery': 'fas fa-crosshairs',
        'ASC': 'fas fa-truck',
        'EME': 'fas fa-tools',
        'Engineers': 'fas fa-hammer',
        'Infantry (BIR)': 'fas fa-user-shield',
        'Infantry (EB)': 'fas fa-user-shield',
        'Ordnance': 'fas fa-bomb',
        'Signals': 'fas fa-broadcast-tower'
    };
    
    // Generate corps cards HTML
    const cardHTML = corpsData.map(corps => {
        const icon = corpsIcons[corps.name] || 'fas fa-star';
        const count = corps.count || 0;
        const percentage = corps.percentage || 0;
        
        return `
            <div class="corps-card">
                <div class="corps-icon">
                    <i class="${icon}"></i>
                </div>
                <div class="corps-info">
                    <div class="corps-name">${corps.name}</div>
                    <div class="corps-stats">
                        <span class="corps-count">${count}</span>
                        <span class="corps-percentage">${percentage}%</span>
                    </div>
                </div>
            </div>
        `;
    }).join('');
    
    // Duplicate cards for seamless marquee effect
    container.innerHTML = cardHTML + cardHTML;
}

function showCorpsError(message) {
    const container = document.getElementById('corps-stats-container');
    container.innerHTML = `
        <div class="stats-error">
            <i class="fas fa-exclamation-triangle"></i>
            <span>Error: ${message}</span>
            <button onclick="loadCorpsStatistics()" class="refresh-btn" style="border-radius: 6px; padding: 6px 12px; font-size: 0.8rem;">
                <i class="fas fa-sync-alt"></i> Retry
            </button>
        </div>
    `;
}


// Floating Admin Button Functions
function setupFloatingAdminBtn() {
    const floatingBtn = document.getElementById('floating-admin-btn');
    let lastScrollY = window.scrollY;
    let ticking = false;
    
    function updateFloatingBtn() {
        const currentScrollY = window.scrollY;
        const heroHeight = document.querySelector('.hero-section').offsetHeight;
        
        // Show button when scrolled past hero section
        if (currentScrollY > heroHeight * 0.3) {
            floatingBtn.classList.add('show');
        } else {
            floatingBtn.classList.remove('show');
        }
        
        lastScrollY = currentScrollY;
        ticking = false;
    }
    
    function requestTick() {
        if (!ticking) {
            requestAnimationFrame(updateFloatingBtn);
            ticking = true;
        }
    }
    
    // Listen for scroll events
    window.addEventListener('scroll', requestTick, { passive: true });
    
    // Initial check
    updateFloatingBtn();
}

// Drone Scanning System
let droneInfoTimeout;
let isShowingInfo = false;

function initializeDroneScanning() {
    console.log('Initializing drone scanning system with continuous database updates...');
    startRandomScanning();
    
    // Set up periodic refresh to ensure data stays current
    setInterval(() => {
        console.log('Periodic database refresh check...');
        if (!isShowingInfo) {
            // Force a new scan if not currently showing info
            startRandomScanning();
        }
    }, 5000); // Check every 5 seconds for fresh data
}

function startRandomScanning() {
    // Random delay between 1-3 seconds for more frequent updates
    const randomDelay = Math.random() * 2000 + 1000; // 1000-3000ms
    
    setTimeout(() => {
        if (!isShowingInfo) {
            showOperatorInfo();
        }
    }, randomDelay);
}

async function showOperatorInfo() {
    const rankElement = document.querySelector('.operator-rank');
    const nameElement = document.querySelector('.operator-name');
    const unitElement = document.querySelector('.operator-unit');
    
    if (!rankElement || !nameElement || !unitElement) return;
    
    try {
        isShowingInfo = true;
        
        // Fetch random operator data with cache-busting to ensure fresh data
        const timestamp = new Date().getTime();
        const response = await fetch(`api/random-operator.php?t=${timestamp}`);
        const data = await response.json();
        
        console.log('API Response:', data); // Debug log
        
        if (data.success && data.data) {
            // Populate the info elements
            rankElement.textContent = data.data.rank || 'N/A';
            nameElement.textContent = data.data.name || 'N/A';
            unitElement.textContent = data.data.unit || 'N/A';
            
            // Show each field with smooth transition in sequence: Rank -> Name -> Unit
            rankElement.style.transition = 'opacity 0.5s ease-in-out';
            nameElement.style.transition = 'opacity 0.5s ease-in-out';
            unitElement.style.transition = 'opacity 0.5s ease-in-out';
            
            // Show Rank first
            rankElement.classList.remove('hide');
            rankElement.classList.add('show');
            
            // Show Name after 500ms delay
            setTimeout(() => {
                nameElement.classList.remove('hide');
                nameElement.classList.add('show');
            }, 500);
            
            // Show Unit after 1000ms delay
            setTimeout(() => {
                unitElement.classList.remove('hide');
                unitElement.classList.add('show');
            }, 1000);
            
            console.log('Drone scanned:', data.data);
            
            // Hide after 2-3 seconds for faster updates
            const displayDuration = Math.random() * 1000 + 2000; // 2000-3000ms
            
            droneInfoTimeout = setTimeout(() => {
                hideOperatorInfo();
            }, displayDuration);
            
        } else {
            console.error('Failed to fetch operator data:', data);
            // Show debug info in the display for testing
            rankElement.textContent = 'DEBUG';
            nameElement.textContent = data.message || 'API ERROR';
            unitElement.textContent = `Total: ${data.total_operators || 0}`;
            
            rankElement.style.transition = 'opacity 0.5s ease-in-out';
            nameElement.style.transition = 'opacity 0.5s ease-in-out';
            unitElement.style.transition = 'opacity 0.5s ease-in-out';
            
            rankElement.classList.remove('hide');
            rankElement.classList.add('show');
            nameElement.classList.remove('hide');
            nameElement.classList.add('show');
            unitElement.classList.remove('hide');
            unitElement.classList.add('show');
            
            setTimeout(() => {
                hideOperatorInfo();
            }, 5000);
        }
        
    } catch (error) {
        console.error('Error fetching operator data:', error);
        scheduleNextScan();
    }
}

function hideOperatorInfo() {
    const rankElement = document.querySelector('.operator-rank');
    const nameElement = document.querySelector('.operator-name');
    const unitElement = document.querySelector('.operator-unit');
    
    if (rankElement && nameElement && unitElement) {
        // Set smooth transition
        rankElement.style.transition = 'opacity 0.5s ease-in-out';
        nameElement.style.transition = 'opacity 0.5s ease-in-out';
        unitElement.style.transition = 'opacity 0.5s ease-in-out';
        
        // Hide each field
        rankElement.classList.remove('show');
        rankElement.classList.add('hide');
        nameElement.classList.remove('show');
        nameElement.classList.add('hide');
        unitElement.classList.remove('show');
        unitElement.classList.add('hide');
        
        // Wait for fade out animation to complete
        setTimeout(() => {
            rankElement.classList.remove('hide');
            nameElement.classList.remove('hide');
            unitElement.classList.remove('hide');
            isShowingInfo = false;
            scheduleNextScan();
        }, 500);
    }
}

function scheduleNextScan() {
    // Schedule the next random scan with fresh database data
    setTimeout(() => {
        startRandomScanning();
    }, Math.random() * 2000 + 1000); // 1-3 seconds before next scan (more frequent updates)
}

// ==========================================
// ANIMATION SETTINGS FUNCTIONALITY
// ==========================================

// Load animation settings from server and apply them
async function loadAnimationSettings() {
    try {
        console.log('Loading animation settings for frontend...');
        
        const response = await fetch(`${API_BASE}animation-settings.php?action=public`);
        const result = await response.json();
        
        if (!result.success) {
            console.warn('Failed to load animation settings, using disabled defaults');
            // Apply default settings (all animations disabled)
            applyDefaultAnimationSettings();
            return;
        }
        
        // Apply animation settings to body classes
        applyAnimationSettings(result.data);
        
        console.log('Animation settings loaded and applied:', result.data);
        console.log('Current body classes:', document.body.className);
        
        // Verify specific settings
        if (result.data.hero_animations === false) {
            console.log('✓ Hero animations are disabled by default');
        }
        if (result.data.drone_animations === false) {
            console.log('✓ Drone animations are disabled by default');
        }
        
    } catch (error) {
        console.warn('Error loading animation settings, using disabled defaults:', error);
        // Apply default settings (all animations disabled)
        applyDefaultAnimationSettings();
    }
}

// Apply default animation settings (all disabled)
function applyDefaultAnimationSettings() {
    const body = document.body;
    
    // Default settings - all animations disabled when not logged in
    const defaultSettings = {
        'hero_animations': false,
        'drone_animations': false,
        'floating_elements': false,
        'background_effects': false
    };
    
    // Apply default settings
    Object.keys(defaultSettings).forEach(settingName => {
        const isEnabled = defaultSettings[settingName];
        const className = `disable-${settingName.replace('_', '-')}`;
        
        if (isEnabled) {
            // Enable animation - remove disable class
            body.classList.remove(className);
        } else {
            // Disable animation - add disable class
            body.classList.add(className);
        }
    });
    
    console.log('Applied default animation settings (all disabled) to frontend');
}

// Apply animation settings by adding/removing CSS classes
function applyAnimationSettings(settings) {
    const body = document.body;
    
    // Apply each setting
    Object.keys(settings).forEach(settingName => {
        const isEnabled = settings[settingName];
        const className = `disable-${settingName.replace('_', '-')}`;
        
        console.log(`Applying setting ${settingName}: ${isEnabled ? 'enabled' : 'disabled'} (class: ${className})`);
        
        if (isEnabled) {
            // Enable animation - remove disable class
            body.classList.remove(className);
            console.log(`Removed class: ${className}`);
        } else {
            // Disable animation - add disable class
            body.classList.add(className);
            console.log(`Added class: ${className}`);
        }
    });
    
    console.log('Applied animation settings to frontend');
    console.log('Final body classes:', body.className);
}
