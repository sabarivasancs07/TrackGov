import './PriorityBadge.css';
import { ArrowUp, ArrowRight, ArrowDown } from 'lucide-react';

const PriorityBadge = ({ priority }) => {
  let config = {};
  
  switch(priority) {
    case 'High':
      config = {
        icon: ArrowUp,
        className: 'priority-high'
      };
      break;
    case 'Low':
      config = {
        icon: ArrowDown,
        className: 'priority-low'
      };
      break;
    case 'Medium':
    default:
      config = {
        icon: ArrowRight,
        className: 'priority-medium'
      };
      break;
  }

  const Icon = config.icon;

  return (
    <div className={`priority-badge ${config.className}`}>
      <Icon size={14} />
      <span>{priority}</span>
    </div>
  );
};

export default PriorityBadge;
