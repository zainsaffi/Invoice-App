"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import { FileText, CreditCard, Building2, CheckCircle, XCircle, Clock, AlertCircle } from "lucide-react";

interface InvoiceItem {
  id: string;
  description: string;
  quantity: number;
  unitPrice: number;
  total: number;
}

interface Invoice {
  id: string;
  invoiceNumber: string;
  clientName: string;
  clientEmail: string;
  description: string;
  items: InvoiceItem[];
  subtotal: number;
  tax: number;
  total: number;
  status: string;
  dueDate: string | null;
  createdAt: string;
  user: {
    businessName: string | null;
    businessEmail: string | null;
    businessPhone: string | null;
    businessAddress: string | null;
  };
}

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(amount);
}

function formatDate(date: string | null): string {
  if (!date) return "-";
  return new Date(date).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

export default function PaymentPage() {
  const params = useParams();
  const token = params.token as string;

  const [invoice, setInvoice] = useState<Invoice | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [processingPayment, setProcessingPayment] = useState(false);

  useEffect(() => {
    const fetchInvoice = async () => {
      try {
        const response = await fetch(`/api/pay/${token}`);
        const data = await response.json();

        if (!response.ok) {
          setError(data.error || "Invoice not found");
          return;
        }

        setInvoice(data);
      } catch {
        setError("Failed to load invoice");
      } finally {
        setLoading(false);
      }
    };

    if (token) {
      fetchInvoice();
    }
  }, [token]);

  const handlePayment = async () => {
    setProcessingPayment(true);
    try {
      const response = await fetch(`/api/pay/${token}/checkout`, {
        method: "POST",
      });
      const data = await response.json();

      if (!response.ok) {
        setError(data.error || "Failed to start payment");
        setProcessingPayment(false);
        return;
      }

      // Redirect to Stripe Checkout
      window.location.href = data.url;
    } catch {
      setError("Failed to process payment");
      setProcessingPayment(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin w-8 h-8 border-4 border-indigo-600 border-t-transparent rounded-full" />
      </div>
    );
  }

  if (error || !invoice) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-lg p-8 text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <XCircle className="w-8 h-8 text-red-600" />
          </div>
          <h1 className="text-xl font-bold text-gray-900 mb-2">Invoice Not Found</h1>
          <p className="text-gray-600">
            {error || "This payment link is invalid or has expired."}
          </p>
        </div>
      </div>
    );
  }

  if (invoice.status === "paid") {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-lg p-8 text-center">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-8 h-8 text-green-600" />
          </div>
          <h1 className="text-xl font-bold text-gray-900 mb-2">Already Paid</h1>
          <p className="text-gray-600 mb-4">
            Invoice {invoice.invoiceNumber} has already been paid.
          </p>
          <p className="text-2xl font-bold text-green-600">{formatCurrency(invoice.total)}</p>
        </div>
      </div>
    );
  }

  if (invoice.status === "cancelled") {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-lg p-8 text-center">
          <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <AlertCircle className="w-8 h-8 text-gray-600" />
          </div>
          <h1 className="text-xl font-bold text-gray-900 mb-2">Invoice Cancelled</h1>
          <p className="text-gray-600">
            This invoice has been cancelled and cannot be paid.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8 px-4">
      <div className="max-w-2xl mx-auto">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-14 h-14 bg-indigo-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <FileText className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">
            {invoice.user.businessName || "Sosocial Invoice"}
          </h1>
          <p className="text-gray-500 mt-1">Invoice {invoice.invoiceNumber}</p>
        </div>

        {/* Invoice Card */}
        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          {/* Bill To */}
          <div className="p-6 border-b border-gray-100">
            <div className="grid grid-cols-2 gap-6">
              <div>
                <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Bill To</p>
                <p className="font-semibold text-gray-900">{invoice.clientName}</p>
                <p className="text-sm text-gray-500">{invoice.clientEmail}</p>
              </div>
              <div className="text-right">
                <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Invoice Date</p>
                <p className="text-gray-900">{formatDate(invoice.createdAt)}</p>
                {invoice.dueDate && (
                  <>
                    <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mt-3 mb-2">Due Date</p>
                    <p className="text-gray-900 flex items-center justify-end gap-1">
                      <Clock className="w-4 h-4" />
                      {formatDate(invoice.dueDate)}
                    </p>
                  </>
                )}
              </div>
            </div>
          </div>

          {/* Description */}
          {invoice.description && (
            <div className="px-6 py-4 bg-gray-50 border-b border-gray-100">
              <p className="text-sm text-gray-600">{invoice.description}</p>
            </div>
          )}

          {/* Items */}
          <div className="p-6">
            <table className="w-full">
              <thead>
                <tr className="text-xs font-semibold text-gray-400 uppercase tracking-wider">
                  <th className="text-left pb-3">Item</th>
                  <th className="text-right pb-3">Qty</th>
                  <th className="text-right pb-3">Price</th>
                  <th className="text-right pb-3">Total</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {invoice.items.map((item) => (
                  <tr key={item.id}>
                    <td className="py-3 text-gray-900">{item.description}</td>
                    <td className="py-3 text-right text-gray-600">{item.quantity}</td>
                    <td className="py-3 text-right text-gray-600">{formatCurrency(item.unitPrice)}</td>
                    <td className="py-3 text-right font-medium text-gray-900">{formatCurrency(item.total)}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* Totals */}
            <div className="mt-6 pt-6 border-t border-gray-200">
              <div className="flex justify-between text-sm mb-2">
                <span className="text-gray-500">Subtotal</span>
                <span className="text-gray-900">{formatCurrency(invoice.subtotal)}</span>
              </div>
              {invoice.tax > 0 && (
                <div className="flex justify-between text-sm mb-2">
                  <span className="text-gray-500">Tax</span>
                  <span className="text-gray-900">{formatCurrency(invoice.tax)}</span>
                </div>
              )}
              <div className="flex justify-between text-lg font-bold mt-4 pt-4 border-t border-gray-200">
                <span className="text-gray-900">Total Due</span>
                <span className="text-indigo-600">{formatCurrency(invoice.total)}</span>
              </div>
            </div>
          </div>

          {/* Payment Button */}
          <div className="p-6 bg-gray-50 border-t border-gray-100">
            <button
              onClick={handlePayment}
              disabled={processingPayment}
              className="w-full flex items-center justify-center gap-3 px-6 py-4 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors shadow-lg shadow-indigo-500/25"
            >
              {processingPayment ? (
                <>
                  <svg className="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                  </svg>
                  Processing...
                </>
              ) : (
                <>
                  <CreditCard className="w-5 h-5" />
                  Pay {formatCurrency(invoice.total)}
                </>
              )}
            </button>

            <div className="mt-4 flex items-center justify-center gap-4 text-xs text-gray-400">
              <div className="flex items-center gap-1">
                <CreditCard className="w-4 h-4" />
                <span>Credit Card</span>
              </div>
              <div className="flex items-center gap-1">
                <Building2 className="w-4 h-4" />
                <span>Bank Transfer</span>
              </div>
            </div>

            <p className="text-center text-xs text-gray-400 mt-4">
              Secure payment powered by Stripe
            </p>
          </div>
        </div>

        {/* From Business */}
        {invoice.user.businessName && (
          <div className="mt-6 text-center text-sm text-gray-500">
            <p>Invoice from <span className="font-medium text-gray-700">{invoice.user.businessName}</span></p>
            {invoice.user.businessEmail && (
              <p className="mt-1">{invoice.user.businessEmail}</p>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
