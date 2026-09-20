import { Check, X, FileText, ExternalLink } from 'lucide-react';
import './DocumentChecklist.css';

const DocumentChecklist = ({ documents }) => {
  if (!documents || documents.length === 0) return null;

  return (
    <div className="card document-checklist">
      <h3 className="card-title mb-4">Document Verification</h3>
      <div className="documents-list">
        {documents.map((doc, idx) => (
          <div key={idx} className="document-item">
            <div className="document-info">
              <FileText size={20} className="text-neutral-400" />
              <div>
                <span className="document-name">{doc.name}</span>
                <a href={doc.url} className="document-link" onClick={e => e.preventDefault()}>
                  View Document <ExternalLink size={12} />
                </a>
              </div>
            </div>
            
            <div className="document-status">
              {doc.verified ? (
                <span className="doc-verified"><Check size={16} /> Verified</span>
              ) : (
                <span className="doc-pending"><ClockIcon /> Pending Verification</span>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// Temporary icon component since we missed importing Clock earlier if needed, but lets just use a dot
const ClockIcon = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline>
  </svg>
);

export default DocumentChecklist;
