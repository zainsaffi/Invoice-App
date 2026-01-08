import { NextResponse } from "next/server";
import { auth } from "@/lib/auth";
import { query, queryOne, queryMany, InvoiceRow, PaymentRow, toPayment, transaction } from "@/db";

// GET /api/invoices/[id]/payments - Get all payments for an invoice
export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { id } = await params;

    // Verify invoice belongs to user
    const invoice = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1 AND user_id = $2",
      [id, session.user.id]
    );

    if (!invoice) {
      return NextResponse.json({ error: "Invoice not found" }, { status: 404 });
    }

    // Get all payments for this invoice
    const paymentRows = await queryMany<PaymentRow>(
      "SELECT * FROM payments WHERE invoice_id = $1 ORDER BY paid_at DESC",
      [id]
    );

    return NextResponse.json(paymentRows.map(toPayment));
  } catch (error) {
    console.error("Error fetching payments:", error);
    return NextResponse.json(
      { error: "Failed to fetch payments" },
      { status: 500 }
    );
  }
}

// POST /api/invoices/[id]/payments - Add a partial payment
export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { id } = await params;
    const body = await request.json();
    const { amount, paymentMethod, reference, notes, paidAt } = body;

    if (!amount || amount <= 0) {
      return NextResponse.json(
        { error: "Valid amount is required" },
        { status: 400 }
      );
    }

    // Use transaction to ensure consistency
    const result = await transaction(async (client) => {
      // Verify invoice belongs to user
      const invoice = await client.queryOne<InvoiceRow>(
        "SELECT * FROM invoices WHERE id = $1 AND user_id = $2",
        [id, session.user.id]
      );

      if (!invoice) {
        throw new Error("Invoice not found");
      }

      // Check if payment would exceed remaining balance
      const remaining = invoice.total - (invoice.amount_paid || 0);
      if (amount > remaining) {
        throw new Error(`Payment amount exceeds remaining balance of ${remaining}`);
      }

      // Insert payment record
      const paymentResult = await client.queryOne<PaymentRow>(
        `INSERT INTO payments (invoice_id, amount, payment_method, reference, notes, paid_at)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [id, amount, paymentMethod || null, reference || null, notes || null, paidAt || new Date()]
      );

      // Update invoice amount_paid
      const newAmountPaid = Number((invoice.amount_paid || 0)) + Number(amount);
      const isPaidInFull = newAmountPaid >= invoice.total;

      if (isPaidInFull) {
        await client.query(
          `UPDATE invoices
           SET amount_paid = $1,
               status = 'paid',
               paid_at = $2,
               payment_method = $3
           WHERE id = $4`,
          [newAmountPaid, paidAt || new Date(), paymentMethod || 'partial', id]
        );
      } else {
        await client.query(
          `UPDATE invoices
           SET amount_paid = $1
           WHERE id = $2`,
          [newAmountPaid, id]
        );
      }

      return {
        payment: paymentResult,
        isPaidInFull,
        newAmountPaid,
      };
    });

    return NextResponse.json({
      payment: toPayment(result.payment!),
      isPaidInFull: result.isPaidInFull,
      amountPaid: result.newAmountPaid,
    }, { status: 201 });
  } catch (error) {
    console.error("Error adding payment:", error);
    const message = error instanceof Error ? error.message : "Failed to add payment";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

// DELETE /api/invoices/[id]/payments?paymentId=xxx - Delete a payment
export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { id } = await params;
    const { searchParams } = new URL(request.url);
    const paymentId = searchParams.get("paymentId");

    if (!paymentId) {
      return NextResponse.json(
        { error: "Payment ID is required" },
        { status: 400 }
      );
    }

    // Use transaction to ensure consistency
    await transaction(async (client) => {
      // Verify invoice belongs to user
      const invoice = await client.queryOne<InvoiceRow>(
        "SELECT * FROM invoices WHERE id = $1 AND user_id = $2",
        [id, session.user.id]
      );

      if (!invoice) {
        throw new Error("Invoice not found");
      }

      // Get payment to delete
      const payment = await client.queryOne<PaymentRow>(
        "SELECT * FROM payments WHERE id = $1 AND invoice_id = $2",
        [paymentId, id]
      );

      if (!payment) {
        throw new Error("Payment not found");
      }

      // Delete payment
      await client.query("DELETE FROM payments WHERE id = $1", [paymentId]);

      // Update invoice amount_paid
      const newAmountPaid = Math.max(0, (invoice.amount_paid || 0) - payment.amount);

      // If status was 'paid' and we're removing payment, set back to previous status
      const newStatus = invoice.status === 'paid' && newAmountPaid < invoice.total
        ? (invoice.email_sent_at ? 'sent' : 'draft')
        : invoice.status;

      await client.query(
        `UPDATE invoices
         SET amount_paid = $1,
             status = $2,
             paid_at = CASE WHEN $2 != 'paid' THEN NULL ELSE paid_at END
         WHERE id = $3`,
        [newAmountPaid, newStatus, id]
      );
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error deleting payment:", error);
    const message = error instanceof Error ? error.message : "Failed to delete payment";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
