import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { stripe, STRIPE_WEBHOOK_SECRET } from "@/lib/stripe";
import Stripe from "stripe";

export async function POST(request: NextRequest) {
  try {
    if (!stripe) {
      console.error("Stripe is not configured");
      return NextResponse.json(
        { error: "Stripe not configured" },
        { status: 500 }
      );
    }

    const body = await request.text();
    const signature = request.headers.get("stripe-signature");

    if (!signature) {
      console.error("Missing stripe-signature header");
      return NextResponse.json(
        { error: "Missing signature" },
        { status: 400 }
      );
    }

    let event: Stripe.Event;

    try {
      if (STRIPE_WEBHOOK_SECRET) {
        event = stripe.webhooks.constructEvent(body, signature, STRIPE_WEBHOOK_SECRET);
      } else {
        // For testing without webhook secret (not recommended for production)
        console.warn("STRIPE_WEBHOOK_SECRET not set - skipping signature verification");
        event = JSON.parse(body) as Stripe.Event;
      }
    } catch (err) {
      console.error("Webhook signature verification failed:", err);
      return NextResponse.json(
        { error: "Invalid signature" },
        { status: 400 }
      );
    }

    // Handle the event
    switch (event.type) {
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session;
        const invoiceId = session.metadata?.invoiceId;

        console.log("Checkout session completed:", session.id);

        if (invoiceId && session.payment_status === "paid") {
          // Update invoice to paid
          await prisma.invoice.update({
            where: { id: invoiceId },
            data: {
              status: "paid",
              paidAt: new Date(),
              paymentMethod: "stripe",
              stripePaymentIntentId: session.payment_intent as string,
            },
          });

          console.log(`Invoice ${invoiceId} marked as paid via Stripe`);
        }
        break;
      }

      case "checkout.session.async_payment_succeeded": {
        // For ACH/bank payments which are async
        const session = event.data.object as Stripe.Checkout.Session;
        const invoiceId = session.metadata?.invoiceId;

        console.log("Async payment succeeded:", session.id);

        if (invoiceId) {
          await prisma.invoice.update({
            where: { id: invoiceId },
            data: {
              status: "paid",
              paidAt: new Date(),
              paymentMethod: "stripe_ach",
              stripePaymentIntentId: session.payment_intent as string,
            },
          });

          console.log(`Invoice ${invoiceId} marked as paid via Stripe ACH`);
        }
        break;
      }

      case "checkout.session.async_payment_failed": {
        // Handle failed ACH payment
        const session = event.data.object as Stripe.Checkout.Session;
        console.error("ACH payment failed for session:", session.id);
        break;
      }

      case "checkout.session.expired": {
        // Session expired without payment
        const session = event.data.object as Stripe.Checkout.Session;
        console.log("Checkout session expired:", session.id);
        break;
      }

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return NextResponse.json({ received: true });
  } catch (error) {
    console.error("Webhook error:", error);
    return NextResponse.json(
      { error: "Webhook handler failed" },
      { status: 500 }
    );
  }
}

// Disable body parser for webhook (we need raw body for signature verification)
export const config = {
  api: {
    bodyParser: false,
  },
};
