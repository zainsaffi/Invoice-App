import Stripe from "stripe";

if (!process.env.STRIPE_SECRET_KEY) {
  console.warn("Warning: STRIPE_SECRET_KEY is not set. Stripe payments will not work.");
}

export const stripe = process.env.STRIPE_SECRET_KEY
  ? new Stripe(process.env.STRIPE_SECRET_KEY, {
      apiVersion: "2025-12-15.clover",
      typescript: true,
    })
  : null;

export const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET;

export function isStripeEnabled(): boolean {
  return !!stripe;
}
