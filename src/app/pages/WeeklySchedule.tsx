import { useState } from 'react';
import { useNavigate } from 'react-router';
import { userWeeklySchedule, weeklyTimeSlots, weekDays, ScheduleBlockType } from '../data/mockData';
import { Calendar, BookOpen, Users as ClubIcon, Clock, Info, ArrowLeft } from 'lucide-react';
import { toast } from 'sonner';

export default function WeeklySchedule() {
  const navigate = useNavigate();
  const [schedule, setSchedule] = useState(userWeeklySchedule);
  const [showModal, setShowModal] = useState(false);
  const [selectedSlot, setSelectedSlot] = useState<{ day: string; time: string } | null>(null);
  const [selectedCourse, setSelectedCourse] = useState<string | null>(null);
  const [courses, setCourses] = useState([
    { code: 'CS101', name: 'Introduction to Computer Science' },
    { code: 'MATH101', name: 'Calculus I' },
    { code: 'PHYS101', name: 'Physics I' },
  ]);

  const getBlockColor = (type: ScheduleBlockType) => {
    if (type === 'lesson') return 'bg-red-500 border-red-600';
    if (type === 'club') return 'bg-purple-500 border-purple-600';
    if (type === 'busy') return 'bg-yellow-500 border-yellow-600';
    return 'bg-gray-100 border-gray-200';
  };

  const getBlockForSlot = (day: string, timeSlot: string) => {
    return schedule.find(block => block.day === day && block.timeSlot === timeSlot);
  };

  const handleSlotClick = (day: string, time: string) => {
    setSelectedSlot({ day, time });
    setShowModal(true);
  };

  const handleTypeSelect = (type: ScheduleBlockType) => {
    if (!selectedSlot) return;

    const existingBlock = schedule.find(
      block => block.day === selectedSlot.day && block.timeSlot === selectedSlot.time
    );

    if (existingBlock) {
      // Clicking same block = clear it
      setSchedule(
        schedule.filter(
          block => !(block.day === selectedSlot.day && block.timeSlot === selectedSlot.time)
        )
      );
      toast.success('Cleared! ✓');
    } else {
      // Add new block
      const newBlock: ScheduleBlock = {
        id: Math.random().toString(36).substr(2, 9),
        day: selectedSlot.day,
        timeSlot: selectedSlot.time,
        type,
        courseName: type === 'lesson' && selectedCourse ? courses.find(c => c.code === selectedCourse)?.name || '' : undefined,
        courseCode: type === 'lesson' ? selectedCourse : undefined,
      };

      setSchedule([...schedule, newBlock]);

      const typeLabel = type === 'lesson' ? 'Lesson' : type === 'club' ? 'Club' : 'Busy';
      toast.success(`Marked as ${typeLabel}`);
    }

    setShowModal(false);
    setSelectedSlot(null);
    setSelectedCourse(null);
  };

  return (
    <div className="h-full bg-white flex flex-col">
      {/* Header */}
      <div className="px-4 pt-2 pb-2 border-b border-gray-200">
        <div className="flex items-center space-x-2 mb-1">
          <button
            onClick={() => navigate(-1)}
            className="p-1.5 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-gray-700" />
          </button>
          <div className="flex-1">
            <h1 className="text-lg font-bold text-gray-900">Weekly Schedule</h1>
          </div>
        </div>
        <p className="text-xs text-gray-600 ml-9">Mark your busy hours</p>
      </div>

      {/* Legend */}
      <div className="px-4 py-2 bg-blue-50 border-b border-blue-100">
        <div className="flex items-center justify-between text-[9px]">
          <div className="flex items-center space-x-1">
            <div className="w-3 h-3 bg-red-500 border border-red-600 rounded"></div>
            <span className="text-gray-700">Lesson</span>
          </div>
          <div className="flex items-center space-x-1">
            <div className="w-3 h-3 bg-purple-500 border border-purple-600 rounded"></div>
            <span className="text-gray-700">Club</span>
          </div>
          <div className="flex items-center space-x-1">
            <div className="w-3 h-3 bg-yellow-500 border border-yellow-600 rounded"></div>
            <span className="text-gray-700">Busy</span>
          </div>
          <div className="flex items-center space-x-1">
            <div className="w-3 h-3 bg-gray-100 border border-gray-200 rounded"></div>
            <span className="text-gray-700">Free</span>
          </div>
        </div>
      </div>

      {/* Info - Moved to top */}
      <div className="p-3 bg-amber-50 border-b border-amber-100">
        <div className="flex items-start space-x-2">
          <Info className="w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5" />
          <p className="text-[10px] text-amber-800">
            Tap any time slot to mark it. The app won't recommend study times during these busy hours.
          </p>
        </div>
      </div>

      {/* Schedule Grid */}
      <div className="flex-1 overflow-auto">
        <div className="p-2">
          <div className="overflow-x-auto">
            <table className="w-full border-collapse">
              <thead>
                <tr>
                  <th className="sticky left-0 bg-white border border-gray-200 p-1 text-[9px] font-bold text-gray-900 w-12">
                    Time
                  </th>
                  {weekDays.map(day => (
                    <th key={day} className="border border-gray-200 p-1 text-[9px] font-bold text-gray-900 min-w-[55px]">
                      {day}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {weeklyTimeSlots.map(time => (
                  <tr key={time}>
                    <td className="sticky left-0 bg-white border border-gray-200 p-1 text-[8px] text-gray-600 text-center font-medium">
                      {time}
                    </td>
                    {weekDays.map(day => {
                      const block = getBlockForSlot(day, time);
                      return (
                        <td
                          key={`${day}-${time}`}
                          className="border border-gray-200 p-0 h-12"
                        >
                          <button
                            onClick={() => handleSlotClick(day, time)}
                            className={`w-full h-full ${getBlockColor(block?.type || null)} border-2 transition-all active:scale-95 flex items-center justify-center`}
                          >
                            {block?.label && (
                              <span className="text-[7px] text-white font-bold truncate px-1">
                                {block.label}
                              </span>
                            )}
                          </button>
                        </td>
                      );
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Modal */}
      {showModal && selectedSlot && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-[280px]">
            <div className="p-4 border-b border-gray-200">
              <h3 className="font-bold text-gray-900">
                {selectedSlot.day} {selectedSlot.time}
              </h3>
              <p className="text-xs text-gray-600">Select block type</p>
            </div>
            
            <div className="p-3 space-y-2">
              <button
                onClick={() => handleTypeSelect('lesson')}
                className="w-full flex items-center space-x-3 p-3 rounded-xl bg-red-50 border-2 border-red-200 active:scale-95 transition-transform"
              >
                <div className="w-8 h-8 bg-red-500 rounded-lg flex items-center justify-center">
                  <BookOpen className="w-4 h-4 text-white" />
                </div>
                <div className="flex-1 text-left">
                  <div className="font-bold text-sm text-gray-900">Lesson</div>
                  <div className="text-[10px] text-gray-600">Class schedule</div>
                </div>
              </button>

              <button
                onClick={() => handleTypeSelect('club')}
                className="w-full flex items-center space-x-3 p-3 rounded-xl bg-purple-50 border-2 border-purple-200 active:scale-95 transition-transform"
              >
                <div className="w-8 h-8 bg-purple-500 rounded-lg flex items-center justify-center">
                  <ClubIcon className="w-4 h-4 text-white" />
                </div>
                <div className="flex-1 text-left">
                  <div className="font-bold text-sm text-gray-900">Club</div>
                  <div className="text-[10px] text-gray-600">Club activity</div>
                </div>
              </button>

              <button
                onClick={() => handleTypeSelect('busy')}
                className="w-full flex items-center space-x-3 p-3 rounded-xl bg-yellow-50 border-2 border-yellow-200 active:scale-95 transition-transform"
              >
                <div className="w-8 h-8 bg-yellow-500 rounded-lg flex items-center justify-center">
                  <Clock className="w-4 h-4 text-white" />
                </div>
                <div className="flex-1 text-left">
                  <div className="font-bold text-sm text-gray-900">Busy</div>
                  <div className="text-[10px] text-gray-600">Personal time</div>
                </div>
              </button>

              <button
                onClick={() => handleTypeSelect(null)}
                className="w-full flex items-center space-x-3 p-3 rounded-xl bg-gray-50 border-2 border-gray-200 active:scale-95 transition-transform"
              >
                <div className="w-8 h-8 bg-gray-200 rounded-lg flex items-center justify-center">
                  <Calendar className="w-4 h-4 text-gray-600" />
                </div>
                <div className="flex-1 text-left">
                  <div className="font-bold text-sm text-gray-900">Clear</div>
                  <div className="text-[10px] text-gray-600">Remove block</div>
                </div>
              </button>
            </div>

            <div className="p-3 border-t border-gray-200">
              <button
                onClick={() => {
                  setShowModal(false);
                  setSelectedSlot(null);
                }}
                className="w-full py-3 bg-gray-100 text-gray-900 rounded-xl font-bold active:scale-95 transition-transform"
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