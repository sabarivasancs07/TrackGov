import AuditEntry from './AuditEntry';
import './AuditLog.css';

const AuditLog = ({ logs }) => {
  return (
    <div className="audit-log-container">
      <div className="audit-entries-list">
        {logs.map(log => (
          <AuditEntry key={log.id} entry={log} />
        ))}
      </div>
    </div>
  );
};

export default AuditLog;
