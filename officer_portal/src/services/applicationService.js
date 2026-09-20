import { apiClient } from './api';

export const mapApplicationData = (backendData) => {
  if (!backendData) return null;

  const app = backendData.application || backendData;
  const workflow = backendData.workflow || null;
  const delay = backendData.delay_info || null;

  const rawStages = workflow?.stages || [];

  return {
    id: app.application_id,
    applicationNumber: app.application_id,
    applicantName: app.applicant_name || app.applicantName || 'Citizen',
    category: app.category || app.application_type || 'General',
    certificateType: app.application_type,
    submissionDate: app.submitted_date,
    lastUpdated: app.last_updated,
    currentOffice: app.current_office || workflow?.current_stage_details?.office || 'Tahsildar Office',
    currentStage: app.current_stage,
    status: (delay?.is_delayed && app.status !== 'Approved' && app.status !== 'Rejected' && app.status !== 'Completed')
            ? 'Delayed' 
            : (app.status || 'Under Verification'),
    daysPending: delay?.days_pending || 0,
    expectedProcessingDays: delay?.expected_processing_days || 15,
    isDelayed: delay?.is_delayed || false,
    delayReason: delay?.reason || '',
    assignedOfficer: app.assigned_officer_id || 'Unassigned',
    remarks: app.remarks || '',
    annualIncome: app.annual_income || 120000,
    landHolding: app.land_holding || 0,
    village: app.village || 'Haveli',
    documents: (app.required_documents || []).map(docName => ({
      id: docName,
      name: docName,
      type: 'PDF',
      status: (app.completed_documents || []).includes(docName) ? 'Verified' : 'Pending'
    })),
    workflowHistory: rawStages.map(stage => ({
      stage: stage.stage_name,
      officer: stage.assigned_to || 'System',
      role: stage.assigned_to ? 'Officer' : 'Automated',
      office: stage.office || 'Department Office',
      action: stage.status,
      remarks: stage.remarks || '',
      date: stage.started_at ? stage.started_at.split('T')[0] : (stage.completed_at ? stage.completed_at.split('T')[0] : ''),
      time: stage.started_at && stage.started_at.includes('T') ? stage.started_at.split('T')[1].substring(0, 5) : ''
    })),
    auditHistory: []
  };
};

export const applicationService = {
  /**
   * Get all applications, with optional search, filter, and officer filtering
   */
  getAllApplications: async (searchQuery = '', statusFilter = 'All', officerId = null) => {
    let endpoint = '/applications/';
    if (officerId) {
      endpoint = `/officers/${officerId}/applications`;
    }
    
    const response = await apiClient.get(endpoint);
    let list = Array.isArray(response) ? response : (response.data || []);
    
    let mappedList = list.map(item => mapApplicationData(item));

    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      mappedList = mappedList.filter(app => 
        app.id.toLowerCase().includes(query) ||
        app.applicantName.toLowerCase().includes(query) ||
        app.applicationNumber.toLowerCase().includes(query)
      );
    }

    if (statusFilter && statusFilter !== 'All') {
      mappedList = mappedList.filter(app => app.status === statusFilter);
    }

    return mappedList;
  },

  /**
   * Get a single application by ID
   */
  getApplicationById: async (id) => {
    const response = await apiClient.get(`/applications/${id}`);
    return mapApplicationData(response);
  },

  /**
   * Update an application state if needed
   */
  updateApplication: async (updatedApp) => {
    return updatedApp;
  }
};

