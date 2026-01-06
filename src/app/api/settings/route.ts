import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
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

    const user = await prisma.user.findUnique({
      where: { id: session.user.id },
      select: {
        businessName: true,
        businessEmail: true,
        businessPhone: true,
        businessAddress: true,
        taxId: true,
        currency: true,
        invoicePrefix: true,
        defaultDueDays: true,
        bankName: true,
        accountName: true,
        accountNumber: true,
        routingNumber: true,
        iban: true,
        paypalEmail: true,
        paymentNotes: true,
      },
    });

    if (!user) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    return NextResponse.json(user);
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
    const updatedUser = await prisma.user.update({
      where: { id: session.user.id },
      data: {
        businessName: body.businessName || null,
        businessEmail: body.businessEmail || null,
        businessPhone: body.businessPhone || null,
        businessAddress: body.businessAddress || null,
        taxId: body.taxId || null,
        currency: body.currency || "USD",
        invoicePrefix: body.invoicePrefix || "INV",
        defaultDueDays: body.defaultDueDays || 30,
        bankName: body.bankName || null,
        accountName: body.accountName || null,
        accountNumber: body.accountNumber || null,
        routingNumber: body.routingNumber || null,
        iban: body.iban || null,
        paypalEmail: body.paypalEmail || null,
        paymentNotes: body.paymentNotes || null,
      },
      select: {
        businessName: true,
        businessEmail: true,
        businessPhone: true,
        businessAddress: true,
        taxId: true,
        currency: true,
        invoicePrefix: true,
        defaultDueDays: true,
        bankName: true,
        accountName: true,
        accountNumber: true,
        routingNumber: true,
        iban: true,
        paypalEmail: true,
        paymentNotes: true,
      },
    });

    return NextResponse.json(updatedUser);
  } catch (error) {
    console.error("Error updating settings:", error);
    return NextResponse.json(
      { error: "Failed to update settings" },
      { status: 500 }
    );
  }
}
