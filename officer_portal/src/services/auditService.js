import { apiClient } from './api';

export const auditService = {
  /**
   * Get all audit history from FastAPI, sorted newest first
   */
  getAuditHistory: async () => {
    const response = await apiClient.get('/audit');
    if (Array.isArray(response)) {
      return response.map(log => ({
        id: log.log_id,
        applicationId: log.application_id,
        applicantName: log.application_id,
        officerName: log.performed_by,
        officerRole: log.performed_by_role || 'Officer',
        office: log.performed_by_role || 'Department',
        action: log.action,
        remarks: log.description || '',
        timestamp: log.timestamp
      })).sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    }
    return [];
  }
};

