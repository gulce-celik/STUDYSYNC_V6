import { useNavigate } from 'react-router';
import { Calendar, Users, MapPin, Star, Package, TrendingUp, Clock, Award, QrCode, Bell, CheckCircle, XCircle } from 'lucide-react';
import { currentUser, upcomingReservations, mockInvitations } from '../data/mockData';
import { useState } from 'react';
import { toast } from 'sonner';

export default function Home() {
  const navigate = useNavigate();
  const [invitations, setInvitations] = useState(mockInvitations.filter(inv => inv.status === 'pending'));

  const handleAcceptInvitation = (invId: string) => {
    setInvitations(invitations.filter(inv => inv.id !== invId));
    toast.success('Accepted! ✓');
  };

  const handleRejectInvitation = (invId: string) => {
    setInvitations(invitations.filter(inv => inv.id !== invId));
    toast.error('Rejected');
  };

  const quickActions = [
    { icon: MapPin, label: 'Reserve', color: 'from-blue-500 to-blue-600', path: '/reserve' },
    { icon: Calendar, label: 'Bookings', color: 'from-purple-500 to-purple-600', path: '/my-reservations' },
    { icon: Users, label: 'Find Buddy', color: 'from-pink-500 to-pink-600', path: '/study-buddy' },
    { icon: Star, label: 'Rate Course', color: 'from-orange-500 to-orange-600', path: '/course-rating' },
    { icon: Package, label: 'Lost & Found', color: 'from-teal-500 to-teal-600', path: '/lost-found' },
  ];

  return (
    <div className="min-h-full bg-gradient-to-br from-gray-50 to-gray-100 pb-2">
      {/* Hero Section */}
      <div className="bg-gradient-to-br from-blue-600 via-purple-600 to-pink-600 px-4 pt-4 pb-6 rounded-b-[30px] shadow-lg">
        <div className="flex items-start justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold text-white mb-0.5">StudySync</h1>
            <p className="text-blue-100 text-xs">Welcome, {currentUser.name.split(' ')[0]}! 👋</p>
          </div>
          <div className="bg-white/20 backdrop-blur-sm px-3 py-1.5 rounded-full border border-white/30">
            <div className="flex items-center space-x-1.5">
              <Award className="w-3.5 h-3.5 text-yellow-300" />
              <span className="text-white font-bold text-xs">{currentUser.responsibilityScore}%</span>
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-3 gap-2">
          <div className="bg-white/10 backdrop-blur-sm rounded-xl p-2.5 border border-white/20">
            <div className="text-xl font-bold text-white mb-0.5">12</div>
            <div className="text-[9px] text-blue-100">Hours/Week</div>
          </div>
          <div className="bg-white/10 backdrop-blur-sm rounded-xl p-2.5 border border-white/20">
            <div className="text-xl font-bold text-white mb-0.5">8</div>
            <div className="text-[9px] text-blue-100">Sessions</div>
          </div>
          <div className="bg-white/10 backdrop-blur-sm rounded-xl p-2.5 border border-white/20">
            <div className="text-xl font-bold text-white mb-0.5">3</div>
            <div className="text-[9px] text-blue-100">Buddies</div>
          </div>
        </div>
      </div>

      <div className="px-4 py-4 space-y-4">
        {/* Study Tips - Moved to top */}
        <div className="bg-gradient-to-br from-amber-50 to-orange-50 rounded-2xl p-4 border border-orange-200">
          <div className="flex items-start space-x-3">
            <div className="w-10 h-10 bg-orange-500 rounded-xl flex items-center justify-center flex-shrink-0">
              <TrendingUp className="w-5 h-5 text-white" />
            </div>
            <div>
              <h3 className="font-bold text-gray-900 text-sm mb-1">💡 Study Tip</h3>
              <p className="text-xs text-gray-700 leading-relaxed">
                Your peak productivity is 9-11 AM. Reserve morning slots for better focus!
              </p>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div>
          <h2 className="text-lg font-bold text-gray-900 mb-3">Quick Actions</h2>
          <div className="grid grid-cols-3 gap-3">
            {quickActions.map((action, idx) => (
              <button
                key={idx}
                onClick={() => navigate(action.path)}
                className="aspect-square bg-white rounded-2xl shadow-sm active:scale-95 transition-transform flex flex-col items-center justify-center p-3 border border-gray-100"
              >
                <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${action.color} flex items-center justify-center mb-2 shadow-md`}>
                  <action.icon className="w-6 h-6 text-white" />
                </div>
                <span className="text-xs font-semibold text-gray-700 text-center leading-tight">{action.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Upcoming Sessions */}
        {upcomingReservations.length > 0 && (
          <div>
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-lg font-bold text-gray-900">Upcoming</h2>
              <button 
                onClick={() => navigate('/my-reservations')}
                className="text-xs font-semibold text-blue-600"
              >
                View All →
              </button>
            </div>

            {/* Check-in Warning */}
            <div className="mb-3 bg-amber-50 border-2 border-amber-200 rounded-xl p-3">
              <div className="flex items-start space-x-2">
                <QrCode className="w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5" />
                <div>
                  <h3 className="font-bold text-amber-900 text-xs mb-0.5">Check-In Required</h3>
                  <p className="text-[10px] text-amber-800">
                    Use QR Check In within 15 minutes of your session start time. Late check-ins result in automatic cancellation and score penalty.
                  </p>
                </div>
              </div>
            </div>

            <div className="space-y-3">
              {upcomingReservations.slice(0, 2).map((reservation) => (
                <div key={reservation.id} className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="font-bold text-gray-900 mb-1">{reservation.workspaceId}</h3>
                      <div className="flex items-center space-x-2 text-xs text-gray-600">
                        <Clock className="w-3.5 h-3.5" />
                        <span>{reservation.timeSlot}</span>
                      </div>
                    </div>
                    <div className={`px-3 py-1.5 rounded-full text-xs font-bold ${
                      reservation.type === 'individual' 
                        ? 'bg-blue-100 text-blue-700' 
                        : 'bg-purple-100 text-purple-700'
                    }`}>
                      {reservation.type === 'individual' ? '👤 Solo' : '👥 Group'}
                    </div>
                  </div>
                  <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                    <span className="text-xs text-gray-500">{reservation.date}</span>
                    <button className="flex items-center space-x-1 text-xs font-semibold text-blue-600">
                      <QrCode className="w-3.5 h-3.5" />
                      <span>QR Check In →</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Group Invitations */}
        {invitations.length > 0 && (
          <div>
            <div className="flex items-center space-x-2 mb-3">
              <Bell className="w-5 h-5 text-purple-600" />
              <h2 className="text-lg font-bold text-gray-900">Group Invitations</h2>
              <span className="bg-purple-600 text-white text-xs font-bold px-2 py-0.5 rounded-full">{invitations.length}</span>
            </div>
            <div className="space-y-2.5">
              {invitations.map((invitation) => (
                <div key={invitation.id} className="bg-gradient-to-r from-purple-50 to-pink-50 rounded-2xl p-3 border-2 border-purple-200">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1">
                      <p className="text-xs text-purple-700 font-semibold mb-0.5">Group Study Invitation</p>
                      <h3 className="font-bold text-gray-900 text-sm mb-1">{invitation.workspaceId}</h3>
                      <div className="flex items-center space-x-3 text-xs text-gray-600">
                        <div className="flex items-center space-x-1">
                          <Calendar className="w-3 h-3" />
                          <span>{invitation.date}</span>
                        </div>
                        <div className="flex items-center space-x-1">
                          <Clock className="w-3 h-3" />
                          <span>{invitation.slot}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="bg-purple-100 rounded-lg p-2 mb-2">
                    <p className="text-[10px] text-purple-800">
                      <span className="font-bold">Expires in:</span> {Math.floor((new Date(invitation.expiresAt).getTime() - new Date(invitation.createdAt).getTime()) / 60000)} minutes
                    </p>
                  </div>
                  <div className="flex space-x-2">
                    <button
                      onClick={() => handleAcceptInvitation(invitation.id)}
                      className="flex-1 flex items-center justify-center space-x-1 bg-green-600 text-white py-2 rounded-lg font-bold text-xs active:scale-95 transition-transform"
                    >
                      <CheckCircle className="w-3.5 h-3.5" />
                      <span>Accept</span>
                    </button>
                    <button
                      onClick={() => handleRejectInvitation(invitation.id)}
                      className="flex-1 flex items-center justify-center space-x-1 bg-red-600 text-white py-2 rounded-lg font-bold text-xs active:scale-95 transition-transform"
                    >
                      <XCircle className="w-3.5 h-3.5" />
                      <span>Reject</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}