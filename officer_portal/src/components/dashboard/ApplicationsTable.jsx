import { Link } from 'react-router-dom';
import { Eye, ChevronLeft, ChevronRight, ArrowUpDown } from 'lucide-react';
import StatusBadge from '../common/StatusBadge';
import { calculateDelay } from '../../utils/calculateDelay';
import { usePagination } from '../../hooks/usePagination';
import './ApplicationsTable.css';

const ApplicationsTable = ({ applications, limit }) => {
  const { currentPage, totalPages, paginate, nextPage, prevPage, goToPage } = usePagination(applications.length, 5);
  
  const displayApps = limit ? applications.slice(0, limit) : paginate(applications);

  return (
    <div className="table-container card">
      <div className="table-header-container">
        <h3 className="table-title">{limit ? 'Recent Applications' : 'All Applications'}</h3>
      </div>
      
      <div className="table-responsive">
        <table className="applications-table">
          <thead>
            <tr>
              <th>Application No. <ArrowUpDown size={14} className="sort-icon" /></th>
              <th>Applicant Name <ArrowUpDown size={14} className="sort-icon" /></th>
              <th>Certificate Type</th>
              <th>Current Office</th>
              <th>Current Stage</th>
              <th>Status</th>
              <th>Days Pending</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {displayApps.length === 0 ? (
              <tr>
                <td colSpan="8" className="text-center p-6 text-neutral-500">
                  No applications found.
                </td>
              </tr>
            ) : (
              displayApps.map(app => {
                const delayInfo = calculateDelay(app.daysPending, app.expectedProcessingDays);
                return (
                  <tr key={app.id}>
                    <td className="font-medium">{app.id}</td>
                    <td>{app.applicantName}</td>
                    <td>{app.certificateType}</td>
                    <td>{app.currentOffice}</td>
                    <td className="text-sm text-neutral-600 truncate-text" title={app.currentStage}>
                      {app.currentStage}
                    </td>
                    <td><StatusBadge status={app.status} size="sm" /></td>
                    <td>
                      <span className={delayInfo.isDelayed ? 'delay-text-delayed' : 'delay-text-ontime'}>
                        {app.daysPending} Days
                      </span>
                    </td>
                    <td>
                      <Link to={`/applications/${app.id}`} className="action-btn">
                        <Eye size={16} />
                        <span>View Details</span>
                      </Link>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {!limit && applications.length > 0 && (
        <div className="pagination">
          <span className="text-sm text-neutral-500">
            Showing Page {currentPage} of {totalPages}
          </span>
          <div className="pagination-controls">
            <button className="pagination-btn" onClick={prevPage} disabled={currentPage === 1}>
              <ChevronLeft size={16} />
            </button>
            {Array.from({ length: totalPages }, (_, i) => i + 1).map(page => (
              <button 
                key={page} 
                className={`pagination-btn ${currentPage === page ? 'active' : ''}`}
                onClick={() => goToPage(page)}
              >
                {page}
              </button>
            ))}
            <button className="pagination-btn" onClick={nextPage} disabled={currentPage === totalPages}>
              <ChevronRight size={16} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default ApplicationsTable;
