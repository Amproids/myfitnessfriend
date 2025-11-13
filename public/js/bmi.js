// Get DOM elements
const heightInput = document.getElementById('height');
const weightInput = document.getElementById('weight');
const inchesInput = document.getElementById('inches');
const calculateButton = document.getElementById('calculate');
const resultElement = document.getElementById('result');
const bmiCategoryElement = document.getElementById('bmi-category');
const bmiInfoElement = document.getElementById('bmi-info');
const sliderMarker = document.querySelector('.slider-marker');
const sliderMarkerValue = document.querySelector('.slider-marker-value');
const resultContainer = document.querySelector('.result-container');

// Get unit toggles and unit display elements
const weightUnitsSelector = document.getElementById('weight-units-selector');
const heightUnitsSelector = document.getElementById('height-units-selector');
const inchesDisplay = document.getElementById('height-inches');
const weightUnitsDisplay = document.getElementById('weight-units');
const heightUnitsDisplay = document.getElementById('height-units');

// Set default units
let weightUnits = 'lbs';
let heightUnits = 'ft';

// Handle weight unit toggle
weightUnitsSelector.addEventListener('change', () => {
    weightUnits = weightUnitsSelector.checked ? 'lbs' : 'kg';
    weightUnitsDisplay.textContent = weightUnits;
});

// Handle height unit toggle
heightUnitsSelector.addEventListener('change', () => {
    heightUnits = heightUnitsSelector.checked ? 'ft' : 'cm';
    heightUnitsDisplay.textContent = heightUnits;
    if (heightUnits === 'cm') {
        inchesDisplay.style.display = 'none';
    } else {
        inchesDisplay.style.display = 'inline-flex';
    }
});

// Calculate BMI function
function calculateBMI(weight, heightFeet, heightInches = 0) {
    // Convert to metric if needed
    if (weightUnits === 'lbs') {
        weight = weight * 0.453592; // Convert pounds to kg
    }
    
    let heightMeters;
    
    if (heightUnits === 'ft') {
        // Convert feet and inches to meters
        const totalInches = (heightFeet * 12) + heightInches;
        heightMeters = totalInches * 0.0254; // Convert inches to meters
    } else if (heightUnits === 'cm') {
        heightMeters = heightFeet / 100; // Convert cm to meters (heightFeet is actually cm in this case)
    }
    
    // Calculate BMI
    return (weight / (heightMeters * heightMeters)).toFixed(1);
}

// Get BMI category
function getBMICategory(bmi) {
    if (bmi < 18.5) {
        return {
            category: 'Underweight',
            class: 'underweight',
            info: 'You may need to gain some weight. Consult with a healthcare provider for advice.'
        };
    } else if (bmi >= 18.5 && bmi < 25) {
        return {
            category: 'Normal weight',
            class: 'normal',
            info: 'Your BMI indicates a healthy weight. Maintain a balanced diet and regular exercise.'
        };
    } else if (bmi >= 25 && bmi < 30) {
        return {
            category: 'Overweight',
            class: 'overweight',
            info: 'You may benefit from losing some weight. Consider consulting a healthcare provider.'
        };
    } else if (bmi >= 30 && bmi < 35) {
        return {
            category: 'Obese Class I',
            class: 'obese',
            info: 'For health reasons, weight loss is recommended. Please consult with a healthcare provider.'
        };
    } else if (bmi >= 35 && bmi < 40) {
        return {
            category: 'Obese Class II',
            class: 'obese2',
            info: 'For health reasons, weight loss is recommended. Please consult with a healthcare provider.'
        };
    } else {
        return {
            category: 'Obese Class III',
            class: 'obese3',
            info: 'For health reasons, weight loss is recommended. Please consult with a healthcare provider urgently.'
        };
    }
}

// Update slider marker position based on BMI
function updateSliderMarker(bmi) {
    // Calculate position (percentage) on the slider
    let position;
    if (bmi < 15) {
        position = 0;
    } else if (bmi > 60) {
        position = 100;
    } else {
        position = ((bmi - 15) / 45) * 100;
    }
    
    sliderMarker.style.left = `${position}%`;
    sliderMarker.style.display = 'block';
    sliderMarkerValue.textContent = bmi;
}

// Calculate button click handler
calculateButton.addEventListener('click', () => {
    const weight = parseFloat(weightInput.value);
    
    let bmi;
    if (heightUnits === 'ft') {
        const feet = parseFloat(heightInput.value);
        const inches = parseFloat(inchesInput.value || 0);
        
        if (!isNaN(feet) && !isNaN(weight) && feet > 0 && weight > 0) {
            bmi = calculateBMI(weight, feet, inches);
        }
    } else { // cm
        const height = parseFloat(heightInput.value);
        
        if (!isNaN(height) && !isNaN(weight) && height > 0 && weight > 0) {
            bmi = calculateBMI(weight, height);
        }
    }
    
    if (bmi) {
        const bmiData = getBMICategory(bmi);
        
        // Display results
        resultElement.textContent = `Your BMI is: ${bmi}`;
        bmiCategoryElement.textContent = `Category: ${bmiData.category}`;
        bmiCategoryElement.className = bmiData.class;
        bmiInfoElement.textContent = bmiData.info;
        
        // Update slider marker
        updateSliderMarker(bmi);
        
        // Show results container
        resultContainer.style.display = 'block';
    } else {
        resultElement.textContent = 'Please enter valid height and weight values.';
        bmiCategoryElement.textContent = '';
        bmiInfoElement.textContent = '';
        resultContainer.style.display = 'block';
        sliderMarker.style.display = 'none';
    }
});

// Initialize unit displays
weightUnitsDisplay.textContent = weightUnits;
heightUnitsDisplay.textContent = heightUnits;

// Set initial inches input visibility
if (heightUnits === 'cm') {
    inchesDisplay.style.display = 'none';
} else {
    inchesDisplay.style.display = 'inline-flex';
}

// Fix inconsistency in height units display from initial code
heightUnits = heightUnitsSelector.checked ? 'ft' : 'cm';
heightUnitsDisplay.textContent = heightUnits;