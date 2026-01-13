import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, queryMany, InvoiceRow, InvoiceItemRow, ReceiptRow, PaymentRow, toInvoice, toInvoiceItem, toReceipt, toPayment } from "@/db";
import { v4 as uuid } from "uuid";
import { auth } from "@/lib/auth";
import { updateInvoiceSchema, uuidSchema, validateInput } from "@/lib/validations";
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

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Authentication check
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    const { id } = await params;

    // Validate ID format
    const idValidation = uuidSchema.safeParse(id);
    if (!idValidation.success) {
      return validationErrorResponse("Invalid invoice ID format");
    }

    // Rate limiting
    const rateLimit = await checkRateLimit(`invoice:get:${session.user.id}`);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Fetch invoice with ownership check
    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1 AND user_id = $2",
      [id, session.user.id]
    );

    if (!invoiceRow) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    // Fetch items, receipts, and payments
    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [id]
    );

    const receiptRows = await queryMany<ReceiptRow>(
      "SELECT * FROM receipts WHERE invoice_id = $1",
      [id]
    );

    const paymentRows = await queryMany<PaymentRow>(
      "SELECT * FROM payments WHERE invoice_id = $1 ORDER BY paid_at DESC",
      [id]
    );

    const invoice = {
      ...toInvoice(invoiceRow),
      items: itemRows.map(toInvoiceItem),
      receipts: receiptRows.map(toReceipt),
      payments: paymentRows.map(toPayment),
    };

    // Audit log
    await logAudit(session.user.id, "view", "invoice", id, null, request);

    return NextResponse.json(invoice);
  } catch (error) {
    console.error("Error fetching invoice:", error);
    return NextResponse.json(
      { error: "Failed to fetch invoice" },
      { status: 500 }
    );
  }
}

export async function PUT(
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
    const rateLimit = await checkRateLimit(`invoice:update:${session.user.id}`, 30);
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
    const validation = validateInput(updateInvoiceSchema, body);
    if (!validation.success) {
      return validationErrorResponse(validation.error);
    }

    const {
      invoiceNumber,
      clientName,
      clientEmail,
      clientBusinessName,
      clientAddress,
      description,
      items,
      tax,
      dueDate,
      paymentInstructions,
      status,
    } = validation.data;

    // Calculate totals
    const subtotal = items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0
    );
    const total = subtotal + tax;

    // Delete existing items
    await query("DELETE FROM invoice_items WHERE invoice_id = $1", [id]);

    // Update invoice
    await query(
      `UPDATE invoices SET
        invoice_number = COALESCE($1, invoice_number),
        client_name = $2,
        client_email = $3,
        client_business_name = $4,
        client_address = $5,
        description = $6,
        subtotal = $7,
        tax = $8,
        total = $9,
        due_date = $10,
        payment_instructions = $11,
        status = COALESCE($12, status),
        updated_at = $13
      WHERE id = $14`,
      [
        invoiceNumber || null,
        clientName,
        clientEmail,
        clientBusinessName || null,
        clientAddress || null,
        description,
        subtotal,
        tax,
        total,
        dueDate ? new Date(dueDate) : null,
        paymentInstructions || null,
        status || null,
        new Date(),
        id,
      ]
    );

    // Insert new items
    for (const item of items) {
      await query(
        `INSERT INTO invoice_items (id, invoice_id, title, description, quantity, unit_price, total)
        VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          uuid(),
          id,
          item.title,
          item.description || "",
          item.quantity,
          item.unitPrice,
          item.quantity * item.unitPrice,
        ]
      );
    }

    // Fetch updated invoice
    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1",
      [id]
    );

    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [id]
    );

    const invoice = invoiceRow
      ? {
          ...toInvoice(invoiceRow),
          items: itemRows.map(toInvoiceItem),
        }
      : null;

    // Audit log
    await logAudit(
      session.user.id,
      "update",
      "invoice",
      id,
      { invoiceNumber: invoice?.invoiceNumber },
      request
    );

    return NextResponse.json(invoice);
  } catch (error) {
    console.error("Error updating invoice:", error);
    return NextResponse.json(
      { error: "Failed to update invoice" },
      { status: 500 }
    );
  }
}

export async function DELETE(
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
    const rateLimit = await checkRateLimit(`invoice:delete:${session.user.id}`, 20);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    // Delete invoice (cascades to items and receipts due to schema)
    await query("DELETE FROM invoices WHERE id = $1", [id]);

    // Audit log
    await logAudit(session.user.id, "delete", "invoice", id, null, request);

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error deleting invoice:", error);
    return NextResponse.json(
      { error: "Failed to delete invoice" },
      { status: 500 }
    );
  }
}
