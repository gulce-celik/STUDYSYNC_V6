import { useState } from 'react';
import { mockStudyBuddies, courses, currentUser } from '../data/mockData';
import { Users, Mail, BookOpen, TrendingUp, MessageCircle, Heart, Search, Filter, ChevronDown, Flag, UserPlus, AlertTriangle } from 'lucide-react';
import { toast } from 'sonner';

export default function StudyBuddy() {
  const [selectedCourse, setSelectedCourse] = useState('');
  const [selectedYear, setSelectedYear] = useState('');
  const [selectedPreference, setSelectedPreference] = useState('');
  const [searchResults, setSearchResults] = useState(mockStudyBuddies);
  const [showFilters, setShowFilters] = useState(false);
  const [showMyListing, setShowMyListing] = useState(false);
  const [showReportModal, setShowReportModal] = useState(false);
  const [reportingBuddy, setReportingBuddy] = useState<{ id: string; name: string } | null>(null);
  const [reportReason, setReportReason] = useState('');
  const [myListingCourse, setMyListingCourse] = useState('');
  const [myListingNote, setMyListingNote] = useState('');

  const handleSearch = () => {
    if (!selectedCourse) {
      toast.error('Select a course');
      return;
    }

    // Filter by selected criteria
    const filtered = mockStudyBuddies.filter(buddy => {
      if (selectedCourse && !buddy.courses.includes(selectedCourse)) return false;
      if (selectedYear && buddy.year !== selectedYear) return false;
      if (selectedPreference && buddy.preference !== selectedPreference) return false;
      return true;
    });

    setSearchResults(filtered);
    setShowFilters(false);
    toast.success(`Found ${filtered.length} buddies`);
  };

  const handleConnect = (buddyId: string, buddyName: string) => {
    toast.success(`Request sent! ✓`);
  };

  const handleReport = (buddyId: string, buddyName: string) => {
    setReportingBuddy({ id: buddyId, name: buddyName });
    setShowReportModal(true);
  };

  const handleReportSubmit = () => {
    if (!reportReason) {
      toast.error('Please provide a reason for reporting');
      return;
    }

    // Simulate report submission
    toast.success(`Reported ${reportingBuddy?.name} for "${reportReason}"`);
    setShowReportModal(false);
    setReportReason('');
  };

  const handleMyListingSubmit = () => {
    if (!myListingCourse) {
      toast.error('Select a course');
      return;
    }

    // Simulate listing submission
    toast.success(`Listed for ${myListingCourse} with note: "${myListingNote}"`);
    setShowMyListing(false);
    setMyListingCourse('');
    setMyListingNote('');
  };

  return (
    <div className="h-full bg-white flex flex-col">
      {/* Header */}
      <div className="px-4 pt-2 pb-2 border-b border-gray-200">
        <h1 className="text-lg font-bold text-gray-900">Study Buddy</h1>
        <p className="text-xs text-gray-600">Find your perfect study partner</p>
      </div>

      <div className="flex-1 overflow-y-auto pb-20">
        <div className="p-4">
          {/* How It Works - Moved to top */}
          <div className="mb-4 bg-gradient-to-r from-purple-50 to-pink-50 rounded-2xl p-4 border border-purple-200">
            <h3 className="font-bold text-purple-900 mb-2 text-sm">How It Works</h3>
            <ul className="space-y-1.5 text-xs text-purple-800">
              <li className="flex items-start space-x-2">
                <span className="text-purple-600 mt-0.5">•</span>
                <span>AI matching based on courses & topics</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-purple-600 mt-0.5">•</span>
                <span>Max 4 students per study group</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-purple-600 mt-0.5">•</span>
                <span>Report inappropriate behavior via Report button</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-purple-600 mt-0.5">•</span>
                <span>5+ reports trigger review & possible action</span>
              </li>
            </ul>
            <div className="mt-3 pt-3 border-t border-purple-200">
              <div className="flex items-start space-x-2">
                <AlertTriangle className="w-3.5 h-3.5 text-red-600 flex-shrink-0 mt-0.5" />
                <p className="text-[10px] text-red-800 font-semibold">
                  False reports may result in account restrictions.
                </p>
              </div>
            </div>
          </div>

          {/* Filter Toggle */}
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="w-full mb-4 px-4 py-3 bg-white rounded-2xl shadow-sm flex items-center justify-between"
          >
            <div className="flex items-center space-x-2">
              <Filter className="w-5 h-5 text-purple-600" />
              <span className="font-semibold text-gray-900">
                {selectedCourse || 'Select Course'}
              </span>
            </div>
            <ChevronDown className={`w-5 h-5 text-gray-400 transition-transform ${showFilters ? 'rotate-180' : ''}`} />
          </button>

          {/* My Listing - Moved to top */}
          <div className="mb-4">
            <button
              onClick={() => setShowMyListing(!showMyListing)}
              className="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white py-3 rounded-2xl font-bold active:scale-95 transition-transform flex items-center justify-center space-x-2 shadow-md"
            >
              <UserPlus className="w-5 h-5" />
              <span>Create My Study Buddy Listing</span>
            </button>

            {showMyListing && (
              <div className="mt-3 p-4 bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl border-2 border-purple-200 shadow-sm">
                <h3 className="text-sm font-bold text-purple-900 mb-3">📢 Post Your Listing</h3>
                <div className="mb-3">
                  <label className="block text-xs font-semibold text-gray-700 mb-2">Course</label>
                  <select
                    value={myListingCourse}
                    onChange={(e) => setMyListingCourse(e.target.value)}
                    className="w-full px-4 py-3 border-2 border-purple-200 rounded-xl text-sm font-medium bg-white"
                  >
                    <option value="">Choose a course</option>
                    {currentUser.courses.map((courseCode) => {
                      const course = courses.find(c => c.code === courseCode);
                      return (
                        <option key={courseCode} value={courseCode}>
                          {course?.code} - {course?.name}
                        </option>
                      );
                    })}
                  </select>
                </div>

                <div className="mb-4">
                  <label className="block text-xs font-semibold text-gray-700 mb-2">Note (Optional)</label>
                  <textarea
                    value={myListingNote}
                    onChange={(e) => setMyListingNote(e.target.value)}
                    className="w-full px-4 py-3 border-2 border-purple-200 rounded-xl text-sm font-medium bg-white"
                    placeholder="e.g., Looking for study partner for midterms..."
                    rows={3}
                  />
                </div>

                <button
                  onClick={handleMyListingSubmit}
                  className="w-full bg-purple-600 text-white py-3 rounded-xl font-bold active:scale-95 transition-transform flex items-center justify-center space-x-2"
                >
                  <UserPlus className="w-5 h-5" />
                  <span>Post Listing</span>
                </button>
              </div>
            )}
          </div>

          {/* Filters */}
          {showFilters && (
            <div className="mb-4 p-4 bg-white rounded-2xl shadow-sm">
              <div className="mb-3">
                <label className="block text-sm font-semibold text-gray-700 mb-2">Course</label>
                <select
                  value={selectedCourse}
                  onChange={(e) => setSelectedCourse(e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-sm font-medium"
                >
                  <option value="">Choose a course</option>
                  {currentUser.courses.map((courseCode) => {
                    const course = courses.find(c => c.code === courseCode);
                    return (
                      <option key={courseCode} value={courseCode}>
                        {course?.code} - {course?.name}
                      </option>
                    );
                  })}
                </select>
              </div>

              <div className="mb-4">
                <label className="block text-sm font-semibold text-gray-700 mb-2">Year</label>
                <select
                  value={selectedYear}
                  onChange={(e) => setSelectedYear(e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-sm font-medium"
                >
                  <option value="">Any year</option>
                  <option value="Freshman">Freshman</option>
                  <option value="Sophomore">Sophomore</option>
                  <option value="Junior">Junior</option>
                  <option value="Senior">Senior</option>
                </select>
              </div>

              <div className="mb-4">
                <label className="block text-sm font-semibold text-gray-700 mb-2">Preference</label>
                <select
                  value={selectedPreference}
                  onChange={(e) => setSelectedPreference(e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-sm font-medium"
                >
                  <option value="">Any preference</option>
                  <option value="Silent study">Silent study</option>
                  <option value="Discussion-based study">Discussion-based</option>
                  <option value="Problem solving together">Problem solving</option>
                </select>
              </div>

              <button
                onClick={handleSearch}
                className="w-full bg-purple-600 text-white py-3 rounded-xl font-bold active:scale-95 transition-transform flex items-center justify-center space-x-2"
              >
                <Search className="w-5 h-5" />
                <span>Search Buddies</span>
              </button>

              {/* Your Preferences */}
              <div className="mt-4 p-3 bg-purple-50 border border-purple-200 rounded-xl">
                <h3 className="text-xs font-bold text-purple-900 mb-2">Your Preferences</h3>
                <div className="space-y-1 text-xs text-purple-800">
                  <p><span className="font-semibold">Style:</span> {currentUser.studyStyle}</p>
                  <p><span className="font-semibold">Topics:</span> {currentUser.preferredTopics.slice(0, 2).join(', ')}</p>
                </div>
              </div>
            </div>
          )}

          {/* Results */}
          <div className="mb-4">
            <h2 className="text-sm font-semibold text-gray-600 mb-3">
              {searchResults.length} Matches Found
            </h2>
          </div>

          {searchResults.length > 0 ? (
            <div className="space-y-3">
              {searchResults.map((buddy) => (
                <div key={buddy.id} className="bg-white rounded-2xl p-4 shadow-sm">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="font-bold text-gray-900">{buddy.name}</h3>
                      <p className="text-xs text-gray-600">{buddy.major}</p>
                    </div>
                    <div className="flex items-center space-x-1 px-2 py-1 bg-green-100 rounded-full">
                      <TrendingUp className="w-3 h-3 text-green-600" />
                      <span className="text-xs font-bold text-green-600">{buddy.matchScore}%</span>
                    </div>
                  </div>

                  {/* Common Courses */}
                  <div className="mb-3">
                    <div className="flex items-center space-x-1 mb-2">
                      <BookOpen className="w-3 h-3 text-gray-400" />
                      <span className="text-xs font-semibold text-gray-700">Common Courses</span>
                    </div>
                    <div className="flex flex-wrap gap-1">
                      {buddy.commonCourses.map((course) => (
                        <span key={course} className="px-2 py-1 bg-blue-100 text-blue-800 text-xs font-semibold rounded-full">
                          {course}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Common Topics */}
                  <div className="mb-3">
                    <div className="flex items-center space-x-1 mb-2">
                      <Heart className="w-3 h-3 text-gray-400" />
                      <span className="text-xs font-semibold text-gray-700">Common Topics</span>
                    </div>
                    <div className="flex flex-wrap gap-1">
                      {buddy.commonTopics.slice(0, 2).map((topic) => (
                        <span key={topic} className="px-2 py-1 bg-purple-100 text-purple-800 text-xs font-semibold rounded-full">
                          {topic}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="space-y-2">
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => handleConnect(buddy.id, buddy.name)}
                        className="flex items-center justify-center space-x-1 px-3 py-2.5 bg-purple-600 text-white rounded-xl font-semibold text-sm active:scale-95 transition-transform"
                      >
                        <MessageCircle className="w-4 h-4" />
                        <span>Connect</span>
                      </button>
                      <a
                        href={`mailto:${buddy.email}`}
                        className="flex items-center justify-center space-x-1 px-3 py-2.5 border-2 border-gray-200 text-gray-700 rounded-xl font-semibold text-sm active:scale-95 transition-transform"
                      >
                        <Mail className="w-4 h-4" />
                        <span>Email</span>
                      </a>
                    </div>
                    <button
                      onClick={() => handleReport(buddy.id, buddy.name)}
                      className="w-full flex items-center justify-center space-x-1 px-3 py-2.5 bg-red-50 border-2 border-red-200 text-red-700 rounded-xl font-semibold text-sm active:scale-95 transition-transform"
                    >
                      <Flag className="w-4 h-4" />
                      <span>Report User</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="bg-white rounded-2xl p-8 shadow-sm text-center">
              <Users className="w-12 h-12 text-gray-300 mx-auto mb-2" />
              <p className="text-gray-500 text-sm mb-2">No study buddies found</p>
              <p className="text-xs text-gray-400">Select a course to see matches</p>
            </div>
          )}

          {/* Report Modal */}
          {showReportModal && (
            <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-2xl p-5 shadow-2xl w-full max-w-[320px]">
                <div className="flex items-center space-x-2 mb-3">
                  <AlertTriangle className="w-5 h-5 text-red-600" />
                  <h3 className="text-sm font-bold text-gray-900">Report User</h3>
                </div>

                <p className="text-xs text-gray-600 mb-4">
                  Reporting <span className="font-semibold text-gray-900">{reportingBuddy?.name}</span>
                </p>

                <div className="mb-4">
                  <label className="block text-xs font-semibold text-gray-700 mb-2">Reason for Report</label>
                  <textarea
                    value={reportReason}
                    onChange={(e) => setReportReason(e.target.value)}
                    className="w-full px-3 py-2.5 border-2 border-gray-200 rounded-xl text-sm font-medium resize-none"
                    placeholder="Describe inappropriate behavior..."
                    rows={4}
                  />
                </div>

                <div className="mb-4 p-2.5 bg-amber-50 border border-amber-200 rounded-lg">
                  <p className="text-[10px] text-amber-800 leading-relaxed">
                    ⚠️ <span className="font-bold">Warning:</span> False reports may result in account restrictions. Only report genuine violations.
                  </p>
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <button
                    onClick={() => {
                      setShowReportModal(false);
                      setReportReason('');
                    }}
                    className="px-4 py-2.5 bg-gray-100 text-gray-700 rounded-xl font-bold text-sm active:scale-95 transition-transform"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleReportSubmit}
                    className="px-4 py-2.5 bg-red-600 text-white rounded-xl font-bold text-sm active:scale-95 transition-transform"
                  >
                    Submit Report
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}