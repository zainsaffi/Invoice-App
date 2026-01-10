import { NextRequest, NextResponse } from "next/server";
import { query, queryOne, InvoiceRow, UserRow, toInvoice, toUser } from "@/db";
import { sendInvoiceEmail } from "@/lib/email";
import { formatDate, generatePaymentToken } from "@/lib/utils";
import { auth } from "@/lib/auth";
import { isStripeEnabled } from "@/lib/stripe";
import { uuidSchema } from "@/lib/validations";
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

// Generate a unique view token
function generateViewToken(): string {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let token = '';
  for (let i = 0; i < 64; i++) {
    token += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return token;
}

export async function POST(
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

    // Rate limiting - stricter for email sending
    const rateLimit = await checkRateLimit(`invoice:send:${session.user.id}`, 10, 60 * 60 * 1000); // 10 per hour
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1 AND user_id = $2",
      [id, session.user.id]
    );

    if (!invoiceRow) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    const invoice = toInvoice(invoiceRow);

    // Cannot send cancelled invoices
    if (invoice.status === "cancelled") {
      return NextResponse.json(
        { error: "Cannot send a cancelled invoice" },
        { status: 400 }
      );
    }

    // Get user info for business name
    const userRow = await queryOne<UserRow>(
      "SELECT * FROM users WHERE id = $1",
      [session.user.id]
    );
    const user = userRow ? toUser(userRow) : null;

    // Generate payment token if Stripe is enabled and no token exists
    let paymentToken = invoice.paymentToken;
    if (isStripeEnabled() && !paymentToken) {
      paymentToken = generatePaymentToken();
    }

    // Generate view token if not exists
    let viewToken = invoice.viewToken;
    if (!viewToken) {
      viewToken = generateViewToken();
    }

    await sendInvoiceEmail({
      to: invoice.clientEmail,
      invoiceNumber: invoice.invoiceNumber,
      clientName: invoice.clientName,
      total: invoice.total,
      dueDate: invoice.dueDate ? formatDate(invoice.dueDate) : null,
      invoiceId: invoice.id,
      paymentToken: paymentToken || undefined,
      viewToken: viewToken,
      businessName: user?.businessName || user?.name || undefined,
    });

    await query(
      `UPDATE invoices SET
        status = $1,
        email_sent_at = $2,
        email_sent_to = $3,
        payment_token = COALESCE($4, payment_token),
        view_token = COALESCE($5, view_token),
        updated_at = $6
      WHERE id = $7`,
      [
        "sent",
        new Date(),
        invoice.clientEmail,
        paymentToken,
        viewToken,
        new Date(),
        id,
      ]
    );

    // Fetch updated invoice
    const updatedInvoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1",
      [id]
    );

    const updatedInvoice = updatedInvoiceRow ? toInvoice(updatedInvoiceRow) : null;

    // Audit log
    await logAudit(
      session.user.id,
      "send",
      "invoice",
      id,
      { sentTo: invoice.clientEmail },
      request
    );

    return NextResponse.json(updatedInvoice);
  } catch (error) {
    console.error("Error sending invoice:", error);
    return NextResponse.json(
      { error: "Failed to send invoice email" },
      { status: 500 }
    );
  }
}
