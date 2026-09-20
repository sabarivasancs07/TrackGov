import { useState } from 'react';
import { Sparkles } from 'lucide-react';
import Button from '../common/Button';
import { apiClient } from '../../services/api';

const AiExplanationCard = ({ applicationId }) => {
  const [aiText, setAiText] = useState('');
  const [loading, setLoading] = useState(false);
  const [type, setType] = useState('');

  const handleFetchAi = async (endpointType) => {
    setLoading(true);
    setType(endpointType);
    try {
      const res = await apiClient.get(`/applications/${applicationId}/ai/${endpointType}`);
      if (res && res.data) {
        setAiText(res.data);
      } else {
        setAiText('No explanation returned by AI service.');
      }
    } catch (err) {
      console.error('AI Error:', err);
      setAiText('Failed to generate AI explanation. Please check backend log or API key configuration.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="card mb-6 p-4 border border-primary-100 bg-primary-50/20">
      <div className="flex items-center gap-2 mb-3">
        <Sparkles size={20} className="text-primary-600" />
        <h4 className="font-semibold text-neutral-800 m-0">TrackGov AI Assistant</h4>
      </div>
      <div className="flex gap-2 mb-3 flex-wrap">
        <Button 
          variant="outline" 
          onClick={() => handleFetchAi('status')}
          isLoading={loading && type === 'status'}
        >
          Status Explanation
        </Button>
        <Button 
          variant="outline" 
          onClick={() => handleFetchAi('delay')}
          isLoading={loading && type === 'delay'}
        >
          Delay Analysis
        </Button>
      </div>
      {aiText && (
        <div className="p-3 bg-white rounded border border-neutral-200 text-sm leading-relaxed text-neutral-700 animate-fade-in">
          <strong>AI Insights:</strong>
          <p className="mt-1 mb-0">{aiText}</p>
        </div>
      )}
    </div>
  );
};

export default AiExplanationCard;
