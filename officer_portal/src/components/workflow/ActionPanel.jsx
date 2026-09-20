import { useState } from 'react';
import { MessageSquare } from 'lucide-react';
import Button from '../common/Button';
import Modal from '../common/Modal';
import { useAuth } from '../../context/AuthContext';
import { workflowService } from '../../services/workflowService';
import { useWorkflow } from '../../hooks/useWorkflow';
import { WORKFLOW_STAGES } from '../../constants/workflow';
import './ActionPanel.css';

const ActionPanel = ({ application, onWorkflowComplete }) => {
  const { user } = useAuth();
  const { executeAction, isProcessing } = useWorkflow(application.id, onWorkflowComplete);
  const [activeModal, setActiveModal] = useState(null);
  const [remarks, setRemarks] = useState('');

  if (!user) return null;

  const availableActions = workflowService.getAvailableActions(user.role, application.currentStage, application.status);

  if (['Approved', 'Rejected', 'Completed'].includes(application.status) && availableActions.length === 0) {
    return (
      <div className="card text-center p-6 bg-neutral-50">
        <p className="text-neutral-500 m-0">
          This application has been {application.status.toLowerCase()}. No further actions can be taken.
        </p>
      </div>
    );
  }

  const handleSubmit = async (actionId) => {
    if (actionId === 'remark') {
      // Logic to just add remarks is subsumed by executeWorkflowAction (or a separate one could be created).
      // For now, we will just use executeAction with 'remark' if supported, or ignore.
      setActiveModal(null);
      setRemarks('');
      return;
    }
    
    await executeAction(actionId, remarks, user);
    setActiveModal(null);
    setRemarks('');
  };

  return (
    <>
      <div className="card action-panel">
        <h3 className="card-title mb-4">Officer Actions</h3>
        <div className="action-buttons-grid">
          {availableActions.map(action => (
            <Button 
              key={action.id}
              variant={action.type} 
              onClick={() => setActiveModal(action)}
            >
              {action.label}
            </Button>
          ))}
          <Button 
            variant="ghost" 
            icon={MessageSquare} 
            onClick={() => setActiveModal({ id: 'remark', label: 'Add Remarks', type: 'ghost' })}
          >
            Add Note
          </Button>
        </div>
      </div>

      <Modal
        isOpen={!!activeModal}
        onClose={() => { setActiveModal(null); setRemarks(''); }}
        title={activeModal ? activeModal.label : ''}
        footer={
          <>
            <Button variant="ghost" onClick={() => { setActiveModal(null); setRemarks(''); }}>
              Cancel
            </Button>
            <Button 
              variant={activeModal?.type === 'danger' ? 'danger' : 'primary'}
              onClick={() => handleSubmit(activeModal.id)}
              isLoading={isProcessing}
              disabled={!remarks.trim() && activeModal?.id === 'reject'}
            >
              Confirm
            </Button>
          </>
        }
      >
        <div className="modal-form-group">
          <label>Remarks {activeModal?.id === 'reject' && <span className="text-status-rejected">*</span>}</label>
          <textarea 
            className="form-textarea"
            placeholder="Enter your remarks here..."
            rows={4}
            value={remarks}
            onChange={(e) => setRemarks(e.target.value)}
          ></textarea>
          {activeModal?.id === 'reject' && (
            <p className="text-xs text-status-rejected mt-1">Remarks are mandatory for rejection.</p>
          )}
        </div>
      </Modal>
    </>
  );
};

export default ActionPanel;
