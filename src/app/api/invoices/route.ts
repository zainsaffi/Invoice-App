import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { generateInvoiceNumber } from "@/lib/utils";
import { auth } from "@/lib/auth";
import { createInvoiceSchema, validateInput } from "@/lib/validations";
import {
  checkRateLimit,
  rateLimitResponse,
  unauthorizedResponse,
  validationErrorResponse,
  validateCsrfToken,
  logAudit,
} from "@/lib/security";

export async function GET(request: NextRequest) {
  try {
    // Authentication check
    const session = await auth();
    if (!session?.user?.id) {
      return unauthorizedResponse();
    }

    // Rate limiting
    const rateLimit = await checkRateLimit(`invoices:get:${session.user.id}`);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    // Only return invoices belonging to the authenticated user
    const invoices = await prisma.invoice.findMany({
      where: {
        userId: session.user.id,
      },
      include: {
        items: true,
        receipts: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return NextResponse.json(invoices);
  } catch (error) {
    console.error("Error fetching invoices:", error);
    return NextResponse.json(
      { error: "Failed to fetch invoices" },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
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

    // Rate limiting
    const rateLimit = await checkRateLimit(`invoices:create:${session.user.id}`, 30);
    if (!rateLimit.allowed) {
      return rateLimitResponse(rateLimit.resetAt);
    }

    const body = await request.json();

    // Validate input
    const validation = validateInput(createInvoiceSchema, body);
    if (!validation.success) {
      return validationErrorResponse(validation.error);
    }

    const { clientName, clientEmail, clientAddress, description, items, tax, dueDate } =
      validation.data;

    // Calculate totals with validated data
    const subtotal = items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0
    );
    const total = subtotal + tax;

    // Get user's invoice prefix
    const user = await prisma.user.findUnique({
      where: { id: session.user.id },
      select: { invoicePrefix: true },
    });

    const invoice = await prisma.invoice.create({
      data: {
        invoiceNumber: generateInvoiceNumber(user?.invoicePrefix || "INV"),
        userId: session.user.id,
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

    // Audit log
    await logAudit(
      session.user.id,
      "create",
      "invoice",
      invoice.id,
      { invoiceNumber: invoice.invoiceNumber, total: invoice.total },
      request
    );

    return NextResponse.json(invoice, { status: 201 });
  } catch (error) {
    console.error("Error creating invoice:", error);
    return NextResponse.json(
      { error: "Failed to create invoice" },
      { status: 500 }
    );
  }
}
