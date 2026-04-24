import { Link, useLocation } from 'react-router';
import { Home, MapPin, Calendar, Users, User } from 'lucide-react';

export default function Navigation() {
  const location = useLocation();

  const navItems = [
    { path: '/home', icon: Home, label: 'Home' },
    { path: '/reserve', icon: MapPin, label: 'Reserve' },
    { path: '/weekly-schedule', icon: Calendar, label: 'Schedule' },
    { path: '/study-buddy', icon: Users, label: 'Buddy' },
    { path: '/profile', icon: User, label: 'Profile' },
  ];

  return (
    <nav className="bg-white border-t border-gray-200 px-1">
      <div className="grid grid-cols-5">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.path;
          return (
            <Link
              key={item.path}
              to={item.path}
              className={`flex flex-col items-center justify-center py-2 transition-all ${
                isActive
                  ? 'text-blue-600'
                  : 'text-gray-400'
              }`}
            >
              <div className={`p-1.5 rounded-xl transition-all ${isActive ? 'bg-blue-50' : ''}`}>
                <Icon className="w-5 h-5" strokeWidth={isActive ? 2.5 : 2} />
              </div>
              <span className={`text-[9px] font-semibold mt-0.5 ${isActive ? 'opacity-100' : 'opacity-70'}`}>
                {item.label}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}