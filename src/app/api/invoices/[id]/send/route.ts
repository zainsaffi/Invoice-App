import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { sendInvoiceEmail } from "@/lib/email";
import { formatDate } from "@/lib/utils";
import { auth } from "@/lib/auth";
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

    const invoice = await prisma.invoice.findFirst({
      where: {
        id,
        userId: session.user.id,
      },
    });

    if (!invoice) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    // Cannot send cancelled invoices
    if (invoice.status === "cancelled") {
      return NextResponse.json(
        { error: "Cannot send a cancelled invoice" },
        { status: 400 }
      );
    }

    await sendInvoiceEmail({
      to: invoice.clientEmail,
      invoiceNumber: invoice.invoiceNumber,
      clientName: invoice.clientName,
      total: invoice.total,
      dueDate: invoice.dueDate ? formatDate(invoice.dueDate) : null,
      invoiceId: invoice.id,
    });

    const updatedInvoice = await prisma.invoice.update({
      where: { id },
      data: {
        status: "sent",
        emailSentAt: new Date(),
        emailSentTo: invoice.clientEmail,
      },
    });

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
