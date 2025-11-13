// /js/exercises.js
import exerciseService from '/services/exerciseService.js';

let currentFilters = {
    bodyPart: 'all',
    equipment: 'all',
    search: '',
    showFavorites: false
};

// Favorites handling
function getFavorites() {
    const favorites = localStorage.getItem('favoriteExercises');
    return favorites ? JSON.parse(favorites) : [];
}

function addToFavorites(exercise) {
    const favorites = getFavorites();
    if (!favorites.some(fav => fav.id === exercise.id)) {
        favorites.push(exercise);
        localStorage.setItem('favoriteExercises', JSON.stringify(favorites));
    }
}

function removeFromFavorites(exerciseId) {
    const favorites = getFavorites();
    const updatedFavorites = favorites.filter(fav => fav.id !== exerciseId);
    localStorage.setItem('favoriteExercises', JSON.stringify(updatedFavorites));
}

function isFavorite(exerciseId) {
    const favorites = getFavorites();
    return favorites.some(fav => fav.id === exerciseId);
}

function createExerciseCard(exercise) {
    const card = document.createElement('div');
    card.className = 'exercise-card';
    
    const favoriteButtonClass = isFavorite(exercise.id) ? 
        'fas fa-heart favorite-btn active' : 
        'far fa-heart favorite-btn';

    card.innerHTML = `
        <div class="exercise-image">
            <img src="${exercise.gifUrl}" alt="${exercise.name}" loading="lazy">
        </div>
        <div class="exercise-content">
            <div class="exercise-header">
                <h3>${exercise.name}</h3>
                <button class="favorite-button">
                    <i class="${favoriteButtonClass}"></i>
                </button>
            </div>
            <p><strong>Body Part:</strong> ${exercise.bodyPart}</p>
            <p><strong>Equipment:</strong> ${exercise.equipment}</p>
        </div>
    `;

    // Add favorite button functionality
    const favoriteButton = card.querySelector('.favorite-button');
    favoriteButton.addEventListener('click', (e) => {
        e.preventDefault();
        const icon = favoriteButton.querySelector('i');
        
        if (isFavorite(exercise.id)) {
            removeFromFavorites(exercise.id);
            icon.className = 'far fa-heart favorite-btn';
        } else {
            addToFavorites(exercise);
            icon.className = 'fas fa-heart favorite-btn active';
        }

        // If we're in favorites view, refresh the display
        if (currentFilters.showFavorites) {
            loadExercises();
        }
    });

    return card;
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

async function loadExercises() {
    const exerciseGrid = document.getElementById('exerciseGrid');
    const loadingSpinner = document.getElementById('loadingSpinner');
    
    try {
        if (loadingSpinner) {
            loadingSpinner.style.display = 'block';
        }
        
        if (exerciseGrid) {
            exerciseGrid.innerHTML = ''; // Clear existing exercises
            
            let exercises;
            if (currentFilters.showFavorites) {
                exercises = getFavorites();
            } else {
                exercises = await exerciseService.getExercises(currentFilters);
            }
            
            if (Array.isArray(exercises)) {
                // Apply search filter if it exists
                if (currentFilters.search) {
                    const searchLower = currentFilters.search.toLowerCase();
                    exercises = exercises.filter(exercise => 
                        exercise.name.toLowerCase().includes(searchLower) ||
                        exercise.bodyPart.toLowerCase().includes(searchLower) ||
                        exercise.equipment.toLowerCase().includes(searchLower)
                    );
                }

                if (exercises.length === 0) {
                    exerciseGrid.innerHTML = '<p class="no-results">No exercises found</p>';
                } else {
                    exercises.forEach(exercise => {
                        const card = createExerciseCard(exercise);
                        exerciseGrid.appendChild(card);
                    });
                }
            } else {
                console.error('Exercises data is not an array:', exercises);
                exerciseGrid.innerHTML = '<p class="error-message">Invalid data received from server</p>';
            }
        }
    } catch (error) {
        console.error('Failed to load exercises:', error);
        if (exerciseGrid) {
            exerciseGrid.innerHTML = '<p class="error-message">Failed to load exercises. Please try again later.</p>';
        }
    } finally {
        if (loadingSpinner) {
            loadingSpinner.style.display = 'none';
        }
    }
}

function initializeExerciseBrowser() {
    const searchInput = document.getElementById('exerciseSearch');
    const bodyPartFilter = document.getElementById('bodyPartFilter');
    const equipmentFilter = document.getElementById('equipmentFilter');
    const favoritesToggle = document.createElement('button');
    
    // Add favorites toggle button
    favoritesToggle.className = 'btn-favorites';
    favoritesToggle.innerHTML = '<i class="far fa-heart"></i> Show Favorites';
    
    // Insert favorites toggle after the filter options
    const filterOptions = document.querySelector('.filter-options');
    if (filterOptions) {
        filterOptions.appendChild(favoritesToggle);
    }
    
    // Event Listeners
    favoritesToggle.addEventListener('click', () => {
        currentFilters.showFavorites = !currentFilters.showFavorites;
        favoritesToggle.innerHTML = currentFilters.showFavorites ? 
            '<i class="fas fa-heart"></i> Show All' : 
            '<i class="far fa-heart"></i> Show Favorites';
        
        // Disable filters when showing favorites
        if (bodyPartFilter) bodyPartFilter.disabled = currentFilters.showFavorites;
        if (equipmentFilter) equipmentFilter.disabled = currentFilters.showFavorites;
        
        loadExercises();
    });

    if (searchInput) {
        searchInput.addEventListener('input', debounce(() => {
            currentFilters.search = searchInput.value;
            loadExercises();
        }, 300));
    }
    
    if (bodyPartFilter) {
        bodyPartFilter.addEventListener('change', () => {
            currentFilters.bodyPart = bodyPartFilter.value;
            loadExercises();
        });
    }
    
    if (equipmentFilter) {
        equipmentFilter.addEventListener('change', () => {
            currentFilters.equipment = equipmentFilter.value;
            loadExercises();
        });
    }
    
    // Initial load
    loadExercises();
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', initializeExerciseBrowser);