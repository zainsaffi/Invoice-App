import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { sendInvoiceEmail } from "@/lib/email";
import { formatDate } from "@/lib/utils";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const invoice = await prisma.invoice.findUnique({
      where: { id },
    });

    if (!invoice) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
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

    return NextResponse.json(updatedInvoice);
  } catch (error) {
    console.error("Error sending invoice:", error);
    return NextResponse.json(
      { error: "Failed to send invoice email" },
      { status: 500 }
    );
  }
}
