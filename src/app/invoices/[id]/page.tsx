"use client";

import { useEffect, useState, use } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import Sidebar from "@/components/Sidebar";
import { Invoice } from "@/types/invoice";
import { formatCurrency, formatDate, getDisplayStatus, getDisplayStatusBadge } from "@/lib/utils";
import {
  ArrowLeft,
  Send,
  Edit,
  Trash2,
  XCircle,
  Mail,
  Calendar,
  CreditCard,
  Upload,
  Download,
  X,
  FileText,
  User,
  Paperclip,
  Clock,
} from "lucide-react";

export default function InvoiceDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const router = useRouter();
  const [invoice, setInvoice] = useState<Invoice | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSending, setIsSending] = useState(false);
  const [isCancelling, setIsCancelling] = useState(false);
  const [isDownloading, setIsDownloading] = useState(false);

  const fetchInvoice = async () => {
    try {
      const response = await fetch(`/api/invoices/${id}`);
      if (response.ok) {
        const data = await response.json();
        setInvoice(data);
      }
    } catch (error) {
      console.error("Error fetching invoice:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchInvoice();
  }, [id]);

  const handleSendEmail = async () => {
    if (!invoice) return;
    if (!confirm(`Send invoice to ${invoice.clientEmail}?`)) return;

    setIsSending(true);
    try {
      const response = await fetch(`/api/invoices/${id}/send`, {
        method: "POST",
      });

      if (response.ok) {
        const updatedInvoice = await response.json();
        setInvoice({ ...invoice, ...updatedInvoice });
        alert("Invoice sent successfully!");
      } else {
        alert("Failed to send invoice. Please check your email configuration.");
      }
    } catch (error) {
      console.error("Error sending invoice:", error);
      alert("Failed to send invoice");
    } finally {
      setIsSending(false);
    }
  };

  const handleDownloadPdf = async () => {
    if (!invoice) return;

    setIsDownloading(true);
    try {
      const response = await fetch(`/api/invoices/${id}/pdf`);

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `${invoice.invoiceNumber}.pdf`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      } else {
        alert("Failed to generate PDF");
      }
    } catch (error) {
      console.error("Error downloading PDF:", error);
      alert("Failed to download PDF");
    } finally {
      setIsDownloading(false);
    }
  };

  const handleDelete = async () => {
    if (!invoice) return;
    if (!confirm("Are you sure you want to delete this invoice?")) return;

    try {
      const response = await fetch(`/api/invoices/${id}`, {
        method: "DELETE",
      });

      if (response.ok) {
        router.push("/");
      } else {
        alert("Failed to delete invoice");
      }
    } catch (error) {
      console.error("Error deleting invoice:", error);
      alert("Failed to delete invoice");
    }
  };

  const handleCancel = async () => {
    if (!invoice) return;
    if (!confirm("Are you sure you want to cancel this invoice? This action cannot be undone.")) return;

    setIsCancelling(true);
    try {
      const response = await fetch(`/api/invoices/${id}/cancel`, {
        method: "POST",
      });

      if (response.ok) {
        const updatedInvoice = await response.json();
        setInvoice({ ...invoice, ...updatedInvoice });
        alert("Invoice cancelled successfully!");
      } else {
        alert("Failed to cancel invoice");
      }
    } catch (error) {
      console.error("Error cancelling invoice:", error);
      alert("Failed to cancel invoice");
    } finally {
      setIsCancelling(false);
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const formData = new FormData();
    formData.append("file", file);

    try {
      const response = await fetch(`/api/invoices/${id}/receipts`, {
        method: "POST",
        body: formData,
      });

      if (response.ok) {
        fetchInvoice();
      } else {
        alert("Failed to upload file");
      }
    } catch (error) {
      console.error("Error uploading file:", error);
      alert("Failed to upload file");
    }
  };

  const handleDeleteReceipt = async (receiptId: string) => {
    if (!confirm("Delete this attachment?")) return;

    try {
      const response = await fetch(
        `/api/invoices/${id}/receipts?receiptId=${receiptId}`,
        { method: "DELETE" }
      );

      if (response.ok) {
        fetchInvoice();
      } else {
        alert("Failed to delete attachment");
      }
    } catch (error) {
      console.error("Error deleting attachment:", error);
    }
  };

  const getStatusBadge = () => {
    if (!invoice) return null;
    const displayStatus = getDisplayStatus(invoice);
    const badge = getDisplayStatusBadge(displayStatus);

    return (
      <span className={`px-3 py-1 text-xs font-semibold rounded-full ${badge.bg} ${badge.text}`}>
        {badge.label}
      </span>
    );
  };

  // Get computed display status for conditional rendering
  const displayStatus = invoice ? getDisplayStatus(invoice) : null;

  if (isLoading) {
    return (
      <div className="flex min-h-screen bg-gray-50">
        <Sidebar />
        <main className="flex-1 ml-64 flex items-center justify-center">
          <div className="text-center">
            <div className="w-8 h-8 border-2 border-indigo-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
            <p className="text-gray-500">Loading invoice...</p>
          </div>
        </main>
      </div>
    );
  }

  if (!invoice) {
    return (
      <div className="flex min-h-screen bg-gray-50">
        <Sidebar />
        <main className="flex-1 ml-64 flex items-center justify-center">
          <div className="text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <FileText className="w-8 h-8 text-gray-400" />
            </div>
            <p className="text-gray-900 font-medium mb-2">Invoice not found</p>
            <p className="text-gray-500 text-sm mb-4">The invoice you're looking for doesn't exist.</p>
            <Link
              href="/"
              className="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 transition-colors"
            >
              <ArrowLeft className="w-4 h-4" />
              Back to Invoices
            </Link>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-4">
              <Link
                href="/"
                className="p-2 text-gray-400 hover:text-gray-600 hover:bg-white rounded-lg transition-colors border border-transparent hover:border-gray-200 hover:shadow-sm"
              >
                <ArrowLeft className="w-5 h-5" />
              </Link>
              <div>
                <div className="flex items-center gap-3">
                  <h1 className="text-2xl font-bold text-gray-900">
                    {invoice.invoiceNumber}
                  </h1>
                  {getStatusBadge()}
                </div>
                <p className="text-gray-500 mt-0.5">{invoice.description}</p>
              </div>
            </div>

            <div className="flex items-center gap-3">
              {displayStatus === "draft" && (
                <button
                  onClick={handleSendEmail}
                  disabled={isSending}
                  className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 text-white text-sm font-medium rounded-xl hover:bg-indigo-700 disabled:opacity-50 transition-colors shadow-lg shadow-indigo-500/25"
                >
                  <Send className="w-4 h-4" />
                  {isSending ? "Sending..." : "Send Invoice"}
                </button>
              )}
              <button
                onClick={handleDownloadPdf}
                disabled={isDownloading}
                className="flex items-center gap-2 px-4 py-2.5 bg-emerald-600 text-white text-sm font-medium rounded-xl hover:bg-emerald-700 disabled:opacity-50 transition-colors shadow-lg shadow-emerald-500/25"
              >
                <Download className="w-4 h-4" />
                {isDownloading ? "Generating..." : "Download PDF"}
              </button>
              {displayStatus !== "paid" && displayStatus !== "cancelled" && (
                <button
                  onClick={handleCancel}
                  disabled={isCancelling}
                  className="flex items-center gap-2 px-4 py-2.5 bg-white border border-gray-200 text-orange-600 text-sm font-medium rounded-xl hover:bg-orange-50 hover:border-orange-200 disabled:opacity-50 transition-colors shadow-sm"
                >
                  <XCircle className="w-4 h-4" />
                  {isCancelling ? "Cancelling..." : "Cancel Invoice"}
                </button>
              )}
              {displayStatus !== "cancelled" && (
                <Link
                  href={`/invoices/${id}/edit`}
                  className="flex items-center gap-2 px-4 py-2.5 bg-white border border-gray-200 text-gray-700 text-sm font-medium rounded-xl hover:bg-gray-50 transition-colors shadow-sm"
                >
                  <Edit className="w-4 h-4" />
                  Edit
                </Link>
              )}
              <button
                onClick={handleDelete}
                className="flex items-center gap-2 px-4 py-2.5 bg-white border border-gray-200 text-red-600 text-sm font-medium rounded-xl hover:bg-red-50 hover:border-red-200 transition-colors shadow-sm"
              >
                <Trash2 className="w-4 h-4" />
                Delete
              </button>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-8">
            {/* Main Content */}
            <div className="col-span-2 space-y-6">
              {/* Client Info */}
              <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                    <User className="w-5 h-5 text-blue-600" />
                  </div>
                  <div>
                    <h2 className="text-lg font-semibold text-gray-900">Client Information</h2>
                    <p className="text-sm text-gray-500">Bill to details</p>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-6">
                  <div>
                    <p className="text-sm text-gray-500 mb-1">Name</p>
                    <p className="text-sm font-medium text-gray-900">{invoice.clientName}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500 mb-1">Email</p>
                    <p className="text-sm font-medium text-gray-900">{invoice.clientEmail}</p>
                  </div>
                  {invoice.clientAddress && (
                    <div className="col-span-2">
                      <p className="text-sm text-gray-500 mb-1">Address</p>
                      <p className="text-sm font-medium text-gray-900 whitespace-pre-line">{invoice.clientAddress}</p>
                    </div>
                  )}
                </div>
              </div>

              {/* Line Items */}
              <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-10 h-10 bg-emerald-100 rounded-xl flex items-center justify-center">
                    <FileText className="w-5 h-5 text-emerald-600" />
                  </div>
                  <div>
                    <h2 className="text-lg font-semibold text-gray-900">Line Items</h2>
                    <p className="text-sm text-gray-500">{invoice.items.length} item{invoice.items.length !== 1 ? 's' : ''}</p>
                  </div>
                </div>

                <div className="overflow-hidden rounded-xl border border-gray-200">
                  <table className="w-full">
                    <thead>
                      <tr className="text-xs font-semibold text-gray-500 uppercase bg-gray-50 border-b border-gray-200">
                        <th className="text-left px-4 py-3">Description</th>
                        <th className="text-right px-4 py-3">Qty</th>
                        <th className="text-right px-4 py-3">Price</th>
                        <th className="text-right px-4 py-3">Total</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                      {invoice.items.map((item) => (
                        <tr key={item.id} className="hover:bg-gray-50">
                          <td className="px-4 py-4 text-sm text-gray-900">{item.description}</td>
                          <td className="px-4 py-4 text-sm text-gray-600 text-right">{item.quantity}</td>
                          <td className="px-4 py-4 text-sm text-gray-600 text-right">{formatCurrency(item.unitPrice)}</td>
                          <td className="px-4 py-4 text-sm font-medium text-gray-900 text-right">{formatCurrency(item.total || 0)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div className="mt-6 flex justify-end">
                  <div className="w-72 space-y-3">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-500">Subtotal</span>
                      <span className="font-medium text-gray-900">{formatCurrency(invoice.subtotal)}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-500">Tax</span>
                      <span className="font-medium text-gray-900">{formatCurrency(invoice.tax)}</span>
                    </div>
                    <div className="flex justify-between pt-3 border-t border-gray-200">
                      <span className="font-semibold text-gray-900">Total</span>
                      <span className="text-2xl font-bold text-gray-900">{formatCurrency(invoice.total)}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Attachments */}
              <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center">
                    <Paperclip className="w-5 h-5 text-purple-600" />
                  </div>
                  <div>
                    <h2 className="text-lg font-semibold text-gray-900">Attachments</h2>
                    <p className="text-sm text-gray-500">{invoice.receipts.length} file{invoice.receipts.length !== 1 ? 's' : ''} attached</p>
                  </div>
                </div>

                <label className="flex items-center justify-center w-full h-28 border-2 border-dashed border-gray-200 rounded-xl cursor-pointer hover:border-indigo-300 hover:bg-indigo-50/50 transition-all group">
                  <div className="text-center">
                    <div className="w-10 h-10 bg-gray-100 group-hover:bg-indigo-100 rounded-xl flex items-center justify-center mx-auto mb-2 transition-colors">
                      <Upload className="w-5 h-5 text-gray-400 group-hover:text-indigo-600 transition-colors" />
                    </div>
                    <p className="text-sm font-medium text-gray-700">Drop files here or click to upload</p>
                    <p className="text-xs text-gray-400 mt-1">PDF, PNG, JPG up to 10MB</p>
                  </div>
                  <input
                    type="file"
                    className="hidden"
                    accept=".pdf,.png,.jpg,.jpeg"
                    onChange={handleFileUpload}
                  />
                </label>

                {invoice.receipts.length > 0 && (
                  <div className="mt-4 space-y-2">
                    {invoice.receipts.map((receipt) => (
                      <div
                        key={receipt.id}
                        className="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-100 group hover:bg-gray-100 transition-colors"
                      >
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center border border-gray-200">
                            <FileText className="w-5 h-5 text-gray-400" />
                          </div>
                          <div>
                            <p className="text-sm font-medium text-gray-900">{receipt.filename}</p>
                            <p className="text-xs text-gray-500">
                              {(receipt.size / 1024).toFixed(1)} KB
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                          <a
                            href={receipt.filepath}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-2 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors"
                          >
                            <Download className="w-4 h-4" />
                          </a>
                          <button
                            onClick={() => handleDeleteReceipt(receipt.id)}
                            className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors"
                          >
                            <X className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Sidebar */}
            <div className="col-span-1 space-y-6">
              {/* Timeline */}
              <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center">
                    <Clock className="w-5 h-5 text-orange-600" />
                  </div>
                  <div>
                    <h2 className="text-lg font-semibold text-gray-900">Timeline</h2>
                    <p className="text-sm text-gray-500">Activity history</p>
                  </div>
                </div>
                <div className="space-y-4">
                  <div className="flex items-start gap-3">
                    <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center flex-shrink-0">
                      <Calendar className="w-4 h-4 text-gray-500" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">Created</p>
                      <p className="text-xs text-gray-500">{formatDate(invoice.createdAt)}</p>
                    </div>
                  </div>

                  {invoice.dueDate && (
                    <div className="flex items-start gap-3">
                      <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center flex-shrink-0">
                        <Calendar className="w-4 h-4 text-gray-500" />
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">Due Date</p>
                        <p className="text-xs text-gray-500">{formatDate(invoice.dueDate)}</p>
                      </div>
                    </div>
                  )}

                  {invoice.emailSentAt && (
                    <div className="flex items-start gap-3">
                      <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                        <Mail className="w-4 h-4 text-green-600" />
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">Email Sent</p>
                        <p className="text-xs text-gray-500">{formatDate(invoice.emailSentAt)}</p>
                        <p className="text-xs text-gray-400">to {invoice.emailSentTo}</p>
                      </div>
                    </div>
                  )}

                  {invoice.paidAt && (
                    <div className="flex items-start gap-3">
                      <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                        <CreditCard className="w-4 h-4 text-green-600" />
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">Paid</p>
                        <p className="text-xs text-gray-500">{formatDate(invoice.paidAt)}</p>
                        {invoice.paymentMethod && (
                          <p className="text-xs text-gray-400">via {invoice.paymentMethod}</p>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </div>

              {/* Quick Stats */}
              <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
                <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Stats</h2>
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-500">Line Items</span>
                    <span className="text-sm font-semibold text-gray-900">{invoice.items.length}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-500">Attachments</span>
                    <span className="text-sm font-semibold text-gray-900">{invoice.receipts.length}</span>
                  </div>
                  <div className="pt-4 border-t border-gray-200">
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium text-gray-900">Total Amount</span>
                      <span className="text-xl font-bold text-indigo-600">{formatCurrency(invoice.total)}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
