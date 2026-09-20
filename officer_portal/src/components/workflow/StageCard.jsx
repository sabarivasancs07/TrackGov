import { CheckCircle, Clock, AlertCircle } from 'lucide-react';
import { formatDate } from '../../utils/formatDate';
import './StageCard.css';

const StageCard = ({ stage, status, date, officer, remarks, isLast }) => {
  const isCompleted = status === 'Completed';
  const isPending = status === 'Pending';
  const isRejected = status === 'Rejected';

  return (
    <div className={`stage-card ${isLast ? 'last' : ''}`}>
      <div className="stage-indicator-col">
        <div className={`stage-icon ${status.toLowerCase()}`}>
          {isCompleted && <CheckCircle size={20} />}
          {isPending && <Clock size={20} />}
          {isRejected && <AlertCircle size={20} />}
          {!isCompleted && !isPending && !isRejected && <div className="dot"></div>}
        </div>
        {!isLast && <div className={`stage-line ${isCompleted ? 'completed' : ''}`}></div>}
      </div>
      
      <div className={`stage-content ${isPending ? 'active-stage' : ''}`}>
        <div className="stage-header">
          <h4 className="stage-title">{stage}</h4>
          <span className="stage-date">{date ? formatDate(date, { hour: '2-digit', minute: '2-digit'}) : 'Pending'}</span>
        </div>
        
        {officer && (
          <div className="stage-officer">
            <span className="text-neutral-500 text-xs">Officer:</span>
            <span className="text-neutral-700 text-sm font-medium ml-1">{officer}</span>
          </div>
        )}
        
        {remarks && (
          <div className={`stage-remarks ${isRejected ? 'rejected-remarks' : ''}`}>
            {remarks}
          </div>
        )}
      </div>
    </div>
  );
};

export default StageCard;
