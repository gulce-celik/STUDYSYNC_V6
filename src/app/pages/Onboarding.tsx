import { useState } from 'react';
import { useNavigate } from 'react-router';
import { departments, yearLevels, courses } from '../data/mockData';
import { GraduationCap, BookOpen, CheckCircle2, ChevronDown } from 'lucide-react';
import { toast } from 'sonner';

export default function Onboarding() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [selectedDepartment, setSelectedDepartment] = useState('');
  const [selectedYear, setSelectedYear] = useState<number | null>(null);
  const [selectedCourses, setSelectedCourses] = useState<string[]>([]);
  const [showDepartmentDropdown, setShowDepartmentDropdown] = useState(false);
  const [showCoursesDropdown, setShowCoursesDropdown] = useState(false);

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
    
    localStorage.setItem('onboardingComplete', 'true');
    localStorage.setItem('userDepartment', selectedDepartment);
    localStorage.setItem('userYear', selectedYear.toString());
    localStorage.setItem('userCourses', JSON.stringify(selectedCourses));
    
    toast.success('Setup complete! ✓');
    navigate('/home');
  };

  const getDepartmentName = () => {
    const dept = departments.find(d => d.id === selectedDepartment);
    return dept?.name || 'Select Department';
  };

  return (
    <div className="h-full bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 flex flex-col">
      {/* Header */}
      <div className="px-4 pt-8 pb-4">
        <h1 className="text-xl font-bold text-white mb-1">Welcome! 👋</h1>
        <p className="text-blue-100 text-xs">Let's set up your profile</p>
        
        {/* Progress */}
        <div className="flex items-center space-x-2 mt-3">
          <div className={`h-1 flex-1 rounded-full ${step >= 1 ? 'bg-white' : 'bg-white/30'}`}></div>
          <div className={`h-1 flex-1 rounded-full ${step >= 2 ? 'bg-white' : 'bg-white/30'}`}></div>
          <div className={`h-1 flex-1 rounded-full ${step >= 3 ? 'bg-white' : 'bg-white/30'}`}></div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 bg-white rounded-t-[30px] overflow-hidden flex flex-col">
        <div className="flex-1 overflow-y-auto p-4">
          
          {/* Step 1: Department */}
          {step === 1 && (
            <div className="space-y-4">
              <div className="flex items-center space-x-2 mb-3">
                <div className="w-9 h-9 bg-blue-100 rounded-full flex items-center justify-center">
                  <GraduationCap className="w-4 h-4 text-blue-600" />
                </div>
                <div>
                  <h2 className="font-bold text-gray-900 text-sm">Select Your Department</h2>
                  <p className="text-[10px] text-gray-600">Which program are you enrolled in?</p>
                </div>
              </div>

              {/* Department Dropdown */}
              <div className="relative">
                <button
                  onClick={() => setShowDepartmentDropdown(!showDepartmentDropdown)}
                  className="w-full p-4 rounded-xl border-2 border-gray-200 bg-white text-left flex items-center justify-between hover:border-blue-400 transition-colors"
                >
                  <span className={`text-sm font-semibold ${selectedDepartment ? 'text-gray-900' : 'text-gray-400'}`}>
                    {getDepartmentName()}
                  </span>
                  <ChevronDown className={`w-5 h-5 text-gray-400 transition-transform ${showDepartmentDropdown ? 'rotate-180' : ''}`} />
                </button>

                {showDepartmentDropdown && (
                  <div className="absolute top-full left-0 right-0 mt-1 bg-white rounded-xl border-2 border-gray-200 shadow-lg z-10 max-h-60 overflow-y-auto">
                    {departments.map((dept) => (
                      <button
                        key={dept.id}
                        onClick={() => {
                          setSelectedDepartment(dept.id);
                          setShowDepartmentDropdown(false);
                        }}
                        className={`w-full p-3 text-left hover:bg-blue-50 transition-colors border-b border-gray-100 last:border-b-0 ${
                          selectedDepartment === dept.id ? 'bg-blue-50' : ''
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <span className="font-semibold text-gray-900 text-sm">{dept.name}</span>
                          {selectedDepartment === dept.id && (
                            <CheckCircle2 className="w-4 h-4 text-blue-600" />
                          )}
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>

              <button
                onClick={() => setStep(2)}
                disabled={!selectedDepartment}
                className="w-full bg-blue-600 text-white py-3.5 rounded-xl font-bold text-sm disabled:bg-gray-300 disabled:cursor-not-allowed active:scale-95 transition-transform shadow-lg mt-4"
              >
                Continue
              </button>
            </div>
          )}

          {/* Step 2: Year */}
          {step === 2 && (
            <div className="space-y-4">
              <div className="flex items-center space-x-2 mb-3">
                <div className="w-9 h-9 bg-purple-100 rounded-full flex items-center justify-center">
                  <GraduationCap className="w-4 h-4 text-purple-600" />
                </div>
                <div>
                  <h2 className="font-bold text-gray-900 text-sm">Select Your Year</h2>
                  <p className="text-[10px] text-gray-600">Which year are you currently in?</p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2">
                {yearLevels.map((year) => (
                  <button
                    key={year.id}
                    onClick={() => setSelectedYear(year.id)}
                    className={`p-5 rounded-xl border-2 transition-all ${
                      selectedYear === year.id
                        ? 'border-purple-600 bg-purple-50'
                        : 'border-gray-200 bg-white'
                    }`}
                  >
                    <div className="text-center">
                      <div className={`text-2xl font-bold mb-0.5 ${
                        selectedYear === year.id ? 'text-purple-600' : 'text-gray-900'
                      }`}>
                        {year.id}
                      </div>
                      <div className="text-[10px] text-gray-600">{year.name}</div>
                    </div>
                  </button>
                ))}
              </div>

              <div className="flex space-x-2 mt-4">
                <button
                  onClick={() => setStep(1)}
                  className="flex-1 bg-gray-100 text-gray-900 py-3.5 rounded-xl font-bold text-sm active:scale-95 transition-transform"
                >
                  Back
                </button>
                <button
                  onClick={() => setStep(3)}
                  disabled={!selectedYear}
                  className="flex-1 bg-purple-600 text-white py-3.5 rounded-xl font-bold text-sm disabled:bg-gray-300 disabled:cursor-not-allowed active:scale-95 transition-transform shadow-lg"
                >
                  Continue
                </button>
              </div>
            </div>
          )}

          {/* Step 3: Courses */}
          {step === 3 && (
            <div className="space-y-4">
              <div className="flex items-center space-x-2 mb-3">
                <div className="w-9 h-9 bg-pink-100 rounded-full flex items-center justify-center">
                  <BookOpen className="w-4 h-4 text-pink-600" />
                </div>
                <div>
                  <h2 className="font-bold text-gray-900 text-sm">Select Your Courses</h2>
                  <p className="text-[10px] text-gray-600">Choose courses you're taking this semester</p>
                </div>
              </div>

              <div className="bg-blue-50 border border-blue-200 rounded-xl p-2.5">
                <p className="text-xs text-blue-800">
                  <span className="font-bold">{selectedCourses.length}</span> course{selectedCourses.length !== 1 ? 's' : ''} selected
                </p>
              </div>

              {/* Courses Dropdown */}
              <div className="relative">
                <button
                  onClick={() => setShowCoursesDropdown(!showCoursesDropdown)}
                  className="w-full p-4 rounded-xl border-2 border-gray-200 bg-white text-left flex items-center justify-between hover:border-pink-400 transition-colors"
                >
                  <span className="text-sm font-semibold text-gray-900">
                    Select Courses
                  </span>
                  <ChevronDown className={`w-5 h-5 text-gray-400 transition-transform ${showCoursesDropdown ? 'rotate-180' : ''}`} />
                </button>

                {showCoursesDropdown && (
                  <div className="absolute top-full left-0 right-0 mt-1 bg-white rounded-xl border-2 border-gray-200 shadow-lg z-10 max-h-72 overflow-y-auto">
                    {courses.map((course) => (
                      <button
                        key={course.id}
                        onClick={() => handleCourseToggle(course.code)}
                        className={`w-full p-3 text-left hover:bg-pink-50 transition-colors border-b border-gray-100 last:border-b-0 ${
                          selectedCourses.includes(course.code) ? 'bg-pink-50' : ''
                        }`}
                      >
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="font-bold text-gray-900 text-xs mb-0.5">{course.code}</div>
                            <div className="text-[10px] text-gray-600">{course.name}</div>
                          </div>
                          {selectedCourses.includes(course.code) && (
                            <CheckCircle2 className="w-4 h-4 text-pink-600 flex-shrink-0 ml-2" />
                          )}
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {/* Selected Courses Display */}
              {selectedCourses.length > 0 && (
                <div className="flex flex-wrap gap-1.5">
                  {selectedCourses.map((code) => {
                    const course = courses.find(c => c.code === code);
                    return (
                      <div key={code} className="bg-pink-100 text-pink-700 px-2 py-1 rounded-lg text-[10px] font-semibold">
                        {course?.code}
                      </div>
                    );
                  })}
                </div>
              )}

              <div className="flex space-x-2 mt-4">
                <button
                  onClick={() => setStep(2)}
                  className="flex-1 bg-gray-100 text-gray-900 py-3.5 rounded-xl font-bold text-sm active:scale-95 transition-transform"
                >
                  Back
                </button>
                <button
                  onClick={handleComplete}
                  disabled={selectedCourses.length === 0}
                  className="flex-1 bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 text-white py-3.5 rounded-xl font-bold text-sm disabled:opacity-50 disabled:cursor-not-allowed active:scale-95 transition-transform shadow-lg"
                >
                  Complete
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}