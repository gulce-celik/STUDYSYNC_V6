import { useState } from 'react';
import { mockReservations } from '../data/mockData';
import { Calendar, Clock, MapPin, Users, QrCode, XCircle, CheckCircle, AlertCircle } from 'lucide-react';
import { QRCodeSVG } from 'qrcode.react';
import { toast } from 'sonner';

export default function MyReservations() {
  const [selectedReservation, setSelectedReservation] = useState<string | null>(null);
  const [showQRCode, setShowQRCode] = useState(false);
  const [activeTab, setActiveTab] = useState<'active' | 'history'>('active');

  const activeReservations = mockReservations.filter(r => r.status === 'active' || r.status === 'pending');
  const pastReservations = mockReservations.filter(r => r.status === 'completed' || r.status === 'cancelled' || r.status === 'no-show');

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800';
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'completed': return 'bg-blue-100 text-blue-800';
      case 'cancelled': return 'bg-gray-100 text-gray-800';
      case 'no-show': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const handleCancelReservation = (id: string) => {
    toast.success('Reservation cancelled');
  };

  const handleCheckIn = (id: string) => {
    setShowQRCode(true);
    setSelectedReservation(id);
  };

  const handleConfirmCheckIn = () => {
    // Simulate QR code scan (90% success rate)
    const success = Math.random() > 0.1;
    
    if (success) {
      toast.success('Checked in! +5 points');
      setShowQRCode(false);
      setSelectedReservation(null);
    } else {
      toast.error('QR scan failed');
    }
  };

  return (
    <div className="h-full bg-white flex flex-col">
      {/* Header */}
      <div className="px-4 pt-2 pb-2 border-b border-gray-200">
        <h1 className="text-lg font-bold text-gray-900">My Bookings</h1>
        <p className="text-xs text-gray-600">Manage your reservations</p>
      </div>

      <div className="flex-1 overflow-y-auto pb-20">
        <div className="p-4">
          {/* Tab Navigation */}
          <div className="flex space-x-2 mb-4 bg-gray-100 p-1 rounded-xl">
            <button
              onClick={() => setActiveTab('active')}
              className={`flex-1 px-4 py-2.5 rounded-lg font-semibold text-xs transition-all ${
                activeTab === 'active' 
                  ? 'bg-blue-600 text-white shadow-sm' 
                  : 'bg-transparent text-gray-600'
              }`}
            >
              Active & Upcoming
            </button>
            <button
              onClick={() => setActiveTab('history')}
              className={`flex-1 px-4 py-2.5 rounded-lg font-semibold text-xs transition-all ${
                activeTab === 'history' 
                  ? 'bg-blue-600 text-white shadow-sm' 
                  : 'bg-transparent text-gray-600'
              }`}
            >
              History
            </button>
          </div>

          {/* Active Reservations */}
          {activeTab === 'active' && (
            <div className="mb-6">
              <h2 className="text-lg font-bold text-gray-900 mb-3">Active & Upcoming</h2>
              {activeReservations.length > 0 ? (
                <div className="space-y-3">
                  {activeReservations.map((reservation) => (
                    <div key={reservation.id} className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100">
                      <div className="flex items-start justify-between mb-3">
                        <div>
                          <h3 className="font-bold text-gray-900 mb-1">{reservation.course}</h3>
                          <span className={`inline-flex items-center space-x-1 px-2.5 py-1 rounded-full text-xs font-semibold ${getStatusColor(reservation.status)}`}>
                            <span className="capitalize">{reservation.status}</span>
                          </span>
                        </div>
                      </div>
                      
                      <div className="grid grid-cols-2 gap-3 mb-3 text-sm text-gray-600">
                        <div className="flex items-center space-x-2">
                          <Calendar className="w-4 h-4" />
                          <span className="text-xs">{reservation.date}</span>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Clock className="w-4 h-4" />
                          <span className="text-xs">{reservation.slot}</span>
                        </div>
                        <div className="flex items-center space-x-2">
                          <MapPin className="w-4 h-4" />
                          <span className="text-xs">{reservation.workspaceId}</span>
                        </div>
                        {reservation.isGroupReservation && (
                          <div className="flex items-center space-x-2 text-purple-600">
                            <Users className="w-4 h-4" />
                            <span className="text-xs">Group ({reservation.participants?.length})</span>
                          </div>
                        )}
                      </div>

                      {reservation.checkedIn && (
                        <div className="mb-3 p-2 bg-green-50 border border-green-200 rounded-lg">
                          <div className="flex items-center space-x-2 text-green-700 text-xs">
                            <CheckCircle className="w-4 h-4" />
                            <span className="font-semibold">Checked in successfully</span>
                          </div>
                        </div>
                      )}

                      <div className="flex space-x-2">
                        {!reservation.checkedIn && reservation.status === 'active' && (
                          <button
                            onClick={() => handleCheckIn(reservation.id)}
                            className="flex-1 flex items-center justify-center space-x-2 px-4 py-2.5 bg-green-600 text-white rounded-xl font-semibold text-sm active:scale-95 transition-transform"
                          >
                            <QrCode className="w-4 h-4" />
                            <span>Check In</span>
                          </button>
                        )}
                        {reservation.status === 'pending' && (
                          <button
                            onClick={() => handleCancelReservation(reservation.id)}
                            className="flex-1 flex items-center justify-center space-x-2 px-4 py-2.5 bg-red-600 text-white rounded-xl font-semibold text-sm active:scale-95 transition-transform"
                          >
                            <XCircle className="w-4 h-4" />
                            <span>Cancel</span>
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="bg-white rounded-2xl p-8 shadow-sm text-center">
                  <Calendar className="w-12 h-12 text-gray-300 mx-auto mb-2" />
                  <p className="text-gray-500 text-sm mb-2">No active reservations</p>
                  <a href="/reserve" className="text-blue-600 text-sm font-semibold">Make a reservation →</a>
                </div>
              )}
            </div>
          )}

          {/* Past Reservations */}
          {activeTab === 'history' && (
            <div>
              <h2 className="text-lg font-bold text-gray-900 mb-3">History</h2>
              <div className="space-y-2">
                {pastReservations.length > 0 ? (
                  pastReservations.map((reservation) => (
                    <div key={reservation.id} className="bg-white rounded-xl p-3 shadow-sm border border-gray-100">
                      <div className="flex items-center justify-between">
                        <div className="flex-1">
                          <h3 className="font-semibold text-gray-900 text-sm mb-1">{reservation.course}</h3>
                          <div className="flex items-center space-x-2 text-xs text-gray-600">
                            <span>{reservation.date}</span>
                            <span>•</span>
                            <span>{reservation.slot}</span>
                          </div>
                        </div>
                        <span className={`px-2 py-1 rounded-full text-xs font-semibold ${getStatusColor(reservation.status)}`}>
                          {reservation.status}
                        </span>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="bg-white rounded-xl p-6 shadow-sm text-center">
                    <p className="text-gray-500 text-sm">No past reservations</p>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* QR Code Modal */}
          {showQRCode && selectedReservation && (
            <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-3xl p-5 w-full max-w-[300px]">
                <div className="text-center">
                  <div className="inline-flex items-center justify-center w-12 h-12 bg-green-100 rounded-full mb-3">
                    <QrCode className="w-6 h-6 text-green-600" />
                  </div>
                  <h2 className="text-base font-bold text-gray-900 mb-1">Check-In QR Code</h2>
                  <p className="text-xs text-gray-600 mb-4">Scan at entrance to check in</p>
                  
                  <div className="bg-white p-3 rounded-2xl border-2 border-gray-200 mb-4 inline-block">
                    <QRCodeSVG
                      value={mockReservations.find(r => r.id === selectedReservation)?.qrCode || 'RES-DEFAULT-CODE'}
                      size={160}
                      level="H"
                    />
                  </div>

                  <div className="bg-blue-50 border border-blue-200 rounded-xl p-2.5 mb-4">
                    <p className="text-[10px] text-blue-800">
                      <span className="font-semibold">Check in within 15 min</span> of reservation start
                    </p>
                  </div>

                  <button
                    onClick={handleConfirmCheckIn}
                    className="w-full bg-green-600 text-white py-2.5 rounded-xl font-bold text-sm active:scale-95 transition-transform"
                  >
                    Confirm Check-In
                  </button>

                  <button
                    onClick={() => {
                      setShowQRCode(false);
                      setSelectedReservation(null);
                    }}
                    className="w-full mt-2 text-gray-600 py-2 text-sm"
                  >
                    Close
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