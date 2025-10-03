const API_BASE = 'api/';

let allOperators = [];
let currentPage = 1;
let totalPages = 1;
let paginationInfo = null;

document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    loadDropdownOptions();
    loadOperators();
    loadDashboardOptions();
    setCurrentYear();
});

function setupEventListeners() {
    const operatorForm = document.getElementById('operator-form');
    if (operatorForm) {
        operatorForm.addEventListener('submit', handleFormSubmit);
    }
    
    // Add update form listener
    const updateForm = document.getElementById('update-form');
    if (updateForm) {
        updateForm.addEventListener('submit', handleUpdateSubmit);
    }
    
    // Add option form listener
    const optionForm = document.getElementById('option-form');
    if (optionForm) {
        optionForm.addEventListener('submit', handleOptionFormSubmit);
    }
    
    // Add admin user form listeners
    const addAdminForm = document.getElementById('add-admin-form');
    if (addAdminForm) {
        addAdminForm.addEventListener('submit', handleAddAdminSubmit);
    }
    
    const editAdminForm = document.getElementById('edit-admin-form');
    if (editAdminForm) {
        editAdminForm.addEventListener('submit', handleEditAdminSubmit);
    }
    
    const changePasswordForm = document.getElementById('change-password-form');
    if (changePasswordForm) {
        changePasswordForm.addEventListener('submit', handleChangePasswordSubmit);
    }
    
    // Add search input listener with debounce
    const searchInput = document.getElementById('search-operators');
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(handleSearch, 500); // 500ms debounce
        });
        console.log('Search input listener attached');
    } else {
        console.error('Search input element not found');
    }
    
    // Admin export dropdown functionality
    const adminExportDropdownBtn = document.getElementById('admin-export-dropdown-btn');
    const adminExportMenu = document.getElementById('admin-export-menu');
    
    if (adminExportDropdownBtn && adminExportMenu) {
        adminExportDropdownBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            adminExportMenu.classList.toggle('show');
        });
        
        // Close dropdown when clicking outside
        document.addEventListener('click', function() {
            adminExportMenu.classList.remove('show');
        });
        
        adminExportMenu.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }
    
    // Detail modal listeners
    const closeDetailBtn = document.querySelector('.close-detail');
    if (closeDetailBtn) {
        closeDetailBtn.addEventListener('click', closeDetailModal);
    }
    
    
    // Initialize bulk upload functionality
    initializeBulkUpload();
    
    // Window click to close modals
    window.addEventListener('click', function(event) {
        const updateModal = document.getElementById('update-modal');
        const addAdminModal = document.getElementById('add-admin-modal');
        const editAdminModal = document.getElementById('edit-admin-modal');
        const changePasswordModal = document.getElementById('change-password-modal');
        const detailModal = document.getElementById('admin-operator-modal');
        if (updateModal && event.target === updateModal) {
            closeUpdateModal();
        }
        if (detailModal && event.target === detailModal) {
            closeDetailModal();
        }
        if (addAdminModal && event.target === addAdminModal) {
            closeAddAdminModal();
        }
        if (editAdminModal && event.target === editAdminModal) {
            closeEditAdminModal();
        }
        if (changePasswordModal && event.target === changePasswordModal) {
            closeChangePasswordModal();
        }
    });
}


function displayOperators(operators) {
    const container = document.getElementById('operators-list');
    
    if (!operators || operators.length === 0) {
        container.innerHTML = '<div class="no-operators"><h3>No operators found</h3><p>There are currently no operators in the system. Add some operators to get started.</p></div>';
        return;
    }
    
    // Clear container and remove any existing checkboxes
    container.innerHTML = '';
    document.querySelectorAll('#select-all-operators').forEach(cb => cb.remove());
    
    // Generate the HTML with a single select-all checkbox
    const html = `
        <div class="selection-controls">
            <label class="checkbox-container">
                <input type="checkbox" id="select-all-operators" onchange="toggleSelectAll()">
                <span class="checkmark"></span>
                Select All
            </label>
            <div class="selection-actions">
                <div class="selected-count">
                    <span id="selected-count">0</span> operators selected
                </div>
                <button class="btn btn-danger" id="delete-selected-btn" onclick="deleteSelectedOperators()" disabled>
                    <i class="fas fa-trash"></i> Delete Selected
                </button>
            </div>
        </div>
        <table class="operators-table">
            <thead>
                <tr>
                    <th width="40">Select</th>
                    <th>Personal No</th>
                    <th>Rank</th>
                    <th>Name</th>
                    <th>Corps</th>
                    <th>Mobile</th>
                    <th width="200">Actions</th>
                </tr>
            </thead>
            <tbody>
                ${operators.map(operator => `
                    <tr>
                        <td>
                            <label class="checkbox-container">
                                <input type="checkbox" class="operator-checkbox" value="${operator.id}" onchange="updateSelectedCount()">
                                <span class="checkmark"></span>
                            </label>
                        </td>
                        <td>${operator.personal_no || 'N/A'}</td>
                        <td>${operator.rank || 'N/A'}</td>
                        <td>${operator.name || 'N/A'}
                            ${operator.special_note_names && operator.special_note_names.length > 0 ? 
                                `<div class="table-special-note">
                                    <i class="fas fa-flag"></i>
                                    ${operator.special_note_names.join(', ')}
                                </div>` : ''}
                        </td>
                        <td>${operator.cores_name || 'N/A'}</td>
                        <td>${operator.mobile_personal || 'N/A'}</td>
                        <td class="action-buttons">
                            <button class="btn btn-primary" onclick="showAdminOperatorDetails(${operator.id})">
                                <i class="fas fa-eye"></i> View
                            </button>
                            <button class="btn btn-edit" onclick="editOperator(${operator.id})">
                                <i class="fas fa-edit"></i> Edit
                            </button>
                            <button class="btn btn-delete" onclick="deleteOperator(${operator.id})">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    
    container.innerHTML = html;
    updateExportButtonsState(false);
}

async function loadDropdownOptions() {
    console.log('Loading dropdown options...');
    console.log('API URL:', `${API_BASE}options.php`);
    try {
        const response = await fetch(`${API_BASE}options.php`);
        console.log('Response status:', response.status);
        console.log('Response headers:', response.headers);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Response error text:', errorText);
            throw new Error(`HTTP error! status: ${response.status} - ${errorText}`);
        }
        
        const options = await response.json();
        console.log('Options loaded:', options);
        console.log('Exercises data:', options.exercises);
        
        if (options.formations) {
            populateDropdown('formations', options.formations);
            populateUpdateDropdown('update-formations', options.formations);
        }
        if (options.cores) {
            populateDropdown('cores', options.cores);
            populateUpdateDropdown('update-cores', options.cores);
        }
        if (options.units) {
            populateDropdown('units', options.units);
            populateUpdateDropdown('update-units', options.units);
            console.log('Units populated:', options.units.length);
        }
        if (options.exercises) {
            populateCheckboxGroup('exercises', options.exercises);
            populateUpdateDropdown('update-exercises', options.exercises);
        }
        if (options.med_categories) {
            console.log('Populating med_categories dropdown with', options.med_categories.length, 'items');
            populateDropdown('med-categories', options.med_categories);
            populateUpdateDropdown('update-med-categories', options.med_categories);
        }
        if (options.ranks) {
            // Special handling for ranks since they use name as value, not id
            const rankSelect = document.getElementById('rank');
            if (rankSelect) {
                rankSelect.innerHTML = '<option value="">Select Rank...</option>';
                options.ranks.forEach(rank => {
                    rankSelect.innerHTML += `<option value="${rank.name}">${rank.name}</option>`;
                });
                console.log('Ranks populated:', options.ranks.length);
            }
            populateUpdateRanksDropdown('update-rank', options.ranks);
        }
        if (options.special_notes) {
            populateCheckboxGroup('special-notes', options.special_notes);
            populateUpdateDropdown('update-special-notes', options.special_notes);
            console.log('Special notes populated:', options.special_notes.length);
        }
        
        // Populate admin filter dropdowns
        populateAdminFilterDropdown('admin-filter-rank', options.ranks, true); // true for ranks (use name as value)
        populateAdminFilterDropdown('admin-filter-corps', options.cores);
        populateAdminFilterDropdown('admin-filter-exercise', options.exercises);
        populateAdminFilterDropdown('admin-filter-special-note', options.special_notes);
        populateAdminFilterDropdown('admin-filter-formation', options.formations);
        populateAdminFilterDropdown('admin-filter-unit', options.units);
    } catch (error) {
        console.error('Error loading dropdown options:', error);
        showAlert('Error loading dropdown options: ' + error.message, 'error');
    }
}

// Function to refresh dropdown options after auto-registration
async function refreshDropdownOptions() {
    console.log('Refreshing dropdown options after auto-registration...');
    try {
        await loadDropdownOptions();
        console.log('Dropdown options refreshed successfully');
        
        // Show a brief notification that dropdowns have been updated
        showNotification('info', 'Dropdown options updated with new items', 3000);
    } catch (error) {
        console.error('Error refreshing dropdown options:', error);
    }
}

function populateDropdown(selectId, options) {
    const select = document.getElementById(selectId);
    if (!select) {
        console.error('Select element not found:', selectId);
        return;
    }
    
    select.innerHTML = '<option value="">Select...</option>';
    if (options && Array.isArray(options)) {
        options.forEach(option => {
            select.innerHTML += `<option value="${option.id}">${option.name}</option>`;
        });
        console.log(`Populated ${selectId} with ${options.length} options`);
    } else {
        console.error(`Invalid options for ${selectId}:`, options);
    }
}

function populateUpdateDropdown(selectId, options) {
    const select = document.getElementById(selectId);
    if (!select) {
        console.error('Update select element not found:', selectId);
        return;
    }
    
    // Keep the first option (placeholder) and clear the rest
    const firstOption = select.querySelector('option');
    select.innerHTML = '';
    if (firstOption) {
        select.appendChild(firstOption);
    } else {
        select.innerHTML = '<option value="">Select...</option>';
    }
    
    if (options && Array.isArray(options)) {
        options.forEach(option => {
            const optionElement = document.createElement('option');
            optionElement.value = option.id;
            optionElement.textContent = option.name;
            select.appendChild(optionElement);
        });
        console.log(`Populated update dropdown ${selectId} with ${options.length} options`);
    } else {
        console.error(`Invalid options for update dropdown ${selectId}:`, options);
    }
}

function populateUpdateRanksDropdown(selectId, options) {
    const select = document.getElementById(selectId);
    if (!select) {
        console.error('Update ranks select element not found:', selectId);
        return;
    }
    
    // Keep the first option (placeholder) and clear the rest
    const firstOption = select.querySelector('option');
    select.innerHTML = '';
    if (firstOption) {
        select.appendChild(firstOption);
    } else {
        select.innerHTML = '<option value="">Select Rank...</option>';
    }
    
    if (options && Array.isArray(options)) {
        options.forEach(option => {
            const optionElement = document.createElement('option');
            optionElement.value = option.name; // Ranks use name as value, not id
            optionElement.textContent = option.name;
            select.appendChild(optionElement);
        });
        console.log(`Populated update ranks dropdown ${selectId} with ${options.length} options`);
    } else {
        console.error(`Invalid options for update ranks dropdown ${selectId}:`, options);
    }
}

function populateCheckboxGroup(groupId, options) {
    console.log(`Attempting to populate checkbox group: ${groupId}`);
    const group = document.getElementById(groupId);
    if (!group) {
        console.error('Checkbox group not found:', groupId);
        return;
    }
    
    console.log(`Found checkbox group element:`, group);
    console.log(`Options received:`, options);
    
    // Determine the field name based on group type
    const fieldName = (groupId === 'special-notes' || groupId === 'update-special-notes') ? 'special_note_ids[]' : 'exercise_ids[]';
    
    let html = '';
    if (options && Array.isArray(options)) {
        options.forEach(option => {
            html += `
                <div class="checkbox-item">
                    <input type="checkbox" id="${groupId}_${option.id}" name="${fieldName}" value="${option.id}">
                    <label for="${groupId}_${option.id}">${option.name}</label>
                </div>
            `;
        });
        console.log(`Generated HTML for ${groupId}:`, html);
        console.log(`Populated ${groupId} with ${options.length} checkboxes`);
    } else {
        console.error(`Invalid options for ${groupId}:`, options);
    }
    
    group.innerHTML = html;
    console.log(`Final HTML in group:`, group.innerHTML);
}

async function handleFormSubmit(event) {
    event.preventDefault();
    console.log('Form submitted');
    
    const formData = new FormData(event.target);
    const operatorData = {};
    
    // Debug: Log all form data entries
    console.log('All form data entries:');
    for (let [key, value] of formData.entries()) {
        console.log(`${key}: ${value}`);
    }
    
    // Handle regular form fields
    for (let [key, value] of formData.entries()) {
        if (key === 'exercise_ids[]') {
            // Handle checkbox arrays specially
            if (!operatorData.exercise_ids) {
                operatorData.exercise_ids = [];
            }
            operatorData.exercise_ids.push(value);
            console.log(`Added exercise ID: ${value}`);
        } else if (key === 'special_note_ids[]') {
            // Handle special note checkbox arrays
            if (!operatorData.special_note_ids) {
                operatorData.special_note_ids = [];
            }
            operatorData.special_note_ids.push(value);
            console.log(`Added special note ID: ${value}`);
        } else {
            operatorData[key] = value || null;
        }
    }
    
    console.log('Operator data to send:', operatorData);
    console.log('Exercise IDs being sent:', operatorData.exercise_ids);
    
    // Show loading state
    const submitBtn = event.target.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerHTML;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
    submitBtn.disabled = true;
    
    // Show loading notification
    showLoading('Creating new operator...');
    
    try {
        console.log('Sending request to:', `${API_BASE}operators.php`);
        console.log('Request data:', JSON.stringify(operatorData, null, 2));
        
        const response = await fetch(`${API_BASE}operators.php`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(operatorData)
        });
        
        console.log('Response status:', response.status);
        console.log('Response headers:', response.headers);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Response error text:', errorText);
            throw new Error(`HTTP error! status: ${response.status} - ${errorText}`);
        }
        
        const result = await response.json();
        console.log('Server response:', result);
        
        if (result.success || result.message === 'Operator created') {
            showSuccess('Operator created successfully!');
            event.target.reset();
            loadOperators();
        } else {
            showError(result.message || 'Error creating operator');
        }
    } catch (error) {
        console.error('Error creating operator:', error);
        showAlert('Network error: Unable to create operator. Please check your connection and try again.', 'error');
    } finally {
        // Restore button state
        submitBtn.innerHTML = originalText;
        submitBtn.disabled = false;
    }
}

