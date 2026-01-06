"use client";

import { useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Invoice } from "@/types/invoice";
import { formatCurrency, formatDate, getDisplayStatus, getDisplayStatusBadge, DisplayStatus } from "@/lib/utils";
import { ChevronDown, ChevronUp, Search, Filter, MoreHorizontal, X, Calendar } from "lucide-react";

interface InvoiceTableProps {
  invoices: Invoice[];
}

type SortField = "invoiceNumber" | "total" | "status" | "clientName" | "createdAt" | "dueDate";
type SortDirection = "asc" | "desc";

const tabs = [
  { id: "all", label: "All" },
  { id: "draft", label: "Draft" },
  { id: "due", label: "Due" },
  { id: "overdue", label: "Overdue" },
  { id: "paid", label: "Paid" },
  { id: "cancelled", label: "Cancelled" },
];

const StatusBadge = ({ invoice }: { invoice: Invoice }) => {
  const displayStatus = getDisplayStatus(invoice);
  const badge = getDisplayStatusBadge(displayStatus);

  return (
    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded ${badge.bg} ${badge.text}`}>
      {badge.label}
    </span>
  );
};

export default function InvoiceTable({ invoices }: InvoiceTableProps) {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState("all");
  const [sortField, setSortField] = useState<SortField>("createdAt");
  const [sortDirection, setSortDirection] = useState<SortDirection>("desc");
  const [searchQuery, setSearchQuery] = useState("");
  const [showFilters, setShowFilters] = useState(false);
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [amountMin, setAmountMin] = useState("");
  const [amountMax, setAmountMax] = useState("");

  const hasActiveFilters = dateFrom || dateTo || amountMin || amountMax;

  const clearFilters = () => {
    setDateFrom("");
    setDateTo("");
    setAmountMin("");
    setAmountMax("");
  };

  const handleSort = (field: SortField) => {
    if (sortField === field) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortField(field);
      setSortDirection("asc");
    }
  };

  // Calculate counts for each status
  const statusCounts = useMemo(() => {
    const counts: Record<string, number> = {
      all: invoices.length,
      draft: 0,
      sent: 0,
      due: 0,
      overdue: 0,
      paid: 0,
      cancelled: 0,
    };

    invoices.forEach((inv) => {
      const status = getDisplayStatus(inv);
      counts[status] = (counts[status] || 0) + 1;
    });

    return counts;
  }, [invoices]);

  const filteredAndSortedInvoices = useMemo(() => {
    let filtered = [...invoices];

    // Filter by tab (using computed display status)
    if (activeTab !== "all") {
      filtered = filtered.filter((inv) => {
        const displayStatus = getDisplayStatus(inv);
        return displayStatus === activeTab;
      });
    }

    // Filter by search
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(
        (inv) =>
          inv.invoiceNumber.toLowerCase().includes(query) ||
          inv.clientName.toLowerCase().includes(query) ||
          inv.clientEmail.toLowerCase().includes(query)
      );
    }

    // Filter by date range
    if (dateFrom) {
      const fromDate = new Date(dateFrom);
      filtered = filtered.filter((inv) => new Date(inv.createdAt) >= fromDate);
    }
    if (dateTo) {
      const toDate = new Date(dateTo);
      toDate.setHours(23, 59, 59, 999);
      filtered = filtered.filter((inv) => new Date(inv.createdAt) <= toDate);
    }

    // Filter by amount range
    if (amountMin) {
      const min = parseFloat(amountMin);
      if (!isNaN(min)) {
        filtered = filtered.filter((inv) => inv.total >= min);
      }
    }
    if (amountMax) {
      const max = parseFloat(amountMax);
      if (!isNaN(max)) {
        filtered = filtered.filter((inv) => inv.total <= max);
      }
    }

    // Sort
    filtered.sort((a, b) => {
      let aVal: string | number | Date = "";
      let bVal: string | number | Date = "";

      switch (sortField) {
        case "invoiceNumber":
          aVal = a.invoiceNumber;
          bVal = b.invoiceNumber;
          break;
        case "total":
          aVal = a.total;
          bVal = b.total;
          break;
        case "status":
          aVal = getDisplayStatus(a);
          bVal = getDisplayStatus(b);
          break;
        case "clientName":
          aVal = a.clientName;
          bVal = b.clientName;
          break;
        case "createdAt":
          aVal = new Date(a.createdAt);
          bVal = new Date(b.createdAt);
          break;
        case "dueDate":
          aVal = a.dueDate ? new Date(a.dueDate) : new Date(0);
          bVal = b.dueDate ? new Date(b.dueDate) : new Date(0);
          break;
      }

      if (aVal < bVal) return sortDirection === "asc" ? -1 : 1;
      if (aVal > bVal) return sortDirection === "asc" ? 1 : -1;
      return 0;
    });

    return filtered;
  }, [invoices, activeTab, sortField, sortDirection, searchQuery, dateFrom, dateTo, amountMin, amountMax]);

  const SortIcon = ({ field }: { field: SortField }) => {
    if (sortField !== field) {
      return <ChevronDown className="w-4 h-4 text-gray-400" />;
    }
    return sortDirection === "asc" ? (
      <ChevronUp className="w-4 h-4 text-gray-700" />
    ) : (
      <ChevronDown className="w-4 h-4 text-gray-700" />
    );
  };

  return (
    <div>
      {/* Filters Row */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium rounded-lg shadow-sm transition-colors ${
              showFilters || hasActiveFilters
                ? "bg-indigo-50 text-indigo-700 border border-indigo-200"
                : "text-gray-700 bg-white border border-gray-300 hover:bg-gray-50"
            }`}
          >
            <Filter className="w-4 h-4" />
            Filters
            {hasActiveFilters && (
              <span className="w-2 h-2 bg-indigo-600 rounded-full"></span>
            )}
          </button>
          {hasActiveFilters && (
            <button
              onClick={clearFilters}
              className="flex items-center gap-1 px-3 py-2 text-sm text-gray-500 hover:text-gray-700 transition-colors"
            >
              <X className="w-4 h-4" />
              Clear filters
            </button>
          )}
        </div>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search invoices..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10 pr-4 py-2.5 text-sm bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent w-72 shadow-sm"
          />
        </div>
      </div>

      {/* Filter Panel */}
      {showFilters && (
        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6 shadow-sm">
          <div className="grid grid-cols-4 gap-6">
            {/* Date From */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Date From
              </label>
              <div className="relative">
                <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="date"
                  value={dateFrom}
                  onChange={(e) => setDateFrom(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 text-sm bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>
            </div>

            {/* Date To */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Date To
              </label>
              <div className="relative">
                <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="date"
                  value={dateTo}
                  onChange={(e) => setDateTo(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 text-sm bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>
            </div>

            {/* Amount Min */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Min Amount
              </label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">$</span>
                <input
                  type="number"
                  placeholder="0.00"
                  value={amountMin}
                  onChange={(e) => setAmountMin(e.target.value)}
                  className="w-full pl-8 pr-4 py-2.5 text-sm bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>
            </div>

            {/* Amount Max */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Max Amount
              </label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">$</span>
                <input
                  type="number"
                  placeholder="0.00"
                  value={amountMax}
                  onChange={(e) => setAmountMax(e.target.value)}
                  className="w-full pl-8 pr-4 py-2.5 text-sm bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tabs */}
      <div className="border-b border-gray-200 mb-6">
        <nav className="flex gap-8">
          {tabs.map((tab) => {
            const count = statusCounts[tab.id] || 0;

            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`pb-3 text-sm font-medium border-b-2 transition-colors ${
                  activeTab === tab.id
                    ? "border-indigo-600 text-indigo-600"
                    : "border-transparent text-gray-500 hover:text-gray-700"
                }`}
              >
                {tab.label}
                <span className={`ml-2 px-2 py-0.5 text-xs rounded-full ${
                  activeTab === tab.id ? "bg-indigo-100 text-indigo-600" : "bg-gray-100 text-gray-500"
                }`}>
                  {count}
                </span>
              </button>
            );
          })}
        </nav>
      </div>

      {/* Table */}
      <div className="bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm">
        <table className="w-full">
          <thead className="bg-gray-50/80 border-b border-gray-200">
            <tr>
              <th className="text-left px-4 py-3">
                <button
                  onClick={() => handleSort("invoiceNumber")}
                  className="flex items-center gap-1 text-xs font-medium text-gray-500 uppercase tracking-wider hover:text-gray-700"
                >
                  Invoice Number
                  <SortIcon field="invoiceNumber" />
                </button>
              </th>
              <th className="text-left px-4 py-3">
                <button
                  onClick={() => handleSort("total")}
                  className="flex items-center gap-1 text-xs font-medium text-gray-500 uppercase tracking-wider hover:text-gray-700"
                >
                  Total Amount
                  <SortIcon field="total" />
                </button>
              </th>
              <th className="text-left px-4 py-3">
                <button
                  onClick={() => handleSort("status")}
                  className="flex items-center gap-1 text-xs font-medium text-gray-500 uppercase tracking-wider hover:text-gray-700"
                >
                  Status
                  <SortIcon field="status" />
                </button>
              </th>
              <th className="text-left px-4 py-3">
                <button
                  onClick={() => handleSort("clientName")}
                  className="flex items-center gap-1 text-xs font-medium text-gray-500 uppercase tracking-wider hover:text-gray-700"
                >
                  Customer Name
                  <SortIcon field="clientName" />
                </button>
              </th>
              <th className="text-left px-4 py-3">
                <button
                  onClick={() => handleSort("createdAt")}
                  className="flex items-center gap-1 text-xs font-medium text-gray-500 uppercase tracking-wider hover:text-gray-700"
                >
                  Date Created
                  <SortIcon field="createdAt" />
                </button>
              </th>
              <th className="text-left px-4 py-3">
                <button
                  onClick={() => handleSort("dueDate")}
                  className="flex items-center gap-1 text-xs font-medium text-gray-500 uppercase tracking-wider hover:text-gray-700"
                >
                  Due Date
                  <SortIcon field="dueDate" />
                </button>
              </th>
              <th className="w-12 px-4 py-3"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 bg-white">
            {filteredAndSortedInvoices.length === 0 ? (
              <tr>
                <td colSpan={7} className="px-4 py-12 text-center text-gray-500">
                  <p className="text-lg font-medium mb-1">No invoices found</p>
                  <p className="text-sm">
                    {activeTab !== "all"
                      ? "Try changing the filter or "
                      : ""}
                    <Link href="/invoices/new" className="text-indigo-600 hover:underline">
                      create a new invoice
                    </Link>
                  </p>
                </td>
              </tr>
            ) : (
              filteredAndSortedInvoices.map((invoice) => (
                <tr
                  key={invoice.id}
                  className="hover:bg-indigo-50/50 cursor-pointer transition-colors group"
                  onClick={() => router.push(`/invoices/${invoice.id}`)}
                >
                  <td className="px-4 py-4">
                    <span className="text-sm font-medium text-indigo-600 group-hover:text-indigo-700">
                      {invoice.invoiceNumber}
                    </span>
                  </td>
                  <td className="px-4 py-4">
                    <span className="text-sm font-medium text-gray-900">
                      {formatCurrency(invoice.total)}
                    </span>
                  </td>
                  <td className="px-4 py-4">
                    <StatusBadge invoice={invoice} />
                  </td>
                  <td className="px-4 py-4">
                    <div>
                      <span className="text-sm font-medium text-gray-900">{invoice.clientName}</span>
                      <p className="text-xs text-gray-500">{invoice.clientEmail}</p>
                    </div>
                  </td>
                  <td className="px-4 py-4">
                    <span className="text-sm text-gray-600">
                      {formatDate(invoice.createdAt)}
                    </span>
                  </td>
                  <td className="px-4 py-4">
                    <span className="text-sm text-gray-600">
                      {invoice.dueDate ? formatDate(invoice.dueDate) : "—"}
                    </span>
                  </td>
                  <td className="px-4 py-4">
                    <button
                      className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 opacity-0 group-hover:opacity-100 transition-all"
                      onClick={(e) => {
                        e.stopPropagation();
                      }}
                    >
                      <MoreHorizontal className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Footer */}
      <div className="mt-4 flex items-center justify-between text-sm text-gray-500">
        <p>
          Showing {filteredAndSortedInvoices.length} of {invoices.length} invoices
        </p>
      </div>
    </div>
  );
}
