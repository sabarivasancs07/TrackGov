export const calculateDelay = (daysPending, expectedProcessingDays) => {
  if (daysPending > expectedProcessingDays) {
    return {
      isDelayed: true,
      text: '⚠ Delay Detected',
      color: 'var(--danger-color)',
      daysOverdue: daysPending - expectedProcessingDays
    };
  }
  return {
    isDelayed: false,
    text: '✓ On Schedule',
    color: 'var(--success-color)',
    daysOverdue: 0
  };
};
