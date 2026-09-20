import { Menu, Bell, Search, ChevronDown } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useNotificationContext } from '../../context/NotificationContext';
import './TopBar.css';

const TopBar = ({ toggleSidebar }) => {
  const { user: officer } = useAuth();
  const { unreadCount } = useNotificationContext();

  return (
    <header className="topbar">
      <div className="topbar-left">
        <button className="icon-btn" onClick={toggleSidebar}>
          <Menu size={20} />
        </button>
        <div className="search-container">
          <Search size={18} className="search-icon" />
          <input 
            type="text" 
            placeholder="Search Application ID, Applicant..." 
            className="search-input"
          />
        </div>
      </div>

      <div className="topbar-right">
        <button className="icon-btn notification-btn">
          <Bell size={20} />
          {unreadCount > 0 && (
            <span className="notification-badge">{unreadCount}</span>
          )}
        </button>

        <div className="officer-profile">
          <img src={officer.avatar} alt="Profile" className="avatar" />
          <div className="officer-info">
            <span className="officer-name">{officer?.name || 'Guest'}</span>
            <span className="officer-designation">{officer?.role || 'Officer'}</span>
          </div>
          <ChevronDown size={16} className="text-neutral-500" />
        </div>
      </div>
    </header>
  );
};

export default TopBar;
