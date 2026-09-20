import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { authService } from '../services/authService';
import Button from '../components/common/Button';
import './LoginPage.css';

const LoginPage = () => {
  const [officerId, setOfficerId] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [officerList, setOfficerList] = useState([]);
  const { login, loading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const loadOfficers = async () => {
      const list = await authService.getOfficers();
      setOfficerList(list);
    };
    loadOfficers();
  }, []);

  const handleSelectOfficer = (username) => {
    setOfficerId(username);
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');

    if (!officerId || !password) {
      setError('Required fields are missing.');
      return;
    }

    const result = await login(officerId, password);
    if (result.success) {
      navigate('/dashboard');
    } else {
      setError(result.message || 'Invalid credentials');
    }
  };

  return (
    <div className="login-card">
      <div className="login-header">
        <h1 className="login-title">TrackGov AI</h1>
        <p className="login-subtitle">Officer Portal Login</p>
      </div>

      {error && (
        <div className="login-error">
          {error}
        </div>
      )}

      <form onSubmit={handleLogin} className="login-form">
        <div className="login-form-group">
          <label htmlFor="officerRole" className="login-label">Select Officer</label>
          <select 
            id="officerRole"
            value={officerId}
            onChange={(e) => handleSelectOfficer(e.target.value)}
            className="login-input"
          >
            <option value="">-- Select an Officer --</option>
            {officerList.map(off => (
              <option key={off.officer_id} value={off.username || off.officer_id}>
                {off.role} - {off.name} ({off.officer_id})
              </option>
            ))}
          </select>
        </div>

        <div className="login-form-group">
          <label htmlFor="officerId" className="login-label">Officer ID / Username</label>
          <input 
            type="text" 
            id="officerId" 
            value={officerId}
            onChange={(e) => setOfficerId(e.target.value)}
            placeholder="e.g. officer001 or OFF-001"
            className="login-input" 
          />
        </div>

        <div className="login-form-group">
          <label htmlFor="password" className="login-label">Password</label>
          <input 
            type="password" 
            id="password" 
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Enter password"
            className="login-input" 
          />
        </div>

        <Button 
          type="submit" 
          disabled={loading}
          className="login-submit-btn"
        >
          {loading ? 'Authenticating...' : 'Sign In'}
        </Button>
      </form>
    </div>
  );
};

export default LoginPage;
