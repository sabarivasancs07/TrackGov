import { useState } from 'react';
import { Filter, X } from 'lucide-react';
import Button from './Button';
import './FilterPanel.css';

const FilterPanel = ({ filters, onFilterChange, onClearFilters }) => {
  const [isOpen, setIsOpen] = useState(false);

  const statuses = ['All', 'Pending', 'In Progress', 'Approved', 'Rejected', 'Delayed'];
  const categories = ['All', 'General', 'OBC', 'SC', 'ST', 'VJNT'];
  const dateRanges = ['All Time', 'Today', 'Last 7 Days', 'Last 30 Days'];

  const handleFilterSelect = (key, value) => {
    onFilterChange({ ...filters, [key]: value });
  };

  const activeFiltersCount = Object.keys(filters).reduce((acc, key) => {
    if (key !== 'search' && filters[key] !== 'All' && filters[key] !== 'All Time') {
      return acc + 1;
    }
    return acc;
  }, 0);

  return (
    <div className="filter-panel-container">
      <Button 
        variant="secondary" 
        icon={Filter} 
        onClick={() => setIsOpen(!isOpen)}
        className={activeFiltersCount > 0 ? 'has-active-filters' : ''}
      >
        Filters
        {activeFiltersCount > 0 && <span className="filter-badge">{activeFiltersCount}</span>}
      </Button>

      {isOpen && (
        <div className="filter-dropdown animate-slide-up">
          <div className="filter-header">
            <h4>Filter Applications</h4>
            <button className="close-filter" onClick={() => setIsOpen(false)}>
              <X size={16} />
            </button>
          </div>

          <div className="filter-body">
            <div className="filter-group">
              <label>Status</label>
              <select 
                value={filters.status || 'All'} 
                onChange={(e) => handleFilterSelect('status', e.target.value)}
              >
                {statuses.map(s => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>

            <div className="filter-group">
              <label>Category</label>
              <select 
                value={filters.category || 'All'} 
                onChange={(e) => handleFilterSelect('category', e.target.value)}
              >
                {categories.map(c => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>

            <div className="filter-group">
              <label>Date Range</label>
              <select 
                value={filters.dateRange || 'All Time'} 
                onChange={(e) => handleFilterSelect('dateRange', e.target.value)}
              >
                {dateRanges.map(d => <option key={d} value={d}>{d}</option>)}
              </select>
            </div>
          </div>

          <div className="filter-footer">
            <Button variant="ghost" size="sm" onClick={onClearFilters}>
              Clear All
            </Button>
            <Button variant="primary" size="sm" onClick={() => setIsOpen(false)}>
              Apply Filters
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};

export default FilterPanel;
