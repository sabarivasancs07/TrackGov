import { formatRelativeTime } from '../../utils/formatDate';
import { FileText, CheckCircle, XCircle, Clock } from 'lucide-react';
import './RecentActivity.css';

const RecentActivity = ({ applications }) => {
  // Extract all workflow events from applications and sort by date
  const allEvents = applications.flatMap(app => 
    (app.workflowHistory || []).map(t => ({
      ...t,
      status: t.action, // Action acts as status in the new schema
      appId: app.id,
      applicantName: app.applicantName
    }))
  ).sort((a, b) => new Date(b.date) - new Date(a.date))
   .slice(0, 10); // get top 10 most recent

  const getEventIcon = (status) => {
    switch(status) {
      case 'Completed': return <CheckCircle size={16} className="text-status-approved" />;
      case 'Rejected': return <XCircle size={16} className="text-status-rejected" />;
      case 'Pending': return <Clock size={16} className="text-status-pending" />;
      default: return <FileText size={16} className="text-neutral-500" />;
    }
  };

  return (
    <div className="card recent-activity-card">
      <h3 className="card-title mb-4">Recent Activity</h3>
      <div className="activity-feed">
        {allEvents.map((event, idx) => (
          <div key={idx} className="activity-item">
            <div className="activity-icon-wrapper">
              {getEventIcon(event.status)}
            </div>
            <div className="activity-content">
              <div className="activity-header">
                <span className="activity-title">
                  <span className="font-medium text-neutral-900">{event.appId}</span> - {event.stage}
                </span>
                <span className="activity-time">{formatRelativeTime(event.date)}</span>
              </div>
              <p className="activity-desc">
                {event.status === 'Completed' ? 'Approved by' : 
                 event.status === 'Rejected' ? 'Rejected by' : 
                 'Action pending from'} {event.officer}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default RecentActivity;
