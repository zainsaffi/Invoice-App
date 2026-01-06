import Sidebar from "@/components/Sidebar";
import { Building2, Plus } from "lucide-react";

export default function DepositsPage() {
  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="flex items-center justify-between mb-8">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Bank Deposits</h1>
              <p className="text-gray-500 mt-1">Track deposits to your bank accounts</p>
            </div>
            <button className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 text-white text-sm font-medium rounded-xl hover:bg-indigo-700 transition-colors shadow-lg shadow-indigo-500/25">
              <Plus className="w-4 h-4" />
              Record Deposit
            </button>
          </div>

          {/* Empty State */}
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
            <div className="px-6 py-16 text-center">
              <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Building2 className="w-8 h-8 text-gray-400" />
              </div>
              <p className="text-gray-900 font-medium mb-2">No deposits recorded</p>
              <p className="text-gray-500 text-sm mb-6">
                Record bank deposits to track when payments are cleared.
              </p>
              <button className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 text-white text-sm font-medium rounded-xl hover:bg-indigo-700 transition-colors">
                <Plus className="w-4 h-4" />
                Record Your First Deposit
              </button>
            </div>
          </div>

          {/* Info Cards */}
          <div className="grid grid-cols-2 gap-6 mt-8">
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <h3 className="font-semibold text-gray-900 mb-2">What are bank deposits?</h3>
              <p className="text-sm text-gray-600">
                Bank deposits help you track when payments from clients are actually deposited
                into your bank account. This is useful for reconciling your books.
              </p>
            </div>
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <h3 className="font-semibold text-gray-900 mb-2">How to record a deposit</h3>
              <p className="text-sm text-gray-600">
                Click "Record Deposit" to log a new bank deposit. You can associate it with
                one or more paid invoices to keep your records organized.
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
