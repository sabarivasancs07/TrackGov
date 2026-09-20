import { useApplications } from '../hooks/useApplications';
import { useSearch } from '../hooks/useSearch';
import ApplicationsTable from '../components/dashboard/ApplicationsTable';
import SearchBar from '../components/common/SearchBar';
import FilterPanel from '../components/common/FilterPanel';
import LoadingSpinner from '../components/common/LoadingSpinner';
import './ApplicationListPage.css';

const ApplicationListPage = () => {
  const { searchTerm, setSearchTerm, debouncedSearch, statusFilter, setStatusFilter } = useSearch();
  const { applications, loading } = useApplications(debouncedSearch, statusFilter);
  
  // Create an adapter for the FilterPanel to keep UI unchanged
  const filters = { search: searchTerm, status: statusFilter, category: 'All', dateRange: 'All Time' };
  const handleFilterChange = (newFilters) => {
    setSearchTerm(newFilters.search);
    setStatusFilter(newFilters.status);
  };
  const clearFilters = () => {
    setSearchTerm('');
    setStatusFilter('All');
  };

  return (
    <div className="page-container animate-fade-in">
      <div className="page-header flex justify-between items-center">
        <div>
          <h1 className="page-title">Applications</h1>
          <p className="page-subtitle">Manage and track all incoming applications.</p>
        </div>
      </div>

      <div className="filters-toolbar">
        <div className="search-wrapper">
          <SearchBar 
            value={searchTerm} 
            onChange={setSearchTerm} 
            placeholder="Search by ID or Applicant Name..."
          />
        </div>
        <div className="filter-wrapper">
          <FilterPanel 
            filters={filters} 
            onFilterChange={handleFilterChange} 
            onClearFilters={clearFilters}
          />
        </div>
      </div>

      {loading ? (
        <LoadingSpinner />
      ) : (
        <ApplicationsTable applications={applications} />
      )}
    </div>
  );
};

export default ApplicationListPage;
