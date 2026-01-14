"use client";

import { Plus, Trash2, Plane, Copy } from "lucide-react";
import { TripLeg } from "@/types/invoice";

interface TripLegsEditorProps {
  legs: TripLeg[];
  onChange: (legs: TripLeg[]) => void;
}

export default function TripLegsEditor({ legs, onChange }: TripLegsEditorProps) {
  function addLeg() {
    const prevLeg = legs.length > 0 ? legs[legs.length - 1] : null;
    const newLeg: TripLeg = {
      legOrder: legs.length + 1,
      fromAirport: prevLeg?.toAirport || "",
      toAirport: "",
      tripDate: "",
      tripDateEnd: "",
      passengers: "",
    };
    onChange([...legs, newLeg]);
  }

  function updateLeg(index: number, field: keyof TripLeg, value: string | number) {
    const updated = [...legs];
    updated[index] = { ...updated[index], [field]: value };
    onChange(updated);
  }

  function copyFromPrevious(index: number, field: 'tripDate' | 'tripDateEnd' | 'passengers') {
    if (index === 0) return;
    const prevLeg = legs[index - 1];
    const updated = [...legs];

    if (field === 'tripDate' || field === 'tripDateEnd') {
      // Copy both date fields when copying date
      updated[index] = {
        ...updated[index],
        tripDate: prevLeg.tripDate || "",
        tripDateEnd: prevLeg.tripDateEnd || "",
      };
    } else {
      updated[index] = { ...updated[index], [field]: prevLeg[field] || "" };
    }
    onChange(updated);
  }

  function removeLeg(index: number) {
    const updated = legs.filter((_, i) => i !== index);
    // Re-order leg numbers
    const reordered = updated.map((leg, i) => ({ ...leg, legOrder: i + 1 }));
    onChange(reordered);
  }

  return (
    <div className="border border-gray-200 rounded-xl p-4 bg-gray-50">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Plane className="w-4 h-4 text-blue-600" />
          <span className="font-medium text-gray-700">Trip Legs</span>
        </div>
        <button
          type="button"
          onClick={addLeg}
          className="flex items-center gap-1 text-sm text-indigo-600 hover:text-indigo-700"
        >
          <Plus className="w-4 h-4" />
          Add Leg
        </button>
      </div>

      {legs.length === 0 ? (
        <div className="text-center py-6 text-gray-400 text-sm">
          No legs added. Click &quot;Add Leg&quot; to add trip itinerary.
        </div>
      ) : (
        <div className="space-y-3">
          {legs.map((leg, index) => {
            const prevLeg = index > 0 ? legs[index - 1] : null;
            const hasPrevious = index > 0;

            return (
              <div
                key={index}
                className="bg-white border border-gray-200 rounded-lg p-3"
              >
                <div className="flex items-center justify-between mb-3">
                  <span className="text-xs font-medium text-gray-500 uppercase tracking-wide">
                    Leg {leg.legOrder}
                  </span>
                  <button
                    type="button"
                    onClick={() => removeLeg(index)}
                    className="p-1 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>

                <div className="grid grid-cols-2 gap-3 mb-3">
                  <div>
                    <label className="block text-xs text-gray-500 mb-1">From Airport</label>
                    <input
                      type="text"
                      value={leg.fromAirport}
                      onChange={(e) => updateLeg(index, "fromAirport", e.target.value.toUpperCase())}
                      placeholder="KFPR"
                      className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-transparent uppercase"
                      maxLength={10}
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-gray-500 mb-1">To Airport</label>
                    <input
                      type="text"
                      value={leg.toAirport}
                      onChange={(e) => updateLeg(index, "toAirport", e.target.value.toUpperCase())}
                      placeholder="KTEB"
                      className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-transparent uppercase"
                      maxLength={10}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3 mb-3">
                  <div>
                    <div className="flex items-center justify-between mb-1">
                      <label className="text-xs text-gray-500">Date</label>
                      {hasPrevious && prevLeg?.tripDate && (
                        <button
                          type="button"
                          onClick={() => copyFromPrevious(index, 'tripDate')}
                          className="flex items-center gap-1 text-xs text-indigo-500 hover:text-indigo-700"
                          title="Copy from previous leg"
                        >
                          <Copy className="w-3 h-3" />
                          Same as prev
                        </button>
                      )}
                    </div>
                    <input
                      type="date"
                      value={leg.tripDate || ""}
                      onChange={(e) => updateLeg(index, "tripDate", e.target.value)}
                      className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                    />
                  </div>
                  <div>
                    <label className="block text-xs text-gray-500 mb-1">End Date (optional)</label>
                    <input
                      type="date"
                      value={leg.tripDateEnd || ""}
                      onChange={(e) => updateLeg(index, "tripDateEnd", e.target.value)}
                      className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                    />
                  </div>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="text-xs text-gray-500">Passengers</label>
                    {hasPrevious && prevLeg?.passengers && (
                      <button
                        type="button"
                        onClick={() => copyFromPrevious(index, 'passengers')}
                        className="flex items-center gap-1 text-xs text-indigo-500 hover:text-indigo-700"
                        title="Copy from previous leg"
                      >
                        <Copy className="w-3 h-3" />
                        Same as prev
                      </button>
                    )}
                  </div>
                  <input
                    type="text"
                    value={leg.passengers || ""}
                    onChange={(e) => updateLeg(index, "passengers", e.target.value)}
                    placeholder="Lead passenger name(s)"
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  />
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
