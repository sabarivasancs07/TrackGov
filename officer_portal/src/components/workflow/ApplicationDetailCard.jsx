import { User, MapPin, IndianRupee, FileBarChart2 } from 'lucide-react';
import './ApplicationDetailCard.css';

const ApplicationDetailCard = ({ application }) => {
  if (!application) return null;

  return (
    <div className="card app-detail-card">
      <div className="detail-section">
        <h3 className="section-title">
          <User size={18} className="text-primary-600" />
          Applicant Information
        </h3>
        <div className="detail-grid">
          <div className="detail-item">
            <span className="detail-label">Full Name</span>
            <span className="detail-value">{application.applicantName}</span>
          </div>
          <div className="detail-item">
            <span className="detail-label">Category</span>
            <span className="detail-value">{application.category}</span>
          </div>
          <div className="detail-item">
            <span className="detail-label">Application ID</span>
            <span className="detail-value font-mono">{application.id}</span>
          </div>
        </div>
      </div>

      <div className="divider"></div>

      <div className="detail-section">
        <h3 className="section-title">
          <IndianRupee size={18} className="text-primary-600" />
          Income & Assets
        </h3>
        <div className="detail-grid">
          <div className="detail-item">
            <span className="detail-label">Declared Annual Income</span>
            <span className="detail-value font-semibold">₹ {application.annualIncome.toLocaleString('en-IN')}</span>
          </div>
          <div className="detail-item">
            <span className="detail-label">Land Holding</span>
            <span className="detail-value">{application.landHolding} Acres</span>
          </div>
        </div>
      </div>

      <div className="divider"></div>

      <div className="detail-section">
        <h3 className="section-title">
          <MapPin size={18} className="text-primary-600" />
          Location Details
        </h3>
        <div className="detail-grid">
          <div className="detail-item">
            <span className="detail-label">District</span>
            <span className="detail-value">Pune (MH02)</span>
          </div>
          <div className="detail-item">
            <span className="detail-label">Taluka</span>
            <span className="detail-value">Haveli (T03)</span>
          </div>
          <div className="detail-item">
            <span className="detail-label">Village</span>
            <span className="detail-value">{application.village}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ApplicationDetailCard;
