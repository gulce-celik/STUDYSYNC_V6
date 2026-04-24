// Mock data for the study area management system

export interface User {
  id: string;
  name: string;
  email: string;
  universityEmail: string;
  nickname?: string; // Unique nickname for group reservations
  responsibilityScore: number;
  reservationCount: number;
  department?: string;
  year?: number;
  courses?: string[];
  major?: string;
  studyPreference?: 'Morning Person' | 'Afternoon' | 'Night Owl';
  studyStyle?: 'Silent study' | 'Discussion-based study' | 'Problem solving together';
  preferredTopics?: string[];
}

export interface ScoreHistory {
  id: string;
  date: string;
  action: string;
  scoreChange: number;
  description: string;
}

export interface WaitlistEntry {
  id: string;
  userId: string;
  workspaceId: string;
  date: string;
  slot: string;
  addedAt: string;
  notified: boolean;
}

export interface GroupInvitation {
  id: string;
  reservationId: string;
  fromUserId: string;
  toNickname: string;
  workspaceId: string;
  date: string;
  slot: string;
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
  createdAt: string;
  expiresAt: string;
}

export interface TimeSlot {
  id: string;
  label: string;
  start: string;
  end: string;
  period: 'morning' | 'class' | 'evening' | 'night';
}

export interface Workspace {
  id: string;
  type: 'individual' | 'group';
  capacity: number;
  status: 'available' | 'occupied';
  x: number;
  y: number;
}

export interface Course {
  id: string;
  code: string;
  name: string;
  department: string;
  difficultyRating: number;
  ratingCount: number;
  topics: string[];
}

export interface Reservation {
  id: string;
  userId: string;
  workspaceId: string;
  date: string;
  slot: string;
  status: 'active' | 'pending' | 'completed' | 'cancelled' | 'no-show';
  checkedIn: boolean;
  course?: string;
  isGroupReservation: boolean;
  participants?: string[];
  qrCode?: string;
}

export interface LostItem {
  id: string;
  workspaceId: string;
  description: string;
  reportedBy: string;
  reportedAt: string;
  expiresAt: string;
}

export const currentUser: User = {
  id: 'user-1',
  name: 'Ahmet Yılmaz',
  email: 'ahmet.yilmaz@example.edu.tr',
  universityEmail: 'ahmet.yilmaz@ankara.edu.tr',
  nickname: 'ahmet_y',
  responsibilityScore: 75, // demo: mid trust; app uses quotas not hard lockout
  reservationCount: 28,
  department: 'Computer Engineering',
  year: 3,
  courses: ['CSE344', 'CSE323', 'CSE331', 'CSE348', 'MATH281', 'CSE354', 'MTH302', 'TKL202'],
  major: 'Computer Science',
  studyPreference: 'Morning Person',
  studyStyle: 'Problem solving together',
  preferredTopics: ['Algorithms', 'Web Development', 'Machine Learning'],
};

// Score history for current user
export const scoreHistory: ScoreHistory[] = [
  {
    id: 'sh-1',
    date: '2026-03-10',
    action: 'successful_checkin',
    scoreChange: 5,
    description: '5 successful check-ins completed'
  },
  {
    id: 'sh-2',
    date: '2026-03-08',
    action: 'early_cancel',
    scoreChange: 3,
    description: 'Cancelled reservation 24h in advance'
  },
  {
    id: 'sh-3',
    date: '2026-03-05',
    action: 'no_show',
    scoreChange: -10,
    description: 'No-show for reservation'
  },
  {
    id: 'sh-4',
    date: '2026-03-01',
    action: 'successful_checkin',
    scoreChange: 5,
    description: '5 successful check-ins completed'
  },
  {
    id: 'sh-5',
    date: '2026-02-28',
    action: 'group_checkin',
    scoreChange: 8,
    description: 'All group members checked in on time'
  }
];

