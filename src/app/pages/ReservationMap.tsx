import { useState } from 'react';
import { workspaces, timeSlots, courses, currentUser, mockLostItems } from '../data/mockData';
import { Calendar, Users, User, AlertCircle, CheckCircle2, ChevronDown, Info } from 'lucide-react';
import { toast } from 'sonner';

// Helper to get current day name
const getCurrentDayName = () => {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  return days[new Date().getDay()];
};

// Helper to get reservation days (Monday and Friday)
const getReservationDays = () => {
  const today = new Date();
  const dayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, ... 5 = Friday
  
  const daysAvailable: Date[] = [];
  
  // If Monday (1), can reserve for Tue, Wed, Thu, Fri
  // If Friday (5), can reserve for Sat, Sun, Mon
  if (dayOfWeek === 1) { // Monday
    for (let i = 1; i <= 4; i++) { // Start from tomorrow (i=1)
      const day = new Date(today);
      day.setDate(today.getDate() + i);
      daysAvailable.push(day);
    }
  } else if (dayOfWeek === 5) { // Friday
    for (let i = 1; i <= 3; i++) { // Start from tomorrow (i=1)
      const day = new Date(today);
      day.setDate(today.getDate() + i);
      daysAvailable.push(day);
    }
  }
  
  return daysAvailable;
};

