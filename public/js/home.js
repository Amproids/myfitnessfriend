const featuresElement = document.getElementById('feature-list');

const features = [
    // Completed
    { feature: 'BMI Calculator', description: 'Quick body mass index calculation with health range indicators', status: 'complete' },
    
    // In Progress
    { feature: 'PostgreSQL Database', description: 'Secure relational database for storing all user data, workouts, and measurements', status: 'in-progress' },
    
    // Core MVP Features
    { feature: 'User Authentication', description: 'Account creation, login, password recovery, and email verification', status: 'pending' },
    { feature: 'Social Sign-In', description: 'Quick registration and login with Google and Facebook accounts', status: 'pending' },
    { feature: 'User Profile & Settings', description: 'Customize personal info, preferences, display options, and notification settings', status: 'pending' },
    { feature: 'Exercise Library', description: 'Browse and search exercises by muscle group, equipment, difficulty, and tags', status: 'pending' },
    { feature: 'Favorite Exercises', description: 'Save exercises for quick access when logging workouts', status: 'pending' },
    { feature: 'Workout Logging', description: 'Record daily workouts with exercises, sets, reps, weights, and personal notes', status: 'pending' },
    { feature: 'Workout History', description: 'View past workouts in list and calendar format with detailed session breakdowns', status: 'pending' },
    { feature: 'Body Measurement Tracking', description: 'Log weight, body fat, and basic measurements to monitor changes over time', status: 'pending' },
    
    // Analytics & Progress
    { feature: 'Progress Charts & Analytics', description: 'Visualize workout frequency, volume trends, and body composition changes over time', status: 'planned' },
    { feature: 'Personal Records', description: 'Automatic tracking of your best lifts, longest workouts, and other PR milestones', status: 'planned' },
    
    // Routines
    { feature: 'Routine Builder', description: 'Create and save custom workout templates for quick logging of repeated sessions', status: 'planned' },
    { feature: 'Routine Sharing', description: 'Publish your routines for others to discover, use, and rate', status: 'planned' },
    
    // Advanced Features
    { feature: 'Advanced Body Measurements', description: 'Detailed tracking for arms, legs, shoulders, chest, neck, and other measurements', status: 'planned' },
    { feature: '3D Body Visualization', description: 'Interactive model highlighting muscle groups and showing development over time', status: 'planned' },
    { feature: 'Workout Reminders', description: 'Customizable notifications to keep you on track with your training schedule', status: 'planned' },
    { feature: 'Data Export', description: 'Download your workout history and measurements as CSV or PDF reports', status: 'planned' },
    
    // Community & Social
    { feature: 'Community Hub', description: 'Reddit-style feed to browse, upvote, and discuss shared routines from other users', status: 'planned' },
    { feature: 'Comments & Discussion', description: 'Leave feedback, ask questions, and share tips on community routines', status: 'planned' },
    { feature: 'Follow Users', description: 'Follow other members to see their shared routines and activity in your feed', status: 'planned' },
    { feature: 'Content Moderation', description: 'Reporting tools and moderation system to keep the community healthy', status: 'planned' },
    
    // Gamification & Competition
    { feature: 'Achievements & Badges', description: 'Earn rewards for hitting milestones, maintaining streaks, and completing challenges', status: 'planned' },
    { feature: 'Leaderboards & Percentiles', description: 'Compare your stats against the community and see where you rank', status: 'planned' },
    
    // Platform Expansion
    { feature: 'Android App', description: 'Native Android application with offline support and gym-friendly interface', status: 'planned' },
    { feature: 'iOS App', description: 'Native iPhone and iPad app with full feature parity and Apple Health integration', status: 'planned' }
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
        case 'planned':
            return '<i class="fas fa-clock"></i>';
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
        <div class="feature-content">
            <span class="feature-name">${feature.feature}</span>
            <span class="feature-description">${feature.description}</span>
        </div>
    `;
    featuresElement.appendChild(featureItem);
});