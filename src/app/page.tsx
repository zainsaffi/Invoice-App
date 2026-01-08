import { queryMany, InvoiceRow, InvoiceItemRow, ReceiptRow, toInvoice, toInvoiceItem, toReceipt } from "@/db";
import Sidebar from "@/components/Sidebar";
import SalesChart from "@/components/SalesChart";
import Link from "next/link";
import { formatCurrency } from "@/lib/utils";
import {
  TrendingUp,
  TrendingDown,
  FileText,
  Clock,
  CheckCircle,
  AlertTriangle,
  ArrowRight,
} from "lucide-react";

export const dynamic = "force-dynamic";

export default async function Dashboard() {
  // Fetch all invoices ordered by created_at desc
  const invoiceRows = await queryMany<InvoiceRow>(
    `SELECT * FROM invoices ORDER BY created_at DESC`
  );

  // Fetch all items and receipts for these invoices
  const invoiceIds = invoiceRows.map((inv) => inv.id);

  let itemRows: InvoiceItemRow[] = [];
  let receiptRows: ReceiptRow[] = [];

  if (invoiceIds.length > 0) {
    // Create parameter placeholders for IN clause
    const placeholders = invoiceIds.map((_, i) => `$${i + 1}`).join(", ");

    itemRows = await queryMany<InvoiceItemRow>(
      `SELECT * FROM invoice_items WHERE invoice_id IN (${placeholders})`,
      invoiceIds
    );

    receiptRows = await queryMany<ReceiptRow>(
      `SELECT * FROM receipts WHERE invoice_id IN (${placeholders})`,
      invoiceIds
    );
  }

  // Convert to camelCase and combine
  const invoices = invoiceRows.map((row) => {
    const invoice = toInvoice(row);
    const items = itemRows
      .filter((item) => item.invoice_id === row.id)
      .map(toInvoiceItem);
    const receipts = receiptRows
      .filter((receipt) => receipt.invoice_id === row.id)
      .map(toReceipt);
    return { ...invoice, items, receipts };
  });

  const now = new Date();

  // Prepare sales data for the chart (include client info)
  const salesData = invoices
    .filter((inv) => inv.status === "paid")
    .map((inv) => ({
      date: new Date(inv.createdAt).toISOString().split("T")[0],
      amount: inv.total,
      paidAt: inv.paidAt ? new Date(inv.paidAt).toISOString() : null,
      clientName: inv.clientName,
      clientEmail: inv.clientEmail,
    }));

  // Calculate quick stats
  const calculateSalesForDays = (days: number) => {
    const start = new Date();
    start.setDate(start.getDate() - days);
    return invoices
      .filter(
        (inv) =>
          inv.status === "paid" && inv.paidAt && new Date(inv.paidAt) >= start
      )
      .reduce((sum, inv) => sum + inv.total, 0);
  };

  const last30Days = calculateSalesForDays(30);
  const prev30Days = (() => {
    const periodStart = new Date();
    periodStart.setDate(periodStart.getDate() - 30);
    const previousStart = new Date();
    previousStart.setDate(previousStart.getDate() - 60);
    return invoices
      .filter((inv) => {
        if (inv.status !== "paid" || !inv.paidAt) return false;
        const paidDate = new Date(inv.paidAt);
        return paidDate >= previousStart && paidDate < periodStart;
      })
      .reduce((sum, inv) => sum + inv.total, 0);
  })();

  const trendPercent =
    prev30Days > 0
      ? Math.round(((last30Days - prev30Days) / prev30Days) * 100)
      : 0;
  const trendUp = last30Days >= prev30Days;

  // Overall stats
  const totalRevenue = invoices
    .filter((inv) => inv.status === "paid")
    .reduce((sum, inv) => sum + inv.total, 0);

  const pendingAmount = invoices
    .filter((inv) => inv.status !== "paid" && inv.status !== "cancelled")
    .reduce((sum, inv) => sum + inv.total, 0);

  const overdueInvoices = invoices.filter(
    (inv) =>
      inv.dueDate &&
      new Date(inv.dueDate) < now &&
      inv.status !== "paid" &&
      inv.status !== "cancelled"
  );
  const overdueAmount = overdueInvoices.reduce(
    (sum, inv) => sum + inv.total,
    0
  );

  // Recent activity
  const recentPaidInvoices = invoices
    .filter((inv) => inv.status === "paid")
    .slice(0, 5);

  const pendingInvoicesList = invoices
    .filter((inv) => inv.status !== "paid" && inv.status !== "cancelled")
    .slice(0, 5);

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
            <p className="text-gray-500 mt-1">
              Overview of your business performance
            </p>
          </div>

          {/* Key Metrics */}
          <div className="grid grid-cols-4 gap-6 mb-8">
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-indigo-100 rounded-xl flex items-center justify-center">
                  <TrendingUp className="w-6 h-6 text-indigo-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">Last 30 Days</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {formatCurrency(last30Days)}
                  </p>
                  {trendPercent !== 0 && (
                    <div
                      className={`flex items-center gap-1 text-xs font-medium mt-1 ${
                        trendUp ? "text-green-600" : "text-red-600"
                      }`}
                    >
                      {trendUp ? (
                        <TrendingUp className="w-3 h-3" />
                      ) : (
                        <TrendingDown className="w-3 h-3" />
                      )}
                      {Math.abs(trendPercent)}% vs prev period
                    </div>
                  )}
                </div>
              </div>
            </div>
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
                  <CheckCircle className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">
                    Total Collected
                  </p>
                  <p className="text-2xl font-bold text-gray-900">
                    {formatCurrency(totalRevenue)}
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-yellow-100 rounded-xl flex items-center justify-center">
                  <Clock className="w-6 h-6 text-yellow-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">Pending</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {formatCurrency(pendingAmount)}
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center">
                  <AlertTriangle className="w-6 h-6 text-red-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-500">Overdue</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {formatCurrency(overdueAmount)}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Sales Chart */}
          <div className="mb-8">
            <SalesChart salesData={salesData} />
          </div>

          {/* Recent Activity */}
          <div className="grid grid-cols-2 gap-8">
            {/* Recent Payments */}
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                <h2 className="text-lg font-semibold text-gray-900">Recent Payments</h2>
                <Link href="/payments" className="text-sm text-indigo-600 hover:text-indigo-700 font-medium flex items-center gap-1">
                  View all <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
              {recentPaidInvoices.length === 0 ? (
                <div className="p-6 text-center text-gray-500">
                  <CheckCircle className="w-8 h-8 mx-auto mb-2 text-gray-300" />
                  <p className="text-sm">No payments yet</p>
                </div>
              ) : (
                <div className="divide-y divide-gray-100">
                  {recentPaidInvoices.map((invoice) => (
                    <Link
                      key={invoice.id}
                      href={`/invoices/${invoice.id}`}
                      className="flex items-center justify-between px-6 py-4 hover:bg-gray-50 transition-colors"
                    >
                      <div>
                        <p className="text-sm font-medium text-gray-900">{invoice.clientName}</p>
                        <p className="text-xs text-gray-500">{invoice.invoiceNumber}</p>
                      </div>
                      <div className="text-right">
                        <p className="text-sm font-semibold text-green-600">{formatCurrency(invoice.total)}</p>
                        <p className="text-xs text-gray-500">
                          {invoice.paidAt ? new Date(invoice.paidAt).toLocaleDateString() : '-'}
                        </p>
                      </div>
                    </Link>
                  ))}
                </div>
              )}
            </div>

            {/* Pending Invoices */}
            <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
              <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                <h2 className="text-lg font-semibold text-gray-900">Pending Invoices</h2>
                <Link href="/invoices" className="text-sm text-indigo-600 hover:text-indigo-700 font-medium flex items-center gap-1">
                  View all <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
              {pendingInvoicesList.length === 0 ? (
                <div className="p-6 text-center text-gray-500">
                  <Clock className="w-8 h-8 mx-auto mb-2 text-gray-300" />
                  <p className="text-sm">No pending invoices</p>
                </div>
              ) : (
                <div className="divide-y divide-gray-100">
                  {pendingInvoicesList.map((invoice) => {
                    const isOverdue = invoice.dueDate && new Date(invoice.dueDate) < now;
                    return (
                      <Link
                        key={invoice.id}
                        href={`/invoices/${invoice.id}`}
                        className="flex items-center justify-between px-6 py-4 hover:bg-gray-50 transition-colors"
                      >
                        <div>
                          <p className="text-sm font-medium text-gray-900">{invoice.clientName}</p>
                          <p className="text-xs text-gray-500">{invoice.invoiceNumber}</p>
                        </div>
                        <div className="text-right">
                          <p className="text-sm font-semibold text-gray-900">{formatCurrency(invoice.total)}</p>
                          {invoice.dueDate && (
                            <p className={`text-xs ${isOverdue ? 'text-red-600 font-medium' : 'text-gray-500'}`}>
                              {isOverdue ? 'Overdue' : `Due ${new Date(invoice.dueDate).toLocaleDateString()}`}
                            </p>
                          )}
                        </div>
                      </Link>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
