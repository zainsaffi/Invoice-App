import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const body = await request.json();
    const { paymentMethod } = body;

    const invoice = await prisma.invoice.findUnique({
      where: { id },
    });

    if (!invoice) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    const updatedInvoice = await prisma.invoice.update({
      where: { id },
      data: {
        status: "paid",
        paidAt: new Date(),
        paymentMethod: paymentMethod || "other",
      },
    });

    return NextResponse.json(updatedInvoice);
  } catch (error) {
    console.error("Error marking invoice as paid:", error);
    return NextResponse.json(
      { error: "Failed to mark invoice as paid" },
      { status: 500 }
    );
  }
}
