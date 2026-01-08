import { queryMany, InvoiceRow, InvoiceItemRow, ReceiptRow, PaymentRow, UserRow, toInvoice, toInvoiceItem, toReceipt, toPayment } from "@/db";
import InvoiceTable from "@/components/InvoiceTable";
import Sidebar from "@/components/Sidebar";
import Link from "next/link";
import { Plus } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function InvoicesPage() {
  // Fetch all invoices ordered by created_at desc
  const invoiceRows = await queryMany<InvoiceRow>(
    `SELECT * FROM invoices ORDER BY created_at DESC`
  );

  // Fetch all items, receipts, and users for these invoices
  const invoiceIds = invoiceRows.map((inv) => inv.id);
  const userIds = [...new Set(invoiceRows.map((inv) => inv.user_id))];

  let itemRows: InvoiceItemRow[] = [];
  let receiptRows: ReceiptRow[] = [];
  let paymentRows: PaymentRow[] = [];
  let userRows: UserRow[] = [];

  if (invoiceIds.length > 0) {
    // Create parameter placeholders for IN clause
    const invoicePlaceholders = invoiceIds.map((_, i) => `$${i + 1}`).join(", ");

    itemRows = await queryMany<InvoiceItemRow>(
      `SELECT * FROM invoice_items WHERE invoice_id IN (${invoicePlaceholders})`,
      invoiceIds
    );

    receiptRows = await queryMany<ReceiptRow>(
      `SELECT * FROM receipts WHERE invoice_id IN (${invoicePlaceholders})`,
      invoiceIds
    );

    paymentRows = await queryMany<PaymentRow>(
      `SELECT * FROM payments WHERE invoice_id IN (${invoicePlaceholders})`,
      invoiceIds
    );
  }

  if (userIds.length > 0) {
    const userPlaceholders = userIds.map((_, i) => `$${i + 1}`).join(", ");
    userRows = await queryMany<UserRow>(
      `SELECT id, name, business_name, currency FROM users WHERE id IN (${userPlaceholders})`,
      userIds
    );
  }

  // Convert to camelCase and combine
  const invoiceList = invoiceRows.map((row) => {
    const invoice = toInvoice(row);
    const items = itemRows
      .filter((item) => item.invoice_id === row.id)
      .map(toInvoiceItem);
    const receipts = receiptRows
      .filter((receipt) => receipt.invoice_id === row.id)
      .map(toReceipt);
    const payments = paymentRows
      .filter((payment) => payment.invoice_id === row.id)
      .map(toPayment);
    const userRow = userRows.find((u) => u.id === row.user_id);
    const user = userRow
      ? {
          id: userRow.id,
          name: userRow.name,
          businessName: userRow.business_name,
          currency: userRow.currency,
        }
      : undefined;
    return { ...invoice, items, receipts, payments, user };
  });

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 ml-64">
        <div className="p-8">
          {/* Header */}
          <div className="flex items-center justify-between mb-8">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Invoices</h1>
              <p className="text-gray-500 mt-1">Manage and track all your invoices</p>
            </div>
            <Link
              href="/invoices/new"
              className="flex items-center gap-2 px-4 py-2.5 bg-indigo-600 text-white text-sm font-medium rounded-xl hover:bg-indigo-700 transition-colors shadow-lg shadow-indigo-500/25"
            >
              <Plus className="w-4 h-4" />
              New Invoice
            </Link>
          </div>

          {/* Invoice Table */}
          <InvoiceTable invoices={invoiceList} />
        </div>
      </main>
    </div>
  );
}
