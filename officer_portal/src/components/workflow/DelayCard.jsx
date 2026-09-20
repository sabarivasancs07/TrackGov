import { AlertTriangle, CheckCircle } from 'lucide-react';
import './DelayCard.css';

const DelayCard = ({ application }) => {
  if (!application) return null;

  const isDelayed = application.isDelayed !== undefined 
    ? application.isDelayed 
    : ((application.daysPending || 0) > (application.expectedProcessingDays || 15));

  const daysOverdue = Math.max(0, (application.daysPending || 0) - (application.expectedProcessingDays || 15));
  const reason = application.delayReason || (isDelayed ? `${daysOverdue} days over expected SLA of ${application.expectedProcessingDays} days.` : `Processing within expected SLA of ${application.expectedProcessingDays} days.`);

  return (
    <div className={`card mb-6 delay-card ${isDelayed ? 'bg-danger-light border-danger' : 'bg-success-light border-success'}`}>
      <div className="delay-card-content">
        {isDelayed ? (
          <AlertTriangle size={24} color="var(--danger-color)" />
        ) : (
          <CheckCircle size={24} color="var(--success-color)" />
        )}
        <div>
          <h4 className={`delay-card-title ${isDelayed ? 'delay-card-title-delayed' : 'delay-card-title-ontime'}`}>
            {isDelayed ? `Delayed (${daysOverdue} Days Overdue)` : 'On Schedule'}
          </h4>
          <p className="delay-card-subtitle">
            {reason}
          </p>
        </div>
      </div>
    </div>
  );
};

export default DelayCard;
