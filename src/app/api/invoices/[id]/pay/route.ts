import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, InvoiceRow, toInvoice } from "@/db";
import { auth } from "@/lib/auth";
import { paymentSchema, uuidSchema, validateInput } from "@/lib/validations";
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
    const rateLimit = await checkRateLimit(`invoice:pay:${session.user.id}`, 30);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    const body = await request.json();

    // Validate input
    const validation = validateInput(paymentSchema, body);
    if (!validation.success) {
      return validationErrorResponse(validation.error);
    }

    const { paymentMethod } = validation.data;

    // Check invoice exists and status
    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1 AND user_id = $2",
      [id, session.user.id]
    );

    if (!invoiceRow) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    const invoice = toInvoice(invoiceRow);

    if (invoice.status === "paid") {
      return NextResponse.json(
        { error: "Invoice is already paid" },
        { status: 400 }
      );
    }

    if (invoice.status === "cancelled") {
      return NextResponse.json(
        { error: "Cannot pay a cancelled invoice" },
        { status: 400 }
      );
    }

    await query(
      `UPDATE invoices SET
        status = $1,
        paid_at = $2,
        payment_method = $3,
        updated_at = $4
      WHERE id = $5`,
      ["paid", new Date(), paymentMethod, new Date(), id]
    );

    const updatedInvoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1",
      [id]
    );

    const updatedInvoice = updatedInvoiceRow ? toInvoice(updatedInvoiceRow) : null;

    // Audit log
    await logAudit(
      session.user.id,
      "pay",
      "invoice",
      id,
      { paymentMethod, amount: invoice.total },
      request
    );

    return NextResponse.json(updatedInvoice);
  } catch (error) {
    console.error("Error marking invoice as paid:", error);
    return NextResponse.json(
      { error: "Failed to mark invoice as paid" },
      { status: 500 }
    );
  }
}
