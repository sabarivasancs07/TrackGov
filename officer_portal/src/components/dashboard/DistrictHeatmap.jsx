import { districts } from '../../data/districts';
import './DistrictHeatmap.css';

const DistrictHeatmap = ({ applications }) => {
  // Calculate stats per district
  const districtStats = districts.map(district => {
    const appsInDistrict = applications.filter(a => a.district === district.id);
    const pending = appsInDistrict.filter(a => ['Pending', 'In Progress', 'Delayed'].includes(a.status)).length;
    const total = appsInDistrict.length;
    
    // Calculate a load percentage (mock calculation for heatmap visual)
    const loadPercent = total > 0 ? (pending / total) * 100 : 0;
    
    return {
      ...district,
      total,
      pending,
      loadPercent
    };
  });

  return (
    <div className="card heatmap-card">
      <h3 className="card-title mb-4">District Pending Load</h3>
      <div className="heatmap-container">
        {districtStats.map(stat => (
          <div key={stat.id} className="heatmap-row">
            <div className="heatmap-label">
              <span className="font-medium text-neutral-800">{stat.name}</span>
              <span className="text-xs text-neutral-500">{stat.pending} pending</span>
            </div>
            <div className="heatmap-bar-container">
              <div 
                className={`heatmap-bar ${
                  stat.loadPercent > 70 ? 'high' : 
                  stat.loadPercent > 30 ? 'medium' : 'low'
                }`}
                style={{ width: `${Math.max(stat.loadPercent, 5)}%` }}
              ></div>
            </div>
          </div>
        ))}
      </div>
      <div className="heatmap-legend mt-4">
        <div className="legend-item">
          <span className="legend-color low"></span>
          <span className="text-xs text-neutral-500">Low</span>
        </div>
        <div className="legend-item">
          <span className="legend-color medium"></span>
          <span className="text-xs text-neutral-500">Medium</span>
        </div>
        <div className="legend-item">
          <span className="legend-color high"></span>
          <span className="text-xs text-neutral-500">High</span>
        </div>
      </div>
    </div>
  );
};

export default DistrictHeatmap;
