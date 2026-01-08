import { NextRequest, NextResponse } from "next/server";
import { queryOne, queryMany, InvoiceRow, InvoiceItemRow, UserRow, toInvoice, toInvoiceItem } from "@/db";

// GET - Fetch invoice details by payment token (PUBLIC - no auth required)
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ token: string }> }
) {
  try {
    const { token } = await params;

    if (!token || token.length !== 64) {
      return NextResponse.json(
        { error: "Invalid payment token" },
        { status: 400 }
      );
    }

    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE payment_token = $1",
      [token]
    );

    if (!invoiceRow) {
      return NextResponse.json(
        { error: "Invoice not found or payment link has expired" },
        { status: 404 }
      );
    }

    const invoice = toInvoice(invoiceRow);

    // Fetch items
    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [invoice.id]
    );

    // Fetch user business details
    const userRow = await queryOne<Pick<UserRow, 'business_name' | 'business_email' | 'business_phone' | 'business_address'>>(
      `SELECT business_name, business_email, business_phone, business_address
      FROM users WHERE id = $1`,
      [invoice.userId]
    );

    // Return invoice data (excluding sensitive fields)
    return NextResponse.json({
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      clientName: invoice.clientName,
      clientEmail: invoice.clientEmail,
      description: invoice.description,
      items: itemRows.map((item) => {
        const converted = toInvoiceItem(item);
        return {
          id: converted.id,
          description: converted.description,
          quantity: converted.quantity,
          unitPrice: converted.unitPrice,
          total: converted.total,
        };
      }),
      subtotal: invoice.subtotal,
      tax: invoice.tax,
      total: invoice.total,
      status: invoice.status,
      dueDate: invoice.dueDate,
      createdAt: invoice.createdAt,
      user: {
        businessName: userRow?.business_name,
        businessEmail: userRow?.business_email,
        businessPhone: userRow?.business_phone,
        businessAddress: userRow?.business_address,
      },
    });
  } catch (error) {
    console.error("Error fetching invoice by payment token:", error);
    return NextResponse.json(
      { error: "Failed to fetch invoice" },
      { status: 500 }
    );
  }
}
