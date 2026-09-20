import { FileText, Clock, CheckCircle, AlertTriangle, XCircle, Loader } from 'lucide-react';
import StatsCard from './StatsCard';
import './StatsGrid.css';

const StatsGrid = ({ applications }) => {
  const total = applications.length;
  const pending = applications.filter(a => a.status === 'Pending').length;
  const inProgress = applications.filter(a => a.status === 'In Progress').length;
  const approved = applications.filter(a => a.status === 'Approved').length;
  const rejected = applications.filter(a => a.status === 'Rejected').length;
  const delayed = applications.filter(a => a.status === 'Delayed').length;

  return (
    <div className="stats-grid">
      <StatsCard title="Total" value={total} icon={FileText} colorClass="stats-primary" />
      <StatsCard title="Pending" value={pending} icon={Clock} colorClass="stats-pending" />
      <StatsCard title="In Progress" value={inProgress} icon={Loader} colorClass="stats-info" />
      <StatsCard title="Approved" value={approved} icon={CheckCircle} colorClass="stats-success" />
      <StatsCard title="Rejected" value={rejected} icon={XCircle} colorClass="stats-danger" />
      <StatsCard title="Delayed" value={delayed} icon={AlertTriangle} colorClass="stats-warning" />
    </div>
  );
};

export default StatsGrid;
