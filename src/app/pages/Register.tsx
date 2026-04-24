import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { UserPlus, Mail, Lock, User, ArrowLeft, CheckCircle2, ChevronDown, AlertCircle } from 'lucide-react';
import { toast } from 'sonner';
import { departments, yearLevels, courses } from '../data/mockData';

export default function Register() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  
  // Disable dark mode on register page
  useEffect(() => {
    document.documentElement.classList.remove('dark');
  }, []);
  
  // Step 1: Basic Info
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailError, setEmailError] = useState('');
  
  // Step 2: Email Verification
  const [verificationCode, setVerificationCode] = useState('');
  const [sentCode, setSentCode] = useState('');
  
  // Step 3: Department
  const [selectedDepartment, setSelectedDepartment] = useState('');
  const [showDepartmentDropdown, setShowDepartmentDropdown] = useState(false);
  
  // Step 4: Year
  const [selectedYear, setSelectedYear] = useState<number | null>(null);
  
  // Step 5: Courses
  const [selectedCourses, setSelectedCourses] = useState<string[]>([]);
  const [showCoursesDropdown, setShowCoursesDropdown] = useState(false);

  const handleSendVerificationCode = () => {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@std\.yeditepe\.edu\.tr$/;
    
    if (!firstName || !lastName) {
      toast.error('Enter your name');
      return;
    }
    
    if (!emailRegex.test(email)) {
      setEmailError('Use Yeditepe email');
      return;
    }
    
    if (!password || password.length < 6) {
      toast.error('Password min 6 chars');
      return;
    }
    
    // Simulate sending verification code
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    setSentCode(code);
    toast.success('Code sent! ✓');
    console.log('🔑 VERIFICATION CODE:', code); // For demo - show in console
    setStep(2);
  };

  const handleVerifyCode = () => {
    // For demo purposes - accept any 6-digit code
    if (verificationCode.length === 6) {
      toast.success('Email verified!');
      setStep(3);
    } else {
      toast.error('Enter 6-digit code');
    }
  };

  const handleCourseToggle = (courseCode: string) => {
    if (selectedCourses.includes(courseCode)) {
      setSelectedCourses(selectedCourses.filter(c => c !== courseCode));
    } else {
      setSelectedCourses([...selectedCourses, courseCode]);
    }
  };

  const handleComplete = () => {
    if (selectedCourses.length === 0) {
      toast.error('Select a course');
      return;
    }
    
    // Generate unique nickname
    const nickname = `${firstName.toLowerCase()}_${lastName.charAt(0).toLowerCase()}${Math.floor(Math.random() * 99)}`;
    
    // Save to localStorage
    localStorage.setItem('userRegistered', 'true');
    localStorage.setItem('userName', `${firstName} ${lastName}`);
    localStorage.setItem('userEmail', email);
    localStorage.setItem('userNickname', nickname);
    localStorage.setItem('userDepartment', selectedDepartment);
    localStorage.setItem('userYear', selectedYear?.toString() || '');
    localStorage.setItem('userCourses', JSON.stringify(selectedCourses));
    
    toast.success(`Welcome ${firstName}! 🎉`);
    navigate('/home');
  };

  const getDepartmentName = () => {
    const dept = departments.find(d => d.id === selectedDepartment);
    return dept?.name || 'Select Department';
  };

  return (
    <div className="h-full bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 flex flex-col">
      {/* Header */}
      <div className="px-4 pt-8 pb-3">
        <button onClick={() => step === 1 ? navigate('/') : setStep(step - 1)} className="mb-2">
          <ArrowLeft className="w-5 h-5 text-white" />
        </button>
        <h1 className="text-xl font-bold text-white mb-1">Create Account 🎓</h1>
        <p className="text-blue-100 text-xs">Join StudySync community</p>
        
        {/* Progress */}
        <div className="flex items-center space-x-1.5 mt-3">
          {[1, 2, 3, 4, 5].map((s) => (
            <div key={s} className={`h-1 flex-1 rounded-full ${step >= s ? 'bg-white' : 'bg-white/30'}`}></div>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 bg-white rounded-t-[30px] overflow-hidden flex flex-col">
        <div className="flex-1 overflow-y-auto p-4">
          
          {/* Step 1: Basic Info */}
          {step === 1 && (
            <div className="space-y-3">
              <div className="flex items-center space-x-2 mb-2">
                <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                  <User className="w-4 h-4 text-blue-600" />
                </div>
                <div>
                  <h2 className="font-bold text-gray-900 text-sm">Basic Information</h2>
                  <p className="text-[10px] text-gray-600">Tell us about yourself</p>
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1.5">First Name</label>
                <input
                  type="text"
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  placeholder="Ahmet"
                  className="w-full px-3 py-2.5 border-2 border-gray-200 rounded-xl text-sm focus:border-blue-500 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1.5">Last Name</label>
                <input
                  type="text"
                  value={lastName}
                  onChange={(e) => setLastName(e.target.value)}
                  placeholder="Yılmaz"
                  className="w-full px-3 py-2.5 border-2 border-gray-200 rounded-xl text-sm focus:border-blue-500 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1.5">University Email</label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="name@std.yeditepe.edu.tr"
                    className="w-full pl-10 pr-3 py-2.5 border-2 border-gray-200 rounded-xl text-sm focus:border-blue-500 focus:outline-none"
                  />
                </div>
                {emailError && <p className="text-xs text-red-500 mt-1">{emailError}</p>}
              </div>

              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1.5">Password</label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full pl-10 pr-3 py-2.5 border-2 border-gray-200 rounded-xl text-sm focus:border-blue-500 focus:outline-none"
                  />
                </div>
              </div>

              <button
                onClick={handleSendVerificationCode}
                className="w-full bg-blue-600 text-white py-3 rounded-xl font-bold text-sm active:scale-95 transition-transform shadow-lg mt-2"
              >
                Send Verification Code
              </button>
            </div>
          )}

          {/* Step 2: Email Verification */}
          {step === 2 && (
            <div className="space-y-3">
              <div className="flex items-center space-x-2 mb-2">
                <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                  <Mail className="w-4 h-4 text-purple-600" />
                </div>
                <div>
                  <h2 className="font-bold text-gray-900 text-sm">Email Verification</h2>
                  <p className="text-[10px] text-gray-600">Enter the code sent to your email</p>
                </div>
              </div>

              <div className="bg-blue-50 border border-blue-200 rounded-xl p-3">
                <p className="text-xs text-blue-800 break-words">
                  We sent a 6-digit code to <span className="font-bold break-all">{email}</span>
                </p>
              </div>

              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1.5">Verification Code</label>
                <input
                  type="text"
                  value={verificationCode}
                  onChange={(e) => setVerificationCode(e.target.value)}
                  placeholder="123456"
                  maxLength={6}
                  className="w-full px-3 py-3 border-2 border-gray-200 rounded-xl text-center text-2xl font-bold tracking-widest focus:border-purple-500 focus:outline-none"
                />
              </div>

              <p className="text-xs text-center text-gray-600">
                Didn't receive? <button className="text-purple-600 font-bold">Resend code</button>
              </p>

              <button
                onClick={handleVerifyCode}
                disabled={verificationCode.length !== 6}
                className="w-full bg-purple-600 text-white py-3 rounded-xl font-bold text-sm disabled:bg-gray-300 disabled:cursor-not-allowed active:scale-95 transition-transform shadow-lg"
              >
                Verify Email
              </button>
            </div>
          )}

          {/* Step 3: Department */}
          {step === 3 && (
            <div className="space-y-3">
              <div className="flex items-center space-x-2 mb-2">
                <div className="w-8 h-8 bg-pink-100 rounded-full flex items-center justify-center">
                  <UserPlus className="w-4 h-4 text-pink-600" />
                </div>
                <div>
                  <h2 className="font-bold text-gray-900 text-sm">Select Department</h2>
                  <p className="text-[10px] text-gray-600">Which program are you in?</p>
                </div>
              </div>

              <div className="relative">
                <button
                  onClick={() => setShowDepartmentDropdown(!showDepartmentDropdown)}
                  className="w-full p-3.5 rounded-xl border-2 border-gray-200 bg-white text-left flex items-center justify-between hover:border-pink-400 transition-colors"
                >
                  <span className={`text-sm font-semibold ${selectedDepartment ? 'text-gray-900' : 'text-gray-400'}`}>
                    {getDepartmentName()}
                  </span>
                  <ChevronDown className={`w-5 h-5 text-gray-400 transition-transform ${showDepartmentDropdown ? 'rotate-180' : ''}`} />
                </button>

                {showDepartmentDropdown && (
                  <div className="absolute top-full left-0 right-0 mt-1 bg-white rounded-xl border-2 border-gray-200 shadow-lg z-10 max-h-56 overflow-y-auto">
                    {departments.map((dept) => (
                      <button
                        key={dept.id}
                        onClick={() => {
                          setSelectedDepartment(dept.id);
                          setShowDepartmentDropdown(false);
                        }}
                        className={`w-full p-3 text-left hover:bg-pink-50 transition-colors border-b border-gray-100 last:border-b-0 ${
                          selectedDepartment === dept.id ? 'bg-pink-50' : ''
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <span className="font-semibold text-gray-900 text-sm">{dept.name}</span>
                          {selectedDepartment === dept.id && (
                            <CheckCircle2 className="w-4 h-4 text-pink-600" />
                          )}
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>

              <button
                onClick={() => setStep(4)}
                disabled={!selectedDepartment}
                className="w-full bg-pink-600 text-white py-3 rounded-xl font-bold text-sm disabled:bg-gray-300 disabled:cursor-not-allowed active:scale-95 transition-transform shadow-lg mt-2"
              >
                Continue
              </button>
            </div>
          )}

          {/* Step 4: Year */}
          {step === 4 && (
            <div className="space-y-3">
              <div className="flex items-center space-x-2 mb-2">
                <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                  <UserPlus className="w-4 h-4 text-green-600" />
                </div>
                <div>
                  <h2 className="font-bold text-gray-900 text-sm">Select Your Year</h2>
                  <p className="text-[10px] text-gray-600">Which year are you in?</p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2">
                {yearLevels.map((year) => (
                  <button
                    key={year.id}
                    onClick={() => setSelectedYear(year.id)}
                    className={`p-4 rounded-xl border-2 transition-all ${
                      selectedYear === year.id
                        ? 'border-green-600 bg-green-50'
                        : 'border-gray-200 bg-white'
                    }`}
                  >
                    <div className="text-center">
                      <div className={`text-2xl font-bold mb-0.5 ${
                        selectedYear === year.id ? 'text-green-600' : 'text-gray-900'
                      }`}>
                        {year.id}
                      </div>
                      <div className="text-[10px] text-gray-600">{year.name}</div>
                    </div>
                  </button>
                ))}
              </div>

              <button
                onClick={() => setStep(5)}
                disabled={!selectedYear}
                className="w-full bg-green-600 text-white py-3 rounded-xl font-bold text-sm disabled:bg-gray-300 disabled:cursor-not-allowed active:scale-95 transition-transform shadow-lg mt-2"
              >
                Continue
              </button>
            </div>
          )}

          {/* Step 5: Courses */}
          {step === 5 && (
            <div className="space-y-3">
              <div className="flex items-center space-x-2 mb-2">
                <div className="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                  <CheckCircle2 className="w-4 h-4 text-orange-600" />
                </div>
                <div>
                  <h2 className="font-bold text-gray-900 text-sm">Select Courses</h2>
                  <p className="text-[10px] text-gray-600">Choose your courses this semester</p>
                </div>
              </div>

              <div className="bg-blue-50 border border-blue-200 rounded-xl p-2">
                <p className="text-xs text-blue-800">
                  <span className="font-bold">{selectedCourses.length}</span> course{selectedCourses.length !== 1 ? 's' : ''} selected
                </p>
              </div>

              <div className="relative">
                <button
                  onClick={() => setShowCoursesDropdown(!showCoursesDropdown)}
                  className="w-full p-3.5 rounded-xl border-2 border-gray-200 bg-white text-left flex items-center justify-between hover:border-orange-400 transition-colors"
                >
                  <span className="text-sm font-semibold text-gray-900">Select Courses</span>
                  <ChevronDown className={`w-5 h-5 text-gray-400 transition-transform ${showCoursesDropdown ? 'rotate-180' : ''}`} />
                </button>

                {showCoursesDropdown && (
                  <div className="absolute top-full left-0 right-0 mt-1 bg-white rounded-xl border-2 border-gray-200 shadow-lg z-10 max-h-60 overflow-y-auto">
                    {courses.map((course) => (
                      <button
                        key={course.id}
                        onClick={() => handleCourseToggle(course.code)}
                        className={`w-full p-2.5 text-left hover:bg-orange-50 transition-colors border-b border-gray-100 last:border-b-0 ${
                          selectedCourses.includes(course.code) ? 'bg-orange-50' : ''
                        }`}
                      >
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="font-bold text-gray-900 text-xs mb-0.5">{course.code}</div>
                            <div className="text-[10px] text-gray-600">{course.name}</div>
                          </div>
                          {selectedCourses.includes(course.code) && (
                            <CheckCircle2 className="w-4 h-4 text-orange-600 flex-shrink-0 ml-2" />
                          )}
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {selectedCourses.length > 0 && (
                <div className="flex flex-wrap gap-1.5">
                  {selectedCourses.map((code) => {
                    const course = courses.find(c => c.code === code);
                    return (
                      <div key={code} className="bg-orange-100 text-orange-700 px-2 py-1 rounded-lg text-[10px] font-semibold">
                        {course?.code}
                      </div>
                    );
                  })}
                </div>
              )}

              <button
                onClick={handleComplete}
                disabled={selectedCourses.length === 0}
                className="w-full bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 text-white py-3 rounded-xl font-bold text-sm disabled:opacity-50 disabled:cursor-not-allowed active:scale-95 transition-transform shadow-lg mt-2"
              >
                Complete Registration
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}