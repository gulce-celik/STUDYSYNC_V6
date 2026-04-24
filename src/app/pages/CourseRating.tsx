import { useState } from 'react';
import { courses } from '../data/mockData';
import { Star, TrendingUp, BookOpen, Search } from 'lucide-react';
import { toast } from 'sonner';

export default function CourseRating() {
  const [searchTerm, setSearchTerm] = useState('');
  const [ratingCourse, setRatingCourse] = useState<string | null>(null);
  const [userRating, setUserRating] = useState(0);
  const [userComment, setUserComment] = useState('');

  const filteredCourses = courses.filter(course => {
    const matchesSearch = course.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         course.code.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesSearch;
  });

  const handleSubmitRating = (courseId: string, courseName: string) => {
    if (userRating === 0) {
      toast.error('Select a rating');
      return;
    }
    toast.success(`Rated ${userRating}/5 ⭐`);
    setRatingCourse(null);
    setUserRating(0);
    setUserComment('');
  };

  const renderStars = (rating: number, interactive = false) => {
    return (
      <div className="flex items-center space-x-1">
        {[1, 2, 3, 4, 5].map((star) => {
          const filled = interactive 
            ? star <= userRating
            : star <= Math.round(rating);
          
          return (
            <Star
              key={star}
              className={`w-5 h-5 ${
                interactive ? 'cursor-pointer' : ''
              } ${
                filled ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'
              }`}
              onClick={() => interactive && setUserRating(star)}
            />
          );
        })}
      </div>
    );
  };

  const getDifficultyLabel = (rating: number) => {
    if (rating >= 4.5) return { label: 'Very Hard', color: 'text-red-600 bg-red-100' };
    if (rating >= 4.0) return { label: 'Hard', color: 'text-orange-600 bg-orange-100' };
    if (rating >= 3.5) return { label: 'Moderate', color: 'text-yellow-600 bg-yellow-100' };
    if (rating >= 3.0) return { label: 'Easy', color: 'text-green-600 bg-green-100' };
    return { label: 'Very Easy', color: 'text-blue-600 bg-blue-100' };
  };

  return (
    <div className="h-full bg-white flex flex-col">
      {/* Header */}
      <div className="px-4 pt-2 pb-2 border-b border-gray-200">
        <h1 className="text-lg font-bold text-gray-900">Rate Courses</h1>
        <p className="text-xs text-gray-600">Help others choose wisely</p>
      </div>

      <div className="flex-1 overflow-y-auto pb-20">
        <div className="p-4">
          {/* Search */}
          <div className="mb-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search courses..."
                className="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-xl text-sm font-medium"
              />
            </div>
          </div>

          {/* Course List */}
          <div className="space-y-3">
            {filteredCourses.map((course) => {
              const difficulty = getDifficultyLabel(course.difficultyRating);
              const isRating = ratingCourse === course.id;

              return (
                <div key={course.id} className="bg-white rounded-2xl p-4 shadow-sm">
                  <div className="mb-3">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <h3 className="font-bold text-gray-900">{course.name}</h3>
                        <p className="text-xs text-gray-600">{course.code} • {course.department}</p>
                      </div>
                    </div>

                    <div className="flex items-center space-x-3 mb-2">
                      {renderStars(course.difficultyRating)}
                      <span className="text-sm font-bold text-gray-900">
                        {course.difficultyRating.toFixed(1)}
                      </span>
                      <span className="text-xs text-gray-600">
                        ({course.ratingCount})
                      </span>
                    </div>

                    <span className={`inline-block px-3 py-1 rounded-full text-xs font-bold ${difficulty.color}`}>
                      {difficulty.label}
                    </span>
                  </div>

                  {/* Topics */}
                  <div className="mb-3">
                    <div className="flex items-center space-x-1 mb-2">
                      <BookOpen className="w-3 h-3 text-gray-400" />
                      <span className="text-xs font-semibold text-gray-700">Topics</span>
                    </div>
                    <div className="flex flex-wrap gap-1">
                      {course.topics.slice(0, 3).map((topic) => (
                        <span
                          key={topic}
                          className="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded-full"
                        >
                          {topic}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* AI Recommendation */}
                  <div className="flex items-start space-x-2 p-3 bg-blue-50 border border-blue-200 rounded-xl mb-3">
                    <TrendingUp className="w-4 h-4 text-blue-600 mt-0.5 flex-shrink-0" />
                    <p className="text-xs text-blue-800">
                      <span className="font-bold">AI:</span> Study {Math.ceil(course.difficultyRating * 2)}h/week
                    </p>
                  </div>

                  {/* Rate Button / Rating Interface */}
                  {!isRating ? (
                    <button
                      onClick={() => setRatingCourse(course.id)}
                      className="w-full px-4 py-2.5 bg-yellow-500 text-white rounded-xl font-bold text-sm active:scale-95 transition-transform"
                    >
                      Rate This Course
                    </button>
                  ) : (
                    <div className="bg-gray-50 p-3 rounded-xl">
                      <p className="text-sm font-bold text-gray-900 mb-3 text-center">
                        Rate difficulty (1-5 stars)
                      </p>
                      <div className="flex justify-center mb-3">
                        {renderStars(userRating, true)}
                      </div>
                      <div className="grid grid-cols-2 gap-2">
                        <button
                          onClick={() => handleSubmitRating(course.id, course.name)}
                          className="px-4 py-2 bg-green-600 text-white rounded-xl font-bold text-sm active:scale-95 transition-transform"
                        >
                          Submit
                        </button>
                        <button
                          onClick={() => {
                            setRatingCourse(null);
                            setUserRating(0);
                          }}
                          className="px-4 py-2 border-2 border-gray-200 text-gray-700 rounded-xl font-semibold text-sm active:scale-95 transition-transform"
                        >
                          Cancel
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {filteredCourses.length === 0 && (
            <div className="bg-white rounded-2xl p-8 shadow-sm text-center">
              <BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-2" />
              <p className="text-gray-500 text-sm">No courses found</p>
            </div>
          )}

          {/* Info */}
          <div className="mt-6 bg-gradient-to-r from-yellow-50 to-orange-50 rounded-2xl p-4 border border-yellow-200">
            <h3 className="font-bold text-yellow-900 mb-2 text-sm">About Ratings</h3>
            <ul className="space-y-1.5 text-xs text-yellow-800">
              <li className="flex items-start space-x-2">
                <span className="text-yellow-600 mt-0.5">•</span>
                <span>Ratings help AI recommend study time</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-yellow-600 mt-0.5">•</span>
                <span>Rate based on workload & complexity</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-yellow-600 mt-0.5">•</span>
                <span>Submit at end of semester</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}