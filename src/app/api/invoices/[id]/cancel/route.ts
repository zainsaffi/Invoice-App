import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
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

    // Rate limiting
    const rateLimit = await checkRateLimit(`invoice:cancel:${session.user.id}`, 30);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    // Check if invoice exists and its current status
    const invoice = await prisma.invoice.findFirst({
      where: {
        id,
        userId: session.user.id,
      },
    });

    if (!invoice) {
      return NextResponse.json(
        { error: "Invoice not found" },
        { status: 404 }
      );
    }

    // Cannot cancel if already paid
    if (invoice.status === "paid") {
      return NextResponse.json(
        { error: "Cannot cancel a paid invoice" },
        { status: 400 }
      );
    }

    // Cannot cancel if already cancelled
    if (invoice.status === "cancelled") {
      return NextResponse.json(
        { error: "Invoice is already cancelled" },
        { status: 400 }
      );
    }

    // Update invoice status to cancelled
    const updatedInvoice = await prisma.invoice.update({
      where: { id },
      data: {
        status: "cancelled",
      },
      include: {
        items: true,
        receipts: true,
      },
    });

    // Audit log
    await logAudit(
      session.user.id,
      "cancel",
      "invoice",
      id,
      { previousStatus: invoice.status },
      request
    );

    return NextResponse.json(updatedInvoice);
  } catch (error) {
    console.error("Error cancelling invoice:", error);
    return NextResponse.json(
      { error: "Failed to cancel invoice" },
      { status: 500 }
    );
  }
}
