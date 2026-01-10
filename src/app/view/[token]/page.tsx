"use client";

import { useEffect, useState, use } from "react";
import Link from "next/link";
import { FileText, Calendar, CreditCard, CheckCircle, Clock, AlertCircle, Download } from "lucide-react";

interface InvoiceItem {
  id: string;
  title: string;
  description: string;
  quantity: number;
  unitPrice: number;
  total: number;
}

interface PublicInvoice {
  id: string;
  invoiceNumber: string;
  clientName: string;
  clientEmail: string;
  clientBusinessName: string | null;
  clientAddress: string | null;
  description: string;
  items: InvoiceItem[];
  subtotal: number;
  tax: number;
  total: number;
  status: string;
  amountPaid: number;
  dueDate: string | null;
  paymentInstructions: string | null;
  paymentToken: string | null;
  createdAt: string;
  business: {
    name: string | null;
    email: string | null;
    phone: string | null;
    address: string | null;
  } | null;
}

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(amount);
}

function formatDate(date: string | Date): string {
  return new Date(date).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

export default function PublicInvoicePage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = use(params);
  const [invoice, setInvoice] = useState<PublicInvoice | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchInvoice = async () => {
      try {
        const response = await fetch(`/api/public/invoice/${token}`);
        if (response.ok) {
          const data = await response.json();
          setInvoice(data);
        } else {
          setError("Invoice not found or has expired.");
        }
      } catch (err) {
        setError("Failed to load invoice. Please try again.");
      } finally {
        setIsLoading(false);
      }
    };

    fetchInvoice();
  }, [token]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-center">
          <div className="w-10 h-10 border-3 border-indigo-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-500">Loading invoice...</p>
        </div>
      </div>
    );
  }

  if (error || !invoice) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-center bg-white rounded-2xl p-8 shadow-sm max-w-md mx-4">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <AlertCircle className="w-8 h-8 text-red-500" />
          </div>
          <h1 className="text-xl font-semibold text-gray-900 mb-2">Invoice Not Found</h1>
          <p className="text-gray-500">{error || "The invoice you're looking for doesn't exist or has been removed."}</p>
        </div>
      </div>
    );
  }

  const isPaid = invoice.amountPaid >= invoice.total;
  const isPartiallyPaid = invoice.amountPaid > 0 && invoice.amountPaid < invoice.total;
  const remaining = invoice.total - invoice.amountPaid;

  return (
    <div className="min-h-screen bg-gray-100 py-8">
      <div className="max-w-3xl mx-auto px-4">
        {/* Header */}
        <div className="bg-white rounded-2xl shadow-sm overflow-hidden mb-6">
          <div className="bg-gradient-to-r from-indigo-600 to-indigo-700 px-8 py-6">
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-2xl font-bold text-white">Invoice</h1>
                <p className="text-indigo-200 mt-1">{invoice.invoiceNumber}</p>
              </div>
              <div className="text-right">
                {isPaid ? (
                  <span className="inline-flex items-center gap-2 px-4 py-2 bg-green-500 text-white rounded-full text-sm font-semibold">
                    <CheckCircle className="w-4 h-4" />
                    Paid
                  </span>
                ) : isPartiallyPaid ? (
                  <span className="inline-flex items-center gap-2 px-4 py-2 bg-yellow-500 text-white rounded-full text-sm font-semibold">
                    <Clock className="w-4 h-4" />
                    Partially Paid
                  </span>
                ) : (
                  <span className="inline-flex items-center gap-2 px-4 py-2 bg-white/20 text-white rounded-full text-sm font-semibold">
                    <Clock className="w-4 h-4" />
                    Awaiting Payment
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Business & Client Info */}
          <div className="px-8 py-6 grid grid-cols-2 gap-8 border-b border-gray-100">
            <div>
              <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">From</p>
              {invoice.business?.name && (
                <p className="text-lg font-semibold text-gray-900">{invoice.business.name}</p>
              )}
              {invoice.business?.email && (
                <p className="text-sm text-gray-600">{invoice.business.email}</p>
              )}
              {invoice.business?.phone && (
                <p className="text-sm text-gray-600">{invoice.business.phone}</p>
              )}
              {invoice.business?.address && (
                <p className="text-sm text-gray-600 whitespace-pre-line mt-1">{invoice.business.address}</p>
              )}
            </div>
            <div>
              <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Bill To</p>
              <p className="text-lg font-semibold text-gray-900">{invoice.clientName}</p>
              <p className="text-sm text-gray-600">{invoice.clientEmail}</p>
              {invoice.clientBusinessName && (
                <p className="text-sm text-gray-600">{invoice.clientBusinessName}</p>
              )}
              {invoice.clientAddress && (
                <p className="text-sm text-gray-600 whitespace-pre-line mt-1">{invoice.clientAddress}</p>
              )}
            </div>
          </div>

          {/* Invoice Details */}
          <div className="px-8 py-4 flex gap-8 border-b border-gray-100 bg-gray-50">
            <div>
              <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide">Invoice Date</p>
              <p className="text-sm font-medium text-gray-900 mt-1">{formatDate(invoice.createdAt)}</p>
            </div>
            {invoice.dueDate && (
              <div>
                <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide">Due Date</p>
                <p className="text-sm font-medium text-gray-900 mt-1">{formatDate(invoice.dueDate)}</p>
              </div>
            )}
            <div>
              <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide">Amount Due</p>
              <p className="text-sm font-bold text-indigo-600 mt-1">{formatCurrency(remaining)}</p>
            </div>
          </div>

          {/* Line Items */}
          <div className="px-8 py-6">
            <table className="w-full">
              <thead>
                <tr className="text-xs font-semibold text-gray-400 uppercase tracking-wide border-b border-gray-200">
                  <th className="text-left py-3">Description</th>
                  <th className="text-right py-3 w-20">Qty</th>
                  <th className="text-right py-3 w-28">Price</th>
                  <th className="text-right py-3 w-28">Total</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {invoice.items.map((item) => (
                  <tr key={item.id}>
                    <td className="py-4">
                      <p className="font-medium text-gray-900">{item.title}</p>
                      {item.description && (
                        <p className="text-sm text-gray-500 mt-1 whitespace-pre-line">{item.description}</p>
                      )}
                    </td>
                    <td className="py-4 text-right text-gray-600">{item.quantity}</td>
                    <td className="py-4 text-right text-gray-600">{formatCurrency(item.unitPrice)}</td>
                    <td className="py-4 text-right font-medium text-gray-900">{formatCurrency(item.total)}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* Totals */}
            <div className="mt-6 border-t border-gray-200 pt-6">
              <div className="flex justify-end">
                <div className="w-64 space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Subtotal</span>
                    <span className="text-gray-900">{formatCurrency(invoice.subtotal)}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">Tax</span>
                    <span className="text-gray-900">{formatCurrency(invoice.tax)}</span>
                  </div>
                  <div className="flex justify-between text-sm border-t border-gray-200 pt-2">
                    <span className="text-gray-900 font-medium">Total</span>
                    <span className="text-gray-900 font-bold">{formatCurrency(invoice.total)}</span>
                  </div>
                  {invoice.amountPaid > 0 && (
                    <>
                      <div className="flex justify-between text-sm text-green-600">
                        <span>Paid</span>
                        <span>-{formatCurrency(invoice.amountPaid)}</span>
                      </div>
                      <div className="flex justify-between text-lg font-bold border-t border-gray-200 pt-2">
                        <span className="text-gray-900">Amount Due</span>
                        <span className="text-indigo-600">{formatCurrency(remaining)}</span>
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Payment Instructions */}
        {invoice.paymentInstructions && !isPaid && (
          <div className="bg-white rounded-2xl shadow-sm p-6 mb-6">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-amber-100 rounded-xl flex items-center justify-center">
                <CreditCard className="w-5 h-5 text-amber-600" />
              </div>
              <h2 className="text-lg font-semibold text-gray-900">Payment Instructions</h2>
            </div>
            <div className="bg-amber-50 rounded-xl p-4 border border-amber-100">
              <p className="text-gray-700 whitespace-pre-line">{invoice.paymentInstructions}</p>
            </div>
          </div>
        )}

        {/* Pay Now Button */}
        {!isPaid && invoice.paymentToken && (
          <div className="bg-white rounded-2xl shadow-sm p-6 text-center">
            <p className="text-gray-600 mb-4">Ready to pay? Click below to complete your payment securely.</p>
            <Link
              href={`/pay/${invoice.paymentToken}`}
              className="inline-flex items-center gap-2 px-8 py-3 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 transition-colors shadow-lg shadow-indigo-500/25"
            >
              <CreditCard className="w-5 h-5" />
              Pay {formatCurrency(remaining)} Now
            </Link>
          </div>
        )}

        {/* Footer */}
        <p className="text-center text-gray-400 text-sm mt-8">
          This invoice was generated by Sosocial Invoice
        </p>
      </div>
    </div>
  );
}
