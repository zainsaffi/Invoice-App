import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, queryMany, InvoiceRow, InvoiceItemRow, UserRow, toInvoice, toInvoiceItem } from "@/db";
import { stripe, isStripeEnabled } from "@/lib/stripe";

// POST - Create Stripe Checkout Session (PUBLIC - no auth required)
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ token: string }> }
) {
  try {
    const { token } = await params;

    // Check if Stripe is configured
    if (!isStripeEnabled() || !stripe) {
      return NextResponse.json(
        { error: "Payment processing is not configured. Please contact the business owner." },
        { status: 503 }
      );
    }

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
        { error: "Invoice not found" },
        { status: 404 }
      );
    }

    const invoice = toInvoice(invoiceRow);

    // Fetch items
    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [invoice.id]
    );

    const items = itemRows.map(toInvoiceItem);

    // Fetch user business name
    const userRow = await queryOne<Pick<UserRow, 'business_name'>>(
      "SELECT business_name FROM users WHERE id = $1",
      [invoice.userId]
    );

    // Check if already paid
    if (invoice.status === "paid") {
      return NextResponse.json(
        { error: "This invoice has already been paid" },
        { status: 400 }
      );
    }

    // Check if cancelled
    if (invoice.status === "cancelled") {
      return NextResponse.json(
        { error: "This invoice has been cancelled" },
        { status: 400 }
      );
    }

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";

    // Create line items for Stripe
    const lineItems = items.map((item) => ({
      price_data: {
        currency: "usd",
        product_data: {
          name: item.description,
        },
        unit_amount: Math.round(item.unitPrice * 100), // Convert to cents
      },
      quantity: item.quantity,
    }));

    // Add tax as separate line item if present
    if (invoice.tax > 0) {
      lineItems.push({
        price_data: {
          currency: "usd",
          product_data: {
            name: "Tax",
          },
          unit_amount: Math.round(invoice.tax * 100),
        },
        quantity: 1,
      });
    }

    // Create Stripe Checkout Session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      mode: "payment",
      customer_email: invoice.clientEmail,
      line_items: lineItems,
      success_url: `${appUrl}/pay/${token}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${appUrl}/pay/${token}`,
      metadata: {
        invoiceId: invoice.id,
        paymentToken: token,
        invoiceNumber: invoice.invoiceNumber,
      },
      payment_intent_data: {
        metadata: {
          invoiceId: invoice.id,
          invoiceNumber: invoice.invoiceNumber,
        },
      },
    });

    // Update invoice with checkout session ID
    await query(
      "UPDATE invoices SET stripe_checkout_session_id = $1, updated_at = $2 WHERE id = $3",
      [session.id, new Date(), invoice.id]
    );

    return NextResponse.json({ url: session.url });
  } catch (error) {
    console.error("Error creating checkout session:", error);
    return NextResponse.json(
      { error: "Failed to create payment session" },
      { status: 500 }
    );
  }
}
