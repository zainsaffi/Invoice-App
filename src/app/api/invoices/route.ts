import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, queryMany, InvoiceRow, InvoiceItemRow, ReceiptRow, UserRow, toInvoice, toInvoiceItem, toReceipt } from "@/db";
import { v4 as uuid } from "uuid";
import { generateInvoiceNumber } from "@/lib/utils";
import { auth } from "@/lib/auth";
import { createInvoiceSchema, validateInput } from "@/lib/validations";
import {
  checkRateLimit,
  rateLimitResponse,
  unauthorizedResponse,
  validationErrorResponse,
  validateCsrfToken,
  logAudit,
} from "@/lib/security";

export async function GET(request: NextRequest) {
  try {
    // Authentication check
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    // Rate limiting
    const rateLimit = await checkRateLimit(`invoices:get:${session.user.id}`);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Get invoices for the user
    const invoiceRows = await queryMany<InvoiceRow>(
      `SELECT * FROM invoices WHERE user_id = $1 ORDER BY created_at DESC`,
      [session.user.id]
    );

    // Get all items and receipts for these invoices
    const invoiceIds = invoiceRows.map((inv) => inv.id);

    let itemRows: InvoiceItemRow[] = [];
    let receiptRows: ReceiptRow[] = [];

    if (invoiceIds.length > 0) {
      itemRows = await queryMany<InvoiceItemRow>(
        `SELECT * FROM invoice_items WHERE invoice_id = ANY($1)`,
        [invoiceIds]
      );
      receiptRows = await queryMany<ReceiptRow>(
        `SELECT * FROM receipts WHERE invoice_id = ANY($1)`,
        [invoiceIds]
      );
    }

    // Map invoices with their items and receipts
    const result = invoiceRows.map((row) => {
      const invoice = toInvoice(row);
      return {
        ...invoice,
        items: itemRows.filter((i) => i.invoice_id === row.id).map(toInvoiceItem),
        receipts: receiptRows.filter((r) => r.invoice_id === row.id).map(toReceipt),
      };
    });

    return NextResponse.json(result);
  } catch (error) {
    console.error("Error fetching invoices:", error);
    return NextResponse.json(
      { error: "Failed to fetch invoices" },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
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

    // Rate limiting
    const rateLimit = await checkRateLimit(`invoices:create:${session.user.id}`, 30);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    const body = await request.json();

    // Validate input
    const validation = validateInput(createInvoiceSchema, body);
    if (!validation.success) {
      return validationErrorResponse(validation.error);
    }

    const { clientName, clientEmail, clientBusinessName, clientAddress, description, items, tax, dueDate } =
      validation.data;

    // Calculate totals with validated data
    const subtotal = items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0
    );
    const total = subtotal + tax;

    // Get user's invoice prefix
    const userRow = await queryOne<UserRow>(
      "SELECT invoice_prefix FROM users WHERE id = $1",
      [session.user.id]
    );

    const invoiceId = uuid();
    const invoiceNumber = generateInvoiceNumber(userRow?.invoice_prefix || "INV");

    // Insert invoice
    await query(
      `INSERT INTO invoices (id, invoice_number, user_id, client_name, client_email, client_business_name,
       client_address, description, subtotal, tax, total, due_date, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW(), NOW())`,
      [
        invoiceId,
        invoiceNumber,
        session.user.id,
        clientName,
        clientEmail,
        clientBusinessName || null,
        clientAddress || null,
        description,
        subtotal,
        tax,
        total,
        dueDate ? new Date(dueDate) : null,
      ]
    );

    // Insert items
    for (const item of items) {
      await query(
        `INSERT INTO invoice_items (id, invoice_id, description, quantity, unit_price, total)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [uuid(), invoiceId, item.description, item.quantity, item.unitPrice, item.quantity * item.unitPrice]
      );
    }

    // Fetch the created invoice with items
    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1",
      [invoiceId]
    );
    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [invoiceId]
    );

    const invoice = invoiceRow ? {
      ...toInvoice(invoiceRow),
      items: itemRows.map(toInvoiceItem),
    } : null;

    // Audit log
    await logAudit(
      session.user.id,
      "create",
      "invoice",
      invoiceId,
      { invoiceNumber, total },
      request
    );

    return NextResponse.json(invoice, { status: 201 });
  } catch (error) {
    console.error("Error creating invoice:", error);
    return NextResponse.json(
      { error: "Failed to create invoice" },
      { status: 500 }
    );
  }
}