// Waitlist entries
export const mockWaitlist: WaitlistEntry[] = [
  {
    id: 'wl-1',
    userId: 'user-1',
    workspaceId: 'group-2',
    date: '2026-03-13',
    slot: '14:00 - 16:00',
    addedAt: '2026-03-12T10:30:00',
    notified: false
  }
];

// Group invitations
export const mockInvitations: GroupInvitation[] = [
  {
    id: 'inv-1',
    reservationId: 'res-4',
    fromUserId: 'user-2',
    toNickname: 'ahmet_y',
    workspaceId: 'group-3',
    date: '2026-03-14',
    slot: '16:00 - 18:00',
    status: 'pending',
    createdAt: '2026-03-12T14:00:00',
    expiresAt: '2026-03-12T14:10:00'
  }
];

// Departments (skeleton — align with Flutter RegistrationMockData + GET /reference/departments)
export const departments = [
  { id: 'cse', name: 'Computer Engineering' },
  { id: 'ie', name: 'Industrial Engineering' },
  { id: 'math', name: 'Mathematics' },
];

// Year levels
export const yearLevels = [
  { id: 1, name: '1st Year' },
  { id: 2, name: '2nd Year' },
  { id: 3, name: '3rd Year' },
  { id: 4, name: '4th Year' },
];

// Weekly Schedule Types
export type ScheduleBlockType = 'lesson' | 'club' | 'busy' | null;

export interface WeeklyScheduleBlock {
  day: 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri';
  timeSlot: string; // e.g., "09-10", "10-11"
  type: ScheduleBlockType;
  label?: string; // Course code or activity name
}

// Time slots for weekly schedule (9:00 - 20:00)
export const weeklyTimeSlots = [
  '09-10', '10-11', '11-12', '12-13', '13-14', 
  '14-15', '15-16', '16-17', '17-18', '18-19', '19-20'
];

export const weekDays: ('Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri')[] = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

// User's weekly schedule (initially from their courses)
export const userWeeklySchedule: WeeklyScheduleBlock[] = [
  { day: 'Mon', timeSlot: '09-10', type: 'lesson', label: 'CSE-344' },
  { day: 'Mon', timeSlot: '10-11', type: 'lesson', label: 'CSE-344' },
  { day: 'Tue', timeSlot: '09-10', type: 'lesson', label: 'CSE-323' },
  { day: 'Tue', timeSlot: '10-11', type: 'lesson', label: 'CSE-323' },
  { day: 'Tue', timeSlot: '11-12', type: 'lesson', label: 'CSE-331' },
  { day: 'Wed', timeSlot: '11-12', type: 'lesson', label: 'CSE-348' },
  { day: 'Wed', timeSlot: '12-13', type: 'lesson', label: 'CSE-348' },
  { day: 'Thu', timeSlot: '11-12', type: 'lesson', label: 'MATH-281' },
  { day: 'Thu', timeSlot: '13-14', type: 'lesson', label: 'CSE-354' },
  { day: 'Thu', timeSlot: '14-15', type: 'lesson', label: 'CSE-331' },
  { day: 'Thu', timeSlot: '15-16', type: 'lesson', label: 'CSE-354' },
  { day: 'Fri', timeSlot: '14-15', type: 'lesson', label: 'MTH-302' },
  { day: 'Wed', timeSlot: '16-17', type: 'lesson', label: 'TKL-202' },
  { day: 'Thu', timeSlot: '16-17', type: 'lesson', label: 'MATH-281' },
];

// Time slots
export const timeSlots: TimeSlot[] = [
  { id: 'slot-1', label: '06:00 - 09:00 (Morning)', start: '06:00', end: '09:00', period: 'morning' },
  { id: 'slot-2', label: '09:00 - 11:00 (Class Time)', start: '09:00', end: '11:00', period: 'class' },
  { id: 'slot-3', label: '11:00 - 13:00 (Class Time)', start: '11:00', end: '13:00', period: 'class' },
  { id: 'slot-4', label: '13:00 - 15:00 (Class Time)', start: '13:00', end: '15:00', period: 'class' },
  { id: 'slot-5', label: '15:00 - 17:00 (Class Time)', start: '15:00', end: '17:00', period: 'class' },
  { id: 'slot-6', label: '17:00 - 20:00 (Evening 1)', start: '17:00', end: '20:00', period: 'evening' },
  { id: 'slot-7', label: '20:00 - 23:00 (Evening 2)', start: '20:00', end: '23:00', period: 'night' },
  { id: 'slot-8', label: '23:00 - 02:00 (Night)', start: '23:00', end: '02:00', period: 'night' },
];

