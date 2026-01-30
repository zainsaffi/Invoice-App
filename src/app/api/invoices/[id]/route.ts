import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, queryMany, InvoiceRow, InvoiceItemRow, ReceiptRow, PaymentRow, TripLegRow, StatusHistoryRow, toInvoice, toInvoiceItem, toReceipt, toPayment, toTripLeg, toStatusHistory } from "@/db";
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

    // Fetch items, receipts, payments, and trip legs
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

    // Fetch trip legs for all items
    const itemIds = itemRows.map((item) => item.id);
    let tripLegRows: TripLegRow[] = [];
    if (itemIds.length > 0) {
      tripLegRows = await queryMany<TripLegRow>(
        `SELECT * FROM trip_legs WHERE invoice_item_id = ANY($1) ORDER BY leg_order`,
        [itemIds]
      );
    }

    // Fetch status history
    const statusHistoryRows = await queryMany<StatusHistoryRow>(
      "SELECT * FROM status_history WHERE invoice_id = $1 ORDER BY changed_at DESC",
      [id]
    );

    const invoice = {
      ...toInvoice(invoiceRow),
      items: itemRows.map((itemRow) => {
        const item = toInvoiceItem(itemRow);
        const legs = tripLegRows
          .filter((leg) => leg.invoice_item_id === itemRow.id)
          .map(toTripLeg);
        return { ...item, legs: legs.length > 0 ? legs : undefined };
      }),
      receipts: receiptRows.map(toReceipt),
      payments: paymentRows.map(toPayment),
      statusHistory: statusHistoryRows.map(toStatusHistory),
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

    // Authorization: check ownership and get current status
    const currentInvoice = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1 AND user_id = $2",
      [id, session.user.id]
    );
    if (!currentInvoice) {
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

    // Delete existing items (trip_legs will cascade)
    await query("DELETE FROM invoice_items WHERE invoice_id = $1", [id]);

    // Update invoice
    await query(
      `UPDATE invoices SET
        invoice_number = COALESCE($1, invoice_number),
        client_name = $2,
        client_email = $3,
        client_business_name = $4,
        client_address = $5,
        subtotal = $6,
        tax = $7,
        total = $8,
        due_date = $9,
        payment_instructions = $10,
        status = COALESCE($11, status),
        updated_at = $12
      WHERE id = $13`,
      [
        invoiceNumber || null,
        clientName,
        clientEmail,
        clientBusinessName || null,
        clientAddress || null,
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

    // Track status change if status has changed
    if (status && status !== currentInvoice.status) {
      await query(
        `INSERT INTO status_history (id, invoice_id, status, changed_at)
         VALUES ($1, $2, $3, $4)`,
        [uuid(), id, status, new Date()]
      );

      // Set paid_at when status changes to paid
      if (status === "paid") {
        await query(
          `UPDATE invoices SET paid_at = NOW() WHERE id = $1 AND paid_at IS NULL`,
          [id]
        );
      }
    }

    // Insert new items with service type and trip legs
    for (const item of items) {
      const itemId = uuid();
      await query(
        `INSERT INTO invoice_items (id, invoice_id, title, description, quantity, unit_price, total, service_type, travel_subtype)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          itemId,
          id,
          item.title,
          item.description || "",
          item.quantity,
          item.unitPrice,
          item.quantity * item.unitPrice,
          item.serviceType || 'standard',
          item.travelSubtype || null,
        ]
      );

      // Insert trip legs if this is a trip-type item
      if (item.serviceType === 'trip' && item.legs && item.legs.length > 0) {
        for (const leg of item.legs) {
          await query(
            `INSERT INTO trip_legs (id, invoice_item_id, leg_order, from_airport, to_airport, trip_date, trip_date_end, passengers)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [uuid(), itemId, leg.legOrder, leg.fromAirport.toUpperCase(), leg.toAirport.toUpperCase(), leg.tripDate ? new Date(leg.tripDate) : null, leg.tripDateEnd ? new Date(leg.tripDateEnd) : null, leg.passengers || null]
          );
        }
      }
    }

    // Fetch updated invoice with items and trip legs
    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1",
      [id]
    );

    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [id]
    );

    const itemIds = itemRows.map((item) => item.id);
    let tripLegRows: TripLegRow[] = [];
    if (itemIds.length > 0) {
      tripLegRows = await queryMany<TripLegRow>(
        `SELECT * FROM trip_legs WHERE invoice_item_id = ANY($1) ORDER BY leg_order`,
        [itemIds]
      );
    }

    const invoice = invoiceRow
      ? {
          ...toInvoice(invoiceRow),
          items: itemRows.map((itemRow) => {
            const item = toInvoiceItem(itemRow);
            const legs = tripLegRows
              .filter((leg) => leg.invoice_item_id === itemRow.id)
              .map(toTripLeg);
            return { ...item, legs: legs.length > 0 ? legs : undefined };
          }),
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
