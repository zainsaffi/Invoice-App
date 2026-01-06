import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

// GET - Fetch invoice details by payment token (PUBLIC - no auth required)
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ token: string }> }
) {
  try {
    const { token } = await params;

    if (!token || token.length !== 64) {
      return NextResponse.json(
        { error: "Invalid payment token" },
        { status: 400 }
      );
    }

    const invoice = await prisma.invoice.findUnique({
      where: { paymentToken: token },
      include: {
        items: true,
        user: {
          select: {
            businessName: true,
            businessEmail: true,
            businessPhone: true,
            businessAddress: true,
          },
        },
      },
    });

    if (!invoice) {
      return NextResponse.json(
        { error: "Invoice not found or payment link has expired" },
        { status: 404 }
      );
    }

    // Return invoice data (excluding sensitive fields)
    return NextResponse.json({
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      clientName: invoice.clientName,
      clientEmail: invoice.clientEmail,
      description: invoice.description,
      items: invoice.items.map((item) => ({
        id: item.id,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        total: item.total,
      })),
      subtotal: invoice.subtotal,
      tax: invoice.tax,
      total: invoice.total,
      status: invoice.status,
      dueDate: invoice.dueDate,
      createdAt: invoice.createdAt,
      user: {
        businessName: invoice.user.businessName,
        businessEmail: invoice.user.businessEmail,
        businessPhone: invoice.user.businessPhone,
        businessAddress: invoice.user.businessAddress,
      },
    });
  } catch (error) {
    console.error("Error fetching invoice by payment token:", error);
    return NextResponse.json(
      { error: "Failed to fetch invoice" },
      { status: 500 }
    );
  }
}
