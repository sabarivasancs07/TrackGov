import { ArrowUpRight, ArrowDownRight, Minus } from 'lucide-react';
import './StatsCard.css';

const StatsCard = ({ title, value, icon: Icon, trend, colorClass }) => {
  return (
    <div className={`stats-card card ${colorClass}`}>
      <div className="stats-header">
        <div className="stats-icon-wrapper">
          {Icon && <Icon size={24} />}
        </div>
        {trend && (
          <div className={`stats-trend ${trend.direction}`}>
            {trend.direction === 'up' && <ArrowUpRight size={16} />}
            {trend.direction === 'down' && <ArrowDownRight size={16} />}
            {trend.direction === 'neutral' && <Minus size={16} />}
            <span>{trend.value}</span>
          </div>
        )}
      </div>
      <div className="stats-body">
        <h3 className="stats-value">{value}</h3>
        <p className="stats-title">{title}</p>
      </div>
    </div>
  );
};

export default StatsCard;
