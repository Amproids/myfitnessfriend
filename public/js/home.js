const featuresElement = document.getElementById('feature-list');
console.log(featuresElement);
const features = [
    { feature: 'Workout API Connection', status: 'complete' },
    { feature: 'Simple BMI Tool', status: 'complete' },
    { feature: 'Workout Library', status: 'pending' },
    { feature: 'PostgreSQL Server For User Data', status: 'in-progress' },
    { feature: 'User Authentication', status: 'pending' },
    { feature: 'UserProfile Settings And Customization', status: 'pending' },
    { feature: 'Progress Tracking', status: 'pending' },
    { feature: 'Community Features', status: 'pending' },
    { feature: '3D Model', status: 'pending' },
    { feature: 'Mobile App Integration', status: 'pending' }
];

// Function to get the appropriate icon based on status
const getStatusIcon = (status) => {
    switch(status) {
        case 'complete':
            return '<i class="fas fa-check"></i>';
        case 'in-progress':
            return '<i class="fas fa-arrows-rotate fa-spin"></i>';
        case 'pending':
            return '<i class="fas fa-circle"></i>';
        default:
            return '<i class="fas fa-circle"></i>';
    }
};

// Clear existing content
featuresElement.innerHTML = '';

// Create and append feature items
features.forEach(feature => {
    const featureItem = document.createElement('li');
    featureItem.classList.add('feature-item');
    featureItem.innerHTML = `
        <span class="status-icon ${feature.status}">${getStatusIcon(feature.status)}</span>
        <span class="feature-name">${feature.feature}</span>
    `;
    featuresElement.appendChild(featureItem);
});