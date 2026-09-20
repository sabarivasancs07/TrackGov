import { useState, useEffect } from 'react';
import AuditLog from '../components/audit/AuditLog';
import { auditService } from '../services/auditService';

const AuditPage = () => {
  const [logs, setLogs] = useState([]);

  useEffect(() => {
    const fetchLogs = async () => {
      const data = await auditService.getAuditHistory();
      setLogs(data);
    };
    fetchLogs();
  }, []);

  return (
    <div className="page-container animate-fade-in">
      <div className="page-header">
        <h1 className="page-title">Audit History</h1>
        <p className="page-subtitle">Track all system actions and application state changes.</p>
      </div>

      <div className="card">
        <AuditLog logs={logs} />
      </div>
    </div>
  );
};

export default AuditPage;
