import { Outlet } from 'react-router-dom';
import '../styles/global.css'; // Ensure global styles are loaded
import './AuthLayout.css';

const AuthLayout = () => {
  return (
    <div className="auth-layout">
      <main className="auth-content">
        <Outlet />
      </main>
    </div>
  );
};

export default AuthLayout;
