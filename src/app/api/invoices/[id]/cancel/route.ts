import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    // Check if invoice exists
    const invoice = await prisma.invoice.findUnique({
      where: { id },
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

    return NextResponse.json(updatedInvoice);
  } catch (error) {
    console.error("Error cancelling invoice:", error);
    return NextResponse.json(
      { error: "Failed to cancel invoice" },
      { status: 500 }
    );
  }
}