// Workspaces - Create a grid layout
export const workspaces: Workspace[] = [
  // Individual desks - 3 rows of 8 (24 total) - optimized for 330px width
  ...Array.from({ length: 24 }, (_, i) => ({
    id: `desk-${i + 1}`,
    type: 'individual' as const,
    capacity: 1,
    // desk-1, desk-7, desk-18 are occupied for demo
    status: (i === 0 || i === 6 || i === 17 ? 'occupied' : 'available') as const,
    x: 12 + (i % 8) * 40,
    y: 35 + Math.floor(i / 8) * 65,
  })),
  // Group rooms - 4 rooms in a row - optimized for 330px width
  { id: 'group-1', type: 'group', capacity: 4, status: 'available', x: 12, y: 265 },
  { id: 'group-2', type: 'group', capacity: 4, status: 'occupied', x: 89, y: 265 },
  { id: 'group-3', type: 'group', capacity: 6, status: 'available', x: 166, y: 265 },
  { id: 'group-4', type: 'group', capacity: 4, status: 'available', x: 243, y: 265 },
];

// Courses
export const courses: Course[] = [
  {
    id: 'cse-344',
    code: 'CSE344',
    name: 'Software Engineering',
    department: 'Computer Engineering',
    difficultyRating: 4.2,
    ratingCount: 145,
    topics: ['Requirements Analysis', 'UML Diagrams', 'Software Design', 'Agile Methodologies']
  },
  {
    id: 'cse-331',
    code: 'CSE331',
    name: 'Database Systems',
    department: 'Computer Engineering',
    difficultyRating: 3.8,
    ratingCount: 132,
    topics: ['SQL', 'Normalization', 'Transactions', 'Query Optimization']
  },
  {
    id: 'cse-312',
    code: 'CSE312',
    name: 'Operating Systems',
    department: 'Computer Engineering',
    difficultyRating: 4.5,
    ratingCount: 128,
    topics: ['Process Management', 'Memory Management', 'File Systems', 'Concurrency']
  },
  {
    id: 'cse-211',
    code: 'CSE211',
    name: 'Data Structures',
    department: 'Computer Engineering',
    difficultyRating: 3.5,
    ratingCount: 198,
    topics: ['Arrays', 'Linked Lists', 'Trees', 'Hash Tables', 'Graphs']
  },
  {
    id: 'math-301',
    code: 'MATH301',
    name: 'Linear Algebra',
    department: 'Mathematics',
    difficultyRating: 3.9,
    ratingCount: 156,
    topics: ['Matrices', 'Vector Spaces', 'Eigenvalues', 'Linear Transformations']
  },
  {
    id: 'ie-202',
    code: 'IE202',
    name: 'Operations Research',
    department: 'Industrial Engineering',
    difficultyRating: 4.0,
    ratingCount: 89,
    topics: ['Linear Programming', 'Optimization', 'Network Models', 'Queueing Theory']
  }
];