export default function ReservationMap() {
  const [selectedDate, setSelectedDate] = useState('2026-03-10');
  const [selectedSlot, setSelectedSlot] = useState('');
  const [selectedCourse, setSelectedCourse] = useState('');
  const [selectedWorkspace, setSelectedWorkspace] = useState<string | null>(null);
  const [reservationType, setReservationType] = useState<'individual' | 'group'>('individual');
  const [allowStudyBuddy, setAllowStudyBuddy] = useState(false);
  const [filterType, setFilterType] = useState<'all' | 'individual' | 'group'>('all');
  const [showFilters, setShowFilters] = useState(false);
  const [groupNicknames, setGroupNicknames] = useState<string[]>([]);
  const [nicknameInput, setNicknameInput] = useState('');
  
  // For testing/demo purposes - allow day selection
  const [simulatedDay, setSimulatedDay] = useState<number>(new Date().getDay());
  const [showDayPicker, setShowDayPicker] = useState(false);

  const reservationDays = getReservationDays();
  const today = new Date();
  
  // Use simulated day instead of actual day
  const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const currentDayName = dayNames[simulatedDay];
  const isMonday = simulatedDay === 1;
  const isFriday = simulatedDay === 5;
  const canReserveAdvance = isMonday || isFriday;

  const filteredWorkspaces = workspaces.filter(ws => {
    if (filterType === 'all') return true;
    return ws.type === filterType;
  });

  const getWorkspaceColor = (workspace: typeof workspaces[0]) => {
    const lostItem = mockLostItems.find(item => item.workspaceId === workspace.id);
    if (lostItem) return 'fill-yellow-400 stroke-yellow-600';
    
    // Base occupied status (always red)
    if (workspace.status === 'occupied') return 'fill-red-400 stroke-red-600';
    
    // Dynamic color based on selected date and slot
    if (selectedDate && selectedSlot) {
      // Simulate occupied workspaces based on date and time slot
      // Use deterministic logic so colors don't change on every render
      const dateNum = parseInt(selectedDate.split('-')[2]); // Day of month
      const slotNum = timeSlots.findIndex(s => s.label === selectedSlot);
      const workspaceNum = parseInt(workspace.id.split('-')[1] || '0');
      
      // Deterministic "random" - specific workspaces are occupied for specific date+time combos
      const seed = (dateNum + slotNum + workspaceNum) % 5;
      const isOccupied = seed === 0 || seed === 1; // 40% chance, but consistent
      
      if (isOccupied) return 'fill-red-400 stroke-red-600';
    }
    
    return 'fill-blue-400 stroke-blue-600';
  };

  const getWorkspaceOpacity = (workspace: typeof workspaces[0]) => {
    // If Monday or Friday, all workspaces are bright (full opacity)
    if (canReserveAdvance) {
      return 'opacity-100';
    }
    
    // On other days, simulate some instant available desks (desk-2, desk-15)
    // These are cancelled/available for instant reservation
    const instantAvailableDesks = ['desk-2', 'desk-15'];
    if (instantAvailableDesks.includes(workspace.id)) {
      return 'opacity-100';
    }
    
    // Other workspaces are faded on non-reservation days
    return 'opacity-30';
  };

  const isInstantAvailable = (workspaceId: string) => {
    // Simulate instant available desks on non-reservation days
    const instantAvailableDesks = ['desk-2', 'desk-15'];
    return !canReserveAdvance && instantAvailableDesks.includes(workspaceId);
  };

  const isWorkspaceOccupied = (workspaceId: string) => {
    const ws = workspaces.find(w => w.id === workspaceId);
    if (!ws) return false;
    
    // Check if workspace is occupied (base status)
    if (ws.status === 'occupied') return true;
    
    // Check dynamic occupied status (must match getWorkspaceColor logic)
    if (selectedDate && selectedSlot) {
      const dateNum = parseInt(selectedDate.split('-')[2]);
      const slotNum = timeSlots.findIndex(s => s.label === selectedSlot);
      const workspaceNum = parseInt(workspaceId.split('-')[1] || '0');
      
      const seed = (dateNum + slotNum + workspaceNum) % 5;
      return seed === 0 || seed === 1;
    }
    
    return false;
  };

  const handleAddNickname = () => {
    const selectedWs = workspaces.find(w => w.id === selectedWorkspace);
    if (!selectedWs) return;
    
    if (!nicknameInput.trim()) {
      toast.error('Enter nickname');
      return;
    }
    
    if (groupNicknames.includes(nicknameInput.trim())) {
      toast.error('Nickname already added');
      return;
    }
    
    if (groupNicknames.length >= (selectedWs.capacity - 1)) {
      toast.error(`Max ${selectedWs.capacity - 1} members`);
      return;
    }
    
    setGroupNicknames([...groupNicknames, nicknameInput.trim()]);
    setNicknameInput('');
  };

  const handleRemoveNickname = (nickname: string) => {
    setGroupNicknames(groupNicknames.filter(n => n !== nickname));
  };

  const handleReservation = () => {
    // Check responsibility score
    if (currentUser.responsibilityScore < 70) {
      toast.error('Score too low (70%+)');
      return;
    }

    if (!selectedDate || !selectedSlot || !selectedCourse || !selectedWorkspace) {
      toast.error('Fill all fields');
      return;
    }

    // Allow instant reservations for specific desks on non-reservation days
    const isInstantReservation = isInstantAvailable(selectedWorkspace);
    
    // Check if reservation day is valid OR it's an instant reservation
    if (!canReserveAdvance && !isInstantReservation) {
      toast.error('Only Mon & Fri!');
      return;
    }

    const selectedWs = workspaces.find(w => w.id === selectedWorkspace);
    
    // Group reservation validation
    if (reservationType === 'group' && selectedWs) {
      if (groupNicknames.length !== selectedWs.capacity - 1) {
        toast.error(`Enter ${selectedWs.capacity - 1} nicknames`);
        return;
      }
      
      if (isInstantReservation) {
        toast.success('Instant reserved! ✓');
      } else {
        toast.success('Invites sent! ✓');
      }
    } else {
      if (isInstantReservation) {
        toast.success('Instant reserved! ✓');
      } else {
        toast.success('Reserved! ✓');
      }
    }

    setSelectedWorkspace(null);
    setSelectedSlot('');
    setSelectedCourse('');
    setGroupNicknames([]);
    setShowFilters(false);
  };

  const handleWorkspaceClick = (workspace: typeof workspaces[0]) => {
    const isDisabled = 
      (reservationType === 'individual' && workspace.type === 'group') ||
      (reservationType === 'group' && workspace.type === 'individual');
    
    if (isDisabled) return;
    
    // Check for lost items first
    const lostItem = mockLostItems.find(item => item.workspaceId === workspace.id);
    if (lostItem) {
      toast.error('⚠️ Lost item found here!');
      return;
    }
    
    // Check if workspace is occupied (base status or dynamic with date/time)
    const isBaseOccupied = workspace.status === 'occupied';
    const isDynamicOccupied = selectedDate && selectedSlot && getWorkspaceColor(workspace).includes('red');
    
    if (isBaseOccupied || isDynamicOccupied) {
      toast.error('🚫 This workspace is occupied!');
      return;
    }
    
    setSelectedWorkspace(workspace.id);
    
    // Auto-fill date and time for instant available desks
    if (isInstantAvailable(workspace.id)) {
      // Set to current day (Wednesday as example) and specific time slot
      const instantDate = new Date();
      const dayOfWeek = instantDate.getDay();
      
      // If it's an instant available desk, set predefined slot
      if (workspace.id === 'desk-2') {
        setSelectedSlot('09:00 - 11:00 (Class Time)');
      } else if (workspace.id === 'desk-15') {
        setSelectedSlot('13:00 - 15:00 (Class Time)');
      }
    }
  };

  return (
    <div className="h-full flex flex-col bg-white">
      {/* Page Header */}
      <div className="px-4 pt-2 pb-2 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <h1 className="text-lg font-bold text-gray-900">Reserve Space</h1>
          <div className="relative">
            <button
              onClick={() => setShowDayPicker(!showDayPicker)}
              className="bg-blue-100 px-3 py-1 rounded-lg flex items-center space-x-1 active:scale-95 transition-transform"
            >
              <span className="text-xs font-bold text-blue-700">{currentDayName}</span>
              <ChevronDown className={`w-3 h-3 text-blue-700 transition-transform ${showDayPicker ? 'rotate-180' : ''}`} />
            </button>
            
            {/* Day Picker Dropdown */}
            {showDayPicker && (
              <div className="absolute right-0 top-full mt-1 bg-white border-2 border-gray-200 rounded-xl shadow-xl z-50 w-32 overflow-hidden">
                {dayNames.map((day, index) => (
                  <button
                    key={day}
                    onClick={() => {
                      setSimulatedDay(index);
                      setShowDayPicker(false);
                      toast.success(`Day: ${day}`);
                    }}
                    className={`w-full px-3 py-2 text-left text-xs font-semibold transition-colors ${
                      simulatedDay === index
                        ? 'bg-blue-600 text-white'
                        : 'text-gray-700 hover:bg-gray-50'
                    }`}
                  >
                    {day}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Map View - No scroll, fits perfectly */}
      <div className="flex-1 overflow-y-auto pb-20">
        <div className="p-3">
          <div className="flex items-center justify-between mb-2">
            <h2 className="text-xs font-bold text-gray-900">Study Area</h2>
            <div className="flex items-center space-x-1">
              <button
                onClick={() => setFilterType('all')}
                className={`px-2 py-1 text-[9px] font-bold rounded-lg ${filterType === 'all' ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-600'}`}
              >
                All
              </button>
              <button
                onClick={() => setFilterType('individual')}
                className={`p-1 text-[9px] font-bold rounded-lg ${filterType === 'individual' ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-600'}`}
              >
                <User className="w-3 h-3" />
              </button>
              <button
                onClick={() => setFilterType('group')}
                className={`p-1 text-[9px] font-bold rounded-lg ${filterType === 'group' ? 'bg-gray-900 text-white' : 'bg-gray-100 text-gray-600'}`}
              >
                <Users className="w-3 h-3" />
              </button>
            </div>
          </div>

          {/* Legend */}
          <div className="flex items-center space-x-2 text-[9px] mb-2">
            <div className="flex items-center space-x-0.5">
              <div className="w-2 h-2 bg-blue-400 border border-blue-600 rounded"></div>
              <span className="text-gray-600">Free</span>
            </div>
            <div className="flex items-center space-x-0.5">
              <div className="w-2 h-2 bg-red-400 border border-red-600 rounded"></div>
              <span className="text-gray-600">Busy</span>
            </div>
            <div className="flex items-center space-x-0.5">
              <div className="w-2 h-2 bg-yellow-400 border border-yellow-600 rounded"></div>
              <span className="text-gray-600">Lost</span>
            </div>
          </div>

          {/* SVG Map - Fits perfectly without scroll */}
          <div className="border border-gray-200 rounded-xl overflow-hidden bg-gray-50 mb-3">
            <svg viewBox="0 0 330 400" className="w-full h-auto">
              <rect x="2" y="2" width="326" height="396" fill="white" stroke="#e5e7eb" strokeWidth="2" />
              
              <text x="165" y="20" textAnchor="middle" className="text-xs font-semibold" fill="#6b7280" fontSize="11">
                Individual Desks
              </text>
              <text x="165" y="250" textAnchor="middle" className="text-xs font-semibold" fill="#6b7280" fontSize="11">
                Group Rooms
              </text>

              {filteredWorkspaces.map((workspace) => {
                const isSelected = selectedWorkspace === workspace.id;
                const isDisabled = workspace.status === 'occupied' || 
                  (reservationType === 'individual' && workspace.type === 'group') ||
                  (reservationType === 'group' && workspace.type === 'individual');
                const opacityClass = getWorkspaceOpacity(workspace);

                if (workspace.type === 'individual') {
                  return (
                    <g key={workspace.id} className={opacityClass}>
                      <rect
                        x={workspace.x}
                        y={workspace.y}
                        width="35"
                        height="50"
                        className={`${getWorkspaceColor(workspace)} cursor-pointer transition-all ${isSelected ? 'stroke-[3]' : 'stroke-2'} ${isDisabled ? 'opacity-50' : ''}`}
                        rx="3"
                        onClick={() => !isDisabled && handleWorkspaceClick(workspace)}
                      />
                      <text
                        x={workspace.x + 17.5}
                        y={workspace.y + 30}
                        textAnchor="middle"
                        className="text-xs font-bold pointer-events-none"
                        fill="white"
                        fontSize="11"
                      >
                        {workspace.id.split('-')[1]}
                      </text>
                    </g>
                  );
                } else {
                  return (
                    <g key={workspace.id} className={opacityClass}>
                      <rect
                        x={workspace.x}
                        y={workspace.y}
                        width="70"
                        height="100"
                        className={`${getWorkspaceColor(workspace)} cursor-pointer transition-all ${isSelected ? 'stroke-[3]' : 'stroke-2'} ${isDisabled ? 'opacity-50' : ''}`}
                        rx="6"
                        onClick={() => !isDisabled && handleWorkspaceClick(workspace)}
                      />
                      <text
                        x={workspace.x + 35}
                        y={workspace.y + 48}
                        textAnchor="middle"
                        className="text-xs font-bold pointer-events-none"
                        fill="white"
                        fontSize="10"
                      >
                        {workspace.id}
                      </text>
                      <text
                        x={workspace.x + 35}
                        y={workspace.y + 64}
                        textAnchor="middle"
                        className="text-xs pointer-events-none"
                        fill="white"
                        fontSize="9"
                      >
                        Cap: {workspace.capacity}
                      </text>
                    </g>
                  );
                }
              })}
            </svg>
          </div>

          {/* Info Text - Between Map and Select Workspace */}
          <div className="px-3 py-2 bg-gradient-to-r from-blue-50 to-purple-50 border border-blue-200 rounded-lg mb-2">
            <p className="text-[10px] text-gray-700 leading-snug text-center mb-2">
              <span className="font-bold text-blue-700">Bright</span> = Available · 
              <span className="font-bold text-red-600"> Red</span> = Occupied · 
              <span className="font-bold text-yellow-600"> Yellow</span> = Lost item
            </p>
            <div className="border-t border-blue-200 pt-2">
              <p className="text-[9px] text-gray-600 leading-relaxed">
                <span className="font-bold text-blue-800">📋 How to Reserve:</span><br/>
                {canReserveAdvance ? (
                  <>
                    <span className="font-semibold">1)</span> Select <span className="font-semibold">Date</span> → 
                    <span className="font-semibold"> 2)</span> Select <span className="font-semibold">Time</span> → 
                    <span className="font-semibold"> 3)</span> Choose workspace from map<br/>
                    <span className="text-red-700 font-semibold">⚠️ Red workspace = Occupied! Alert shown</span>
                  </>
                ) : (
                  <>
                    <span className="font-semibold">⚡ Instant Booking:</span> Click <span className="font-bold text-blue-700">bright</span> workspace → 
                    Auto-filled date & time shown below → Confirm!
                  </>
                )}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Sheet - Reservation Form */}
      <div className="bg-white border-t border-gray-200 shadow-2xl">
        <button
          onClick={() => setShowFilters(!showFilters)}
          className="w-full px-4 py-3 flex items-center justify-between"
        >
          <div className="flex items-center space-x-2">
            <Calendar className="w-5 h-5 text-blue-600" />
            <span className="font-bold text-gray-900">
              {selectedWorkspace ? `${selectedWorkspace} Selected` : 'Select Workspace'}
            </span>
          </div>
          <ChevronDown className={`w-5 h-5 text-gray-400 transition-transform ${showFilters ? 'rotate-180' : ''}`} />
        </button>

        {showFilters && (
          <div className="px-4 pb-3 max-h-[60vh] overflow-y-auto">{/* Increased from 50vh to 60vh */}
            {/* Reservation Info Banner - Moved to top */}
            <div className="mb-3 p-2.5 bg-blue-50 border border-blue-200 rounded-lg">
              <div className="flex items-start space-x-2">
                <Info className="w-4 h-4 text-blue-600 flex-shrink-0 mt-0.5" />
                <div className="text-xs text-blue-800 leading-snug">
                  <p className="font-bold mb-0.5">
                    {isMonday ? '📅 Monday: Reserve Tue-Fri' : isFriday ? '📅 Friday: Reserve Sat-Mon' : `⚠️ ${currentDayName}: Instant only`}
                  </p>
                  <p>Cancel 24h early: +3 | No-show: -10</p>
                </div>
              </div>
            </div>

            {/* Instant Reservation Info - Show on other days, moved to top */}
            {!canReserveAdvance && (
              <div className="p-2.5 bg-amber-50 border border-amber-200 rounded-lg mb-3">
                <div className="flex items-start space-x-2">
                  <AlertCircle className="w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5" />
                  <div className="text-[10px] text-amber-800 leading-snug">
                    <p className="font-bold mb-1">Reservation Schedule:</p>
                    <p className="mb-0.5">• <span className="font-semibold">Monday:</span> Opens Tue-Fri</p>
                    <p className="mb-0.5">• <span className="font-semibold">Friday:</span> Opens Sat-Mon</p>
                    <p className="font-bold mt-1">📍 Instant slots if cancelled!</p>
                  </div>
                </div>
              </div>
            )}

            {/* Reservation Type */}
            <div className="mb-3">
              <label className="block text-xs font-bold text-gray-700 mb-2">Type</label>
              <div className="grid grid-cols-2 gap-2">
                <button
                  onClick={() => setReservationType('individual')}
                  className={`flex items-center justify-center space-x-2 px-4 py-2.5 rounded-lg border-2 transition-colors ${
                    reservationType === 'individual'
                      ? 'border-blue-600 bg-blue-50 text-blue-600'
                      : 'border-gray-200 text-gray-600'
                  }`}
                >
                  <User className="w-4 h-4" />
                  <span className="text-xs font-bold">Individual</span>
                </button>
                <button
                  onClick={() => setReservationType('group')}
                  className={`flex items-center justify-center space-x-2 px-4 py-2.5 rounded-lg border-2 transition-colors ${
                    reservationType === 'group'
                      ? 'border-blue-600 bg-blue-50 text-blue-600'
                      : 'border-gray-200 text-gray-600'
                  }`}
                >
                  <Users className="w-4 h-4" />
                  <span className="text-xs font-bold">Group</span>
                </button>
              </div>
            </div>

            {/* Date */}
            <div className="mb-3">
              <label className="block text-xs font-bold text-gray-700 mb-2">Date</label>
              <input
                type="date"
                value={selectedDate}
                onChange={(e) => setSelectedDate(e.target.value)}
                disabled={selectedWorkspace ? isInstantAvailable(selectedWorkspace) : false}
                min="2026-03-10"
                max="2026-03-13"
                className={`w-full px-3 py-2.5 border-2 rounded-lg text-xs font-medium ${
                  selectedWorkspace && isInstantAvailable(selectedWorkspace)
                    ? 'border-gray-300 bg-gray-100 text-gray-500 cursor-not-allowed'
                    : 'border-gray-200'
                }`}
              />
              {selectedWorkspace && isInstantAvailable(selectedWorkspace) && (
                <p className="text-[9px] text-blue-600 mt-1 font-medium">✓ Auto-filled for instant booking</p>
              )}
            </div>

            {/* Time Slot */}
            <div className="mb-3">
              <label className="block text-xs font-bold text-gray-700 mb-2">Time Slot</label>
              <div className={`border-2 rounded-lg overflow-hidden ${
                selectedWorkspace && isInstantAvailable(selectedWorkspace)
                  ? 'border-gray-300 bg-gray-100'
                  : 'border-gray-200 bg-white'
              }`}>
                <select
                  value={selectedSlot}
                  onChange={(e) => setSelectedSlot(e.target.value)}
                  disabled={selectedWorkspace ? isInstantAvailable(selectedWorkspace) : false}
                  className={`w-full px-3 py-2 text-xs font-medium focus:outline-none appearance-none ${
                    selectedWorkspace && isInstantAvailable(selectedWorkspace)
                      ? 'cursor-not-allowed text-gray-500'
                      : 'cursor-pointer'
                  }`}
                  style={{
                    backgroundImage: 'none',
                    height: 'auto',
                    maxHeight: '140px',
                    backgroundColor: selectedSlot === '' ? '#EFF6FF' : 'white',
                    color: selectedSlot === '' ? '#60A5FA' : '#374151',
                  }}
                  size={5}
                >
                  <option value="" disabled className="py-2" style={{ color: '#60A5FA', fontWeight: '500', backgroundColor: '#EFF6FF' }}>
                    Select time slot...
                  </option>
                  {timeSlots.map((slot) => (
                    <option 
                      key={slot.id} 
                      value={slot.label}
                      className="py-2 hover:bg-blue-50 cursor-pointer"
                      style={{
                        backgroundColor: selectedSlot === slot.label ? '#EFF6FF' : 'white',
                        color: selectedSlot === slot.label ? '#2563EB' : '#374151',
                        fontWeight: selectedSlot === slot.label ? '600' : '500',
                        padding: '8px 12px',
                      }}
                    >
                      {slot.label}
                    </option>
                  ))}
                </select>
              </div>
              {selectedWorkspace && isInstantAvailable(selectedWorkspace) && (
                <p className="text-[9px] text-blue-600 mt-1 font-medium">✓ This slot is available now</p>
              )}
            </div>

            {/* Course */}
            <div className="mb-3">
              <label className="block text-xs font-bold text-gray-700 mb-2">Course</label>
              <div className="border-2 border-gray-200 rounded-lg overflow-hidden bg-white">
                <select
                  value={selectedCourse}
                  onChange={(e) => setSelectedCourse(e.target.value)}
                  className="w-full px-3 py-2 text-xs font-medium focus:outline-none appearance-none cursor-pointer"
                  style={{
                    backgroundImage: 'none',
                    height: 'auto',
                    maxHeight: '140px',
                    backgroundColor: selectedCourse === '' ? '#EFF6FF' : 'white',
                    color: selectedCourse === '' ? '#60A5FA' : '#374151',
                  }}
                  size={5}
                >
                  <option value="" disabled className="py-2" style={{ color: '#60A5FA', fontWeight: '500', backgroundColor: '#EFF6FF' }}>
                    Select course...
                  </option>
                  {courses.map((course) => (
                    <option 
                      key={course.id} 
                      value={course.code}
                      className="py-2 hover:bg-blue-50 cursor-pointer"
                      style={{
                        backgroundColor: selectedCourse === course.code ? '#EFF6FF' : 'white',
                        color: selectedCourse === course.code ? '#2563EB' : '#374151',
                        fontWeight: selectedCourse === course.code ? '600' : '500',
                        padding: '8px 12px',
                      }}
                    >
                      {course.code} - {course.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Group Nicknames Input (only for group reservations) */}
            {reservationType === 'group' && selectedWorkspace && (
              <div className="mb-3 bg-purple-50 border-2 border-purple-200 rounded-lg p-3">
                <label className="block text-xs font-bold text-purple-900 mb-2">
                  Group Members 
                  {workspaces.find(w => w.id === selectedWorkspace) && (
                    <span className="ml-1 text-[10px]">
                      ({groupNicknames.length}/{workspaces.find(w => w.id === selectedWorkspace)!.capacity - 1} required)
                    </span>
                  )}
                </label>
                <div className="flex space-x-2 mb-2">
                  <input
                    type="text"
                    value={nicknameInput}
                    onChange={(e) => setNicknameInput(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && handleAddNickname()}
                    placeholder="Enter nickname..."
                    className="flex-1 px-3 py-2 border-2 border-purple-300 rounded-lg text-xs font-medium"
                  />
                  <button
                    onClick={handleAddNickname}
                    className="px-4 py-2 bg-purple-600 text-white rounded-lg font-bold text-xs active:scale-95 transition-transform"
                  >
                    Add
                  </button>
                </div>
                {groupNicknames.length > 0 && (
                  <div className="space-y-1.5">
                    {groupNicknames.map((nickname, idx) => (
                      <div key={idx} className="flex items-center justify-between bg-white px-3 py-2 rounded-lg">
                        <span className="text-xs font-semibold text-gray-900">{nickname}</span>
                        <button
                          onClick={() => handleRemoveNickname(nickname)}
                          className="text-red-600 text-[10px] font-bold"
                        >
                          Remove
                        </button>
                      </div>
                    ))}
                  </div>
                )}
                <p className="text-[9px] text-purple-700 mt-2">
                  All members must accept invite within 10 minutes
                </p>
              </div>
            )}

            {/* Study Buddy Toggle */}
            {reservationType === 'individual' && (
              <label className="flex items-center space-x-2.5 mb-3 p-2.5 bg-purple-50 rounded-lg">
                <input
                  type="checkbox"
                  checked={allowStudyBuddy}
                  onChange={(e) => setAllowStudyBuddy(e.target.checked)}
                  className="w-4 h-4 text-purple-600 rounded"
                />
                <span className="text-xs font-medium text-gray-700">Allow study buddy matching</span>
              </label>
            )}

            {/* Reserve Button - Show on Mon/Fri OR for instant available desks */}
            {(canReserveAdvance || (selectedWorkspace && isInstantAvailable(selectedWorkspace))) && (
              <button
                onClick={handleReservation}
                disabled={!selectedWorkspace || !selectedSlot || !selectedCourse || isWorkspaceOccupied(selectedWorkspace || '')}
                className="w-full bg-blue-600 text-white py-3 rounded-xl font-bold text-sm disabled:bg-gray-300 disabled:cursor-not-allowed active:scale-95 transition-transform shadow-lg"
              >
                {selectedWorkspace && isInstantAvailable(selectedWorkspace) ? '⚡ Instant Reserve' : 'Confirm Reservation'}
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
}