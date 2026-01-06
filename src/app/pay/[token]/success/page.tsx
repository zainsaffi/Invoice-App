"use client";

import { useEffect, useState } from "react";
import { useParams, useSearchParams } from "next/navigation";
import Link from "next/link";

interface InvoiceData {
  invoiceNumber: string;
  clientName: string;
  total: number;
  status: string;
  paidAt: string | null;
  user: {
    businessName: string | null;
  };
}

export default function PaymentSuccessPage() {
  const params = useParams();
  const searchParams = useSearchParams();
  const token = params.token as string;
  const sessionId = searchParams.get("session_id");

  const [invoice, setInvoice] = useState<InvoiceData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchInvoice() {
      try {
        const response = await fetch(`/api/pay/${token}`);
        if (!response.ok) {
          const data = await response.json();
          throw new Error(data.error || "Failed to load invoice");
        }
        const data = await response.json();
        setInvoice(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : "An error occurred");
      } finally {
        setLoading(false);
      }
    }

    if (token) {
      fetchInvoice();
    }
  }, [token]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading payment details...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg
              className="w-8 h-8 text-red-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </div>
          <h1 className="text-xl font-semibold text-gray-900 mb-2">
            Something went wrong
          </h1>
          <p className="text-gray-600 mb-6">{error}</p>
          <Link
            href={`/pay/${token}`}
            className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Back to Invoice
          </Link>
        </div>
      </div>
    );
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(amount);
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
        {/* Success Icon */}
        <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <svg
            className="w-10 h-10 text-green-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>

        {/* Success Message */}
        <h1 className="text-2xl font-bold text-gray-900 mb-2">
          Payment Successful!
        </h1>
        <p className="text-gray-600 mb-6">
          Thank you for your payment. Your transaction has been completed.
        </p>

        {/* Invoice Details */}
        {invoice && (
          <div className="bg-gray-50 rounded-lg p-6 mb-6 text-left">
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-500">Invoice</span>
                <span className="font-medium text-gray-900">
                  {invoice.invoiceNumber}
                </span>
              </div>
              {invoice.user?.businessName && (
                <div className="flex justify-between">
                  <span className="text-gray-500">From</span>
                  <span className="font-medium text-gray-900">
                    {invoice.user.businessName}
                  </span>
                </div>
              )}
              <div className="flex justify-between">
                <span className="text-gray-500">Amount Paid</span>
                <span className="font-semibold text-green-600">
                  {formatCurrency(invoice.total)}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Status</span>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  {invoice.status === "paid" ? "Paid" : "Processing"}
                </span>
              </div>
            </div>
          </div>
        )}

        {/* Confirmation Note */}
        <p className="text-sm text-gray-500 mb-6">
          A confirmation email will be sent to you shortly. If you have any
          questions, please contact the business directly.
        </p>

        {/* Session ID for reference */}
        {sessionId && (
          <p className="text-xs text-gray-400 mb-4">
            Reference: {sessionId.substring(0, 20)}...
          </p>
        )}

        {/* Actions */}
        <div className="space-y-3">
          <Link
            href={`/pay/${token}`}
            className="block w-full bg-gray-100 text-gray-700 px-6 py-3 rounded-lg hover:bg-gray-200 transition-colors"
          >
            View Invoice
          </Link>
        </div>
      </div>
    </div>
  );
}
