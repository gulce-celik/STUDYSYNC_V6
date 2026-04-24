import { useState, useEffect } from 'react';
import { currentUser, departments, courses, scoreHistory } from '../data/mockData';
import { User, Award, LogOut, Calendar, Settings, TrendingUp, TrendingDown, Hash, Moon, Sun, Monitor, Lock, Eye, EyeOff, Users } from 'lucide-react';
import { toast } from 'sonner';
import { useNavigate } from 'react-router';

export default function Profile() {
  const navigate = useNavigate();
  const [studyGoal, setStudyGoal] = useState<string>('');
  const [userLevel, setUserLevel] = useState<string>('');
  const [learningStyle, setLearningStyle] = useState<string>('');
  const [preferredTime, setPreferredTime] = useState<string>('');
  const [preferredDays, setPreferredDays] = useState<string>('');
  const [darkMode, setDarkMode] = useState<'auto' | 'on' | 'off'>('off');
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [studyPreferencesComplete, setStudyPreferencesComplete] = useState(false);

  // Check if study preferences are complete
  useEffect(() => {
    if (studyGoal && userLevel && learningStyle && preferredTime && preferredDays) {
      setStudyPreferencesComplete(true);
    } else {
      setStudyPreferencesComplete(false);
    }
  }, [studyGoal, userLevel, learningStyle, preferredTime, preferredDays]);

  // Apply dark mode
  useEffect(() => {
    if (darkMode === 'on') {
      document.documentElement.classList.add('dark');
      toast.success('Dark mode enabled');
    } else if (darkMode === 'off') {
      document.documentElement.classList.remove('dark');
    } else {
      // Auto mode - check system preference
      const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      if (isDark) {
        document.documentElement.classList.add('dark');
      } else {
        document.documentElement.classList.remove('dark');
      }
      toast.success('Auto mode enabled');
    }
  }, [darkMode]);

  const handleSave = () => {
    toast.success('Profile updated!');
  };

  const handleLogout = () => {
    toast.success('Logged out');
    navigate('/');
  };

  const handlePasswordChange = () => {
    if (!currentPassword) {
      toast.error('Enter current password');
      return;
    }
    if (newPassword.length < 6) {
      toast.error('Password must be 6+ chars');
      return;
    }
    if (newPassword !== confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }
    
    toast.success('Password changed!');
    setShowPasswordModal(false);
    setCurrentPassword('');
    setNewPassword('');
    setConfirmPassword('');
  };

  const userDepartment = departments.find(d => d.id === currentUser.department)?.name || currentUser.department;
  const userCourses = courses.filter(c => currentUser.courses && currentUser.courses.includes(c.code));

  return (
    <div className="h-full bg-white flex flex-col">
      {/* Header */}
      <div className="bg-gradient-to-br from-blue-600 to-purple-600 px-4 pt-2 pb-4 rounded-b-[24px]">
        <h1 className="text-lg font-bold text-white mb-0.5">Profile</h1>
        <p className="text-[10px] text-blue-100">Manage your preferences</p>
      </div>

      <div className="flex-1 overflow-y-auto pb-16 -mt-3">
        <div className="px-4 space-y-2.5">
          {/* User Info Card */}
          <div className="bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl p-3 text-white shadow-lg">
            <div className="flex items-center space-x-2.5 mb-2">
              <div className="w-11 h-11 bg-white/30 backdrop-blur rounded-full flex items-center justify-center">
                <User className="w-5 h-5" />
              </div>
              <div className="flex-1">
                <h2 className="font-bold text-base">{currentUser.name}</h2>
                <p className="text-[10px] text-blue-100">{userDepartment} • {currentUser.year}. Year</p>
              </div>
            </div>
            <div className="bg-white/20 backdrop-blur rounded-xl p-2.5">
              <div className="flex items-center justify-between mb-1">
                <span className="text-[10px] opacity-90">Responsibility Score</span>
                <Award className="w-3.5 h-3.5" />
              </div>
              <div className="flex items-end space-x-1">
                <span className="text-2xl font-bold">{currentUser.responsibilityScore}</span>
                <span className="text-sm mb-0.5">%</span>
              </div>
              <div className="mt-1.5 w-full bg-white/30 rounded-full h-1">
                <div
                  className="bg-white h-1 rounded-full transition-all"
                  style={{ width: `${currentUser.responsibilityScore}%` }}
                ></div>
              </div>
            </div>
          </div>

          {/* My Courses */}
          <div className="bg-gray-50 rounded-2xl p-3 border border-gray-200">
            <div className="flex items-center justify-between mb-2">
              <h3 className="font-bold text-gray-900 text-xs">My Courses</h3>
              <button
                onClick={() => navigate('/weekly-schedule')}
                className="flex items-center space-x-0.5 text-blue-600 text-[10px] font-bold"
              >
                <Calendar className="w-3 h-3" />
                <span>Edit</span>
              </button>
            </div>
            <div className="grid grid-cols-2 gap-1.5">
              {userCourses.slice(0, 4).map((course) => (
                <div key={course.id} className="bg-white rounded-lg p-2 border border-gray-200">
                  <div className="font-bold text-gray-900 text-[10px] mb-0.5">{course.code}</div>
                  <div className="text-[8px] text-gray-600 line-clamp-1">{course.name}</div>
                </div>
              ))}
            </div>
            {userCourses.length > 4 && (
              <p className="text-[9px] text-gray-500 text-center mt-1.5">+{userCourses.length - 4} more</p>
            )}
          </div>

          {/* Nickname */}
          <div className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-2xl p-3 border-2 border-indigo-200">
            <div className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center">
                <Hash className="w-4 h-4 text-indigo-600" />
              </div>
              <div>
                <p className="text-[9px] text-indigo-600 font-semibold">Your Nickname</p>
                <p className="text-sm font-bold text-indigo-900">{currentUser.nickname || 'ahmet_y'}</p>
              </div>
            </div>
            <p className="text-[9px] text-indigo-600 mt-2">Used for group reservations</p>
          </div>

          {/* Study Buddy Matching Preferences - Required */}
          <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl p-3.5 border-2 border-purple-300 shadow-sm">
            <div className="flex items-start justify-between mb-2">
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 bg-purple-500 rounded-full flex items-center justify-center">
                  <Users className="w-4 h-4 text-white" />
                </div>
                <div>
                  <h3 className="font-bold text-purple-900 text-xs">Study Buddy Preferences</h3>
                  <p className="text-[9px] text-purple-700">Required for AI matching</p>
                </div>
              </div>
              {studyPreferencesComplete && (
                <div className="bg-green-500 rounded-full w-5 h-5 flex items-center justify-center">
                  <span className="text-white text-xs">✓</span>
                </div>
              )}
            </div>

            {!studyPreferencesComplete && (
              <div className="mb-3 bg-amber-100 border border-amber-300 rounded-lg p-2">
                <p className="text-[9px] text-amber-900 font-semibold">
                  ⚠️ Complete your preferences to improve match accuracy
                </p>
              </div>
            )}

            {/* Study Goal */}
            <div className="mb-3">
              <label className="block text-[10px] font-bold text-purple-900 mb-1.5">Study Goal</label>
              <div className="grid grid-cols-2 gap-1.5">
                {(['Exam Prep', 'Homework Help', 'Practice', 'Project Work'] as const).map((goal) => (
                  <button
                    key={goal}
                    onClick={() => setStudyGoal(goal)}
                    className={`px-2 py-2 rounded-lg border-2 transition-colors text-[10px] font-semibold ${
                      studyGoal === goal
                        ? 'border-purple-600 bg-purple-100 text-purple-700'
                        : 'border-purple-200 bg-white text-gray-600'
                    }`}
                  >
                    {goal}
                  </button>
                ))}
              </div>
            </div>

            {/* User Level */}
            <div className="mb-3">
              <label className="block text-[10px] font-bold text-purple-900 mb-1.5">User Level</label>
              <div className="grid grid-cols-3 gap-1.5">
                {(['Beginner', 'Intermediate', 'Advanced'] as const).map((level) => (
                  <button
                    key={level}
                    onClick={() => setUserLevel(level)}
                    className={`px-2 py-2 rounded-lg border-2 transition-colors text-[10px] font-semibold ${
                      userLevel === level
                        ? 'border-purple-600 bg-purple-100 text-purple-700'
                        : 'border-purple-200 bg-white text-gray-600'
                    }`}
                  >
                    {level}
                  </button>
                ))}
              </div>
            </div>

            {/* Study Style / Learning Style */}
            <div className="mb-3">
              <label className="block text-[10px] font-bold text-purple-900 mb-1.5">Study Style</label>
              <div className="grid grid-cols-2 gap-1.5">
                {(['Explain to others', 'Practice together', 'Listen & Learn', 'Accountability'] as const).map((style) => (
                  <button
                    key={style}
                    onClick={() => setLearningStyle(style)}
                    className={`px-2 py-2 rounded-lg border-2 transition-colors text-[9px] font-semibold ${
                      learningStyle === style
                        ? 'border-purple-600 bg-purple-100 text-purple-700'
                        : 'border-purple-200 bg-white text-gray-600'
                    }`}
                  >
                    {style}
                  </button>
                ))}
              </div>
            </div>

            {/* Preferred Time */}
            <div className="mb-3">
              <label className="block text-[10px] font-bold text-purple-900 mb-1.5">Preferred Time</label>
              <div className="grid grid-cols-3 gap-1.5">
                {(['Morning', 'Afternoon', 'Evening'] as const).map((time) => (
                  <button
                    key={time}
                    onClick={() => setPreferredTime(time)}
                    className={`px-2 py-2 rounded-lg border-2 transition-colors text-[10px] font-semibold ${
                      preferredTime === time
                        ? 'border-purple-600 bg-purple-100 text-purple-700'
                        : 'border-purple-200 bg-white text-gray-600'
                    }`}
                  >
                    {time}
                  </button>
                ))}
              </div>
            </div>

            {/* Preferred Days */}
            <div>
              <label className="block text-[10px] font-bold text-purple-900 mb-1.5">Preferred Days</label>
              <div className="grid grid-cols-2 gap-1.5">
                {(['Weekdays', 'Weekend'] as const).map((day) => (
                  <button
                    key={day}
                    onClick={() => setPreferredDays(day)}
                    className={`px-2 py-2 rounded-lg border-2 transition-colors text-[10px] font-semibold ${
                      preferredDays === day
                        ? 'border-purple-600 bg-purple-100 text-purple-700'
                        : 'border-purple-200 bg-white text-gray-600'
                    }`}
                  >
                    {day}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Score History */}
          <div className="bg-white rounded-2xl p-3 shadow-sm border border-gray-200">
            <h3 className="font-bold text-gray-900 text-xs mb-2 flex items-center space-x-1.5">
              <Award className="w-3.5 h-3.5 text-purple-600" />
              <span>Score History</span>
            </h3>
            <div className="space-y-1.5 max-h-48 overflow-y-auto">
              {scoreHistory.map((entry) => (
                <div key={entry.id} className="bg-gray-50 rounded-lg p-2 border border-gray-100">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <p className="text-[10px] text-gray-900 font-semibold mb-0.5">{entry.description}</p>
                      <p className="text-[8px] text-gray-500">{new Date(entry.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</p>
                    </div>
                    <div className={`flex items-center space-x-0.5 px-2 py-0.5 rounded-full ${
                      entry.scoreChange > 0 ? 'bg-green-100' : 'bg-red-100'
                    }`}>
                      {entry.scoreChange > 0 ? (
                        <TrendingUp className="w-3 h-3 text-green-600" />
                      ) : (
                        <TrendingDown className="w-3 h-3 text-red-600" />
                      )}
                      <span className={`text-[10px] font-bold ${
                        entry.scoreChange > 0 ? 'text-green-700' : 'text-red-700'
                      }`}>
                        {entry.scoreChange > 0 ? '+' : ''}{entry.scoreChange}
                      </span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
            <div className="mt-2 bg-blue-50 border border-blue-200 rounded-lg p-2">
              <p className="text-[9px] text-blue-800 leading-relaxed">
                <span className="font-bold">Score Rules:</span> +5 for check-in, +3 for early cancel, -10 for no-show. Score below 70% = reservation ban for 1 week.
              </p>
            </div>
          </div>

          {/* Dark Mode Settings */}
          <div className="bg-white rounded-2xl p-3 shadow-sm border border-gray-200">
            <h3 className="font-bold text-gray-900 text-xs mb-2 flex items-center space-x-1.5">
              <Moon className="w-3.5 h-3.5 text-indigo-600" />
              <span>Dark Mode</span>
            </h3>
            <div className="grid grid-cols-3 gap-1.5">
              <button
                onClick={() => setDarkMode('auto')}
                className={`flex flex-col items-center justify-center px-2 py-2.5 rounded-lg border-2 transition-colors ${
                  darkMode === 'auto'
                    ? 'border-indigo-600 bg-indigo-50 text-indigo-600'
                    : 'border-gray-200 text-gray-600'
                }`}
              >
                <Monitor className="w-4 h-4 mb-0.5" />
                <span className="text-[9px] font-semibold">Auto</span>
              </button>
              <button
                onClick={() => setDarkMode('on')}
                className={`flex flex-col items-center justify-center px-2 py-2.5 rounded-lg border-2 transition-colors ${
                  darkMode === 'on'
                    ? 'border-indigo-600 bg-indigo-50 text-indigo-600'
                    : 'border-gray-200 text-gray-600'
                }`}
              >
                <Moon className="w-4 h-4 mb-0.5" />
                <span className="text-[9px] font-semibold">On</span>
              </button>
              <button
                onClick={() => setDarkMode('off')}
                className={`flex flex-col items-center justify-center px-2 py-2.5 rounded-lg border-2 transition-colors ${
                  darkMode === 'off'
                    ? 'border-indigo-600 bg-indigo-50 text-indigo-600'
                    : 'border-gray-200 text-gray-600'
                }`}
              >
                <Sun className="w-4 h-4 mb-0.5" />
                <span className="text-[9px] font-semibold">Off</span>
              </button>
            </div>
            <p className="text-[9px] text-gray-500 mt-2">Auto adjusts based on system preference</p>
          </div>

          {/* Security Settings */}
          <div className="bg-white rounded-2xl p-3 shadow-sm border border-gray-200">
            <h3 className="font-bold text-gray-900 text-xs mb-2 flex items-center space-x-1.5">
              <Lock className="w-3.5 h-3.5 text-red-600" />
              <span>Security</span>
            </h3>
            <button
              onClick={() => setShowPasswordModal(true)}
              className="w-full flex items-center justify-between p-2.5 bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <div className="flex items-center space-x-2">
                <Lock className="w-3.5 h-3.5 text-gray-600" />
                <span className="text-[10px] font-semibold text-gray-900">Change Password</span>
              </div>
              <span className="text-gray-400">›</span>
            </button>
          </div>

          {/* Account Info */}
          <div className="bg-white rounded-2xl p-3 shadow-sm border border-gray-200">
            <h3 className="font-bold text-gray-900 text-xs mb-2">Account</h3>
            <div className="space-y-1.5">
              <div className="p-2 bg-gray-50 rounded-lg">
                <p className="text-[9px] text-gray-600 mb-0.5">Email</p>
                <p className="text-[10px] font-medium text-gray-900">{currentUser.email}</p>
              </div>
              <div className="p-2 bg-gray-50 rounded-lg">
                <p className="text-[9px] text-gray-600 mb-0.5">Major</p>
                <p className="text-[10px] font-medium text-gray-900">{currentUser.major}</p>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="space-y-2 pt-1">
            <button
              onClick={handleSave}
              className="w-full bg-purple-600 text-white py-3 rounded-xl font-bold text-sm active:scale-95 transition-transform shadow-lg"
            >
              Save Changes
            </button>

            <button
              onClick={handleLogout}
              className="w-full flex items-center justify-center space-x-2 bg-red-600 text-white py-2.5 rounded-xl font-semibold text-sm active:scale-95 transition-transform"
            >
              <LogOut className="w-4 h-4" />
              <span>Logout</span>
            </button>
          </div>
        </div>
      </div>

      {/* Password Change Modal */}
      {showPasswordModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-3xl p-4 w-full max-w-[300px] shadow-2xl">
            <div className="text-center mb-3">
              <div className="inline-flex items-center justify-center w-12 h-12 bg-red-100 rounded-full mb-2">
                <Lock className="w-6 h-6 text-red-600" />
              </div>
              <h2 className="text-base font-bold text-gray-900 mb-0.5">Change Password</h2>
              <p className="text-[10px] text-gray-600">Enter current and new password</p>
            </div>
            
            <div className="space-y-2.5 mb-3">
              {/* Current Password */}
              <div>
                <label className="block text-[10px] font-semibold text-gray-700 mb-1">Current Password</label>
                <div className="relative">
                  <input
                    type={showCurrentPassword ? 'text' : 'password'}
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    placeholder="Enter current password"
                    className="w-full px-2.5 py-2 pr-9 border-2 border-gray-200 rounded-lg text-xs font-medium focus:border-red-500 focus:outline-none"
                  />
                  <button
                    onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400"
                  >
                    {showCurrentPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                  </button>
                </div>
              </div>

              {/* New Password */}
              <div>
                <label className="block text-[10px] font-semibold text-gray-700 mb-1">New Password</label>
                <div className="relative">
                  <input
                    type={showNewPassword ? 'text' : 'password'}
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="6+ characters"
                    className="w-full px-2.5 py-2 pr-9 border-2 border-gray-200 rounded-lg text-xs font-medium focus:border-red-500 focus:outline-none"
                  />
                  <button
                    onClick={() => setShowNewPassword(!showNewPassword)}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400"
                  >
                    {showNewPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                  </button>
                </div>
              </div>

              {/* Confirm Password */}
              <div>
                <label className="block text-[10px] font-semibold text-gray-700 mb-1">Confirm Password</label>
                <div className="relative">
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="Confirm password"
                    className="w-full px-2.5 py-2 pr-9 border-2 border-gray-200 rounded-lg text-xs font-medium focus:border-red-500 focus:outline-none"
                  />
                  <button
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400"
                  >
                    {showConfirmPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                  </button>
                </div>
              </div>
            </div>

            <div className="space-y-2">
              <button
                onClick={handlePasswordChange}
                className="w-full bg-red-600 text-white py-2.5 rounded-xl font-bold text-xs active:scale-95 transition-transform shadow-lg"
              >
                Change Password
              </button>
              <button
                onClick={() => {
                  setShowPasswordModal(false);
                  setCurrentPassword('');
                  setNewPassword('');
                  setConfirmPassword('');
                }}
                className="w-full bg-gray-100 text-gray-700 py-2.5 rounded-xl font-bold text-xs active:scale-95 transition-transform"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}