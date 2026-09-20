import { useState, useEffect, useCallback } from 'react';
import { applicationService } from '../services/applicationService';
import { useAuth } from '../context/AuthContext';

export const useApplications = (searchQuery = '', statusFilter = 'All', officerOnly = false) => {
  const [applications, setApplications] = useState([]);
  const [loading, setLoading] = useState(true);
  const { user } = useAuth();

  const fetchApplications = useCallback(async () => {
    setLoading(true);
    try {
      const officerId = officerOnly && user ? user.id : null;
      const data = await applicationService.getAllApplications(searchQuery, statusFilter, officerId);
      setApplications(data);
    } catch (error) {
      console.error("Failed to fetch applications", error);
      setApplications([]);
    } finally {
      setLoading(false);
    }
  }, [searchQuery, statusFilter, officerOnly, user]);

  useEffect(() => {
    fetchApplications();
  }, [fetchApplications]);

  const getApplicationById = useCallback(async (id) => {
    return await applicationService.getApplicationById(id);
  }, []);

  return {
    applications,
    loading,
    refetch: fetchApplications,
    getApplicationById
  };
};

