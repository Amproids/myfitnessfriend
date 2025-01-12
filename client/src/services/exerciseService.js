// client/src/services/exerciseService.js
const exerciseService = {
    async getExercises(filters = {}) {
        try {
            const queryParams = new URLSearchParams();
            
            if (filters.bodyPart) {
                queryParams.append('bodyPart', filters.bodyPart);
            }
            if (filters.equipment) {
                queryParams.append('equipment', filters.equipment);
            }
            if (filters.search) {
                queryParams.append('search', filters.search);
            }
            
            const response = await fetch(`/api/exercises?${queryParams}`);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            return await response.json();
        } catch (error) {
            console.error('Error fetching exercises:', error);
            throw error;
        }
    }
};

export default exerciseService;