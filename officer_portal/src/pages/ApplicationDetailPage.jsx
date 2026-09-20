import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { useApplications } from '../hooks/useApplications';
import Button from '../components/common/Button';
import StatusBadge from '../components/common/StatusBadge';
import PriorityBadge from '../components/common/PriorityBadge';
import ApplicationDetailCard from '../components/workflow/ApplicationDetailCard';
import WorkflowTimeline from '../components/workflow/WorkflowTimeline';
import ActionPanel from '../components/workflow/ActionPanel';
import DocumentChecklist from '../components/workflow/DocumentChecklist';
import EmptyState from '../components/common/EmptyState';
import DelayCard from '../components/workflow/DelayCard';
import AiExplanationCard from '../components/workflow/AiExplanationCard';
import { FileText } from 'lucide-react';
import { formatDate } from '../utils/formatDate';
import './ApplicationDetailPage.css';

const ApplicationDetailPage = () => {
  const { applicationId } = useParams();
  const navigate = useNavigate();
  const { getApplicationById } = useApplications();
  const [application, setApplication] = useState(null);
  
  useEffect(() => {
    const fetchApp = async () => {
      const app = await getApplicationById(applicationId);
      setApplication(app);
    };
    fetchApp();
  }, [applicationId, getApplicationById]);

  if (!application) {
    return (
      <div className="page-container animate-fade-in">
        <EmptyState 
          icon={FileText}
          title="Application Not Found"
          description={`We couldn't find any application with ID: ${applicationId}`}
          action={<Button onClick={() => navigate('/applications')}>Back to Applications</Button>}
        />
      </div>
    );
  }

  return (
    <div className="page-container app-detail-page animate-fade-in">
      <div className="app-detail-header">
        <div className="flex items-center gap-4 mb-4">
          <button className="back-btn" onClick={() => navigate(-1)} aria-label="Go back">
            <ArrowLeft size={20} />
          </button>
          <div>
            <h1 className="page-title flex items-center gap-3">
              Application {application.id}
              <StatusBadge status={application.status} />
              <PriorityBadge priority={application.priority || 'Medium'} />
            </h1>
            <p className="page-subtitle mt-1">
              Submitted on {formatDate(application.submissionDate || application.applicationDate)}
            </p>
          </div>
        </div>
      </div>

      <div className="app-detail-grid">
        <div className="app-detail-main">
          <ApplicationDetailCard application={application} />
          <DocumentChecklist documents={application.documents || []} />
          <ActionPanel application={application} onWorkflowComplete={setApplication} />
        </div>
        <div className="app-detail-sidebar">
          <AiExplanationCard applicationId={application.id} />
          <DelayCard application={application} />
          <WorkflowTimeline workflowHistory={application.workflowHistory} />
        </div>
      </div>
    </div>
  );
};

export default ApplicationDetailPage;