// Reservations
export const mockReservations: Reservation[] = [
  {
    id: 'res-1',
    userId: 'user-1',
    workspaceId: 'desk-5',
    date: '2026-03-10',
    slot: '10:00 - 12:00',
    status: 'active',
    checkedIn: true,
    course: 'CSE344',
    isGroupReservation: false,
    qrCode: 'RES-CSE344-20260310-1000'
  },
  {
    id: 'res-2',
    userId: 'user-1',
    workspaceId: 'desk-12',
    date: '2026-03-11',
    slot: '14:00 - 16:00',
    status: 'pending',
    checkedIn: false,
    course: 'MATH301',
    isGroupReservation: false
  },
  {
    id: 'res-3',
    userId: 'user-1',
    workspaceId: 'group-1',
    date: '2026-03-12',
    slot: '18:00 - 20:00',
    status: 'pending',
    checkedIn: false,
    course: 'CSE344',
    isGroupReservation: true,
    participants: ['user-1', 'user-2', 'user-3']
  }
];

// Upcoming reservations (for Home page)
export const upcomingReservations = mockReservations.filter(res => 
  res.status === 'pending' || res.status === 'active'
).map(res => ({
  id: res.id,
  workspaceId: res.workspaceId,
  date: res.date,
  timeSlot: res.slot,
  type: res.isGroupReservation ? 'group' : 'individual',
  course: res.course || '',
  status: res.status
}));

// Lost items
export const mockLostItems: LostItem[] = [
  {
    id: 'lost-1',
    workspaceId: 'desk-8',
    description: 'Black phone charger (USB-C)',
    reportedBy: 'user-1',
    reportedAt: '2026-03-10T14:30:00',
    expiresAt: '2026-03-11T14:30:00'
  },
  {
    id: 'lost-2',
    workspaceId: 'group-2',
    description: 'Blue notebook - Algorithms notes',
    reportedBy: 'user-2',
    reportedAt: '2026-03-10T11:00:00',
    expiresAt: '2026-03-11T11:00:00'
  }
];

// Study buddy matches
export const mockStudyBuddies = [
  {
    id: 'user-2',
    name: 'Michael Chen',
    email: 'michael.chen@university.edu',
    major: 'Computer Engineering',
    year: 3,
    courses: ['CSE344', 'CSE312'],
    studyStyle: 'Problem solving together',
    preference: 'Morning Person',
    matchScore: 95,
    commonCourses: ['CSE344'],
    commonTopics: ['Software Design', 'UML Diagrams']
  },
  {
    id: 'user-3',
    name: 'Emma Williams',
    email: 'emma.williams@university.edu',
    major: 'Computer Engineering',
    year: 3,
    courses: ['CSE344', 'CSE331', 'IE202'],
    studyStyle: 'Discussion-based study',
    preference: 'Afternoon',
    matchScore: 88,
    commonCourses: ['CSE344', 'CSE331'],
    commonTopics: ['Requirements Analysis', 'SQL']
  },
  {
    id: 'user-4',
    name: 'James Rodriguez',
    email: 'james.rodriguez@university.edu',
    major: 'Computer Engineering',
    year: 2,
    courses: ['MATH301', 'CSE211'],
    studyStyle: 'Problem solving together',
    preference: 'Night Owl',
    matchScore: 82,
    commonCourses: ['MATH301'],
    commonTopics: ['Linear Algebra', 'Matrices']
  }
];

// Admin statistics
export const adminStats = {
  totalReservationsToday: 124,
  peakHour: '18:00 - 20:00',
  noShowRate: 12,
  mostUsedWorkspace: 'Study Room B',
  totalUsers: 456,
  activeReservations: 47,
  averageResponsibilityScore: 78,
  reservationsByDay: [
    { day: 'Mon', count: 98 },
    { day: 'Tue', count: 112 },
    { day: 'Wed', count: 124 },
    { day: 'Thu', count: 135 },
    { day: 'Fri', count: 89 },
    { day: 'Sat', count: 45 },
    { day: 'Sun', count: 23 }
  ],
  slotUtilization: [
    { slot: '08-10', usage: 45 },
    { slot: '10-12', usage: 67 },
    { slot: '12-14', usage: 58 },
    { slot: '14-16', usage: 72 },
    { slot: '16-18', usage: 85 },
    { slot: '18-20', usage: 95 },
    { slot: '20-22', usage: 78 },
    { slot: '22-24', usage: 34 }
  ]
};