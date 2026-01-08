import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, queryMany, InvoiceRow, InvoiceItemRow, ReceiptRow, toInvoice, toInvoiceItem, toReceipt } from "@/db";
import { auth } from "@/lib/auth";
import { uuidSchema } from "@/lib/validations";
import {
  checkRateLimit,
  rateLimitResponse,
  unauthorizedResponse,
  forbiddenResponse,
  validationErrorResponse,
  validateCsrfToken,
  logAudit,
  checkInvoiceOwnership,
} from "@/lib/security";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Authentication check
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    // CSRF validation
    if (!validateCsrfToken(request)) {
      return NextResponse.json(
        { error: "Invalid request origin" },
        { status: 403 }
      );
    }

    const { id } = await params;

    // Validate ID format
    const idValidation = uuidSchema.safeParse(id);
    if (!idValidation.success) {
      return validationErrorResponse("Invalid invoice ID format");
    }

    // Rate limiting
    const rateLimit = await checkRateLimit(`invoice:cancel:${session.user.id}`, 30);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    // Check if invoice exists and its current status
    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1 AND user_id = $2",
      [id, session.user.id]
    );

    if (!invoiceRow) {
      return NextResponse.json(
        { error: "Invoice not found" },
        { status: 404 }
      );
    }

    const invoice = toInvoice(invoiceRow);

    // Cannot cancel if already paid
    if (invoice.status === "paid") {
      return NextResponse.json(
        { error: "Cannot cancel a paid invoice" },
        { status: 400 }
      );
    }

    // Cannot cancel if already cancelled
    if (invoice.status === "cancelled") {
      return NextResponse.json(
        { error: "Invoice is already cancelled" },
        { status: 400 }
      );
    }

    // Update invoice status to cancelled
    await query(
      "UPDATE invoices SET status = $1, updated_at = $2 WHERE id = $3",
      ["cancelled", new Date(), id]
    );

    // Fetch updated invoice with relations
    const updatedInvoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1",
      [id]
    );

    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [id]
    );

    const receiptRows = await queryMany<ReceiptRow>(
      "SELECT * FROM receipts WHERE invoice_id = $1",
      [id]
    );

    const updatedInvoice = updatedInvoiceRow
      ? {
          ...toInvoice(updatedInvoiceRow),
          items: itemRows.map(toInvoiceItem),
          receipts: receiptRows.map(toReceipt),
        }
      : null;

    // Audit log
    await logAudit(
      session.user.id,
      "cancel",
      "invoice",
      id,
      { previousStatus: invoice.status },
      request
    );

    return NextResponse.json(updatedInvoice);
  } catch (error) {
    console.error("Error cancelling invoice:", error);
    return NextResponse.json(
      { error: "Failed to cancel invoice" },
      { status: 500 }
    );
  }
}
