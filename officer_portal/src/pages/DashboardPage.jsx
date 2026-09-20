import { useApplications } from '../hooks/useApplications';
import StatsGrid from '../components/dashboard/StatsGrid';
import ApplicationsTable from '../components/dashboard/ApplicationsTable';
import RecentActivity from '../components/dashboard/RecentActivity';
import DistrictHeatmap from '../components/dashboard/DistrictHeatmap';
import './DashboardPage.css';

const DashboardPage = () => {
  const { applications, loading } = useApplications();

  return (
    <div className="page-container dashboard-page animate-fade-in">
      <div className="page-header">
        <h1 className="page-title">Dashboard Overview</h1>
        <p className="page-subtitle">Welcome back, Officer. Here's what's happening today.</p>
      </div>

      <StatsGrid applications={applications} />

      <div className="dashboard-main-grid">
        <div className="dashboard-col-large">
          <ApplicationsTable applications={applications} limit={5} />
        </div>
        <div className="dashboard-col-small">
          <RecentActivity applications={applications} />
        </div>
      </div>

      <div className="mt-6">
        <DistrictHeatmap applications={applications} />
      </div>
    </div>
  );
};

export default DashboardPage;
