import React from 'react';
import { useAuth } from '../context/AuthContext';
import './SettingsPage.css';

const SettingsPage = () => {
  const { user: officer } = useAuth();

  return (
    <div className="settings-page p-6">
      <h1 className="text-2xl font-bold mb-6">Settings</h1>
      
      <div className="settings-card bg-white rounded-lg shadow p-6 max-w-2xl">
        <h2 className="text-xl font-semibold mb-4 border-b pb-2">Officer Profile</h2>
        
        <div className="profile-details space-y-4">
          <div className="detail-group flex flex-col">
            <span className="text-sm text-gray-500 font-medium">Name</span>
            <span className="text-lg">{officer?.name || 'N/A'}</span>
          </div>
          
          <div className="detail-group flex flex-col">
            <span className="text-sm text-gray-500 font-medium">Role</span>
            <span className="text-lg">{officer?.role || 'N/A'}</span>
          </div>
          
          <div className="detail-group flex flex-col">
            <span className="text-sm text-gray-500 font-medium">Department / Office</span>
            <span className="text-lg">{officer?.office || 'N/A'}</span>
          </div>
          
          <div className="detail-group flex flex-col">
            <span className="text-sm text-gray-500 font-medium">Officer ID</span>
            <span className="text-lg">{officer?.id || officer?.officer_id || 'N/A'}</span>
          </div>
        </div>

        <div className="mt-8 pt-4 border-t text-sm text-gray-500 italic">
          Profile settings are currently read-only.
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;
