"use client";

import { useState, useMemo } from "react";
import { Search, X, SlidersHorizontal, ChevronDown } from "lucide-react";
import { Invoice } from "@/types/invoice";
import InvoiceList from "./InvoiceList";

interface InvoiceFiltersProps {
  invoices: Invoice[];
}

export default function InvoiceFilters({ invoices }: InvoiceFiltersProps) {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [clientFilter, setClientFilter] = useState<string>("all");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [showFilters, setShowFilters] = useState(false);

  const uniqueClients = useMemo(() => {
    const clients = [...new Set(invoices.map((inv) => inv.clientName))];
    return clients.sort();
  }, [invoices]);

  const filteredInvoices = useMemo(() => {
    return invoices.filter((invoice) => {
      if (search) {
        const searchLower = search.toLowerCase();
        const matchesSearch =
          invoice.invoiceNumber.toLowerCase().includes(searchLower) ||
          invoice.clientName.toLowerCase().includes(searchLower) ||
          invoice.clientEmail.toLowerCase().includes(searchLower) ||
          invoice.description.toLowerCase().includes(searchLower);
        if (!matchesSearch) return false;
      }

      if (statusFilter !== "all" && invoice.status !== statusFilter) {
        return false;
      }

      if (clientFilter !== "all" && invoice.clientName !== clientFilter) {
        return false;
      }

      if (dateFrom) {
        const invoiceDate = new Date(invoice.createdAt);
        const fromDate = new Date(dateFrom);
        if (invoiceDate < fromDate) return false;
      }

      if (dateTo) {
        const invoiceDate = new Date(invoice.createdAt);
        const toDate = new Date(dateTo);
        toDate.setHours(23, 59, 59, 999);
        if (invoiceDate > toDate) return false;
      }

      return true;
    });
  }, [invoices, search, statusFilter, clientFilter, dateFrom, dateTo]);

  const clearFilters = () => {
    setSearch("");
    setStatusFilter("all");
    setClientFilter("all");
    setDateFrom("");
    setDateTo("");
  };

  const hasActiveFilters =
    search ||
    statusFilter !== "all" ||
    clientFilter !== "all" ||
    dateFrom ||
    dateTo;

  const activeFilterCount = [
    search,
    statusFilter !== "all",
    clientFilter !== "all",
    dateFrom,
    dateTo,
  ].filter(Boolean).length;

  return (
    <div className="space-y-4">
      {/* Search and Filter Toggle */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-slate-400" />
          <input
            type="text"
            placeholder="Search invoices..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-slate-900 placeholder:text-slate-400"
          />
          {search && (
            <button
              onClick={() => setSearch("")}
              className="absolute right-4 top-1/2 transform -translate-y-1/2 text-slate-400 hover:text-slate-600"
            >
              <X className="w-4 h-4" />
            </button>
          )}
        </div>

        <button
          onClick={() => setShowFilters(!showFilters)}
          className={`flex items-center gap-2 px-5 py-3 rounded-xl border transition-all font-medium text-sm ${
            showFilters || hasActiveFilters
              ? "bg-blue-50 border-blue-200 text-blue-600"
              : "bg-white border-slate-200 text-slate-600 hover:bg-slate-50"
          }`}
        >
          <SlidersHorizontal className="w-4 h-4" />
          Filters
          {activeFilterCount > 0 && (
            <span className="w-5 h-5 bg-blue-500 text-white text-xs rounded-full flex items-center justify-center">
              {activeFilterCount}
            </span>
          )}
          <ChevronDown
            className={`w-4 h-4 transition-transform ${
              showFilters ? "rotate-180" : ""
            }`}
          />
        </button>
      </div>

      {/* Expanded Filters */}
      {showFilters && (
        <div className="bg-slate-50 rounded-xl p-4 border border-slate-200 animate-in slide-in-from-top-2 duration-200">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                Status
              </label>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-slate-900"
              >
                <option value="all">All Statuses</option>
                <option value="draft">Draft</option>
                <option value="sent">Sent</option>
                <option value="paid">Paid</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                Client
              </label>
              <select
                value={clientFilter}
                onChange={(e) => setClientFilter(e.target.value)}
                className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-slate-900"
              >
                <option value="all">All Clients</option>
                {uniqueClients.map((client) => (
                  <option key={client} value={client}>
                    {client}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                From Date
              </label>
              <input
                type="date"
                value={dateFrom}
                onChange={(e) => setDateFrom(e.target.value)}
                className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-slate-900"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                To Date
              </label>
              <input
                type="date"
                value={dateTo}
                onChange={(e) => setDateTo(e.target.value)}
                className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-slate-900"
              />
            </div>
          </div>

          {hasActiveFilters && (
            <div className="mt-4 pt-4 border-t border-slate-200 flex items-center justify-between">
              <p className="text-sm text-slate-500">
                {filteredInvoices.length} of {invoices.length} invoices
              </p>
              <button
                onClick={clearFilters}
                className="text-sm text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1"
              >
                <X className="w-4 h-4" />
                Clear all filters
              </button>
            </div>
          )}
        </div>
      )}

      {/* Results Info */}
      {!showFilters && hasActiveFilters && (
        <div className="flex items-center justify-between text-sm">
          <p className="text-slate-500">
            Showing {filteredInvoices.length} of {invoices.length} invoices
          </p>
          <button
            onClick={clearFilters}
            className="text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1"
          >
            <X className="w-4 h-4" />
            Clear filters
          </button>
        </div>
      )}

      {/* Invoice List */}
      <InvoiceList invoices={filteredInvoices} />
    </div>
  );
}
