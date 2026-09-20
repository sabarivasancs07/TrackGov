import { Link } from 'react-router-dom';
import { Home } from 'lucide-react';
import EmptyState from '../components/common/EmptyState';
import Button from '../components/common/Button';

const NotFoundPage = () => {
  return (
    <div className="page-container flex items-center justify-center min-h-[70vh] animate-fade-in">
      <EmptyState
        title="404 - Page Not Found"
        description="The page you are looking for doesn't exist or has been moved."
        action={
          <Link to="/">
            <Button icon={Home}>Back to Dashboard</Button>
          </Link>
        }
      />
    </div>
  );
};

export default NotFoundPage;
