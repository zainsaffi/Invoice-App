import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, queryMany, InvoiceRow, InvoiceItemRow, toInvoice, toInvoiceItem } from "@/db";

// Public endpoint - no auth required
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ token: string }> }
) {
  try {
    const { token } = await params;

    if (!token || token.length < 32) {
      return NextResponse.json({ error: "Invalid token" }, { status: 400 });
    }

    // Find invoice by view_token
    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE view_token = $1",
      [token]
    );

    if (!invoiceRow) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    // Track view - increment view count and update last viewed time
    await query(
      `UPDATE invoices SET
        view_count = COALESCE(view_count, 0) + 1,
        last_viewed_at = NOW()
      WHERE id = $1`,
      [invoiceRow.id]
    );

    // Get invoice items
    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [invoiceRow.id]
    );

    // Get user info for business details
    const userRow = await queryOne<{
      business_name: string | null;
      business_email: string | null;
      business_phone: string | null;
      business_address: string | null;
    }>(
      "SELECT business_name, business_email, business_phone, business_address FROM users WHERE id = $1",
      [invoiceRow.user_id]
    );

    const invoice = toInvoice(invoiceRow);
    const items = itemRows.map(toInvoiceItem);

    // Return sanitized public invoice data (no sensitive info)
    return NextResponse.json({
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      clientName: invoice.clientName,
      clientEmail: invoice.clientEmail,
      clientBusinessName: invoice.clientBusinessName,
      clientAddress: invoice.clientAddress,
      description: invoice.description,
      items: items.map(item => ({
        id: item.id,
        title: item.title,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        total: item.total,
      })),
      subtotal: invoice.subtotal,
      tax: invoice.tax,
      total: invoice.total,
      status: invoice.status,
      amountPaid: invoice.amountPaid,
      dueDate: invoice.dueDate,
      paymentInstructions: invoice.paymentInstructions,
      paymentToken: invoice.paymentToken,
      createdAt: invoice.createdAt,
      business: userRow ? {
        name: userRow.business_name,
        email: userRow.business_email,
        phone: userRow.business_phone,
        address: userRow.business_address,
      } : null,
    });
  } catch (error) {
    console.error("Error fetching public invoice:", error);
    return NextResponse.json(
      { error: "Failed to fetch invoice" },
      { status: 500 }
    );
  }
}