async function loadOperators(page = 1) {
    const container = document.getElementById('operators-list');
    container.innerHTML = '<div class="loading">Loading...</div>';
    
    try {
        const response = await fetch(`${API_BASE}operators.php?page=${page}&limit=50`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        
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
        
        console.log('Admin: Number of operators loaded:', allOperators.length);
        console.log('Admin: Sample operator data:', allOperators[0]);
        displayOperators(allOperators);
        displayAdminPagination();
    } catch (error) {
        console.error('Error loading operators:', error);
        container.innerHTML = '<div class="error">Error loading operators</div>';
    }
}

function handleSearch() {
    // Get search term
    const searchInput = document.getElementById('search-operators');
    if (!searchInput) {
        console.error('Search input not found in handleSearch');
        return;
    }
    
    const searchTerm = searchInput.value.trim();
    console.log('handleSearch called with term:', searchTerm);
    
    if (searchTerm.length > 0) {
        // Perform server-side search
        console.log('Performing server-side search');
        searchOperators(searchTerm);
    } else {
        // If no search term, load all operators
        console.log('No search term, loading all operators');
        loadOperators();
    }
}

function handleSearchButton() {
    handleSearch();
}

async function searchOperators(searchTerm) {
    const container = document.getElementById('operators-list');
    container.innerHTML = '<div class="loading">Searching...</div>';
    
    console.log('Searching for:', searchTerm);
    console.log('API URL:', `${API_BASE}operators.php?search=${encodeURIComponent(searchTerm)}&limit=100`);
    
    try {
        const response = await fetch(`${API_BASE}operators.php?search=${encodeURIComponent(searchTerm)}&limit=100`);
        
        console.log('Search response status:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        console.log('Search API response:', result);
        
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
        
        console.log('Search results:', allOperators.length, 'operators found');
        displayOperators(allOperators);
        displayAdminPagination();
        
        if (allOperators.length === 0) {
            container.innerHTML = '<div class="no-operators"><h3>No operators found</h3><p>No operators match your search criteria. Try different keywords.</p></div>';
        }
        
    } catch (error) {
        console.error('Error searching operators:', error);
        container.innerHTML = '<div class="error">Error searching operators: ' + error.message + '</div>';
    }
}

async function deleteOperator(id) {
    showWarning('⚠️ Confirm deletion - this action cannot be undone!');
    
    const confirmed = await showDeleteConfirmation(
        'Are you sure you want to delete this operator? This action cannot be undone.',
        null,
        () => showInfo('Delete operation cancelled')
    );
    
    if (!confirmed) {
        return;
    }
    
    showLoading('Deleting operator...');
    
    try {
        await fetch(`${API_BASE}operators.php`, {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({id})
        });
        showSuccess('✅ Operator deleted successfully');
        loadOperators();
    } catch (error) {
        showError('Error deleting operator. Please try again.');
        console.error('Delete error:', error);
    }
}

async function editOperator(id) {
    try {
        console.log('Starting edit for operator ID:', id);
        
        // Check if update modal exists
        const updateModal = document.getElementById('update-modal');
        if (!updateModal) {
            throw new Error('Update modal not found in DOM');
        }
        
        // First, ensure update dropdowns are populated
        console.log('Populating update dropdowns...');
        await populateUpdateDropdowns();
        console.log('Update dropdowns populated successfully');
        
        console.log('Fetching operator data...');
        const response = await fetch(`${API_BASE}operators.php?id=${id}`);
        console.log('Response received:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const operator = await response.json();
        console.log('Operator data parsed:', operator);
        
        if (!operator || operator.message) {
            throw new Error(operator.message || 'Operator not found');
        }
        
        console.log('Editing operator:', operator);
        
        // Populate update form text fields
        console.log('Populating form fields...');
        const updateId = document.getElementById('update-id');
        const updatePersonalNo = document.getElementById('update-personal-no');
        const updateRank = document.getElementById('update-rank');
        const updateName = document.getElementById('update-name');
        const updateMobilePersonal = document.getElementById('update-mobile-personal');
        const updateMobileFamily = document.getElementById('update-mobile-family');
        
        if (!updateId || !updatePersonalNo || !updateRank || !updateName) {
            throw new Error('Update form elements not found. Modal may not be properly loaded.');
        }
        
        updateId.value = operator.id;
        updatePersonalNo.value = operator.personal_no || '';
        updateRank.value = operator.rank || '';
        updateName.value = operator.name || '';
        if (updateMobilePersonal) updateMobilePersonal.value = operator.mobile_personal || '';
        if (updateMobileFamily) updateMobileFamily.value = operator.mobile_family || '';
        document.getElementById('update-course-cadre-name').value = operator.course_cadre_name || '';
        document.getElementById('update-birth-date').value = operator.birth_date || '';
        document.getElementById('update-admission-date').value = operator.admission_date || '';
        document.getElementById('update-joining-date-awgc').value = operator.joining_date_awgc || '';
        document.getElementById('update-civil-edu').value = operator.civil_edu || '';
        document.getElementById('update-course').value = operator.course || '';
        document.getElementById('update-cadre').value = operator.cadre || '';
        document.getElementById('update-permanent-address').value = operator.permanent_address || '';
        document.getElementById('update-present-address').value = operator.present_address || '';
        document.getElementById('update-worked-in-awgc').value = operator.worked_in_awgc || '';
        document.getElementById('update-expertise-area').value = operator.expertise_area || '';
        document.getElementById('update-punishment').value = operator.punishment || '';
        
        // Wait a moment for dropdowns to be populated, then set values
        setTimeout(() => {
            console.log('Setting dropdown values...');
            if (operator.cores_id) {
                const coresSelect = document.getElementById('update-cores');
                if (coresSelect) {
                    coresSelect.value = operator.cores_id;
                    console.log('Set cores to:', operator.cores_id);
                }
            }
            if (operator.unit_id) {
                const unitsSelect = document.getElementById('update-units');
                if (unitsSelect) {
                    unitsSelect.value = operator.unit_id;
                    console.log('Set units to:', operator.unit_id);
                }
            }
            if (operator.formation_id) {
                const formationsSelect = document.getElementById('update-formations');
                if (formationsSelect) {
                    formationsSelect.value = operator.formation_id;
                    console.log('Set formations to:', operator.formation_id);
                }
            }
            if (operator.med_category_id) {
                const medCategoriesSelect = document.getElementById('update-med_categories');
                if (medCategoriesSelect) {
                    medCategoriesSelect.value = operator.med_category_id;
                    console.log('Set med_categories to:', operator.med_category_id);
                }
            }
            // Handle exercises checkboxes
            const exercisesGroup = document.getElementById('update-exercises');
            if (exercisesGroup) {
                // Clear all checkboxes first
                const checkboxes = exercisesGroup.querySelectorAll('input[type="checkbox"]');
                checkboxes.forEach(checkbox => checkbox.checked = false);
                
                // Set exercises checkboxes if operator has exercises
                if (operator.exercise_ids && operator.exercise_ids.length > 0) {
                    operator.exercise_ids.forEach(exerciseId => {
                        const checkbox = exercisesGroup.querySelector(`input[value="${exerciseId}"]`);
                        if (checkbox) {
                            checkbox.checked = true;
                        }
                    });
                    console.log('Set exercises to:', operator.exercise_ids);
                }
            }
            
            // Handle special notes checkboxes
            const specialNotesGroup = document.getElementById('update-special-notes');
            if (specialNotesGroup) {
                const specialNotesCheckboxes = specialNotesGroup.querySelectorAll('input[type="checkbox"]');
                specialNotesCheckboxes.forEach(checkbox => checkbox.checked = false);
                
                if (operator.special_note_ids && operator.special_note_ids.length > 0) {
                    operator.special_note_ids.forEach(specialNoteId => {
                        const checkbox = specialNotesGroup.querySelector(`input[value="${specialNoteId}"]`);
                        if (checkbox) {
                            checkbox.checked = true;
                        }
                    });
                    console.log('Set special notes to:', operator.special_note_ids);
                }
            }
        }, 500); // Wait 500ms for dropdowns to be populated
        
        document.getElementById('update-modal').style.display = 'block';
    } catch (error) {
        console.error('Error in editOperator:', error);
        showError('Error loading operator data for editing');
    }
}

async function populateUpdateDropdowns() {
    try {
        console.log('Starting to populate update dropdowns...');
        const response = await fetch(`${API_BASE}options.php`);
        console.log('Options API response status:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const options = await response.json();
        console.log('Received options:', options);
        
        // Test if dropdowns exist
        const dropdowns = {
            'update-formations': document.getElementById('update-formations'),
            'update-med_categories': document.getElementById('update-med_categories'),
            'update-cores': document.getElementById('update-cores'),
            'update-exercises': document.getElementById('update-exercises'),
            'update-units': document.getElementById('update-units'),
            'update-rank': document.getElementById('update-rank')
        };
        
        console.log('Dropdown elements:', dropdowns);
        
        // Populate each dropdown manually
        if (options.formations && dropdowns['update-formations']) {
            console.log('Populating formations:', options.formations.length, 'items');
            let html = '<option value="">Select Formation...</option>';
            options.formations.forEach(item => {
                html += `<option value="${item.id}">${item.name}</option>`;
            });
            dropdowns['update-formations'].innerHTML = html;
        }
        
        if (options.med_categories && dropdowns['update-med_categories']) {
            console.log('Populating med_categories:', options.med_categories.length, 'items');
            let html = '<option value="">Select Med Category...</option>';
            options.med_categories.forEach(item => {
                html += `<option value="${item.id}">${item.name}</option>`;
            });
            dropdowns['update-med_categories'].innerHTML = html;
        }
        
        if (options.cores && dropdowns['update-cores']) {
            console.log('Populating corps:', options.cores.length, 'items');
            let html = '<option value="">Select Corps...</option>';
            options.cores.forEach(item => {
                html += `<option value="${item.id}">${item.name}</option>`;
            });
            dropdowns['update-cores'].innerHTML = html;
        }
        
        if (options.exercises && dropdowns['update-exercises']) {
            console.log('Populating exercises:', options.exercises.length, 'items');
            populateCheckboxGroup('update-exercises', options.exercises);
        }
        
        if (options.units && dropdowns['update-units']) {
            console.log('Populating units:', options.units.length, 'items');
            let html = '<option value="">Select Unit...</option>';
            options.units.forEach(item => {
                html += `<option value="${item.id}">${item.name}</option>`;
            });
            dropdowns['update-units'].innerHTML = html;
        }
        
        if (options.ranks && dropdowns['update-rank']) {
            console.log('Populating ranks:', options.ranks.length, 'items');
            let html = '<option value="">Select Rank...</option>';
            options.ranks.forEach(item => {
                html += `<option value="${item.name}">${item.name}</option>`;
            });
            dropdowns['update-rank'].innerHTML = html;
        }
        
        // Populate special notes checkboxes for update form
        if (options.special_notes) {
            populateCheckboxGroup('update-special-notes', options.special_notes);
            console.log('Update special notes populated:', options.special_notes.length);
        }
        
        console.log('Finished populating update dropdowns');
    } catch (error) {
        console.error('Error populating update dropdowns:', error);
    }
}

async function handleUpdateSubmit(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    const operatorData = {};
    
    // Handle regular form fields
    for (let [key, value] of formData.entries()) {
        if (key === 'exercise_ids[]') {
            // Handle checkbox arrays specially
            if (!operatorData.exercise_ids) {
                operatorData.exercise_ids = [];
            }
            operatorData.exercise_ids.push(value);
        } else if (key === 'special_note_ids[]') {
            // Handle special note checkbox arrays
            if (!operatorData.special_note_ids) {
                operatorData.special_note_ids = [];
            }
            operatorData.special_note_ids.push(value);
        } else {
            operatorData[key] = value || null;
        }
    }
    
    console.log('Update - Operator data to send:', operatorData);
    console.log('Update - Exercise IDs being sent:', operatorData.exercise_ids);
    
    // Show loading notification
    showLoading('Updating operator information...');
    
    try {
        console.log('Sending UPDATE request to:', `${API_BASE}operators.php`);
        console.log('Update data:', JSON.stringify(operatorData, null, 2));
        
        const response = await fetch(`${API_BASE}operators.php`, {
            method: 'PUT',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(operatorData)
        });
        
        console.log('Update response status:', response.status);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Update response error text:', errorText);
            throw new Error(`HTTP error! status: ${response.status} - ${errorText}`);
        }
        
        const result = await response.json();
        console.log('Update server response:', result);
        
        if (result.success || result.message === 'Updated') {
            showSuccess('Operator updated successfully!');
            closeUpdateModal();
            loadOperators();
        } else {
            showError('Error updating operator: ' + (result.error || result.message || 'Unknown error'));
            console.error('Update failed:', result);
        }
    } catch (error) {
        showError('Network error: Unable to update operator. Please try again.');
        console.error('Update error:', error);
    }
}

function closeUpdateModal() {
    document.getElementById('update-modal').style.display = 'none';
}

function showNotificationPopup(message, type, title = null) {
    const modal = document.getElementById('notification-modal');
    const icon = modal.querySelector('.notification-icon');
    const titleElement = modal.querySelector('.notification-title');
    const messageElement = modal.querySelector('.notification-message');
    const okButton = modal.querySelector('.notification-btn-ok');
    const closeButton = modal.querySelector('.notification-close');
    
    // Set modal type class
    modal.className = `notification-modal ${type}`;
    
    // Set icon
    icon.innerHTML = `<i class="fas ${getNotificationIcon(type)}"></i>`;
    
    // Set title
    titleElement.textContent = title || getNotificationTitle(type);
    
    // Set message
    messageElement.textContent = message;
    
    // Show modal
    modal.style.display = 'block';
    
    // Add event listeners
    const closeModal = () => {
        modal.style.display = 'none';
    };
    
    okButton.onclick = closeModal;
    closeButton.onclick = closeModal;
    
    // Close on outside click
    modal.onclick = (e) => {
        if (e.target === modal) {
            closeModal();
        }
    };
    
    // Auto-close for info messages after 3 seconds
    if (type === 'info') {
        setTimeout(closeModal, 3000);
    }
}

function getNotificationIcon(type) {
    switch(type) {
        case 'success': return 'fa-check-circle';
        case 'error': return 'fa-exclamation-circle';
        case 'warning': return 'fa-exclamation-triangle';
        case 'info': return 'fa-info-circle';
        default: return 'fa-info-circle';
    }
}

function getNotificationTitle(type) {
    switch(type) {
        case 'success': return 'Success';
        case 'error': return 'Error';
        case 'warning': return 'Warning';
        case 'info': return 'Information';
        default: return 'Notification';
    }
}

// Enhanced notification functions
function showSuccess(message, title = 'Success') {
    showNotificationPopup(message, 'success', title);
}

function showError(message, title = 'Error') {
    showNotificationPopup(message, 'error', title);
}

function showWarning(message, title = 'Warning') {
    showNotificationPopup(message, 'warning', title);
}

function showInfo(message, title = 'Information') {
    showNotificationPopup(message, 'info', title);
}

function showLoading(message, title = 'Please Wait') {
    showNotificationPopup(message, 'info', title);
}

// Legacy function for compatibility
function showAlert(message, type, duration = 3000) {
    showNotificationPopup(message, type);
}

// Compatibility function for showNotification
function showNotification(type, message, title = null) {
    showNotificationPopup(message, type, title);
}

// Custom Delete Confirmation Modal
function showDeleteConfirmation(message, onConfirm, onCancel = null) {
    return new Promise((resolve, reject) => {
        const modal = document.getElementById('delete-confirmation-modal');
        const messageElement = modal.querySelector('.delete-message');
        const cancelBtn = modal.querySelector('.notification-btn-cancel');
        const deleteBtn = modal.querySelector('.notification-btn-delete');
        const closeBtn = modal.querySelector('.notification-close');
        
        // Set the message
        messageElement.textContent = message;
        
        // Show modal
        modal.style.display = 'block';
        modal.classList.add('show');
        
        // Handle delete confirmation
        const handleDelete = () => {
            modal.style.display = 'none';
            modal.classList.remove('show');
            if (onConfirm) onConfirm();
            resolve(true);
            cleanup();
        };
        
        // Handle cancel
        const handleCancel = () => {
            modal.style.display = 'none';
            modal.classList.remove('show');
            if (onCancel) onCancel();
            resolve(false);
            cleanup();
        };
        
        // Cleanup event listeners
        const cleanup = () => {
            deleteBtn.removeEventListener('click', handleDelete);
            cancelBtn.removeEventListener('click', handleCancel);
            closeBtn.removeEventListener('click', handleCancel);
            modal.removeEventListener('click', handleOutsideClick);
            document.removeEventListener('keydown', handleEscapeKey);
        };
        
        // Handle clicking outside modal
        const handleOutsideClick = (e) => {
            if (e.target === modal) {
                handleCancel();
            }
        };
        
        // Handle escape key
        const handleEscapeKey = (e) => {
            if (e.key === 'Escape') {
                handleCancel();
            }
        };
        
        // Add event listeners
        deleteBtn.addEventListener('click', handleDelete);
        cancelBtn.addEventListener('click', handleCancel);
        closeBtn.addEventListener('click', handleCancel);
        modal.addEventListener('click', handleOutsideClick);
        document.addEventListener('keydown', handleEscapeKey);
        
        // Focus on cancel button by default (safer option)
        setTimeout(() => cancelBtn.focus(), 100);
    });
}

function showTab(tabName) {
    // Check if user has access to this tab
    const userRole = window.currentAdminRole || 'admin';
    const restrictedTabs = ['manage', 'bulk-upload', 'analytics', 'dashboard'];
    
    if (userRole === 'add_op' && restrictedTabs.includes(tabName)) {
        showAlert('Access denied. You can only access the Add Operator section.', 'error');
        return;
    }
    
    // Remove active class from all tabs and buttons
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.nav-tab').forEach(btn => btn.classList.remove('active'));
    
    // Add active class to selected tab and button
    document.getElementById(tabName).classList.add('active');
    event.target.classList.add('active');
    
    // Load operators when switching to manage tab
    if (tabName === 'manage') {
        loadOperators();
    }
    
    // Load dashboard options when dashboard tab is shown
    if (tabName === 'dashboard') {
        loadDashboardOptions();
        // Load animation settings when dashboard tab is shown
        setTimeout(() => {
            loadAnimationSettings();
        }, 100);
    }
    
    // Load admin users when admin-users tab is shown
    if (tabName === 'admin-users') {
        loadAdminUsers();
    }
    
    // Load analytics when analytics tab is shown
    if (tabName === 'analytics') {
        showAnalyticsTab();
    }
}


async function showAdminOperatorDetails(id) {
    try {
        const response = await fetch(`${API_BASE}operators.php?id=${id}`);
        const operator = await response.json();
        
        document.getElementById('admin-modal-title').textContent = operator.name;
        
        // Create special note banner if it exists (matching index.php style)
        let specialNoteBanner = '';
        if (operator.special_note_names && operator.special_note_names.length > 0) {
            specialNoteBanner = `
                <div class="special-note-banner">
                    <div class="special-note-icon">
                        <i class="fas fa-flag"></i>
                    </div>
                    <div class="special-note-content">
                        <strong>Special Notes:</strong> ${operator.special_note_names.join(', ')}
                    </div>
                </div>
            `;
        }
        
        document.getElementById('admin-modal-body').innerHTML = `
            ${specialNoteBanner}
            <div class="operator-details">
                <div class="detail-item">
                    <span class="detail-label">Personal No</span>
                    <span class="detail-value">${operator.personal_no || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Rank</span>
                    <span class="detail-value">${operator.rank || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Name</span>
                    <span class="detail-value">${operator.name || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Formation</span>
                    <span class="detail-value">${operator.formation_name || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Corps</span>
                    <span class="detail-value">${operator.cores_name || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Unit</span>
                    <span class="detail-value">${operator.unit_name || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Mobile (Personal)</span>
                    <span class="detail-value">${operator.mobile_personal || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Mobile (Family)</span>
                    <span class="detail-value">${operator.mobile_family || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Birth Date</span>
                    <span class="detail-value">${operator.birth_date || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Admission Date</span>
                    <span class="detail-value">${operator.admission_date || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Joining Date AWGC</span>
                    <span class="detail-value">${operator.joining_date_awgc || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Civil Education</span>
                    <span class="detail-value">${operator.civil_edu || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Course</span>
                    <span class="detail-value">${operator.course || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Cadre</span>
                    <span class="detail-value">${operator.cadre || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">OP Qualifying Course/Cader</span>
                    <span class="detail-value">${operator.course_cadre_name || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Medical Category</span>
                    <span class="detail-value">${operator.med_category_name || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Exercises</span>
                    <span class="detail-value">${operator.exercise_names ? operator.exercise_names.join(', ') : 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Permanent Address</span>
                    <span class="detail-value">${operator.permanent_address || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Present Address</span>
                    <span class="detail-value">${operator.present_address || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Worked in AWGC</span>
                    <span class="detail-value">${operator.worked_in_awgc || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Expertise Area</span>
                    <span class="detail-value">${operator.expertise_area || 'N/A'}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Punishment</span>
                    <span class="detail-value">${operator.punishment || 'N/A'}</span>
                </div>
            </div>
        `;
        
        document.getElementById('admin-operator-modal').style.display = 'block';
    } catch (error) {
        console.error('Error loading operator details:', error);
        showAlert('Error loading operator details', 'error');
    }
}

function closeDetailModal() {
    document.getElementById('admin-operator-modal').style.display = 'none';
}

function closeUpdateModal() {
    document.getElementById('update-modal').style.display = 'none';
}

// Test function to manually check dropdowns
function testDropdowns() {
    console.log('Testing dropdown population...');
    populateUpdateDropdowns();
}

// Dashboard Management Functions
async function loadDashboardOptions() {
    const optionTypes = ['formations', 'med_categories', 'cores', 'exercises', 'units', 'ranks', 'special_notes'];
    
    for (const type of optionTypes) {
        try {
            const response = await fetch(`${API_BASE}options.php?type=${type}`);
            const options = await response.json();
            displayOptionsList(type, options);
        } catch (error) {
            console.error(`Error loading ${type}:`, error);
            document.getElementById(`${type}-list`).innerHTML = '<div class="error">Error loading options</div>';
        }
    }
}

function displayOptionsList(type, options) {
    const container = document.getElementById(`${type}-list`);
    
    if (!options || options.length === 0) {
        container.innerHTML = '<div class="no-options">No options available</div>';
        return;
    }
    
    const html = options.map(option => `
        <div class="option-item">
            <span class="option-name">${option.name}</span>
            <div class="option-actions">
                <button class="btn btn-edit" onclick="editOption('${type}', ${option.id}, '${option.name}')">
                    <i class="fas fa-edit"></i> Edit
                </button>
                <button class="btn btn-delete" onclick="deleteOption('${type}', ${option.id}, '${option.name}')">
                    <i class="fas fa-trash"></i> Delete
                </button>
            </div>
        </div>
    `).join('');
    
    container.innerHTML = html;
}

function addNewOption(type) {
    document.getElementById('option-modal-title').textContent = `Add New ${getTypeDisplayName(type)}`;
    document.getElementById('option-type').value = type;
    document.getElementById('option-id').value = '';
    document.getElementById('option-name').value = '';
    document.getElementById('option-modal').style.display = 'block';
}

function editOption(type, id, name) {
    document.getElementById('option-modal-title').textContent = `Edit ${getTypeDisplayName(type)}`;
    document.getElementById('option-type').value = type;
    document.getElementById('option-id').value = id;
    document.getElementById('option-name').value = name;
    document.getElementById('option-modal').style.display = 'block';
}

async function deleteOption(type, id, name) {
    const confirmed = await showDeleteConfirmation(
        `Are you sure you want to delete "${name}"? This action cannot be undone.`
    );
    
    if (!confirmed) {
        return;
    }
    
    showLoading(`Deleting ${name}...`);
    
    try {
        const response = await fetch(`${API_BASE}manage-options.php`, {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({type, id})
        });
        
        const result = await response.json();
        
        if (result.success) {
            showSuccess(`${name} deleted successfully!`);
            loadDashboardOptions();
            loadDropdownOptions();
        } else {
            showError(result.message || 'Error deleting option');
        }
    } catch (error) {
        showError('Network error: Unable to delete option');
        console.error('Delete error:', error);
    }
}

function closeOptionModal() {
    document.getElementById('option-modal').style.display = 'none';
}

function getTypeDisplayName(type) {
    const displayNames = {
        'formations': 'Formation',
        'med_categories': 'Medical',
        'cores': 'Corps',
        'exercises': 'Exercise',
        'units': 'Unit',
        'ranks': 'Rank',
        'special_notes': 'Special Note'
    };
    return displayNames[type] || type;
}

async function handleOptionFormSubmit(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    const optionData = {
        type: formData.get('type'),
        id: formData.get('id'),
        name: formData.get('name')
    };
    
    const isEdit = optionData.id !== '';
    const action = isEdit ? 'PUT' : 'POST';
    
    showLoading(isEdit ? 'Updating option...' : 'Creating option...');
    
    try {
        const response = await fetch(`${API_BASE}manage-options.php`, {
            method: action,
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(optionData)
        });
        
        const result = await response.json();
        
        if (result.success) {
            showSuccess(isEdit ? 'Option updated successfully!' : 'Option created successfully!');
            closeOptionModal();
            loadDashboardOptions();
            loadDropdownOptions();
        } else {
            showError(result.message || 'Error saving option');
        }
    } catch (error) {
        showError('Network error: Unable to save option');
        console.error('Save error:', error);
    }
}

// Add this to window for manual testing
window.testDropdowns = testDropdowns;
window.editOperator = editOperator;

// Debug function to test edit operator manually
window.debugEditOperator = async function(id = 22) {
    console.log('=== DEBUG EDIT OPERATOR ===');
    console.log('Testing editOperator function with ID:', id);
    
    try {
        // Test if function exists
        if (typeof editOperator !== 'function') {
            console.error('editOperator function not found!');
            return;
        }
        
        // Test if modal exists
        const modal = document.getElementById('update-modal');
        if (!modal) {
            console.error('Update modal not found in DOM!');
            return;
        }
        console.log('✓ Update modal found');
        
        // Test if form exists
        const form = document.getElementById('update-form');
        if (!form) {
            console.error('Update form not found in DOM!');
            return;
        }
        console.log('✓ Update form found');
        
        // Test API endpoint
        console.log('Testing API endpoint...');
        const response = await fetch(`${API_BASE}operators.php?id=${id}`);
        console.log('API Response status:', response.status);
        
        if (!response.ok) {
            console.error('API request failed:', response.status);
            return;
        }
        
        const data = await response.json();
        console.log('✓ API data received:', data);
        
        // Now try the actual function
        console.log('Calling editOperator function...');
        await editOperator(id);
        
    } catch (error) {
        console.error('Debug test failed:', error);
    }
};

function setCurrentYear() {
    const currentYear = new Date().getFullYear();
    const yearElement = document.getElementById('current-year');
    if (yearElement) {
        yearElement.textContent = currentYear;
    }
}

// Operator Selection Functions
function toggleSelectAll() {
    const selectAllCheckbox = document.getElementById('select-all-operators');
    const operatorCheckboxes = document.querySelectorAll('.operator-checkbox');
    
    operatorCheckboxes.forEach(checkbox => {
        checkbox.checked = selectAllCheckbox.checked;
    });
    
    updateSelectedCount();
}

function updateSelectedCount() {
    const selectedCheckboxes = document.querySelectorAll('.operator-checkbox:checked');
    const selectedCount = selectedCheckboxes.length;
    const totalCheckboxes = document.querySelectorAll('.operator-checkbox');
    
    document.getElementById('selected-count').textContent = selectedCount;
    
    // Update select all checkbox state
    const selectAllCheckbox = document.getElementById('select-all-operators');
    if (selectAllCheckbox) {
        selectAllCheckbox.checked = selectedCount === totalCheckboxes.length;
        selectAllCheckbox.indeterminate = selectedCount > 0 && selectedCount < totalCheckboxes.length;
    }
    
    // Enable/disable export buttons based on selection
    updateExportButtonsState(selectedCount > 0);
    
    // Enable/disable delete selected button based on selection
    const deleteSelectedBtn = document.getElementById('delete-selected-btn');
    if (deleteSelectedBtn) {
        deleteSelectedBtn.disabled = selectedCount === 0;
    }
}

function updateExportButtonsState(hasSelection) {
    const exportBtn = document.getElementById('admin-export-dropdown-btn');
    const printBtn = document.querySelector('.admin-export-actions .print-btn');
    
    if (exportBtn) {
        exportBtn.disabled = !hasSelection;
        exportBtn.title = hasSelection ? 'Export selected operators' : 'Select operators to export';
    }
    
    if (printBtn) {
        printBtn.disabled = !hasSelection;
        printBtn.title = hasSelection ? 'Print selected operators' : 'Select operators to print';
    }
}

function getSelectedOperatorIds() {
    const selectedCheckboxes = document.querySelectorAll('.operator-checkbox:checked');
    return Array.from(selectedCheckboxes).map(checkbox => checkbox.value);
}

async function deleteSelectedOperators() {
    const selectedIds = getSelectedOperatorIds();
    
    if (selectedIds.length === 0) {
        showWarning('No operators selected for deletion.');
        return;
    }
    
    const confirmMessage = `Are you sure you want to delete ${selectedIds.length} selected operator${selectedIds.length > 1 ? 's' : ''}? This action cannot be undone.`;
    
    const confirmed = await showDeleteConfirmation(confirmMessage);
    
    if (!confirmed) {
        return;
    }
    
    showLoading(`Deleting ${selectedIds.length} operators...`, 'Please Wait');
    
    try {
        let successCount = 0;
        let failCount = 0;
        
        // Delete operators one by one
        for (const id of selectedIds) {
            try {
                const response = await fetch(`${API_BASE}operators.php`, {
                    method: 'DELETE',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({id: parseInt(id)})
                });
                
                if (response.ok) {
                    successCount++;
                } else {
                    failCount++;
                    console.error(`Failed to delete operator ${id}`);
                }
            } catch (error) {
                failCount++;
                console.error(`Error deleting operator ${id}:`, error);
            }
        }
        
        // Show results and reload
        if (successCount > 0) {
            showSuccess(`✅ Successfully deleted ${successCount} operator${successCount > 1 ? 's' : ''}.`);
            loadOperators(); // Reload the operators list
        }
        
        if (failCount > 0) {
            showError(`❌ Failed to delete ${failCount} operator${failCount > 1 ? 's' : ''}.`);
        }
        
    } catch (error) {
        showError('Error during bulk deletion. Please try again.');
        console.error('Bulk delete error:', error);
    }
}

// Export and Print Functions for Admin Panel
function exportAdminResults(format) {
    const selectedIds = getSelectedOperatorIds();
    
    if (selectedIds.length === 0) {
        alert('Please select at least one operator to export.');
        return;
    }
    
    const searchTerm = document.getElementById('search-operators').value;
    const adminFilters = getAdminFilters();
    const currentFilters = {
        search: searchTerm,
        selected_ids: selectedIds.join(','),
        rank: adminFilters.rank,
        corps: adminFilters.corps,
        exercise: adminFilters.exercise,
        special_note: adminFilters.special_note,
        formation: adminFilters.formation,
        unit: adminFilters.unit,
        selected_fields: getSelectedFields().join(',')
    };
    const exportUrl = buildAdminExportUrl('operators', format, currentFilters);
    
    // Show loading indicator
    showAdminExportLoading();
    
    // Create a temporary link to trigger download
    const link = document.createElement('a');
    link.href = exportUrl;
    link.target = '_blank';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Hide loading indicator after a short delay
    setTimeout(hideAdminExportLoading, 2000);
}

function printAdminResults() {
    const selectedIds = getSelectedOperatorIds();
    
    if (selectedIds.length === 0) {
        alert('Please select at least one operator to print.');
        return;
    }
    
    // Create a print-friendly version of the selected admin results
    const printWindow = window.open('', '_blank');
    const printContent = generateAdminPrintContent(selectedIds);
    
    printWindow.document.write(printContent);
    printWindow.document.close();
    
    // Wait for content to load, then print
    printWindow.onload = function() {
        printWindow.print();
        printWindow.close();
    };
}

function exportReport() {
    const reportType = document.getElementById('report-type').value;
    const dateFilter = document.getElementById('date-filter').value;
    
    const filters = {
        report_type: reportType,
        date_filter: dateFilter
    };
    
    const exportUrl = buildAdminExportUrl('analytics', 'csv', filters);
    
    // Create a temporary link to trigger download
    const link = document.createElement('a');
    link.href = exportUrl;
    link.target = '_blank';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function buildAdminExportUrl(action, format, filters) {
    const params = new URLSearchParams();
    params.append('action', action);
    params.append('format', format);
    
    Object.keys(filters).forEach(key => {
        if (filters[key]) {
            params.append(key, filters[key]);
        }
    });
    
    return `${API_BASE}export.php?${params.toString()}`;
}

function generateAdminPrintContent(selectedIds = null) {
    const searchTerm = document.getElementById('search-operators').value;
    let operatorsToPrint = allOperators;
    let title = 'All Operators';
    
    if (selectedIds && selectedIds.length > 0) {
        operatorsToPrint = allOperators.filter(operator => selectedIds.includes(operator.id.toString()));
        title = `Selected Operators (${selectedIds.length} operators)`;
        if (searchTerm) {
            title += ` - Search: "${searchTerm}"`;
        }
    } else if (searchTerm) {
        title = `Operators Search Results: "${searchTerm}"`;
    }
    
    const currentDate = new Date().toLocaleDateString();
    const totalResults = operatorsToPrint.length;
    
    let html = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>${title} - Admin Print</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                margin: 20px; 
                color: #333;
            }
            .print-header {
                text-align: center;
                border-bottom: 2px solid #007bff;
                padding-bottom: 20px;
                margin-bottom: 30px;
            }
            .print-header h1 {
                color: #007bff;
                margin: 0;
                font-size: 24px;
            }
            .print-info {
                display: flex;
                justify-content: space-between;
                margin-bottom: 20px;
                font-size: 14px;
                color: #666;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                font-size: 11px;
            }
            th, td {
                border: 1px solid #ddd;
                padding: 6px;
                text-align: left;
            }
            th {
                background-color: #f8f9fa;
                font-weight: bold;
                color: #495057;
            }
            tr:nth-child(even) {
                background-color: #f9f9f9;
            }
            .special-note {
                color: #dc3545;
                font-weight: bold;
                font-size: 9px;
            }
            @media print {
                body { margin: 0; }
                .print-header { page-break-inside: avoid; }
            }
            @page {
                margin: 0.75in;
                size: A4 portrait;
            }
        </style>
    </head>
    <body>
        <div class="print-header">
            <h1><i class="fas fa-graduation-cap"></i> Operator Information System - Admin Panel</h1>
            <h2>${title}</h2>
        </div>
        
        <div class="print-info">
            <div>Generated on: ${currentDate}</div>
            <div>Total Records: ${totalResults}</div>
        </div>
    `;
    
    if (operatorsToPrint.length > 0) {
        html += `
        <table>
            <thead>
                <tr>
                    <th>Personal No</th>
                    <th>Rank</th>
                    <th>Name</th>
                    <th>Corps</th>
                    <th>Unit</th>
                    <th>Mobile</th>
                </tr>
            </thead>
            <tbody>
        `;
        
        operatorsToPrint.forEach(operator => {
            html += `
                <tr>
                    <td>${operator.personal_no || 'N/A'}</td>
                    <td>${operator.rank || 'N/A'}</td>
                    <td>
                        ${operator.name}
                        ${operator.special_note_names && operator.special_note_names.length > 0 ? 
                            `<br><span class="special-note">${operator.special_note_names.join(', ')}</span>` : ''}
                    </td>
                    <td>${operator.cores_name || 'N/A'}</td>
                    <td>${operator.unit_name || 'N/A'}</td>
                    <td>${operator.mobile_personal || 'N/A'}</td>
                </tr>
            `;
        });
        
        html += `
            </tbody>
        </table>
        `;
    } else {
        html += '<p style="text-align: center; color: #666; font-style: italic;">No operators found.</p>';
    }
    
    html += `
        <div style="margin-top: 30px; text-align: center; font-size: 12px; color: #666;">
            <p>© ${new Date().getFullYear()} Operator Information System - Admin Panel. All rights reserved.</p>
        </div>
    </body>
    </html>
    `;
    
    return html;
}

function showAdminExportLoading() {
    const exportBtn = document.getElementById('admin-export-dropdown-btn');
    const originalContent = exportBtn.innerHTML;
    exportBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Exporting...';
    exportBtn.disabled = true;
    
    // Store original content for restoration
    exportBtn.dataset.originalContent = originalContent;
}

function hideAdminExportLoading() {
    const exportBtn = document.getElementById('admin-export-dropdown-btn');
    if (exportBtn.dataset.originalContent) {
        exportBtn.innerHTML = exportBtn.dataset.originalContent;
        exportBtn.disabled = false;
        delete exportBtn.dataset.originalContent;
    }
}

// Admin Filter Functions
function populateAdminFilterDropdown(selectId, options, useNameAsValue = false) {
    const select = document.getElementById(selectId);
    if (!select || !options) {
        return;
    }
    
    // Keep the default "All ..." option
    const defaultOption = select.querySelector('option[value=""]');
    select.innerHTML = '';
    if (defaultOption) {
        select.appendChild(defaultOption);
    }
    
    options.forEach(option => {
        const value = useNameAsValue ? option.name : option.id;
        const optionElement = document.createElement('option');
        optionElement.value = value;
        optionElement.textContent = option.name;
        select.appendChild(optionElement);
    });
}

function toggleFilters() {
    const filtersContent = document.getElementById('filters-content');
    const toggleBtn = document.getElementById('toggle-filters-btn');
    const isVisible = filtersContent.style.display !== 'none';
    
    if (isVisible) {
        filtersContent.style.display = 'none';
        toggleBtn.innerHTML = '<i class="fas fa-chevron-down"></i> Show Filters';
        toggleBtn.classList.remove('active');
    } else {
        filtersContent.style.display = 'block';
        toggleBtn.innerHTML = '<i class="fas fa-chevron-up"></i> Hide Filters';
        toggleBtn.classList.add('active');
    }
}

function applyAdminFilters() {
    const filters = getAdminFilters();
    
    // Filter the allOperators array based on selected filters
    let filteredOperators = [...allOperators];
    
    // Apply search filter first
    const searchTerm = document.getElementById('search-operators').value.trim().toLowerCase();
    if (searchTerm) {
        filteredOperators = filteredOperators.filter(operator => 
            operator.name.toLowerCase().includes(searchTerm) ||
            operator.personal_no.toLowerCase().includes(searchTerm) ||
            operator.rank.toLowerCase().includes(searchTerm)
        );
    }
    
    // Apply individual filters
    if (filters.rank) {
        filteredOperators = filteredOperators.filter(operator => operator.rank === filters.rank);
    }
    
    if (filters.corps) {
        filteredOperators = filteredOperators.filter(operator => operator.cores_id == filters.corps);
    }
    
    if (filters.exercise) {
        filteredOperators = filteredOperators.filter(operator => 
            operator.exercise_ids && operator.exercise_ids.includes(parseInt(filters.exercise))
        );
    }
    
    if (filters.special_note) {
        filteredOperators = filteredOperators.filter(operator => 
            operator.special_note_ids && operator.special_note_ids.includes(parseInt(filters.special_note))
        );
    }
    
    if (filters.formation) {
        filteredOperators = filteredOperators.filter(operator => operator.formation_id == filters.formation);
    }
    
    if (filters.unit) {
        filteredOperators = filteredOperators.filter(operator => operator.unit_id == filters.unit);
    }
    
    // Update the display
    displayOperators(filteredOperators);
    updateFilterSummary(filters);
}

function getAdminFilters() {
    return {
        rank: document.getElementById('admin-filter-rank').value,
        corps: document.getElementById('admin-filter-corps').value,
        exercise: document.getElementById('admin-filter-exercise').value,
        special_note: document.getElementById('admin-filter-special-note').value,
        formation: document.getElementById('admin-filter-formation').value,
        unit: document.getElementById('admin-filter-unit').value
    };
}

function clearAdminFilters() {
    document.getElementById('admin-filter-rank').value = '';
    document.getElementById('admin-filter-corps').value = '';
    document.getElementById('admin-filter-exercise').value = '';
    document.getElementById('admin-filter-special-note').value = '';
    document.getElementById('admin-filter-formation').value = '';
    document.getElementById('admin-filter-unit').value = '';
    
    // Also clear search
    document.getElementById('search-operators').value = '';
    
    // Reset display to all operators
    displayOperators(allOperators);
    updateFilterSummary({});
}

function updateFilterSummary(filters) {
    const summary = document.getElementById('filter-summary');
    const activeFilters = Object.entries(filters).filter(([key, value]) => value !== '');
    
    if (activeFilters.length === 0) {
        summary.textContent = 'No filters applied';
        summary.classList.remove('active');
    } else {
        summary.textContent = `${activeFilters.length} filter${activeFilters.length > 1 ? 's' : ''} applied`;
        summary.classList.add('active');
    }
}

// Field Selection Functions
let selectedFields = ['personal_no', 'rank', 'name', 'cores_name', 'mobile_personal']; // Default fields

function openFieldSelectionModal() {
    const modal = document.getElementById('field-selection-modal');
    modal.style.display = 'block';
    updateFieldSelectionCount();
}

function closeFieldSelectionModal() {
    const modal = document.getElementById('field-selection-modal');
    modal.style.display = 'none';
}

function selectAllFields() {
    const checkboxes = document.querySelectorAll('input[name="export_fields"]');
    checkboxes.forEach(checkbox => {
        checkbox.checked = true;
    });
    updateFieldSelectionCount();
}

function deselectAllFields() {
    const checkboxes = document.querySelectorAll('input[name="export_fields"]');
    checkboxes.forEach(checkbox => {
        checkbox.checked = false;
    });
    updateFieldSelectionCount();
}

function selectEssentialFields() {
    const essentialFields = ['personal_no', 'rank', 'name', 'cores_name', 'mobile_personal'];
    const checkboxes = document.querySelectorAll('input[name="export_fields"]');
    
    checkboxes.forEach(checkbox => {
        checkbox.checked = essentialFields.includes(checkbox.value);
    });
    updateFieldSelectionCount();
}

function updateFieldSelectionCount() {
    const checkedBoxes = document.querySelectorAll('input[name="export_fields"]:checked');
    const count = checkedBoxes.length;
    document.getElementById('selected-fields-count').textContent = count;
}

function applyFieldSelection() {
    const checkedBoxes = document.querySelectorAll('input[name="export_fields"]:checked');
    selectedFields = Array.from(checkedBoxes).map(checkbox => checkbox.value);
    
    if (selectedFields.length === 0) {
        alert('Please select at least one field to export.');
        return;
    }
    
    closeFieldSelectionModal();
    
    // Show confirmation message
    showInfo(`Field selection applied: ${selectedFields.length} fields selected for export.`);
}

function getSelectedFields() {
    return selectedFields;
}

// Add event listener for field checkboxes
document.addEventListener('DOMContentLoaded', function() {
    // Add event listeners to field checkboxes
    setTimeout(() => {
        const checkboxes = document.querySelectorAll('input[name="export_fields"]');
        checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', updateFieldSelectionCount);
        });
    }, 100);
});

function displayAdminPagination() {
    if (!paginationInfo || paginationInfo.total_pages <= 1) {
        return; // No pagination needed
    }
    
    const container = document.getElementById('operators-list');
    const paginationHTML = `
        <div class="pagination-container">
            <div class="pagination-info">
                Showing page ${paginationInfo.current_page} of ${paginationInfo.total_pages} 
                (${paginationInfo.total_records} total operators)
            </div>
            <div class="pagination-controls">
                <button class="pagination-btn" ${!paginationInfo.has_prev ? 'disabled' : ''} 
                        onclick="changeAdminPage(${paginationInfo.current_page - 1})">
                    <i class="fas fa-chevron-left"></i> Previous
                </button>
                
                ${generateAdminPageNumbers()}
                
                <button class="pagination-btn" ${!paginationInfo.has_next ? 'disabled' : ''} 
                        onclick="changeAdminPage(${paginationInfo.current_page + 1})">
                    Next <i class="fas fa-chevron-right"></i>
                </button>
            </div>
        </div>
    `;
    
    container.innerHTML += paginationHTML;
}

function generateAdminPageNumbers() {
    let pages = '';
    const current = paginationInfo.current_page;
    const total = paginationInfo.total_pages;
    
    // Show first page
    if (current > 3) {
        pages += `<button class="pagination-btn page-num" onclick="changeAdminPage(1)">1</button>`;
        if (current > 4) {
            pages += `<span class="pagination-dots">...</span>`;
        }
    }
    
    // Show pages around current
    for (let i = Math.max(1, current - 2); i <= Math.min(total, current + 2); i++) {
        pages += `<button class="pagination-btn page-num ${i === current ? 'active' : ''}" 
                          onclick="changeAdminPage(${i})">${i}</button>`;
    }
    
    // Show last page
    if (current < total - 2) {
        if (current < total - 3) {
            pages += `<span class="pagination-dots">...</span>`;
        }
        pages += `<button class="pagination-btn page-num" onclick="changeAdminPage(${total})">${total}</button>`;
    }
    
    return pages;
}

function changeAdminPage(page) {
    if (page < 1 || page > totalPages || page === currentPage) {
        return;
    }
    loadOperators(page);
}

// Utility Functions
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

// Admin Users Management Functions
function loadAdminUsers() {
    console.log('Loading admin users...');
    
    const tbody = document.getElementById('admin-users-tbody');
    if (!tbody) {
        console.error('Admin users table body not found');
        return;
    }
    
    // Show loading state
    tbody.innerHTML = '<tr><td colspan="8" class="loading">Loading admin users...</td></tr>';
    
    fetch('api/admin-users.php?action=list')
        .then(response => {
            console.log('Response status:', response.status);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Admin users data:', data);
            if (data.success) {
                displayAdminUsers(data.data);
            } else {
                console.error('Failed to load admin users:', data.message);
                tbody.innerHTML = `<tr><td colspan="8" class="error">Error: ${data.message}</td></tr>`;
                showNotification('error', 'Failed to load admin users: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error loading admin users:', error);
            tbody.innerHTML = `<tr><td colspan="8" class="error">Connection error: ${error.message}</td></tr>`;
            showNotification('error', 'Error loading admin users: ' + error.message);
        });
}

function displayAdminUsers(users) {
    const tbody = document.getElementById('admin-users-tbody');
    if (!tbody) return;
    
    if (users.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="no-data">No admin users found</td></tr>';
        return;
    }
    
    tbody.innerHTML = users.map(user => `
        <tr>
            <td>${user.id}</td>
            <td>${escapeHtml(user.username)}</td>
            <td>${escapeHtml(user.full_name)}</td>
            <td>${escapeHtml(user.email)}</td>
            <td>
                <span class="role-badge ${user.role === 'super_admin' ? 'super-admin' : (user.role === 'add_op' ? 'add-op' : 'admin')}">
                    ${user.role === 'super_admin' ? 'Super Admin' : (user.role === 'add_op' ? 'Add OP' : 'Admin')}
                </span>
            </td>
            <td>
                <span class="status-badge ${user.status}">
                    ${user.status === 'active' ? 'Active' : 'Inactive'}
                </span>
            </td>
            <td>${user.last_login ? formatDateTime(user.last_login) : 'Never'}</td>
            <td class="actions">
                <button class="btn btn-sm btn-primary" onclick="editAdminUser(${user.id})" title="Edit">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm btn-info" onclick="viewUserLoginLogs('${escapeHtml(user.username)}')" title="View Login Logs">
                    <i class="fas fa-history"></i>
                </button>
                <button class="btn btn-sm btn-warning" onclick="changeAdminPassword(${user.id})" title="Change Password">
                    <i class="fas fa-key"></i>
                </button>
                ${user.id != getCurrentAdminId() ? `
                <button class="btn btn-sm btn-danger" onclick="deleteAdminUser(${user.id}, '${escapeHtml(user.username)}')" title="Delete">
                    <i class="fas fa-trash"></i>
                </button>
                ` : ''}
            </td>
        </tr>
    `).join('');
}

function showAddAdminModal() {
    console.log('Opening add admin modal...');
    const modal = document.getElementById('add-admin-modal');
    const form = document.getElementById('add-admin-form');
    
    if (modal) {
        modal.style.display = 'block';
        console.log('Modal opened');
    } else {
        console.error('Add admin modal not found');
    }
    
    if (form) {
        form.reset();
        console.log('Form reset');
    } else {
        console.error('Add admin form not found');
    }
}

function closeAddAdminModal() {
    document.getElementById('add-admin-modal').style.display = 'none';
}

function editAdminUser(userId) {
    fetch(`api/admin-users.php?action=get&id=${userId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const user = data.data;
                document.getElementById('edit-admin-id').value = user.id;
                document.getElementById('edit-admin-username').value = user.username;
                document.getElementById('edit-admin-email').value = user.email;
                document.getElementById('edit-admin-full-name').value = user.full_name;
                document.getElementById('edit-admin-role').value = user.role;
                document.getElementById('edit-admin-status').value = user.status;
                
                document.getElementById('edit-admin-modal').style.display = 'block';
            } else {
                showNotification('error', 'Failed to load admin user: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error loading admin user:', error);
            showNotification('error', 'Error loading admin user');
        });
}

function closeEditAdminModal() {
    document.getElementById('edit-admin-modal').style.display = 'none';
}

function changeAdminPassword(userId) {
    document.getElementById('change-password-user-id').value = userId;
    document.getElementById('change-password-form').reset();
    document.getElementById('change-password-user-id').value = userId;
    document.getElementById('change-password-modal').style.display = 'block';
}

function closeChangePasswordModal() {
    document.getElementById('change-password-modal').style.display = 'none';
}

async function deleteAdminUser(userId, username) {
    const confirmed = await showDeleteConfirmation(
        `Are you sure you want to delete admin user "${username}"? This action cannot be undone.`
    );
    
    if (confirmed) {
        fetch(`api/admin-users.php?action=delete&id=${userId}`, {
            method: 'DELETE'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification('success', 'Admin user deleted successfully');
                loadAdminUsers();
            } else {
                showNotification('error', 'Failed to delete admin user: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error deleting admin user:', error);
            showNotification('error', 'Error deleting admin user');
        });
    }
}

function getCurrentAdminId() {
    // This should be set from PHP session data
    return window.currentAdminId || null;
}

function formatDateTime(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString();
}

// Custom Restore Confirmation Modal
function showRestoreConfirmation() {
    return new Promise((resolve, reject) => {
        // Create restore confirmation modal
        const modal = document.createElement('div');
        modal.className = 'notification-modal';
        modal.style.display = 'block';
        modal.innerHTML = `
            <div class="notification-modal-content restore-confirmation">
                <div class="notification-header">
                    <span class="notification-icon restore-icon">
                        <i class="fas fa-database"></i>
                    </span>
                    <span class="notification-title">Confirm Database Restore</span>
                    <span class="notification-close">&times;</span>
                </div>
                <div class="notification-body">
                    <p class="notification-message">Are you sure you want to restore the database from this backup?</p>
                    <div class="restore-warning">
                        <i class="fas fa-exclamation-triangle"></i>
                        <span><strong>WARNING:</strong> This will replace ALL current data with the backup data. This action cannot be undone.</span>
                    </div>
                </div>
                <div class="notification-footer restore-actions">
                    <button class="notification-btn-cancel">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button class="notification-btn-restore">
                        <i class="fas fa-database"></i> Restore Database
                    </button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        const cancelBtn = modal.querySelector('.notification-btn-cancel');
        const restoreBtn = modal.querySelector('.notification-btn-restore');
        const closeBtn = modal.querySelector('.notification-close');
        
        let isResolved = false;
        
        // Focus on cancel button (safer default)
        setTimeout(() => cancelBtn.focus(), 100);
        
        // Handle cancel
        const handleCancel = (e) => {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            if (isResolved) return;
            isResolved = true;
            
            cleanup();
            resolve(false);
        };
        
        // Handle restore
        const handleRestore = (e) => {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            if (isResolved) return;
            isResolved = true;
            
            cleanup();
            resolve(true);
        };
        
        // Handle escape key
        const handleEscape = (e) => {
            if (e.key === 'Escape') {
                handleCancel(e);
            }
        };
        
        // Handle click outside modal
        const handleOutsideClick = (e) => {
            if (e.target === modal) {
                handleCancel(e);
            }
        };
        
        // Cleanup function
        const cleanup = () => {
            cancelBtn.removeEventListener('click', handleCancel);
            restoreBtn.removeEventListener('click', handleRestore);
            closeBtn.removeEventListener('click', handleCancel);
            document.removeEventListener('keydown', handleEscape);
            modal.removeEventListener('click', handleOutsideClick);
            document.body.removeChild(modal);
        };
        
        // Add event listeners
        cancelBtn.addEventListener('click', handleCancel);
        restoreBtn.addEventListener('click', handleRestore);
        closeBtn.addEventListener('click', handleCancel);
        document.addEventListener('keydown', handleEscape);
        modal.addEventListener('click', handleOutsideClick);
    });
}

// Custom Logout Confirmation Modal
function showLogoutConfirmation() {
    return new Promise((resolve, reject) => {
        const modal = document.getElementById('logout-confirmation-modal');
        const cancelBtn = modal.querySelector('.notification-btn-cancel');
        const logoutBtn = modal.querySelector('.notification-btn-logout');
        const closeBtn = modal.querySelector('.notification-close');
        
        let isResolved = false; // Flag to prevent multiple resolves
        
        // Clear any existing event listeners first
        const newCancelBtn = cancelBtn.cloneNode(true);
        const newLogoutBtn = logoutBtn.cloneNode(true);
        const newCloseBtn = closeBtn.cloneNode(true);
        
        cancelBtn.parentNode.replaceChild(newCancelBtn, cancelBtn);
        logoutBtn.parentNode.replaceChild(newLogoutBtn, logoutBtn);
        closeBtn.parentNode.replaceChild(newCloseBtn, closeBtn);
        
        // Show modal
        modal.style.display = 'block';
        
        // Focus on cancel button (safer default)
        setTimeout(() => newCancelBtn.focus(), 100);
        
        // Handle cancel
        const handleCancel = (e) => {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            if (isResolved) return;
            isResolved = true;
            
            console.log('Cancel clicked - should not logout');
            modal.style.display = 'none';
            cleanup();
            resolve(false);
        };
        
        // Handle logout
        const handleLogout = (e) => {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            if (isResolved) return;
            isResolved = true;
            
            console.log('Logout clicked - should logout');
            modal.style.display = 'none';
            cleanup();
            resolve(true);
        };
        
        // Handle escape key
        const handleEscape = (e) => {
            if (e.key === 'Escape') {
                handleCancel(e);
            }
        };
        
        // Handle click outside modal
        const handleOutsideClick = (e) => {
            if (e.target === modal) {
                handleCancel(e);
            }
        };
        
        // Cleanup function
        const cleanup = () => {
            newCancelBtn.removeEventListener('click', handleCancel);
            newLogoutBtn.removeEventListener('click', handleLogout);
            newCloseBtn.removeEventListener('click', handleCancel);
            document.removeEventListener('keydown', handleEscape);
            modal.removeEventListener('click', handleOutsideClick);
        };
        
        // Add event listeners to new elements
        newCancelBtn.addEventListener('click', handleCancel);
        newLogoutBtn.addEventListener('click', handleLogout);
        newCloseBtn.addEventListener('click', handleCancel);
        document.addEventListener('keydown', handleEscape);
        modal.addEventListener('click', handleOutsideClick);
    });
}

// Logout function
async function logout() {
    const confirmed = await showLogoutConfirmation();
    
    if (!confirmed) {
        return;
    }
    
    fetch('api/auth.php?action=logout', {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showSuccess('Logged out successfully');
            setTimeout(() => {
                window.location.href = 'login.php';
            }, 1000);
        } else {
            showError('Logout failed: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Logout error:', error);
        showWarning('Logout request failed, redirecting anyway...');
        setTimeout(() => {
            window.location.href = 'login.php';
        }, 1500);
    });
}

// Admin form submission handlers
function handleAddAdminSubmit(e) {
    console.log('Add admin form submitted');
    e.preventDefault();
    
    const form = e.target;
    const submitButton = form.querySelector('button[type="submit"]');
    
    // Disable submit button to prevent double submission
    if (submitButton) {
        submitButton.disabled = true;
        submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating...';
    }
    
    const formData = new FormData(form);
    const adminData = Object.fromEntries(formData);
    
    console.log('Form data:', adminData);
    
    // Basic validation
    if (!adminData.username || !adminData.email || !adminData.password || !adminData.full_name) {
        showNotification('error', 'Please fill in all required fields');
        if (submitButton) {
            submitButton.disabled = false;
            submitButton.innerHTML = '<i class="fas fa-user-plus"></i> Create Admin';
        }
        return;
    }
    
    fetch('api/admin-users.php?action=create', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(adminData)
    })
    .then(response => {
        console.log('Create admin response status:', response.status);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        console.log('Create admin response:', data);
        if (data.success) {
            showNotification('success', 'Admin user created successfully');
            closeAddAdminModal();
            loadAdminUsers();
        } else {
            showNotification('error', 'Failed to create admin user: ' + (data.message || 'Unknown error'));
            if (data.errors) {
                console.error('Validation errors:', data.errors);
                // Show specific validation errors
                const errorMsg = Array.isArray(data.errors) ? data.errors.join(', ') : data.errors;
                showNotification('error', 'Validation errors: ' + errorMsg);
            }
        }
    })
    .catch(error => {
        console.error('Error creating admin user:', error);
        showNotification('error', 'Error creating admin user: ' + error.message);
    })
    .finally(() => {
        // Re-enable submit button
        if (submitButton) {
            submitButton.disabled = false;
            submitButton.innerHTML = '<i class="fas fa-user-plus"></i> Create Admin';
        }
    });
}

function handleEditAdminSubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const adminData = Object.fromEntries(formData);
    const userId = adminData.id;
    
    fetch(`api/admin-users.php?action=update&id=${userId}`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(adminData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('success', 'Admin user updated successfully');
            closeEditAdminModal();
            loadAdminUsers();
        } else {
            showNotification('error', 'Failed to update admin user: ' + (data.message || 'Unknown error'));
            if (data.errors) {
                console.error('Validation errors:', data.errors);
            }
        }
    })
    .catch(error => {
        console.error('Error updating admin user:', error);
        showNotification('error', 'Error updating admin user');
    });
}

function handleChangePasswordSubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const passwordData = Object.fromEntries(formData);
    
    // Validate password confirmation
    if (passwordData.new_password !== passwordData.confirm_password) {
        showNotification('error', 'Password confirmation does not match');
        return;
    }
    
    fetch('api/admin-users.php?action=change_password', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(passwordData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('success', 'Password changed successfully');
            closeChangePasswordModal();
        } else {
            showNotification('error', 'Failed to change password: ' + (data.message || 'Unknown error'));
            if (data.errors) {
                console.error('Validation errors:', data.errors);
            }
        }
    })
    .catch(error => {
        console.error('Error changing password:', error);
        showNotification('error', 'Error changing password');
    });
}

// Bulk Upload Functions
let csvData = [];
let uploadedFile = null;

function downloadTemplate(format = 'csv') {
    window.open(`api/bulk-upload.php?action=template&format=${format}`, '_blank');
}

function showSampleData() {
    fetch('api/bulk-upload.php?action=sample')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                displaySampleData(data.data);
            } else {
                showNotification('error', 'Failed to load sample data');
            }
        })
        .catch(error => {
            console.error('Error loading sample data:', error);
            showNotification('error', 'Error loading sample data');
        });
}

function displaySampleData(sampleData) {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.display = 'block';
    modal.innerHTML = `
        <div class="modal-content" style="max-width: 90%; max-height: 90%; overflow: auto;">
            <div class="modal-header">
                <h3><i class="fas fa-table"></i> Sample Data Format</h3>
                <span class="close" onclick="this.closest('.modal').remove()">&times;</span>
            </div>
            <div class="modal-body">
                <p>Here's an example of how your CSV data should be formatted:</p>
                <div class="preview-table-container">
                    <table class="preview-table">
                        <thead>
                            <tr>
                                ${Object.keys(sampleData[0]).map(key => `<th>${key.replace(/_/g, ' ').toUpperCase()}</th>`).join('')}
                            </tr>
                        </thead>
                        <tbody>
                            ${sampleData.map(row => `
                                <tr>
                                    ${Object.values(row).map(value => `<td>${value || ''}</td>`).join('')}
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="this.closest('.modal').remove()">Close</button>
            </div>
        </div>
    `;
    document.body.appendChild(modal);
}

// Initialize bulk upload when page loads
function initializeBulkUpload() {
    const fileInput = document.getElementById('bulk-file-input');
    const uploadArea = document.getElementById('file-upload-area');
    const chooseFileBtn = document.getElementById('choose-file-btn');
    
    if (fileInput && uploadArea) {
        // File input change handler
        fileInput.addEventListener('change', handleFileSelect);
        
        // Choose file button handler
        if (chooseFileBtn) {
            chooseFileBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                fileInput.click();
            });
        }
        
        // Drag and drop handlers
        uploadArea.addEventListener('dragover', handleDragOver);
        uploadArea.addEventListener('dragleave', handleDragLeave);
        uploadArea.addEventListener('drop', handleFileDrop);
        
        // Only allow clicking on the upload area itself (not the button) to trigger file selection
        uploadArea.addEventListener('click', (e) => {
            // Only trigger if clicking on the upload area itself, not the button
            if (e.target === uploadArea || e.target.closest('.upload-placeholder') && !e.target.closest('#choose-file-btn')) {
                fileInput.click();
            }
        });
    }
}

function handleFileSelect(event) {
    const file = event.target.files[0];
    if (file) {
        processFile(file);
    }
}

function handleDragOver(event) {
    event.preventDefault();
    event.currentTarget.classList.add('dragover');
}

function handleDragLeave(event) {
    event.currentTarget.classList.remove('dragover');
}

function handleFileDrop(event) {
    event.preventDefault();
    event.currentTarget.classList.remove('dragover');
    
    const files = event.dataTransfer.files;
    if (files.length > 0) {
        processFile(files[0]);
    }
}

function processFile(file) {
    // Validate file type
    const allowedTypes = ['text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
    const allowedExtensions = ['.csv', '.xls', '.xlsx'];
    
    const fileExtension = '.' + file.name.split('.').pop().toLowerCase();
    
    if (!allowedTypes.includes(file.type) && !allowedExtensions.includes(fileExtension)) {
        showNotification('error', 'Please select a CSV or Excel file');
        resetFileInput();
        return;
    }
    
    uploadedFile = file;
    
    // Show file info
    document.getElementById('file-name').textContent = file.name;
    document.getElementById('file-size').textContent = formatFileSize(file.size);
    
    // Update file icon based on file type
    const fileIcon = document.querySelector('#file-info .file-details i');
    if (fileIcon) {
        if (fileExtension === '.csv') {
            fileIcon.className = 'fas fa-file-csv';
        } else if (fileExtension === '.xlsx' || fileExtension === '.xls') {
            fileIcon.className = 'fas fa-file-excel';
        } else {
            fileIcon.className = 'fas fa-file';
        }
    }
    
    document.getElementById('file-info').style.display = 'block';
    document.getElementById('file-upload-area').style.display = 'none';
    
    // Read and parse file
    if (fileExtension === '.csv') {
        readCSVFile(file);
    } else if (fileExtension === '.xlsx' || fileExtension === '.xls') {
        readExcelFile(file);
    } else {
        showNotification('error', 'Unsupported file format. Please use CSV or Excel files.');
        resetFileInput();
    }
}

function resetFileInput() {
    const fileInput = document.getElementById('bulk-file-input');
    if (fileInput) {
        fileInput.value = '';
    }
}

function readCSVFile(file) {
    const reader = new FileReader();
    reader.onload = function(e) {
        const csv = e.target.result;
        parseCSV(csv);
    };
    reader.readAsText(file);
}

function readExcelFile(file) {
    // Check if SheetJS library is available
    if (typeof XLSX === 'undefined') {
        showNotification('error', 'Excel processing library not loaded. Please convert to CSV format.');
        resetFileInput();
        return;
    }
    
    showNotification('info', 'Processing Excel file...');
    
    const reader = new FileReader();
    reader.onload = function(e) {
        try {
            const data = new Uint8Array(e.target.result);
            const workbook = XLSX.read(data, {type: 'array'});
            
            if (workbook.SheetNames.length === 0) {
                showNotification('error', 'Excel file contains no worksheets');
                resetFileInput();
                return;
            }
            
            const firstSheetName = workbook.SheetNames[0];
            const worksheet = workbook.Sheets[firstSheetName];
            const csv = XLSX.utils.sheet_to_csv(worksheet);
            
            if (!csv.trim()) {
                showNotification('error', 'Excel worksheet is empty');
                resetFileInput();
                return;
            }
            
            showNotification('success', 'Excel file processed successfully');
            parseCSV(csv);
        } catch (error) {
            showNotification('error', 'Error reading Excel file: ' + error.message);
            resetFileInput();
        }
    };
    
    reader.onerror = function() {
        showNotification('error', 'Error reading file');
        resetFileInput();
    };
    
    reader.readAsArrayBuffer(file);
}

function parseCSV(csv) {
    const lines = csv.split('\n').filter(line => line.trim());
    if (lines.length < 2) {
        showNotification('error', 'CSV file must contain at least a header row and one data row');
        return;
    }
    
    const headers = lines[0].split(',').map(h => h.trim().replace(/"/g, ''));
    const data = [];
    
    for (let i = 1; i < lines.length; i++) {
        const values = parseCSVLine(lines[i]);
        if (values.length === headers.length) {
            const row = {};
            headers.forEach((header, index) => {
                row[header] = values[index] || '';
            });
            data.push(row);
        }
    }
    
    csvData = data;
    displayPreview(headers, data);
}

function parseCSVLine(line) {
    const result = [];
    let current = '';
    let inQuotes = false;
    
    for (let i = 0; i < line.length; i++) {
        const char = line[i];
        
        if (char === '"') {
            inQuotes = !inQuotes;
        } else if (char === ',' && !inQuotes) {
            result.push(current.trim());
            current = '';
        } else {
            current += char;
        }
    }
    
    result.push(current.trim());
    return result;
}

function displayPreview(headers, data) {
    const previewSection = document.getElementById('preview-section');
    const previewStats = document.getElementById('preview-stats');
    const previewThead = document.getElementById('preview-thead');
    const previewTbody = document.getElementById('preview-tbody');
    
    // Show preview section
    previewSection.style.display = 'block';
    
    // Update stats
    previewStats.innerHTML = `
        <div class="preview-stat">
            <i class="fas fa-table"></i>
            <span>Total Rows: ${data.length}</span>
        </div>
        <div class="preview-stat">
            <i class="fas fa-columns"></i>
            <span>Columns: ${headers.length}</span>
        </div>
        <div class="preview-stat">
            <i class="fas fa-file"></i>
            <span>File: ${uploadedFile.name}</span>
        </div>
    `;
    
    // Update table headers
    previewThead.innerHTML = `
        <tr>
            ${headers.map(header => `<th>${header.replace(/_/g, ' ').toUpperCase()}</th>`).join('')}
        </tr>
    `;
    
    // Update table body (show first 10 rows)
    const displayData = data.slice(0, 10);
    previewTbody.innerHTML = displayData.map(row => `
        <tr>
            ${headers.map(header => `<td title="${escapeHtml(row[header] || '')}">${escapeHtml(row[header] || '')}</td>`).join('')}
        </tr>
    `).join('');
    
    if (data.length > 10) {
        previewTbody.innerHTML += `
            <tr>
                <td colspan="${headers.length}" style="text-align: center; font-style: italic; color: #6c757d;">
                    ... and ${data.length - 10} more rows
                </td>
            </tr>
        `;
    }
}

function clearFile() {
    uploadedFile = null;
    csvData = [];
    document.getElementById('bulk-file-input').value = '';
    document.getElementById('file-info').style.display = 'none';
    document.getElementById('file-upload-area').style.display = 'block';
    clearPreview();
}

function clearPreview() {
    document.getElementById('preview-section').style.display = 'none';
    document.getElementById('upload-results').style.display = 'none';
}

function processBulkUpload() {
    if (!csvData || csvData.length === 0) {
        showNotification('error', 'No data to upload');
        return;
    }
    
    const uploadBtn = document.getElementById('upload-btn');
    uploadBtn.disabled = true;
    uploadBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Uploading...';
    
    fetch('api/bulk-upload.php?action=upload', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            operators: csvData
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            displayUploadResults(data.results);
            
            // Build success message with auto-registration info
            let successMessage = `Upload completed! ${data.results.successful} operators added successfully.`;
            
            if (data.results.auto_registered) {
                const totalAutoReg = Object.values(data.results.auto_registered).reduce((sum, arr) => sum + arr.length, 0);
                if (totalAutoReg > 0) {
                    successMessage += ` ${totalAutoReg} new reference items were automatically registered.`;
                    
                    // Refresh dropdown options to include newly registered items
                    refreshDropdownOptions();
                }
            }
            
            showNotification('success', successMessage);
            
            // Refresh operator list to show new entries
            loadOperators();
        } else {
            showNotification('error', 'Upload failed: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Upload error:', error);
        showNotification('error', 'Upload failed: ' + error.message);
    })
    .finally(() => {
        uploadBtn.disabled = false;
        uploadBtn.innerHTML = '<i class="fas fa-check"></i> Upload All Data';
    });
}

function displayUploadResults(results) {
    const resultsSection = document.getElementById('upload-results');
    const resultsSummary = document.getElementById('results-summary');
    const resultsDetails = document.getElementById('results-details');
    
    // Show results section
    resultsSection.style.display = 'block';
    
    // Update summary
    resultsSummary.innerHTML = `
        <div class="result-card total">
            <div class="result-number">${results.total}</div>
            <div class="result-label">Total Records</div>
        </div>
        <div class="result-card success">
            <div class="result-number">${results.successful}</div>
            <div class="result-label">Successful</div>
        </div>
        <div class="result-card error">
            <div class="result-number">${results.failed}</div>
            <div class="result-label">Failed</div>
        </div>
    `;
    
    // Build details content
    let detailsContent = '';
    
    // Show auto-registered items if any
    if (results.auto_registered) {
        const autoRegItems = [];
        const categories = {
            'formations': 'Formations',
            'cores': 'Corps',
            'units': 'Units', 
            'ranks': 'Ranks',
            'exercises': 'Exercises',
            'special_notes': 'Special Notes',
            'med_categories': 'Medical Categories'
        };
        
        Object.keys(categories).forEach(key => {
            if (results.auto_registered[key] && results.auto_registered[key].length > 0) {
                autoRegItems.push({
                    category: categories[key],
                    items: results.auto_registered[key]
                });
            }
        });
        
        if (autoRegItems.length > 0) {
            detailsContent += `
                <div class="auto-registered-section">
                    <h5><i class="fas fa-plus-circle" style="color: #3498db;"></i> Auto-Registered Items</h5>
                    <div class="auto-registered-info">
                        <p style="margin-bottom: 15px; color: #7f8c8d;">
                            <i class="fas fa-info-circle"></i> 
                            The following new items were automatically added to the system settings:
                        </p>
                        <div class="auto-registered-grid">
                            ${autoRegItems.map(item => `
                                <div class="auto-reg-category">
                                    <div class="auto-reg-header">
                                        <i class="fas fa-tag"></i> ${item.category} (${item.items.length})
                                    </div>
                                    <div class="auto-reg-items">
                                        ${item.items.map(name => `<span class="auto-reg-item">${name}</span>`).join('')}
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                        <div class="auto-registered-note">
                            <i class="fas fa-lightbulb"></i>
                            These items are now available in the Settings → Manage Options section for future use.
                        </div>
                    </div>
                </div>
            `;
        }
    }
    
    // Show errors if any
    if (results.errors && results.errors.length > 0) {
        detailsContent += `
            <div class="errors-section">
                <h5><i class="fas fa-exclamation-triangle"></i> Errors (${results.errors.length})</h5>
                <div class="error-list">
                    ${results.errors.map(error => `
                        <div class="error-item">
                            <div class="error-row">Row ${error.row}: ${error.personal_no}</div>
                            <div class="error-message">${error.error}</div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    } else if (!detailsContent) {
        detailsContent = `
            <div style="text-align: center; color: #27ae60; padding: 20px;">
                <i class="fas fa-check-circle" style="font-size: 2rem; margin-bottom: 10px;"></i>
                <p>All records were uploaded successfully!</p>
            </div>
        `;
    }
    
    resultsDetails.innerHTML = detailsContent;
    
    // Scroll to results
    resultsSection.scrollIntoView({ behavior: 'smooth' });
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Analytics Report Functions
let mainChart = null;
let secondaryChart = null;

function loadAnalyticsSummary() {
    fetch(API_BASE + 'analytics.php?action=summary')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                updateSummaryCards(data.data);
            } else {
                showNotification('error', 'Failed to load summary data: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error loading analytics summary:', error);
            showNotification('error', 'Error loading analytics summary');
        });
}

function updateSummaryCards(data) {
    // Debug: Log special note names for Trg NCO matching
    if (data.debug_special_note_names) {
        console.log('=== TRG NCO DEBUG INFORMATION ===');
        console.log('All special note names:', data.debug_special_note_names);
        console.log('Trg NCO count from special notes:', data.trg_nco);
        console.log('Special notes data:', data.special_notes);
        console.log('=================================');
    }
    
    // Update main summary cards
    document.getElementById('total-operators').textContent = data.total_operators || 0;
    document.getElementById('total-formations').textContent = data.total_formations || 0;
    document.getElementById('total-units').textContent = data.total_units || 0;
    document.getElementById('total-exercises').textContent = data.total_exercises || 0;
    
    // Update header quick stats
    const quickTotalOperators = document.getElementById('quick-total-operators');
    const quickTrgNco = document.getElementById('quick-trg-nco');
    
    if (quickTotalOperators) {
        quickTotalOperators.textContent = data.total_operators || 0;
    }
    if (quickTrgNco) {
        quickTrgNco.textContent = data.trg_nco || 0;
    }
    
    // Create dynamic special notes cards
    createSpecialNotesCards(data.special_notes || []);
    
    // Load corps metrics
    loadCorpsMetrics();
}

function createSpecialNotesCards(specialNotes) {
    const summaryCardsContainer = document.getElementById('summary-cards');
    
    // Remove existing special notes cards
    const existingSpecialCards = summaryCardsContainer.querySelectorAll('.special-note-card');
    existingSpecialCards.forEach(card => card.remove());
    
    // Create cards for each special note type
    specialNotes.forEach((note, index) => {
        const card = document.createElement('div');
        card.className = 'modern-summary-card special-note-card';
        card.setAttribute('data-metric', 'special-note');
        
        // Get appropriate icon for the special note
        const icon = getSpecialNoteIcon(note.name);
        
        // Use person icon specifically for Trg NCO
        const finalIcon = note.name.toLowerCase().includes('trg nco') || 
                         note.name.toLowerCase().includes('training nco') ? 
                         'fas fa-user-tie' : icon;
        
        // Get color scheme based on index
        const colorSchemes = [
            'linear-gradient(135deg, #ec4899, #be185d)',
            'linear-gradient(135deg, #06b6d4, #0891b2)',
            'linear-gradient(135deg, #84cc16, #65a30d)',
            'linear-gradient(135deg, #f97316, #ea580c)',
            'linear-gradient(135deg, #a855f7, #9333ea)'
        ];
        const colorScheme = colorSchemes[index % colorSchemes.length];
        
        card.innerHTML = `
            <div class="card-background"></div>
            <div class="card-icon" style="background: ${colorScheme};">
                <i class="${finalIcon}"></i>
            </div>
            <div class="card-content">
                <h4>${note.count}</h4>
                <p>${note.name}</p>
                <div class="card-trend">
                    <i class="fas fa-info-circle"></i>
                    <span>Special Note</span>
                </div>
            </div>
        `;
        
        // Add appropriate styling based on index
        const cardIndex = 5 + index; // Start from 5th position (after exercises)
        card.style.setProperty('--card-index', cardIndex);
        
        summaryCardsContainer.appendChild(card);
    });
}

function getSpecialNoteIcon(noteName) {
    const iconMap = {
        'Died': 'fas fa-skull-crossbones',
        'Instructor': 'fas fa-chalkboard-teacher',
        'Injured': 'fas fa-user-injured',
        'Transferred': 'fas fa-plane-departure',
        'Retired': 'fas fa-user-clock',
        'Promoted': 'fas fa-arrow-up',
        'Demoted': 'fas fa-arrow-down',
        'Suspended': 'fas fa-pause-circle',
        'Active': 'fas fa-user-check',
        'Inactive': 'fas fa-user-times',
        'AWGC Prohibited': 'fas fa-times-circle',
        'AWGC prohibited': 'fas fa-times-circle',
        'awgc prohibited': 'fas fa-times-circle'
    };
    
    // Check for partial matches for AWGC prohibited variations
    const lowerNoteName = noteName.toLowerCase();
    if (lowerNoteName.includes('awgc') && lowerNoteName.includes('prohibited')) {
        return 'fas fa-times-circle';
    }
    
    return iconMap[noteName] || 'fas fa-sticky-note';
}

function loadReport() {
    const reportType = document.getElementById('report-type').value;
    const dateFilter = document.getElementById('date-filter').value;
    
    // Show loading state
    showLoadingCharts();
    
    fetch(`${API_BASE}analytics.php?action=report&type=${reportType}&date_filter=${dateFilter}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                displayReportData(data.data, reportType);
            } else {
                showNotification('error', 'Failed to load report: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Error loading report:', error);
            showNotification('error', 'Error loading report');
        });
}

function showLoadingCharts() {
    // Clear existing charts
    if (mainChart) {
        mainChart.destroy();
        mainChart = null;
    }
    if (secondaryChart) {
        secondaryChart.destroy();
        secondaryChart = null;
    }
    
    // Show loading message in chart containers
    const chartContainers = document.querySelectorAll('.chart-content');
    if (chartContainers.length >= 2) {
        chartContainers[0].innerHTML = '<div class="loading-chart"><i class="fas fa-spinner"></i>Loading chart data...</div>';
        chartContainers[1].innerHTML = '<div class="loading-chart"><i class="fas fa-spinner"></i>Loading chart data...</div>';
    }
}

function displayReportData(data, reportType) {
    // Update chart titles
    document.getElementById('chart-title').textContent = data.title || 'Report Data';
    document.getElementById('secondary-chart-title').textContent = 'Additional Analysis';
    
    // Restore canvas elements
    document.querySelector('.chart-content').innerHTML = '<canvas id="main-chart"></canvas>';
    document.querySelectorAll('.chart-content')[1].innerHTML = '<canvas id="secondary-chart"></canvas>';
    
    // Wait a moment for DOM to update, then create charts
    setTimeout(() => {
        createChartsForReportType(data, reportType);
    }, 100);
}

function createChartsForReportType(data, reportType) {
    // Destroy existing charts
    if (mainChart) {
        mainChart.destroy();
        mainChart = null;
    }
    if (secondaryChart) {
        secondaryChart.destroy();
        secondaryChart = null;
    }
    
    const mainCanvas = document.getElementById('main-chart');
    const secondaryCanvas = document.getElementById('secondary-chart');
    
    if (!mainCanvas || !secondaryCanvas) {
        console.error('Canvas elements not found, retrying...');
        setTimeout(() => createChartsForReportType(data, reportType), 100);
        return;
    }
    
    // Create charts based on report type
    switch (reportType) {
        case 'overview':
            createOverviewCharts(data);
            break;
        case 'rank-distribution':
            createRankDistributionChart(data);
            break;
        case 'formation-analysis':
            createFormationAnalysisChart(data);
            break;
        case 'unit-breakdown':
            createUnitBreakdownChart(data);
            break;
        case 'exercise-participation':
            createExerciseParticipationChart(data);
            break;
        case 'medical-categories':
            createMedicalCategoriesChart(data);
            break;
        case 'age-demographics':
            createAgeDemographicsChart(data);
            break;
        case 'service-length':
            createServiceLengthChart(data);
            break;
    }
    
    // Update data table
    updateReportTable(data, reportType);
}


function createOverviewCharts(data) {
    // Main chart - Rank distribution
    const ctx1 = document.getElementById('main-chart');
    if (!ctx1) {
        console.error('Main chart canvas not found');
        return;
    }
    
    try {
        mainChart = new Chart(ctx1.getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: data.rank_distribution.map(item => item.rank),
            datasets: [{
                data: data.rank_distribution.map(item => item.count),
                backgroundColor: [
                    '#FF6384',
                    '#36A2EB',
                    '#FFCE56',
                    '#4BC0C0',
                    '#9966FF',
                    '#FF9F40'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Rank Distribution'
                },
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
    } catch (error) {
        console.error('Error creating main chart:', error);
        showNotification('error', 'Error creating main chart');
        return;
    }
    
    // Secondary chart - Formation distribution
    const ctx2 = document.getElementById('secondary-chart');
    if (!ctx2) {
        console.error('Secondary chart canvas not found');
        return;
    }
    
    try {
        secondaryChart = new Chart(ctx2.getContext('2d'), {
        type: 'bar',
        data: {
            labels: data.formation_distribution.map(item => item.name || 'Unknown'),
            datasets: [{
                label: 'Operators',
                data: data.formation_distribution.map(item => item.count),
                backgroundColor: '#36A2EB'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Formation Distribution'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    } catch (error) {
        console.error('Error creating secondary chart:', error);
        showNotification('error', 'Error creating secondary chart');
    }
}

function createRankDistributionChart(data) {
    const ctx = document.getElementById('main-chart').getContext('2d');
    mainChart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: data.distribution.map(item => item.rank),
            datasets: [{
                data: data.distribution.map(item => item.count),
                backgroundColor: [
                    '#FF6384',
                    '#36A2EB',
                    '#FFCE56',
                    '#4BC0C0',
                    '#9966FF',
                    '#FF9F40'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Rank Distribution'
                },
                legend: {
                    position: 'right'
                }
            }
        }
    });
    
    // Hide secondary chart for this report
    document.querySelectorAll('.chart-content')[1].innerHTML = '<div class="loading-chart">No additional data for this report</div>';
}

function createFormationAnalysisChart(data) {
    const ctx = document.getElementById('main-chart').getContext('2d');
    mainChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.formations.map(item => item.formation || 'Unknown'),
            datasets: [{
                label: 'Number of Operators',
                data: data.formations.map(item => item.count),
                backgroundColor: '#36A2EB'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Operators by Formation'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    
    // Secondary chart - Average age by formation
    const ctx2 = document.getElementById('secondary-chart').getContext('2d');
    secondaryChart = new Chart(ctx2, {
        type: 'line',
        data: {
            labels: data.formations.map(item => item.formation || 'Unknown'),
            datasets: [{
                label: 'Average Age',
                data: data.formations.map(item => item.avg_age),
                borderColor: '#FF6384',
                backgroundColor: 'rgba(255, 99, 132, 0.1)',
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Average Age by Formation'
                }
            },
            scales: {
                y: {
                    beginAtZero: false
                }
            }
        }
    });
}

function createUnitBreakdownChart(data) {
    const ctx = document.getElementById('main-chart').getContext('2d');
    mainChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.units.map(item => item.unit || 'Unknown'),
            datasets: [{
                label: 'Number of Operators',
                data: data.units.map(item => item.count),
                backgroundColor: '#4BC0C0'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            indexAxis: 'y',
            plugins: {
                title: {
                    display: true,
                    text: 'Operators by Unit'
                }
            },
            scales: {
                x: {
                    beginAtZero: true
                }
            }
        }
    });
    
    // Hide secondary chart
    document.querySelectorAll('.chart-content')[1].innerHTML = '<div class="loading-chart">No additional data for this report</div>';
}

function createExerciseParticipationChart(data) {
    const ctx = document.getElementById('main-chart').getContext('2d');
    mainChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: data.exercises.map(item => item.exercise),
            datasets: [{
                data: data.exercises.map(item => item.participants),
                backgroundColor: [
                    '#FF6384',
                    '#36A2EB',
                    '#FFCE56',
                    '#4BC0C0',
                    '#9966FF',
                    '#FF9F40',
                    '#FF6384',
                    '#36A2EB'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Exercise Participation'
                },
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
    
    // Hide secondary chart
    document.querySelectorAll('.chart-content')[1].innerHTML = '<div class="loading-chart">No additional data for this report</div>';
}

function createMedicalCategoriesChart(data) {
    const ctx = document.getElementById('main-chart').getContext('2d');
    mainChart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: data.categories.map(item => item.category || 'Unknown'),
            datasets: [{
                data: data.categories.map(item => item.count),
                backgroundColor: [
                    '#FF6384',
                    '#36A2EB',
                    '#FFCE56',
                    '#4BC0C0',
                    '#9966FF'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Medical Categories'
                },
                legend: {
                    position: 'right'
                }
            }
        }
    });
    
    // Hide secondary chart
    document.querySelectorAll('.chart-content')[1].innerHTML = '<div class="loading-chart">No additional data for this report</div>';
}

function createAgeDemographicsChart(data) {
    const ctx = document.getElementById('main-chart').getContext('2d');
    mainChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.age_groups.map(item => item.age_group),
            datasets: [{
                label: 'Number of Operators',
                data: data.age_groups.map(item => item.count),
                backgroundColor: '#FFCE56'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Age Demographics'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    
    // Hide secondary chart
    document.querySelectorAll('.chart-content')[1].innerHTML = '<div class="loading-chart">No additional data for this report</div>';
}

function createServiceLengthChart(data) {
    const ctx = document.getElementById('main-chart').getContext('2d');
    mainChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: data.service_lengths.map(item => item.service_length),
            datasets: [{
                data: data.service_lengths.map(item => item.count),
                backgroundColor: [
                    '#9966FF',
                    '#FF9F40',
                    '#FF6384',
                    '#36A2EB',
                    '#4BC0C0'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Service Length Distribution'
                },
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
    
    // No secondary chart for service length
    document.querySelectorAll('.chart-content')[1].innerHTML = '<div class="loading-chart">No additional data for this report</div>';
}

function updateReportTable(data, reportType) {
    const tableHead = document.getElementById('report-table-head');
    const tableBody = document.getElementById('report-table-body');
    
    tableHead.innerHTML = '';
    tableBody.innerHTML = '';
    
    let headers = [];
    let rows = [];
    
    switch (reportType) {
        case 'rank-distribution':
            headers = ['Rank', 'Count', 'Percentage'];
            rows = data.distribution.map(item => [item.rank, item.count, item.percentage + '%']);
            break;
            
        case 'formation-analysis':
            headers = ['Formation', 'Operators', 'Average Age', 'Units'];
            rows = data.formations.map(item => [
                item.formation || 'Unknown',
                item.count,
                item.avg_age + ' years',
                item.units_count
            ]);
            break;
            
        case 'unit-breakdown':
            headers = ['Unit', 'Formation', 'Operators'];
            rows = data.units.map(item => [
                item.unit || 'Unknown',
                item.formation || 'Unknown',
                item.count
            ]);
            break;
            
        case 'exercise-participation':
            headers = ['Exercise', 'Participants'];
            rows = data.exercises.map(item => [item.exercise, item.participants]);
            break;
            
        case 'medical-categories':
            headers = ['Category', 'Count'];
            rows = data.categories.map(item => [item.category || 'Unknown', item.count]);
            break;
            
        case 'age-demographics':
            headers = ['Age Group', 'Count'];
            rows = data.age_groups.map(item => [item.age_group, item.count]);
            break;
            
        case 'service-length':
            headers = ['Service Length', 'Count'];
            rows = data.service_lengths.map(item => [item.service_length, item.count]);
            break;
            
            
        default:
            headers = ['Data'];
            rows = [['No detailed data available for this report']];
    }
    
    // Create header row
    const headerRow = document.createElement('tr');
    headers.forEach(header => {
        const th = document.createElement('th');
        th.textContent = header;
        headerRow.appendChild(th);
    });
    tableHead.appendChild(headerRow);
    
    // Create data rows
    rows.forEach(rowData => {
        const row = document.createElement('tr');
        rowData.forEach(cellData => {
            const td = document.createElement('td');
            td.textContent = cellData;
            row.appendChild(td);
        });
        tableBody.appendChild(row);
    });
}

function filterReportTable() {
    const searchTerm = document.getElementById('table-search').value.toLowerCase();
    const tableRows = document.querySelectorAll('#report-table tbody tr');
    
    tableRows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

function exportReport(format = 'csv') {
    const reportType = document.getElementById('report-type').value;
    const dateFilter = document.getElementById('date-filter').value;
    
    if (!reportType) {
        alert('Please select a report type first.');
        return;
    }
    
    const url = `${API_BASE}analytics.php?action=export&type=${reportType}&date_filter=${dateFilter}&format=${format}`;
    
    if (format === 'pdf') {
        // Open PDF in new window for printing
        window.open(url, '_blank');
    } else {
        // Download CSV/Excel files
        const link = document.createElement('a');
        link.href = url;
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
}

// Analytics Export Dropdown
document.addEventListener('DOMContentLoaded', function() {
    const analyticsExportBtn = document.getElementById('analytics-export-dropdown-btn');
    const analyticsExportMenu = document.getElementById('analytics-export-menu');
    
    if (analyticsExportBtn && analyticsExportMenu) {
        analyticsExportBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            analyticsExportMenu.classList.toggle('show');
        });
        
        // Close dropdown when clicking outside
        document.addEventListener('click', function() {
            analyticsExportMenu.classList.remove('show');
        });
        
        analyticsExportMenu.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }
});

// Modern Analytics Functions
function downloadChart(chartType) {
    const canvas = document.getElementById(chartType === 'main' ? 'main-chart' : 'secondary-chart');
    if (canvas) {
        const link = document.createElement('a');
        link.download = `${chartType}-chart-${new Date().toISOString().split('T')[0]}.png`;
        link.href = canvas.toDataURL();
        link.click();
    }
}

function fullscreenChart(chartType) {
    const container = document.querySelector(chartType === 'main' ? '.primary-chart' : '.secondary-chart');
    if (container) {
        if (container.requestFullscreen) {
            container.requestFullscreen();
        } else if (container.webkitRequestFullscreen) {
            container.webkitRequestFullscreen();
        } else if (container.msRequestFullscreen) {
            container.msRequestFullscreen();
        }
    }
}

function exportTableData() {
    const table = document.getElementById('report-table');
    if (!table) return;
    
    let csv = '';
    const rows = table.querySelectorAll('tr');
    
    rows.forEach(row => {
        const cols = row.querySelectorAll('td, th');
        const rowData = Array.from(cols).map(col => {
            let text = col.textContent.trim();
            // Escape quotes and wrap in quotes if contains comma
            if (text.includes(',') || text.includes('"')) {
                text = '"' + text.replace(/"/g, '""') + '"';
            }
            return text;
        });
        csv += rowData.join(',') + '\n';
    });
    
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `analytics-data-${new Date().toISOString().split('T')[0]}.csv`;
    link.click();
    window.URL.revokeObjectURL(url);
}

// Chart view toggle functionality
document.addEventListener('DOMContentLoaded', function() {
    const chartToggles = document.querySelectorAll('.chart-toggle');
    const chartsGrid = document.getElementById('charts-grid');
    
    chartToggles.forEach(toggle => {
        toggle.addEventListener('click', function() {
            chartToggles.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            
            const view = this.getAttribute('data-view');
            if (view === 'single') {
                chartsGrid.classList.add('single-view');
            } else {
                chartsGrid.classList.remove('single-view');
            }
        });
    });
});

// Initialize analytics when tab is shown
function showAnalyticsTab() {
    // Ensure Chart.js is loaded before proceeding
    if (typeof Chart === 'undefined') {
        console.log('Chart.js not loaded yet, retrying...');
        setTimeout(showAnalyticsTab, 200);
        return;
    }
    
    // Ensure DOM elements exist
    const analyticsTab = document.getElementById('analytics');
    if (!analyticsTab || !analyticsTab.classList.contains('active')) {
        console.log('Analytics tab not active yet, retrying...');
        setTimeout(showAnalyticsTab, 100);
        return;
    }
    
    // Small delay to ensure DOM is fully ready
    setTimeout(() => {
        console.log('Loading analytics data...');
        loadAnalyticsSummary();
        loadReport();
    }, 150);
}

// Login Logs Functionality
function showLoginLogsModal() {
    document.getElementById('login-logs-modal').style.display = 'block';
    loadUsernamesForFilter();
    loadLoginLogs();
}

function closeLoginLogsModal() {
    document.getElementById('login-logs-modal').style.display = 'none';
}

async function loadUsernamesForFilter() {
    try {
        const response = await fetch(`${API_BASE}admin-users.php?action=list`);
        const result = await response.json();
        
        if (result.success) {
            const select = document.getElementById('username-filter');
            select.innerHTML = '<option value="">All Users</option>';
            
            result.data.forEach(user => {
                const option = document.createElement('option');
                option.value = user.username;
                option.textContent = user.username;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading usernames:', error);
    }
}

async function loadLoginLogs(page = 1) {
    const tbody = document.getElementById('login-logs-tbody');
    tbody.innerHTML = '<tr><td colspan="6" class="loading">Loading login logs...</td></tr>';
    
    try {
        const username = document.getElementById('username-filter').value;
        let url = `${API_BASE}admin-users.php?action=login_logs&page=${page}&limit=20`;
        
        if (username) {
            url += `&username=${encodeURIComponent(username)}`;
        }
        
        const response = await fetch(url);
        const result = await response.json();
        
        if (result.success) {
            displayLoginLogs(result.data);
            displayLoginLogsPagination(result.pagination);
        } else {
            tbody.innerHTML = `<tr><td colspan="6" class="error">Error: ${result.message}</td></tr>`;
        }
    } catch (error) {
        console.error('Error loading login logs:', error);
        tbody.innerHTML = '<tr><td colspan="6" class="error">Failed to load login logs</td></tr>';
    }
}

function displayLoginLogs(logs) {
    const tbody = document.getElementById('login-logs-tbody');
    
    if (logs.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="no-data">No login logs found</td></tr>';
        return;
    }
    
    tbody.innerHTML = logs.map(log => `
        <tr>
            <td>${formatDateTime(log.created_at)}</td>
            <td><strong>${log.username}</strong></td>
            <td>
                <span class="status-badge ${log.success ? 'success' : 'failed'}">
                    <i class="fas ${log.success ? 'fa-check-circle' : 'fa-times-circle'}"></i>
                    ${log.success ? 'Success' : 'Failed'}
                </span>
            </td>
            <td>${log.ip_address || 'N/A'}</td>
            <td class="user-agent" title="${log.user_agent || 'N/A'}">
                ${truncateText(log.user_agent || 'N/A', 30)}
            </td>
            <td>${log.details || 'N/A'}</td>
        </tr>
    `).join('');
}

function displayLoginLogsPagination(pagination) {
    const container = document.getElementById('login-logs-pagination');
    
    if (pagination.total_pages <= 1) {
        container.innerHTML = '';
        return;
    }
    
    let paginationHTML = '<div class="pagination">';
    
    // Previous button
    if (pagination.has_prev) {
        paginationHTML += `<button class="pagination-btn" onclick="loadLoginLogs(${pagination.current_page - 1})">
            <i class="fas fa-chevron-left"></i> Previous
        </button>`;
    }
    
    // Page numbers
    const startPage = Math.max(1, pagination.current_page - 2);
    const endPage = Math.min(pagination.total_pages, pagination.current_page + 2);
    
    if (startPage > 1) {
        paginationHTML += `<button class="pagination-btn" onclick="loadLoginLogs(1)">1</button>`;
        if (startPage > 2) {
            paginationHTML += '<span class="pagination-ellipsis">...</span>';
        }
    }
    
    for (let i = startPage; i <= endPage; i++) {
        paginationHTML += `<button class="pagination-btn ${i === pagination.current_page ? 'active' : ''}" 
                          onclick="loadLoginLogs(${i})">${i}</button>`;
    }
    
    if (endPage < pagination.total_pages) {
        if (endPage < pagination.total_pages - 1) {
            paginationHTML += '<span class="pagination-ellipsis">...</span>';
        }
        paginationHTML += `<button class="pagination-btn" onclick="loadLoginLogs(${pagination.total_pages})">${pagination.total_pages}</button>`;
    }
    
    // Next button
    if (pagination.has_next) {
        paginationHTML += `<button class="pagination-btn" onclick="loadLoginLogs(${pagination.current_page + 1})">
            Next <i class="fas fa-chevron-right"></i>
        </button>`;
    }
    
    paginationHTML += '</div>';
    paginationHTML += `<div class="pagination-info">
        Showing ${(pagination.current_page - 1) * pagination.limit + 1} to 
        ${Math.min(pagination.current_page * pagination.limit, pagination.total_records)} of 
        ${pagination.total_records} entries
    </div>`;
    
    container.innerHTML = paginationHTML;
}

function truncateText(text, maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
}

function viewUserLoginLogs(username) {
    document.getElementById('login-logs-modal').style.display = 'block';
    loadUsernamesForFilter();
    
    // Set the username filter and load logs
    setTimeout(() => {
        document.getElementById('username-filter').value = username;
        loadLoginLogs();
    }, 100);
}

// Clear Logs Functionality
function showClearLogsModal() {
    document.getElementById('clear-logs-modal').style.display = 'block';
    loadUsernamesForClearLogs();
}

function closeClearLogsModal() {
    document.getElementById('clear-logs-modal').style.display = 'none';
    document.getElementById('clear-logs-form').reset();
    document.getElementById('clear-logs-preview').style.display = 'none';
}

async function loadUsernamesForClearLogs() {
    try {
        const response = await fetch(`${API_BASE}admin-users.php?action=list`);
        const result = await response.json();
        
        if (result.success) {
            const select = document.getElementById('clear-username');
            select.innerHTML = '<option value="">Select User...</option>';
            
            result.data.forEach(user => {
                const option = document.createElement('option');
                option.value = user.username;
                option.textContent = user.username;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading usernames for clear logs:', error);
    }
}

// Handle clear logs form submission
document.addEventListener('DOMContentLoaded', function() {
    const clearLogsForm = document.getElementById('clear-logs-form');
    if (clearLogsForm) {
        clearLogsForm.addEventListener('submit', handleClearLogs);
        
        // Hide preview when clear type changes
        const radioButtons = clearLogsForm.querySelectorAll('input[name="clear_type"]');
        radioButtons.forEach(radio => {
            radio.addEventListener('change', function() {
                document.getElementById('clear-logs-preview').style.display = 'none';
            });
        });
    }
});

async function handleClearLogs(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    const clearType = formData.get('clear_type');
    const username = formData.get('username');
    const daysOld = formData.get('days_old');
    
    // Validate input based on clear type
    if (clearType === 'user' && !username) {
        showAlert('Please select a username to clear logs for.', 'error');
        return;
    }
    
    if (clearType === 'older_than' && (!daysOld || daysOld < 1)) {
        showAlert('Please enter a valid number of days (1 or more).', 'error');
        return;
    }
    
    // Confirm the action
    let confirmMessage = 'Are you sure you want to clear ';
    switch (clearType) {
        case 'all':
            confirmMessage += 'ALL login logs?';
            break;
        case 'failed':
            confirmMessage += 'all FAILED login attempts?';
            break;
        case 'older_than':
            confirmMessage += `all login logs older than ${daysOld} days?`;
            break;
        case 'user':
            confirmMessage += `all login logs for user "${username}"?`;
            break;
    }
    confirmMessage += '\n\nThis action cannot be undone!';
    
    if (!confirm(confirmMessage)) {
        return;
    }
    
    try {
        showLoading('Clearing login logs...');
        
        const requestData = {
            type: clearType,
            username: username,
            days_old: daysOld ? parseInt(daysOld) : 0
        };
        
        const response = await fetch(`${API_BASE}admin-users.php?action=clear_logs`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(requestData)
        });
        
        const result = await response.json();
        
        if (result.success) {
            showSuccess(`Successfully cleared ${result.deleted_count} login log entries.`);
            closeClearLogsModal();
            loadLoginLogs(); // Refresh the logs display
        } else {
            showError(result.message || 'Failed to clear login logs');
        }
        
    } catch (error) {
        console.error('Error clearing login logs:', error);
        showError('Network error: Failed to clear login logs. Please try again.');
    }
}

async function previewClearLogs() {
    const clearType = document.querySelector('input[name="clear_type"]:checked').value;
    const username = document.getElementById('clear-username').value;
    const daysOld = document.getElementById('days-old').value;
    
    // Validate input based on clear type
    if (clearType === 'user' && !username) {
        showAlert('Please select a username to preview logs for.', 'error');
        return;
    }
    
    if (clearType === 'older_than' && (!daysOld || daysOld < 1)) {
        showAlert('Please enter a valid number of days (1 or more).', 'error');
        return;
    }
    
    try {
        // Build query parameters for preview
        let url = `${API_BASE}admin-users.php?action=login_logs&limit=1000`;
        
        if (clearType === 'user' && username) {
            url += `&username=${encodeURIComponent(username)}`;
        }
        
        const response = await fetch(url);
        const result = await response.json();
        
        if (result.success) {
            let count = 0;
            let description = '';
            
            if (clearType === 'all') {
                count = result.pagination.total_records;
                description = 'all login log entries';
            } else if (clearType === 'failed') {
                count = result.data.filter(log => !log.success).length;
                description = 'failed login attempts';
            } else if (clearType === 'older_than') {
                const cutoffDate = new Date();
                cutoffDate.setDate(cutoffDate.getDate() - parseInt(daysOld));
                count = result.data.filter(log => new Date(log.created_at) < cutoffDate).length;
                description = `login logs older than ${daysOld} days`;
            } else if (clearType === 'user') {
                count = result.data.length;
                description = `login logs for user "${username}"`;
            }
            
            const previewSection = document.getElementById('clear-logs-preview');
            const previewText = document.getElementById('preview-text');
            
            previewText.innerHTML = `This will delete <strong>${count}</strong> ${description}`;
            previewSection.style.display = 'block';
            
            if (count === 0) {
                previewText.innerHTML = `<span style="color: #28a745;">No matching log entries found to delete.</span>`;
            }
            
        } else {
            showError('Failed to preview logs: ' + result.message);
        }
        
    } catch (error) {
        console.error('Error previewing clear logs:', error);
        showError('Network error: Failed to preview logs. Please try again.');
    }
}

// Corps Metrics Functions
async function loadCorpsMetrics() {
    try {
        console.log('Loading corps metrics...');
        const response = await fetch(`${API_BASE}analytics.php?type=corps_distribution`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        console.log('Corps metrics data:', data);
        
        if (data.success && data.data) {
            createCorpsCards(data.data);
        } else {
            throw new Error(data.message || 'Failed to load corps metrics');
        }
    } catch (error) {
        console.error('Error loading corps metrics:', error);
        showCorpsError(error.message);
    }
}

function createCorpsCards(corpsData) {
    const corpsContainer = document.getElementById('corps-cards');
    if (!corpsContainer) return;
    
    // Define color schemes for different corps
    const corpsColors = [
        'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', // Infantry (EB)
        'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)', // Armoured
        'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)', // Artillery
        'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)', // Engineers
        'linear-gradient(135deg, #fa709a 0%, #fee140 100%)', // Signals
        'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)', // Air Defence
        'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)', // ASC
        'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)', // Infantry (BIR)
        'linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)', // Ordnance
        'linear-gradient(135deg, #fad0c4 0%, #ffd1ff 100%)'  // EME
    ];
    
    // Define icons for different corps
    const corpsIcons = {
        'Infantry (EB)': 'fas fa-user-shield',
        'Infantry (BIR)': 'fas fa-users',
        'Armoured': 'fas fa-shield-alt',
        'Artillery': 'fas fa-crosshairs',
        'Engineers': 'fas fa-tools',
        'Signals': 'fas fa-broadcast-tower',
        'Air Defence': 'fas fa-fighter-jet',
        'ASC': 'fas fa-truck',
        'Ordnance': 'fas fa-bomb',
        'EME': 'fas fa-cogs'
    };
    
    let html = '';
    
    corpsData.forEach((corps, index) => {
        const color = corpsColors[index % corpsColors.length];
        const icon = corpsIcons[corps.name] || 'fas fa-shield-alt';
        const percentage = corpsData.length > 0 ? ((corps.count / corpsData.reduce((sum, c) => sum + c.count, 0)) * 100).toFixed(1) : 0;
        
        html += `
            <div class="corps-card" style="--corps-color: ${color}">
                <div class="corps-card-header">
                    <div class="corps-card-icon">
                        <i class="${icon}"></i>
                    </div>
                    <div class="corps-card-count">${corps.count}</div>
                </div>
                <div class="corps-card-body">
                    <div class="corps-card-title">${corps.name}</div>
                    <div class="corps-card-subtitle">${percentage}% of total</div>
                </div>
            </div>
        `;
    });
    
    corpsContainer.innerHTML = html;
}

function showCorpsError(message) {
    const corpsContainer = document.getElementById('corps-cards');
    if (!corpsContainer) return;
    
    corpsContainer.innerHTML = `
        <div class="loading-corps">
            <i class="fas fa-exclamation-triangle" style="color: #e74c3c;"></i>
            <span>Error loading corps data: ${message}</span>
        </div>
    `;
}

// ==========================================
// BACKUP/RESTORE FUNCTIONALITY
// ==========================================

// Initialize backup/restore functionality when tab is shown
function initializeBackupRestore() {
    console.log('Initializing backup/restore functionality...');
    
    // Load existing backups
    refreshBackupList();
    
    // Setup file upload handlers
    setupFileUploadHandlers();
}

// Create a new backup
async function createBackup() {
    const createBtn = document.getElementById('create-backup-btn');
    const originalText = createBtn.innerHTML;
    
    try {
        // Show loading state
        createBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating Backup...';
        createBtn.disabled = true;
        
        console.log('Creating database backup...');
        const response = await fetch(`${API_BASE}backup.php?action=backup`);
        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to create backup');
        }
        
        showSuccess(`Backup created successfully: ${result.data.filename} (${result.data.size_formatted})`);
        
        // Refresh the backup list
        refreshBackupList();
        
        console.log('Backup created:', result.data);
        
    } catch (error) {
        console.error('Error creating backup:', error);
        showError('Failed to create backup: ' + error.message);
    } finally {
        // Restore button state
        createBtn.innerHTML = originalText;
        createBtn.disabled = false;
    }
}

// Load and display existing backups
async function refreshBackupList() {
    const container = document.getElementById('backup-list-container');
    
    try {
        // Show loading state
        container.innerHTML = `
            <div class="loading-backups">
                <div class="spinner"></div>
                <p>Loading backups...</p>
            </div>
        `;
        
        console.log('Loading backup list...');
        const response = await fetch(`${API_BASE}backup.php?action=list`);
        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to load backups');
        }
        
        displayBackupList(result.data);
        console.log('Backup list loaded:', result.data);
        
    } catch (error) {
        console.error('Error loading backups:', error);
        container.innerHTML = `
            <div class="no-backups">
                <i class="fas fa-exclamation-triangle"></i>
                <h4>Error Loading Backups</h4>
                <p>${error.message}</p>
                <button class="btn btn-secondary btn-sm" onclick="refreshBackupList()">
                    <i class="fas fa-sync-alt"></i> Try Again
                </button>
            </div>
        `;
    }
}

// Display backup list
function displayBackupList(backups) {
    const container = document.getElementById('backup-list-container');
    
    if (!backups || backups.length === 0) {
        container.innerHTML = `
            <div class="no-backups">
                <i class="fas fa-archive"></i>
                <h4>No Backups Found</h4>
                <p>Create your first backup to get started</p>
            </div>
        `;
        return;
    }
    
    let html = '<div class="backup-list">';
    
    backups.forEach(backup => {
        html += `
            <div class="backup-item">
                <div class="backup-item-info">
                    <div class="backup-filename">
                        <i class="fas fa-file-archive"></i>
                        ${backup.filename}
                    </div>
                    <div class="backup-details">
                        <span><i class="fas fa-calendar"></i> ${backup.created_at}</span>
                        <span><i class="fas fa-hdd"></i> ${backup.size_formatted}</span>
                        <span><i class="fas fa-clock"></i> ${backup.age}</span>
                    </div>
                </div>
                <div class="backup-item-actions">
                    <button class="btn btn-info btn-sm" onclick="downloadBackup('${backup.filename}')" title="Download">
                        <i class="fas fa-download"></i>
                    </button>
                    <button class="btn btn-danger btn-sm" onclick="deleteBackup('${backup.filename}')" title="Delete">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        `;
    });
    
    html += '</div>';
    container.innerHTML = html;
}

// Download backup file
function downloadBackup(filename) {
    try {
        console.log('Downloading backup:', filename);
        
        // Create a temporary link and trigger download
        const link = document.createElement('a');
        link.href = `${API_BASE}backup.php?action=download&filename=${encodeURIComponent(filename)}`;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        showInfo(`Downloading backup: ${filename}`);
        
    } catch (error) {
        console.error('Error downloading backup:', error);
        showError('Failed to download backup: ' + error.message);
    }
}

// Delete backup file
async function deleteBackup(filename) {
    const confirmed = await showDeleteConfirmation(
        `Are you sure you want to delete the backup "${filename}"? This action cannot be undone.`
    );
    
    if (!confirmed) {
        return;
    }
    
    try {
        console.log('Deleting backup:', filename);
        
        const response = await fetch(`${API_BASE}backup.php?action=delete`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ filename: filename })
        });
        
        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to delete backup');
        }
        
        showSuccess(`Backup deleted successfully: ${filename}`);
        
        // Refresh the backup list
        refreshBackupList();
        
    } catch (error) {
        console.error('Error deleting backup:', error);
        showError('Failed to delete backup: ' + error.message);
    }
}

// Setup file upload handlers
function setupFileUploadHandlers() {
    const uploadArea = document.getElementById('backup-upload-area');
    const fileInput = document.getElementById('backup-file-input');
    const chooseFileBtn = document.getElementById('choose-backup-file-btn');
    
    if (!uploadArea || !fileInput) return;
    
    // Remove existing event listeners to prevent duplicates
    if (uploadArea._backupHandlersAdded) return;
    
    // Handle drag and drop
    uploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });
    
    uploadArea.addEventListener('dragleave', (e) => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
    });
    
    uploadArea.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            handleFileSelection(files[0]);
        }
    });
    
    // Handle choose file button click
    if (chooseFileBtn) {
        chooseFileBtn.addEventListener('click', (e) => {
            e.stopPropagation(); // Prevent event bubbling
            fileInput.click();
        });
    }
    
    // Handle file input change
    fileInput.addEventListener('change', (e) => {
        if (e.target.files.length > 0) {
            handleFileSelection(e.target.files[0]);
        }
    });
    
    // Mark that handlers have been added
    uploadArea._backupHandlersAdded = true;
}

// Handle file selection for restore
function handleFileSelection(file) {
    console.log('File selected:', file.name, file.size);
    
    // Validate file type
    if (!file.name.toLowerCase().endsWith('.sql')) {
        showError('Invalid file type. Please select a .sql backup file.');
        return;
    }
    
    // Validate file size (max 50MB)
    const maxSize = 50 * 1024 * 1024; // 50MB
    if (file.size > maxSize) {
        showError('File is too large. Maximum size is 50MB.');
        return;
    }
    
    // Store file for later use
    window.selectedBackupFile = file;
    
    // Show file info
    const fileInfo = document.getElementById('selected-file-info');
    const fileName = document.getElementById('selected-file-name');
    const fileSize = document.getElementById('selected-file-size');
    const restoreControls = document.getElementById('restore-controls');
    const uploadArea = document.getElementById('backup-upload-area');
    
    fileName.textContent = file.name;
    fileSize.textContent = formatFileSize(file.size);
    
    fileInfo.style.display = 'flex';
    restoreControls.style.display = 'block';
    uploadArea.style.display = 'none';
}

// Clear selected file
function clearSelectedFile() {
    window.selectedBackupFile = null;
    
    const fileInfo = document.getElementById('selected-file-info');
    const restoreControls = document.getElementById('restore-controls');
    const uploadArea = document.getElementById('backup-upload-area');
    const fileInput = document.getElementById('backup-file-input');
    
    fileInfo.style.display = 'none';
    restoreControls.style.display = 'none';
    uploadArea.style.display = 'block';
    fileInput.value = '';
}

// Restore backup from uploaded file
async function restoreBackup() {
    if (!window.selectedBackupFile) {
        showError('No backup file selected');
        return;
    }
    
    const confirmed = await showRestoreConfirmation();
    
    if (!confirmed) {
        return;
    }
    
    const restoreBtn = document.getElementById('restore-backup-btn');
    const originalText = restoreBtn.innerHTML;
    
    try {
        // Show loading state
        restoreBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Restoring...';
        restoreBtn.disabled = true;
        
        console.log('Restoring backup from file:', window.selectedBackupFile.name);
        
        // Create FormData for file upload
        const formData = new FormData();
        formData.append('backup_file', window.selectedBackupFile);
        
        const response = await fetch(`${API_BASE}backup.php?action=restore`, {
            method: 'POST',
            body: formData
        });
        
        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to restore backup');
        }
        
        showSuccess('Database restored successfully! The page will reload to reflect changes.');
        
        // Clear selected file
        clearSelectedFile();
        
        // Reload page after 3 seconds to reflect changes
        setTimeout(() => {
            window.location.reload();
        }, 3000);
        
        console.log('Backup restored successfully');
        
    } catch (error) {
        console.error('Error restoring backup:', error);
        showError('Failed to restore backup: ' + error.message);
    } finally {
        // Restore button state
        restoreBtn.innerHTML = originalText;
        restoreBtn.disabled = false;
    }
}

// Format file size for display
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Update showTab function to initialize backup/restore when tab is shown
const originalShowTab = window.showTab;
window.showTab = function(tabName) {
    // Call original showTab function
    if (originalShowTab) {
        originalShowTab(tabName);
    } else {
        // Fallback implementation
        document.querySelectorAll('.tab-content').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        
        const targetTab = document.getElementById(tabName);
        if (targetTab) {
            targetTab.classList.add('active');
        }
        
        const targetNavTab = document.querySelector(`[onclick="showTab('${tabName}')"]`);
        if (targetNavTab) {
            targetNavTab.classList.add('active');
        }
    }
    
    // Initialize backup/restore functionality when backup tab is shown
    if (tabName === 'backup') {
        setTimeout(() => {
            initializeBackupRestore();
        }, 100);
    }
    
};

// ==========================================
// ANIMATION CONTROLS FUNCTIONALITY
// ==========================================

// Load current animation settings
async function loadAnimationSettings() {
    try {
        console.log('Loading animation settings...');
        
        const response = await fetch(`${API_BASE}animation-settings.php?action=list`);
        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to load animation settings');
        }
        
        // Store original settings and update toggle switches
        originalAnimationSettings = {};
        result.data.forEach(setting => {
            const toggle = document.getElementById(`${setting.name.replace('_', '-')}-toggle`);
            const status = document.getElementById(`${setting.name.replace('_', '-')}-status`);
            
            // Store original value
            originalAnimationSettings[setting.name] = setting.value;
            
            if (toggle && status) {
                toggle.checked = setting.value;
                updateToggleStatus(status, setting.value);
                
                // Add event listener for immediate feedback
                toggle.addEventListener('change', function() {
                    updateToggleStatus(status, this.checked);
                    console.log(`Animation setting ${setting.name} changed to:`, this.checked);
                });
            }
        });
        
        console.log('Animation settings loaded:', result.data);
        
    } catch (error) {
        console.error('Error loading animation settings:', error);
        showAlert('Failed to load animation settings: ' + error.message, 'error');
    }
}

// Update toggle status text and styling
function updateToggleStatus(statusElement, isEnabled) {
    statusElement.className = 'toggle-status ' + (isEnabled ? 'enabled' : 'disabled');
    statusElement.textContent = isEnabled ? 'Enabled' : 'Disabled';
}

// Store original settings to track changes
let originalAnimationSettings = {};

// Save animation settings
async function saveAnimationSettings() {
    const saveBtn = document.getElementById('save-animation-settings');
    const originalText = saveBtn.innerHTML;
    
    try {
        // Show loading state
        saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';
        saveBtn.disabled = true;
        
        // Collect current toggle states
        const currentSettings = {};
        const toggles = document.querySelectorAll('.animation-controls-grid input[type="checkbox"]');
        
        toggles.forEach(toggle => {
            const settingName = toggle.getAttribute('data-setting');
            if (settingName) {
                currentSettings[settingName] = toggle.checked;
            }
        });
        
        // Only include settings that have actually changed
        const changedSettings = [];
        Object.keys(currentSettings).forEach(settingName => {
            if (originalAnimationSettings[settingName] !== currentSettings[settingName]) {
                changedSettings.push({
                    name: settingName,
                    value: currentSettings[settingName]
                });
            }
        });
        
        // If no changes, show message and return
        if (changedSettings.length === 0) {
            showAlert('No changes to save.', 'info');
            return;
        }
        
        console.log('Saving changed animation settings:', changedSettings);
        
        const response = await fetch(`${API_BASE}animation-settings.php?action=update`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ settings: changedSettings })
        });
        
        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to save animation settings');
        }
        
        // Update original settings to current state
        originalAnimationSettings = { ...currentSettings };
        
        // Show success message with correct count
        const settingWord = result.updated_count === 1 ? 'setting' : 'settings';
        showAlert(`Animation settings saved successfully! Updated ${result.updated_count} ${settingWord}.`, 'success');
        
        // Update status labels
        toggles.forEach(toggle => {
            const settingName = toggle.getAttribute('data-setting');
            const status = document.getElementById(`${settingName.replace('_', '-')}-status`);
            if (status) {
                updateToggleStatus(status, toggle.checked);
            }
        });
        
        // Apply settings to current page immediately
        const allSettings = [];
        Object.keys(currentSettings).forEach(settingName => {
            allSettings.push({
                name: settingName,
                value: currentSettings[settingName]
            });
        });
        applyAnimationSettings(allSettings);
        
        console.log('Animation settings saved successfully');
        
    } catch (error) {
        console.error('Error saving animation settings:', error);
        showAlert('Failed to save animation settings: ' + error.message, 'error');
    } finally {
        // Restore button state
        saveBtn.innerHTML = originalText;
        saveBtn.disabled = false;
    }
}

// Reset animation settings to defaults
async function resetAnimationSettings() {
    if (!confirm('Are you sure you want to reset all animation settings to their default values (disabled)?')) {
        return;
    }
    
    const resetBtn = document.getElementById('reset-animation-settings');
    const originalText = resetBtn.innerHTML;
    
    try {
        // Show loading state
        resetBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Resetting...';
        resetBtn.disabled = true;
        
        // Set all toggles to disabled (default state)
        const settings = [
            { name: 'hero_animations', value: false },
            { name: 'drone_animations', value: false }
        ];
        
        const response = await fetch(`${API_BASE}animation-settings.php?action=update`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ settings: settings })
        });
        
        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.message || 'Failed to reset animation settings');
        }
        
        // Update UI to reflect reset values and store as original settings
        originalAnimationSettings = {};
        settings.forEach(setting => {
            const toggle = document.getElementById(`${setting.name.replace('_', '-')}-toggle`);
            const status = document.getElementById(`${setting.name.replace('_', '-')}-status`);
            
            // Store as original value
            originalAnimationSettings[setting.name] = setting.value;
            
            if (toggle && status) {
                toggle.checked = setting.value;
                updateToggleStatus(status, setting.value);
            }
        });
        
        showAlert('Animation settings reset to defaults successfully!', 'success');
        
        // Apply settings to current page immediately
        applyAnimationSettings(settings);
        
        console.log('Animation settings reset to defaults');
        
    } catch (error) {
        console.error('Error resetting animation settings:', error);
        showAlert('Failed to reset animation settings: ' + error.message, 'error');
    } finally {
        // Restore button state
        resetBtn.innerHTML = originalText;
        resetBtn.disabled = false;
    }
}

// Apply animation settings to current page (for immediate preview)
function applyAnimationSettings(settings) {
    settings.forEach(setting => {
        const body = document.body;
        const className = `disable-${setting.name.replace('_', '-')}`;
        
        if (setting.value) {
            // Enable animation - remove disable class
            body.classList.remove(className);
        } else {
            // Disable animation - add disable class
            body.classList.add(className);
        }
    });
    
    console.log('Applied animation settings to current page');
}
