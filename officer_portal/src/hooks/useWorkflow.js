import { useState } from 'react';
import { workflowService } from '../services/workflowService';

export const useWorkflow = (applicationId, onWorkflowComplete) => {
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState(null);

  const executeAction = async (actionId, remarks, officer) => {
    setIsProcessing(true);
    setError(null);
    try {
      const updatedApp = await workflowService.executeWorkflowAction(applicationId, actionId, remarks, officer);
      
      if (onWorkflowComplete) {
        onWorkflowComplete(updatedApp);
      }
      return updatedApp;
    } catch (err) {
      setError(err.message || 'An error occurred during workflow execution');
      return null;
    } finally {
      setIsProcessing(false);
    }
  };

  return {
    executeAction,
    isProcessing,
    error
  };
};
