import { apiClient } from './api';

export const authService = {
  login: async (officerId, password) => {
    if (!officerId || !password) {
      throw new Error("Please enter both ID and password");
    }
    
    const response = await apiClient.post('/auth/login', {
      username: officerId,
      password: password
    });
    
    if (response.success) {
      return {
        id: response.officer_id,
        name: response.name,
        role: response.role,
        department: response.department,
        office: response.department
      };
    } else {
      throw new Error(response.message || "Invalid Officer ID or Password");
    }
  },

  getOfficers: async () => {
    try {
      const response = await apiClient.get('/officers');
      return response || [];
    } catch (error) {
      console.error("Failed to fetch officers from API:", error);
      return [];
    }
  }
};

