import { applicationService } from './applicationService';
import { apiClient } from './api';

export const workflowService = {
  getAvailableActions: (officerRole, currentStage, status) => {
    const actions = [];
    const isCompleted = ['Approved', 'Rejected', 'Completed'].includes(status);
    
    if (isCompleted) return [];

    const stage = typeof currentStage === 'string' ? currentStage : '';

    if (stage.includes('Verification') || stage.includes('Submitted') || stage.includes('VAO') || stage.includes('RI')) {
      actions.push({ id: 'forward', label: 'Verify & Forward', type: 'primary' });
      actions.push({ id: 'reject', label: 'Reject', type: 'danger' });
    } else if (stage.includes('Approval') || stage.includes('Tahsildar') || stage.includes('Final')) {
      actions.push({ id: 'approve', label: 'Approve', type: 'success' });
      actions.push({ id: 'reject', label: 'Reject', type: 'danger' });
    } else {
      // Default actions for active stages
      actions.push({ id: 'forward', label: 'Verify & Forward', type: 'primary' });
      actions.push({ id: 'approve', label: 'Approve', type: 'success' });
      actions.push({ id: 'reject', label: 'Reject', type: 'danger' });
    }

    return actions;
  },

  executeWorkflowAction: async (applicationId, actionId, remarks, officer) => {
    const app = await applicationService.getApplicationById(applicationId);
    if (!app) throw new Error("Application not found");

    let newStatus = 'Completed';
    let actionText = '';
    let stageName = app.currentStage;

    if (actionId === 'forward') {
      actionText = 'Forwarded stage: ' + stageName;
      newStatus = 'Completed';
    } else if (actionId === 'approve') {
      newStatus = 'Completed';
      actionText = 'Approved application';
    } else if (actionId === 'reject') {
      newStatus = 'Rejected';
      actionText = 'Rejected application';
    } else if (actionId === 'generate') {
      newStatus = 'Completed';
      actionText = 'Generated Certificate';
    }

    const payload = {
      application_id: applicationId,
      stage_name: stageName,
      status: newStatus,
      remarks: remarks || actionText,
      officer_id: officer.id || officer.officer_id
    };

    const officerId = officer.id || officer.officer_id;
    await apiClient.put(`/officers/${officerId}/applications/${applicationId}/workflow`, payload);

    return await applicationService.getApplicationById(applicationId);
  }
};

