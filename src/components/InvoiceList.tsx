"use client";

import Link from "next/link";
import { Invoice } from "@/types/invoice";
import { formatCurrency, formatDate } from "@/lib/utils";
import {
  Eye,
  Mail,
  FileText,
  CheckCircle,
  Clock,
  Send,
  MoreHorizontal,
  Paperclip,
} from "lucide-react";

interface InvoiceListProps {
  invoices: Invoice[];
}

const getStatusConfig = (status: string) => {
  switch (status) {
    case "draft":
      return {
        icon: Clock,
        bg: "bg-amber-50",
        text: "text-amber-600",
        border: "border-amber-200",
        label: "Draft",
      };
    case "sent":
      return {
        icon: Send,
        bg: "bg-blue-50",
        text: "text-blue-600",
        border: "border-blue-200",
        label: "Sent",
      };
    case "paid":
      return {
        icon: CheckCircle,
        bg: "bg-emerald-50",
        text: "text-emerald-600",
        border: "border-emerald-200",
        label: "Paid",
      };
    default:
      return {
        icon: Clock,
        bg: "bg-slate-50",
        text: "text-slate-600",
        border: "border-slate-200",
        label: status,
      };
  }
};

export default function InvoiceList({ invoices }: InvoiceListProps) {
  if (invoices.length === 0) {
    return (
      <div className="text-center py-16">
        <div className="w-16 h-16 bg-slate-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
          <FileText className="w-8 h-8 text-slate-400" />
        </div>
        <h3 className="text-lg font-semibold text-slate-900 mb-2">
          No invoices found
        </h3>
        <p className="text-slate-500 mb-6 max-w-sm mx-auto">
          Create your first invoice to start tracking your revenue.
        </p>
        <Link
          href="/invoices/new"
          className="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl hover:from-blue-600 hover:to-blue-700 transition-all shadow-lg shadow-blue-500/25 font-medium text-sm"
        >
          Create Invoice
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {invoices.map((invoice) => {
        const statusConfig = getStatusConfig(invoice.status);
        const StatusIcon = statusConfig.icon;

        return (
          <Link
            key={invoice.id}
            href={`/invoices/${invoice.id}`}
            className="block bg-white rounded-xl border border-slate-200 p-4 hover:border-slate-300 hover:shadow-md transition-all group"
          >
            <div className="flex items-center gap-4">
              {/* Invoice Number & Status */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-3 mb-1">
                  <span className="font-semibold text-slate-900">
                    {invoice.invoiceNumber}
                  </span>
                  <span
                    className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium ${statusConfig.bg} ${statusConfig.text} border ${statusConfig.border}`}
                  >
                    <StatusIcon className="w-3 h-3" />
                    {statusConfig.label}
                  </span>
                </div>
                <div className="flex items-center gap-2 text-sm text-slate-500">
                  <span className="font-medium text-slate-700">
                    {invoice.clientName}
                  </span>
                  <span className="text-slate-300">|</span>
                  <span>{invoice.clientEmail}</span>
                </div>
              </div>

              {/* Amount */}
              <div className="text-right">
                <p className="text-lg font-bold text-slate-900">
                  {formatCurrency(invoice.total)}
                </p>
                <p className="text-xs text-slate-400">
                  {invoice.dueDate ? `Due ${formatDate(invoice.dueDate)}` : "No due date"}
                </p>
              </div>

              {/* Indicators */}
              <div className="flex items-center gap-2">
                {invoice.emailSentAt && (
                  <div
                    className="w-8 h-8 bg-emerald-50 rounded-lg flex items-center justify-center"
                    title={`Sent on ${formatDate(invoice.emailSentAt)}`}
                  >
                    <Mail className="w-4 h-4 text-emerald-500" />
                  </div>
                )}
                {invoice.receipts.length > 0 && (
                  <div
                    className="w-8 h-8 bg-slate-100 rounded-lg flex items-center justify-center"
                    title={`${invoice.receipts.length} attachment(s)`}
                  >
                    <Paperclip className="w-4 h-4 text-slate-500" />
                  </div>
                )}
                <div className="w-8 h-8 bg-slate-100 rounded-lg flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <Eye className="w-4 h-4 text-slate-500" />
                </div>
              </div>
            </div>

            {/* Mobile Layout - Additional Info */}
            <div className="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between text-xs text-slate-400 sm:hidden">
              <span>Created {formatDate(invoice.createdAt)}</span>
              <span>{invoice.items.length} item(s)</span>
            </div>
          </Link>
        );
      })}
    </div>
  );
}
