import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, UserRow } from "@/db";
import { auth } from "@/lib/auth";
import {
  checkRateLimit,
  rateLimitResponse,
  unauthorizedResponse,
  validateCsrfToken,
} from "@/lib/security";

// GET - Fetch user settings
export async function GET() {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    const user = await queryOne<Pick<UserRow,
      'business_name' | 'business_email' | 'business_phone' | 'business_address' |
      'tax_id' | 'currency' | 'invoice_prefix' | 'default_due_days' |
      'bank_name' | 'account_name' | 'account_number' | 'routing_number' |
      'iban' | 'paypal_email' | 'payment_notes'
    >>(
      `SELECT
        business_name, business_email, business_phone, business_address,
        tax_id, currency, invoice_prefix, default_due_days,
        bank_name, account_name, account_number, routing_number,
        iban, paypal_email, payment_notes
      FROM users WHERE id = $1`,
      [session.user.id]
    );

    if (!user) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    // Convert to camelCase for response
    return NextResponse.json({
      businessName: user.business_name,
      businessEmail: user.business_email,
      businessPhone: user.business_phone,
      businessAddress: user.business_address,
      taxId: user.tax_id,
      currency: user.currency,
      invoicePrefix: user.invoice_prefix,
      defaultDueDays: user.default_due_days,
      bankName: user.bank_name,
      accountName: user.account_name,
      accountNumber: user.account_number,
      routingNumber: user.routing_number,
      iban: user.iban,
      paypalEmail: user.paypal_email,
      paymentNotes: user.payment_notes,
    });
  } catch (error) {
    console.error("Error fetching settings:", error);
    return NextResponse.json(
      { error: "Failed to fetch settings" },
      { status: 500 }
    );
  }
}

// PUT - Update user settings
export async function PUT(request: NextRequest) {
  try {
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
    const rateLimit = await checkRateLimit(`settings:${session.user.id}`, 30);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    const body = await request.json();

    // Update user settings
    await query(
      `UPDATE users SET
        business_name = $1,
        business_email = $2,
        business_phone = $3,
        business_address = $4,
        tax_id = $5,
        currency = $6,
        invoice_prefix = $7,
        default_due_days = $8,
        bank_name = $9,
        account_name = $10,
        account_number = $11,
        routing_number = $12,
        iban = $13,
        paypal_email = $14,
        payment_notes = $15,
        updated_at = $16
      WHERE id = $17`,
      [
        body.businessName || null,
        body.businessEmail || null,
        body.businessPhone || null,
        body.businessAddress || null,
        body.taxId || null,
        body.currency || "USD",
        body.invoicePrefix || "INV",
        body.defaultDueDays || 30,
        body.bankName || null,
        body.accountName || null,
        body.accountNumber || null,
        body.routingNumber || null,
        body.iban || null,
        body.paypalEmail || null,
        body.paymentNotes || null,
        new Date(),
        session.user.id,
      ]
    );

    const updatedUser = await queryOne<Pick<UserRow,
      'business_name' | 'business_email' | 'business_phone' | 'business_address' |
      'tax_id' | 'currency' | 'invoice_prefix' | 'default_due_days' |
      'bank_name' | 'account_name' | 'account_number' | 'routing_number' |
      'iban' | 'paypal_email' | 'payment_notes'
    >>(
      `SELECT
        business_name, business_email, business_phone, business_address,
        tax_id, currency, invoice_prefix, default_due_days,
        bank_name, account_name, account_number, routing_number,
        iban, paypal_email, payment_notes
      FROM users WHERE id = $1`,
      [session.user.id]
    );

    if (!updatedUser) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    // Convert to camelCase for response
    return NextResponse.json({
      businessName: updatedUser.business_name,
      businessEmail: updatedUser.business_email,
      businessPhone: updatedUser.business_phone,
      businessAddress: updatedUser.business_address,
      taxId: updatedUser.tax_id,
      currency: updatedUser.currency,
      invoicePrefix: updatedUser.invoice_prefix,
      defaultDueDays: updatedUser.default_due_days,
      bankName: updatedUser.bank_name,
      accountName: updatedUser.account_name,
      accountNumber: updatedUser.account_number,
      routingNumber: updatedUser.routing_number,
      iban: updatedUser.iban,
      paypalEmail: updatedUser.paypal_email,
      paymentNotes: updatedUser.payment_notes,
    });
  } catch (error) {
    console.error("Error updating settings:", error);
    return NextResponse.json(
      { error: "Failed to update settings" },
      { status: 500 }
    );
  }
}
