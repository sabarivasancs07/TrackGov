import { Clock, CheckCircle, AlertCircle, AlertTriangle, PlayCircle } from 'lucide-react';

export const getStatusConfig = (status) => {
  switch (status) {
    case 'Pending':
      return {
        className: 'badge-pending',
        icon: Clock,
        label: 'Pending'
      };
    case 'In Progress':
      return {
        className: 'badge-progress',
        icon: PlayCircle,
        label: 'In Progress'
      };
    case 'Approved':
      return {
        className: 'badge-approved',
        icon: CheckCircle,
        label: 'Approved'
      };
    case 'Rejected':
      return {
        className: 'badge-rejected',
        icon: AlertCircle,
        label: 'Rejected'
      };
    case 'Delayed':
      return {
        className: 'badge-delayed',
        icon: AlertTriangle,
        label: 'Delayed'
      };
    default:
      return {
        className: 'badge-default',
        icon: Clock,
        label: status || 'Unknown'
      };
  }
};
