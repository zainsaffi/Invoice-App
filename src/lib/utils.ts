import { randomBytes } from "crypto";

export function generatePaymentToken(): string {
  // Generate a cryptographically secure 64-character hex token
  return randomBytes(32).toString("hex");
}

export function generateInvoiceNumber(prefix: string = "INV"): string {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const random = Math.floor(Math.random() * 10000)
    .toString()
    .padStart(4, "0");
  return `${prefix}-${year}${month}-${random}`;
}

export function formatCurrency(amount: number, currency: string = "USD"): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: currency,
  }).format(amount);
}

export function formatDate(date: Date | string | null): string {
  if (!date) return "-";
  return new Date(date).toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

export function getStatusColor(status: string): string {
  switch (status) {
    case "draft":
      return "bg-gray-100 text-gray-800";
    case "sent":
      return "bg-blue-100 text-blue-800";
    case "paid":
      return "bg-green-100 text-green-800";
    default:
      return "bg-gray-100 text-gray-800";
  }
}

export type DisplayStatus = "draft" | "sent" | "due" | "overdue" | "paid" | "partial" | "cancelled";

/**
 * Computes the display status based on invoice data
 * - draft: Not sent yet
 * - sent: Sent but no due date set
 * - due: Sent and due date is in the future
 * - overdue: Sent and due date has passed
 * - partial: Some payment received but not full amount
 * - paid: Full payment received
 * - cancelled: Invoice was cancelled
 */
export function getDisplayStatus(invoice: {
  status: string;
  dueDate: Date | string | null;
  emailSentAt: Date | string | null;
  amountPaid?: number;
  total?: number;
}): DisplayStatus {
  // If cancelled, return as-is
  if (invoice.status === "cancelled") return "cancelled";

  // Check for partial payment (some payment but not full)
  if (invoice.amountPaid && invoice.total && invoice.amountPaid > 0 && invoice.amountPaid < invoice.total) {
    return "partial";
  }

  // If fully paid, return paid
  if (invoice.status === "paid" || (invoice.amountPaid && invoice.total && invoice.amountPaid >= invoice.total)) {
    return "paid";
  }

  // If not sent yet, it's a draft
  if (invoice.status === "draft" || !invoice.emailSentAt) return "draft";

  // If sent, check due date
  if (invoice.dueDate) {
    const now = new Date();
    const dueDate = new Date(invoice.dueDate);
    // Set time to end of day for due date comparison
    dueDate.setHours(23, 59, 59, 999);

    if (now > dueDate) {
      return "overdue";
    } else {
      return "due";
    }
  }

  // Sent but no due date
  return "sent";
}

export function getDisplayStatusBadge(status: DisplayStatus): { bg: string; text: string; label: string } {
  switch (status) {
    case "draft":
      return { bg: "bg-gray-100", text: "text-gray-700", label: "DRAFT" };
    case "sent":
      return { bg: "bg-blue-100", text: "text-blue-700", label: "SENT" };
    case "due":
      return { bg: "bg-yellow-100", text: "text-yellow-700", label: "DUE" };
    case "overdue":
      return { bg: "bg-red-100", text: "text-red-700", label: "OVERDUE" };
    case "partial":
      return { bg: "bg-amber-100", text: "text-amber-700", label: "PARTIAL" };
    case "paid":
      return { bg: "bg-green-100", text: "text-green-700", label: "PAID" };
    case "cancelled":
      return { bg: "bg-gray-100", text: "text-gray-500", label: "CANCELLED" };
    default:
      return { bg: "bg-gray-100", text: "text-gray-700", label: String(status).toUpperCase() };
  }
}
