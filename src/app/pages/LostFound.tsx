import { useState } from 'react';
import { mockLostItems, workspaces } from '../data/mockData';
import { MapPin, Package, Clock, AlertCircle, Plus, X } from 'lucide-react';
import { toast } from 'sonner';

export default function LostFound() {
  const [showReportModal, setShowReportModal] = useState(false);
  const [selectedWorkspace, setSelectedWorkspace] = useState('');
  const [itemDescription, setItemDescription] = useState('');
  const [showMap, setShowMap] = useState(false);
  const [itemImage, setItemImage] = useState<File | null>(null);

  const handleReportItem = () => {
    if (!selectedWorkspace || !itemDescription) {
      toast.error('Fill all fields');
      return;
    }

    toast.success('Item reported! ✓');
    setShowReportModal(false);
    setSelectedWorkspace('');
    setItemDescription('');
    setItemImage(null);
  };

  const getTimeRemaining = (expiresAt: string) => {
    const now = new Date('2026-03-10T15:00:00');
    const expires = new Date(expiresAt);
    const diff = expires.getTime() - now.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    return hours > 0 ? `${hours}h left` : 'Expired';
  };

  return (
    <div className="h-full bg-white flex flex-col">
      {/* Header */}
      <div className="px-4 pt-2 pb-2 border-b border-gray-200">
        <h1 className="text-lg font-bold text-gray-900">Lost & Found</h1>
        <p className="text-xs text-gray-600">Report and find lost items</p>
      </div>

      <div className="flex-1 overflow-y-auto pb-20">
        <div className="p-4">
          {/* How It Works - Moved to top */}
          <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-3 mb-3">
            <div className="flex items-start space-x-2">
              <AlertCircle className="w-4 h-4 text-yellow-600 flex-shrink-0 mt-0.5" />
              <div>
                <h3 className="font-bold text-yellow-900 text-xs mb-1">How It Works</h3>
                <ul className="space-y-0.5 text-[10px] text-yellow-800">
                  <li>• Report items after your session</li>
                  <li>• Items marked on map (yellow)</li>
                  <li>• Auto-expire after 24 hours</li>
                </ul>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="grid grid-cols-2 gap-2 mb-3">
            <button
              onClick={() => setShowReportModal(true)}
              className="flex items-center justify-center space-x-1.5 px-3 py-3 bg-blue-600 text-white rounded-xl font-bold text-sm active:scale-95 transition-transform"
            >
              <Plus className="w-4 h-4" />
              <span>Report Item</span>
            </button>
            <button
              onClick={() => setShowMap(!showMap)}
              className="flex items-center justify-center space-x-1.5 px-3 py-3 bg-purple-600 text-white rounded-xl font-bold text-sm active:scale-95 transition-transform"
            >
              <MapPin className="w-4 h-4" />
              <span>{showMap ? 'Hide' : 'Show'} Map</span>
            </button>
          </div>

          {/* Map */}
          {showMap && (
            <div className="bg-gray-50 rounded-xl p-3 border border-gray-200 mb-3">
              <h3 className="font-bold text-gray-900 mb-2 text-sm">Map View</h3>
              
              <div className="flex items-center space-x-2 mb-2 text-[9px]">
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
                  <span className="text-gray-600">Lost Item</span>
                </div>
              </div>

              <div className="border border-gray-200 rounded-xl overflow-hidden bg-white">
                <svg viewBox="0 0 330 400" className="w-full h-auto">
                  <rect x="2" y="2" width="326" height="396" fill="white" stroke="#e5e7eb" strokeWidth="2" />
                  
                  <text x="165" y="20" textAnchor="middle" className="text-xs font-semibold" fill="#6b7280" fontSize="11">
                    Individual Desks
                  </text>
                  <text x="165" y="250" textAnchor="middle" className="text-xs font-semibold" fill="#6b7280" fontSize="11">
                    Group Rooms
                  </text>

                  {workspaces.map((workspace) => {
                    const hasLostItem = mockLostItems.some(item => item.workspaceId === workspace.id);
                    const fillColor = hasLostItem ? '#facc15' : workspace.status === 'occupied' ? '#f87171' : '#60a5fa';
                    const strokeColor = hasLostItem ? '#eab308' : workspace.status === 'occupied' ? '#dc2626' : '#2563eb';

                    if (workspace.type === 'individual') {
                      return (
                        <g key={workspace.id}>
                          <rect
                            x={workspace.x}
                            y={workspace.y}
                            width="35"
                            height="50"
                            fill={fillColor}
                            stroke={strokeColor}
                            strokeWidth="2"
                            rx="3"
                          />
                          <text
                            x={workspace.x + 17.5}
                            y={workspace.y + 30}
                            textAnchor="middle"
                            className="text-xs font-bold"
                            fill="white"
                            fontSize="11"
                          >
                            {workspace.id.split('-')[1]}
                          </text>
                          {hasLostItem && (
                            <circle
                              cx={workspace.x + 28}
                              cy={workspace.y + 7}
                              r="4"
                              fill="#ef4444"
                              stroke="white"
                              strokeWidth="1.5"
                            >
                              <animate
                                attributeName="r"
                                values="4;5;4"
                                dur="1.5s"
                                repeatCount="indefinite"
                              />
                            </circle>
                          )}
                        </g>
                      );
                    } else {
                      return (
                        <g key={workspace.id}>
                          <rect
                            x={workspace.x}
                            y={workspace.y}
                            width="70"
                            height="100"
                            fill={fillColor}
                            stroke={strokeColor}
                            strokeWidth="2"
                            rx="6"
                          />
                          <text
                            x={workspace.x + 35}
                            y={workspace.y + 52}
                            textAnchor="middle"
                            className="text-xs font-bold"
                            fill="white"
                            fontSize="10"
                          >
                            {workspace.id}
                          </text>
                          {hasLostItem && (
                            <circle
                              cx={workspace.x + 60}
                              cy={workspace.y + 12}
                              r="6"
                              fill="#ef4444"
                              stroke="white"
                              strokeWidth="2"
                            >
                              <animate
                                attributeName="r"
                                values="6;7;6"
                                dur="1.5s"
                                repeatCount="indefinite"
                              />
                            </circle>
                          )}
                        </g>
                      );
                    }
                  })}
                </svg>
              </div>
            </div>
          )}

          {/* Active Lost Items */}
          <div>
            <h2 className="font-bold text-gray-900 mb-2 text-sm">Active Items</h2>
            {mockLostItems.length > 0 ? (
              <div className="space-y-2">
                {mockLostItems.map((item) => (
                  <div key={item.id} className="bg-yellow-50 rounded-xl p-3 border-2 border-yellow-300">
                    <div className="flex items-start space-x-2">
                      <div className="flex-shrink-0 w-10 h-10 bg-yellow-200 rounded-lg flex items-center justify-center">
                        <Package className="w-5 h-5 text-yellow-700" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <h3 className="font-bold text-gray-900 text-sm mb-1">{item.description}</h3>
                        
                        <div className="space-y-0.5 text-[10px] text-gray-600 mb-2">
                          <div className="flex items-center space-x-1">
                            <MapPin className="w-3 h-3" />
                            <span>{item.workspaceId}</span>
                          </div>
                          <div className="flex items-center space-x-1">
                            <Clock className="w-3 h-3" />
                            <span>{getTimeRemaining(item.expiresAt)}</span>
                          </div>
                        </div>

                        <button className="text-[10px] text-blue-600 font-bold">
                          Contact Reporter →
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="bg-gray-50 rounded-xl p-6 text-center">
                <Package className="w-10 h-10 text-gray-300 mx-auto mb-2" />
                <p className="text-gray-500 text-xs">No lost items</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Report Modal */}
      {showReportModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-[300px] shadow-2xl">
            <div className="flex items-center justify-between p-4 border-b border-gray-200">
              <h2 className="font-bold text-gray-900">Report Lost Item</h2>
              <button
                onClick={() => setShowReportModal(false)}
                className="w-7 h-7 flex items-center justify-center bg-gray-100 rounded-full"
              >
                <X className="w-4 h-4 text-gray-600" />
              </button>
            </div>
            
            <div className="p-4 space-y-3">
              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1.5">
                  Workspace
                </label>
                <select
                  value={selectedWorkspace}
                  onChange={(e) => setSelectedWorkspace(e.target.value)}
                  className="w-full px-3 py-2.5 border-2 border-gray-200 rounded-xl text-xs font-medium"
                >
                  <option value="">Select workspace</option>
                  {workspaces.slice(0, 10).map((ws) => (
                    <option key={ws.id} value={ws.id}>
                      {ws.id}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1.5">
                  Description
                </label>
                <textarea
                  value={itemDescription}
                  onChange={(e) => setItemDescription(e.target.value)}
                  placeholder="E.g., Black phone charger (USB-C)"
                  rows={4}
                  className="w-full px-3 py-2.5 border-2 border-gray-200 rounded-xl text-xs resize-none"
                />
              </div>

              <div className="bg-blue-50 border border-blue-200 rounded-xl p-2.5">
                <p className="text-[10px] text-blue-800">
                  Alert will be visible for 24 hours and auto-expire
                </p>
              </div>

              <button
                onClick={handleReportItem}
                className="w-full bg-blue-600 text-white py-3 rounded-xl font-bold text-sm active:scale-95 transition-transform"
              >
                Report Item
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}