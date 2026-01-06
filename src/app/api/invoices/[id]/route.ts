import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { auth } from "@/lib/auth";
import { updateInvoiceSchema, uuidSchema, validateInput } from "@/lib/validations";
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

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Authentication check
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    const { id } = await params;

    // Validate ID format
    const idValidation = uuidSchema.safeParse(id);
    if (!idValidation.success) {
      return validationErrorResponse("Invalid invoice ID format");
    }

    // Rate limiting
    const rateLimit = await checkRateLimit(`invoice:get:${session.user.id}`);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Fetch invoice with ownership check
    const invoice = await prisma.invoice.findFirst({
      where: {
        id,
        userId: session.user.id, // Authorization: only owner can view
      },
      include: {
        items: true,
        receipts: true,
      },
    });

    if (!invoice) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    // Audit log
    await logAudit(session.user.id, "view", "invoice", id, null, request);

    return NextResponse.json(invoice);
  } catch (error) {
    console.error("Error fetching invoice:", error);
    return NextResponse.json(
      { error: "Failed to fetch invoice" },
      { status: 500 }
    );
  }
}

export async function PUT(
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
    const rateLimit = await checkRateLimit(`invoice:update:${session.user.id}`, 30);
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
    const validation = validateInput(updateInvoiceSchema, body);
    if (!validation.success) {
      return validationErrorResponse(validation.error);
    }

    const {
      invoiceNumber,
      clientName,
      clientEmail,
      clientAddress,
      description,
      items,
      tax,
      dueDate,
    } = validation.data;

    // Calculate totals
    const subtotal = items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0
    );
    const total = subtotal + tax;

    // Use transaction to ensure atomicity
    const invoice = await prisma.$transaction(async (tx) => {
      // Delete existing items within transaction
      await tx.invoiceItem.deleteMany({
        where: { invoiceId: id },
      });

      // Update invoice with new items
      return tx.invoice.update({
        where: { id },
        data: {
          ...(invoiceNumber && { invoiceNumber }),
          clientName,
          clientEmail,
          clientAddress: clientAddress || "",
          description,
          subtotal,
          tax,
          total,
          dueDate: dueDate ? new Date(dueDate) : null,
          items: {
            create: items.map((item) => ({
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              total: item.quantity * item.unitPrice,
            })),
          },
        },
        include: {
          items: true,
        },
      });
    });

    // Audit log
    await logAudit(
      session.user.id,
      "update",
      "invoice",
      id,
      { invoiceNumber: invoice.invoiceNumber },
      request
    );

    return NextResponse.json(invoice);
  } catch (error) {
    console.error("Error updating invoice:", error);
    return NextResponse.json(
      { error: "Failed to update invoice" },
      { status: 500 }
    );
  }
}

export async function DELETE(
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
    const rateLimit = await checkRateLimit(`invoice:delete:${session.user.id}`, 20);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Authorization: check ownership
    const isOwner = await checkInvoiceOwnership(id, session.user.id);
    if (!isOwner) {
      return forbiddenResponse();
    }

    // Delete invoice (cascades to items and receipts due to schema)
    await prisma.invoice.delete({
      where: { id },
    });

    // Audit log
    await logAudit(session.user.id, "delete", "invoice", id, null, request);

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error deleting invoice:", error);
    return NextResponse.json(
      { error: "Failed to delete invoice" },
      { status: 500 }
    );
  }
}
