import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { auth } from "@/lib/auth";
import { paymentSchema, uuidSchema, validateInput } from "@/lib/validations";
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
    const rateLimit = await checkRateLimit(`invoice:pay:${session.user.id}`, 30);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    const body = await request.json();

    // Validate input
    const validation = validateInput(paymentSchema, body);
    if (!validation.success) {
      return validationErrorResponse(validation.error);
    }

    const { paymentMethod } = validation.data;

    // Check invoice exists and status
    const invoice = await prisma.invoice.findFirst({
      where: {
        id,
        userId: session.user.id,
      },
    });

    if (!invoice) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    if (invoice.status === "paid") {
      return NextResponse.json(
        { error: "Invoice is already paid" },
        { status: 400 }
      );
    }

    if (invoice.status === "cancelled") {
      return NextResponse.json(
        { error: "Cannot pay a cancelled invoice" },
        { status: 400 }
      );
    }

    const updatedInvoice = await prisma.invoice.update({
      where: { id },
      data: {
        status: "paid",
        paidAt: new Date(),
        paymentMethod,
      },
    });

    // Audit log
    await logAudit(
      session.user.id,
      "pay",
      "invoice",
      id,
      { paymentMethod, amount: invoice.total },
      request
    );

    return NextResponse.json(updatedInvoice);
  } catch (error) {
    console.error("Error marking invoice as paid:", error);
    return NextResponse.json(
      { error: "Failed to mark invoice as paid" },
      { status: 500 }
    );
  }
}
