import { queryMany, InvoiceRow, toInvoice } from "@/db";
import Sidebar from "@/components/Sidebar";
import { CreditCard, CheckCircle, Clock, DollarSign } from "lucide-react";
import { formatCurrency, formatDate } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function PaymentsPage() {
  // Fetch all paid invoices ordered by paid_at desc
  const invoiceRows = await queryMany<InvoiceRow>(
    `SELECT * FROM invoices WHERE status = $1 ORDER BY paid_at DESC`,
    ["paid"]
  );

  // Convert to camelCase
  const paidInvoices = invoiceRows.map(toInvoice);

  const totalPaid = paidInvoices.reduce((sum, inv) => sum + inv.total, 0);

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-2xl font-bold text-gray-900">Payments</h1>
            <p className="text-gray-500 mt-1">Track all received payments</p>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-6 mb-8">
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-emerald-100 rounded-xl flex items-center justify-center">
                  <DollarSign className="w-6 h-6 text-emerald-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">Total Received</p>
                  <p className="text-2xl font-bold text-gray-900">{formatCurrency(totalPaid)}</p>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                  <CheckCircle className="w-6 h-6 text-blue-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">Paid Invoices</p>
                  <p className="text-2xl font-bold text-gray-900">{paidInvoices.length}</p>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center">
                  <Clock className="w-6 h-6 text-purple-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">This Month</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {formatCurrency(
                      paidInvoices
                        .filter((inv) => {
                          const paidDate = inv.paidAt ? new Date(inv.paidAt) : new Date();
                          const now = new Date();
                          return paidDate.getMonth() === now.getMonth() && paidDate.getFullYear() === now.getFullYear();
                        })
                        .reduce((sum, inv) => sum + inv.total, 0)
                    )}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Payments List */}
          <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">Payment History</h2>
            </div>
            {paidInvoices.length === 0 ? (
              <div className="px-6 py-12 text-center">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <CreditCard className="w-8 h-8 text-gray-400" />
                </div>
                <p className="text-gray-900 font-medium mb-2">No payments yet</p>
                <p className="text-gray-500 text-sm">Payments will appear here when invoices are marked as paid.</p>
              </div>
            ) : (
              <table className="w-full">
                <thead className="bg-gray-50/80 border-b border-gray-200">
                  <tr>
                    <th className="text-left px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Invoice
                    </th>
                    <th className="text-left px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Client
                    </th>
                    <th className="text-left px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Payment Method
                    </th>
                    <th className="text-left px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Date
                    </th>
                    <th className="text-right px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Amount
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {paidInvoices.map((invoice) => (
                    <tr key={invoice.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <span className="text-sm font-medium text-indigo-600">{invoice.invoiceNumber}</span>
                      </td>
                      <td className="px-6 py-4">
                        <span className="text-sm text-gray-900">{invoice.clientName}</span>
                      </td>
                      <td className="px-6 py-4">
                        <span className="text-sm text-gray-600">{invoice.paymentMethod || "—"}</span>
                      </td>
                      <td className="px-6 py-4">
                        <span className="text-sm text-gray-600">
                          {invoice.paidAt ? formatDate(invoice.paidAt) : "—"}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <span className="text-sm font-medium text-emerald-600">
                          {formatCurrency(invoice.total)}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
