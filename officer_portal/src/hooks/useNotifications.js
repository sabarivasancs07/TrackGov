import { useState, useCallback, useMemo } from 'react';

export const useNotifications = () => {
  const [notifications, setNotifications] = useState([]);

  const unreadCount = useMemo(() => 
    notifications.filter(n => !n.read).length
  , [notifications]);

  const markAsRead = useCallback((id) => {
    setNotifications(prev => 
      prev.map(n => n.id === id ? { ...n, read: true } : n)
    );
  }, []);

  const markAllAsRead = useCallback(() => {
    setNotifications(prev => 
      prev.map(n => ({ ...n, read: true }))
    );
  }, []);

  const addNotification = useCallback((notification) => {
    setNotifications(prev => [
      {
        ...notification,
        id: `NOT-${Date.now()}`,
        timestamp: new Date().toISOString(),
        read: false
      },
      ...prev
    ]);
  }, []);

  return {
    notifications,
    unreadCount,
    markAsRead,
    markAllAsRead,
    addNotification
  };
};
