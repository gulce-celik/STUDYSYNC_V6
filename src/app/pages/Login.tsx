import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { LogIn, Mail, Lock, Smartphone } from 'lucide-react';
import { toast } from 'sonner';

export default function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // Disable dark mode on login page
  useEffect(() => {
    document.documentElement.classList.remove('dark');
  }, []);

  const handleLogin = (e?: React.FormEvent) => {
    e?.preventDefault();
    
    // Validate Yeditepe University email format
    const emailRegex = /^[a-zA-Z0-9._%+-]+@std\.yeditepe\.edu\.tr$/;
    
    if (!emailRegex.test(email)) {
      toast.error('Use Yeditepe email');
      return;
    }
    
    if (!password) {
      toast.error('Enter password');
      return;
    }

    toast.success('Welcome! 🎓');
    
    // Check if user is registered (has completed registration)
    const userRegistered = localStorage.getItem('userRegistered');
    
    if (userRegistered === 'true') {
      // Registered user - go directly to home
      navigate('/home');
    } else {
      // Not registered - clear old data and go to onboarding
      localStorage.removeItem('onboardingComplete');
      localStorage.removeItem('userDepartment');
      localStorage.removeItem('userYear');
      localStorage.removeItem('userCourses');
      navigate('/onboarding');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 flex flex-col items-center justify-center px-6 py-12">
      {/* Logo */}
      <div className="mb-8 text-center">
        <div className="w-24 h-24 bg-white rounded-3xl flex items-center justify-center mx-auto mb-4 shadow-xl">
          <Smartphone className="w-12 h-12 text-blue-600" />
        </div>
        <h1 className="text-4xl font-bold text-white mb-2">StudySync</h1>
        <p className="text-blue-100">Your University Study Hub</p>
      </div>

      {/* Login Form */}
      <div className="w-full max-w-md bg-white rounded-3xl p-8 shadow-2xl">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Welcome Back</h2>
        <p className="text-gray-600 mb-6 text-sm">Login with your university email</p>

        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">
              University Email
            </label>
            <div className="relative">
              <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="name@std.yeditepe.edu.tr"
                className="w-full pl-12 pr-4 py-3.5 border-2 border-gray-200 rounded-xl text-sm font-medium focus:border-blue-500 focus:outline-none"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">
              Password
            </label>
            <div className="relative">
              <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full pl-12 pr-4 py-3.5 border-2 border-gray-200 rounded-xl text-sm font-medium focus:border-blue-500 focus:outline-none"
                required
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-gradient-to-r from-blue-600 to-purple-600 text-white py-4 rounded-xl font-bold text-lg shadow-lg active:scale-95 transition-transform disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
          >
            {isLoading ? (
              <div className="w-6 h-6 border-3 border-white border-t-transparent rounded-full animate-spin"></div>
            ) : (
              <>
                <LogIn className="w-5 h-5" />
                <span>Login</span>
              </>
            )}
          </button>
        </form>

        <div className="mt-6 text-center">
          <a href="#" className="text-sm text-blue-600 font-semibold">
            Forgot password?
          </a>
        </div>
        
        <div className="mt-4 text-center">
          <span className="text-sm text-gray-600">Not registered yet? </span>
          <button 
            onClick={() => navigate('/register')}
            className="text-sm text-purple-600 font-bold hover:underline"
          >
            Create Account
          </button>
        </div>
      </div>

      {/* Info */}
      <div className="mt-8 bg-white/20 backdrop-blur rounded-2xl p-4 max-w-md">
        <p className="text-white text-xs text-center">
          🎓 University students only • Verified .edu emails
        </p>
      </div>
    </div>
  );
}