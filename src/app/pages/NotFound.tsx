import { useNavigate } from 'react-router';
import { Home, ArrowLeft } from 'lucide-react';

export default function NotFound() {
  const navigate = useNavigate();

  return (
    <div className="h-full bg-white flex flex-col items-center justify-center p-8">
      <div className="text-center">
        <div className="text-6xl font-bold text-blue-600 mb-4">404</div>
        <h1 className="text-xl font-bold text-gray-900 mb-2">Page Not Found</h1>
        <p className="text-sm text-gray-600 mb-8">
          The page you're looking for doesn't exist.
        </p>
        
        <div className="flex flex-col space-y-3">
          <button
            onClick={() => navigate(-1)}
            className="flex items-center justify-center space-x-2 px-6 py-3 bg-gray-100 text-gray-900 rounded-xl font-semibold active:scale-95 transition-transform"
          >
            <ArrowLeft className="w-5 h-5" />
            <span>Go Back</span>
          </button>
          
          <button
            onClick={() => navigate('/home')}
            className="flex items-center justify-center space-x-2 px-6 py-3 bg-blue-600 text-white rounded-xl font-semibold active:scale-95 transition-transform"
          >
            <Home className="w-5 h-5" />
            <span>Go Home</span>
          </button>
        </div>
      </div>
    </div>
  );
}
