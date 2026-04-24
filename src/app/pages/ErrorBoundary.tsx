import { useRouteError, isRouteErrorResponse, useNavigate } from 'react-router';
import { AlertTriangle, Home, RefreshCcw } from 'lucide-react';

export default function ErrorBoundary() {
  const error = useRouteError();
  const navigate = useNavigate();

  let errorMessage: string;
  let errorStatus: string | number | undefined;

  if (isRouteErrorResponse(error)) {
    errorStatus = error.status;
    errorMessage = error.statusText || error.data?.message || 'An error occurred';
  } else if (error instanceof Error) {
    errorMessage = error.message;
  } else {
    errorMessage = 'Unknown error occurred';
  }

  return (
    <div className="h-full bg-white flex flex-col items-center justify-center p-8">
      <div className="text-center">
        <AlertTriangle className="w-16 h-16 text-orange-500 mx-auto mb-4" />
        
        {errorStatus && (
          <div className="text-4xl font-bold text-gray-900 mb-2">{errorStatus}</div>
        )}
        
        <h1 className="text-xl font-bold text-gray-900 mb-2">Oops! Something went wrong</h1>
        <p className="text-sm text-gray-600 mb-6 max-w-xs mx-auto">
          {errorMessage}
        </p>
        
        <div className="flex flex-col space-y-3">
          <button
            onClick={() => window.location.reload()}
            className="flex items-center justify-center space-x-2 px-6 py-3 bg-gray-100 text-gray-900 rounded-xl font-semibold active:scale-95 transition-transform"
          >
            <RefreshCcw className="w-5 h-5" />
            <span>Reload Page</span>
          </button>
          
          <button
            onClick={() => navigate('/home')}
            className="flex items-center justify-center space-x-2 px-6 py-3 bg-blue-600 text-white rounded-xl font-semibold active:scale-95 transition-transform"
          >
            <Home className="w-5 h-5" />
            <span>Go Home</span>
          </button>
        </div>
        
        {import.meta.env.DEV && (
          <div className="mt-6 p-4 bg-gray-100 rounded-xl text-left">
            <p className="text-xs font-mono text-gray-700 break-all">
              {error instanceof Error ? error.stack : JSON.stringify(error)}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
