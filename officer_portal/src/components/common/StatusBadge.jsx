import { getStatusConfig } from '../../utils/statusHelpers';
import './StatusBadge.css';

const StatusBadge = ({ status, showIcon = true, size = 'md' }) => {
  const config = getStatusConfig(status);
  const Icon = config.icon;

  return (
    <span className={`status-badge status-badge-${size} ${config.className}`}>
      {showIcon && <Icon size={size === 'sm' ? 12 : 14} className="status-icon" />}
      {config.label}
    </span>
  );
};

export default StatusBadge;
