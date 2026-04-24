import { Outlet, useLocation } from 'react-router';
import Navigation from './components/Navigation';

export default function Root() {
  const location = useLocation();
  const showNavigation = location.pathname !== '/' && 
                         location.pathname !== '/register' &&
                         location.pathname !== '/onboarding';

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 flex items-center justify-center p-4">
      {/* Mobile Frame - Standard mobile size (360x800 - most common) */}
      <div className="w-[360px] h-[800px] bg-white rounded-[45px] shadow-2xl overflow-hidden relative border-[10px] border-gray-900">
        {/* Notch - Universal notch */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[120px] h-[30px] bg-gray-900 rounded-b-3xl z-50"></div>
        
        {/* Status Bar */}
        <div className="absolute top-0 left-0 right-0 h-10 pt-2 px-5 flex items-center justify-between z-40">
          <span className="text-[11px] font-semibold text-gray-900">9:41</span>
          <div className="flex items-center space-x-1">
            <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
              <path d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z" />
            </svg>
            <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M17.778 8.222c-4.296-4.296-11.26-4.296-15.556 0A1 1 0 01.808 6.808c5.076-5.077 13.308-5.077 18.384 0a1 1 0 01-1.414 1.414zM14.95 11.05a7 7 0 00-9.9 0 1 1 0 01-1.414-1.414 9 9 0 0112.728 0 1 1 0 01-1.414 1.414zM12.12 13.88a3 3 0 00-4.242 0 1 1 0 01-1.415-1.415 5 5 0 017.072 0 1 1 0 01-1.415 1.415zM9 16a1 1 0 011-1h.01a1 1 0 110 2H10a1 1 0 01-1-1z" clipRule="evenodd" />
            </svg>
            <div className="w-5 h-2.5 border-2 border-gray-900 rounded-sm relative">
              <div className="absolute inset-0.5 bg-gray-900 rounded-sm"></div>
            </div>
          </div>
        </div>
        
        {/* App Content - Everything inside the phone */}
        <div className="h-full flex flex-col bg-gray-50 pt-10">
          <main className="flex-1 overflow-y-auto">
            <Outlet />
          </main>
          {showNavigation && (
            <div className="pb-2">
              <Navigation />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}