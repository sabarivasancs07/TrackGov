import { NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, FileText, Activity, Settings, LogOut } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import './Sidebar.css';

const Sidebar = ({ isOpen }) => {
  const navigate = useNavigate();
  const { logout } = useAuth();

  const navItems = [
    { name: 'Dashboard', icon: LayoutDashboard, path: '/dashboard' },
    { name: 'Applications', icon: FileText, path: '/applications' },
    { name: 'Audit Log', icon: Activity, path: '/audit-history' },
    { name: 'Settings', icon: Settings, path: '/settings' }
  ];

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <aside className={`sidebar ${isOpen ? 'open' : 'closed'}`}>
      <div className="sidebar-header">
        <div className="logo-container">
          <div className="logo-icon">🏛️</div>
          {isOpen && <span className="logo-text">TrackGov AI</span>}
        </div>
      </div>

      <nav className="sidebar-nav">
        <ul>
          {navItems.map((item) => (
            <li key={item.name}>
              <NavLink 
                to={item.path} 
                className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
              >
                <item.icon className="nav-icon" size={20} />
                {isOpen && <span className="nav-text">{item.name}</span>}
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>

      <div className="sidebar-footer">
        <button className="nav-link logout-btn" onClick={handleLogout}>
          <LogOut className="nav-icon" size={20} />
          {isOpen && <span className="nav-text">Sign Out</span>}
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
