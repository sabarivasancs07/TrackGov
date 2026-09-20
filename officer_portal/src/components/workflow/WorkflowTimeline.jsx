import StageCard from './StageCard';
import './WorkflowTimeline.css';

const WorkflowTimeline = ({ workflowHistory }) => {
  if (!workflowHistory || workflowHistory.length === 0) return null;

  return (
    <div className="workflow-timeline card">
      <h3 className="card-title mb-6">Processing Timeline</h3>
      <div className="timeline-container">
        {workflowHistory.map((historyItem, idx) => (
          <StageCard 
            key={idx}
            stage={historyItem.stage}
            status={historyItem.action}
            date={historyItem.date}
            officer={historyItem.officer}
            remarks={historyItem.remarks}
            isLast={idx === workflowHistory.length - 1}
          />
        ))}
      </div>
    </div>
  );
};

export default WorkflowTimeline;
