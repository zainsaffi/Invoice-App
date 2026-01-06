import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
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

    const invoice = await prisma.invoice.findUnique({
      where: { paymentToken: token },
      include: {
        items: true,
        user: {
          select: {
            businessName: true,
          },
        },
      },
    });

    if (!invoice) {
      return NextResponse.json(
        { error: "Invoice not found" },
        { status: 404 }
      );
    }

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
    const lineItems = invoice.items.map((item) => ({
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
    await prisma.invoice.update({
      where: { id: invoice.id },
      data: {
        stripeCheckoutSessionId: session.id,
      },
    });

    return NextResponse.json({ url: session.url });
  } catch (error) {
    console.error("Error creating checkout session:", error);
    return NextResponse.json(
      { error: "Failed to create payment session" },
      { status: 500 }
    );
  }
}
