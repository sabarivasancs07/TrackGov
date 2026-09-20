import { Clock, User, Building } from 'lucide-react';
import { formatDate } from '../../utils/formatDate';
import './AuditEntry.css';

const AuditEntry = ({ entry }) => {
  return (
    <div className="audit-entry audit-entry-wrapper">
      <div className="audit-entry-header-row">
        <div>
          <div className="audit-actor-group">
            <User size={16} className="text-neutral-500" />
            <span className="actor-name">{entry.officerName} <span className="audit-actor-role">({entry.officerRole})</span></span>
          </div>
          <div className="audit-office-info">
            <Building size={12} />
            <span>{entry.office}</span>
          </div>
        </div>
        <div className="audit-time-info">
          <Clock size={14} className="text-neutral-400" />
          <span className="time-text">{formatDate(entry.timestamp, { hour: '2-digit', minute: '2-digit' })}</span>
        </div>
      </div>
      
      <div className="audit-body-container">
        <span className="audit-action-text">{entry.action}</span>
        <span className="audit-target-text">on Application {entry.applicationId}</span>
      </div>
      
      {entry.remarks && (
        <div className="audit-footer-container">
          <p className="audit-remarks-text">"{entry.remarks}"</p>
        </div>
      )}
    </div>
  );
};

export default AuditEntry;
