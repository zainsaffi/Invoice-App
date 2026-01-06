import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT || "587"),
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

interface SendInvoiceEmailParams {
  to: string;
  invoiceNumber: string;
  clientName: string;
  total: number;
  dueDate: string | null;
  invoiceId: string;
}

export async function sendInvoiceEmail({
  to,
  invoiceNumber,
  clientName,
  total,
  dueDate,
  invoiceId,
}: SendInvoiceEmailParams) {
  const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";
  const viewUrl = `${appUrl}/invoices/${invoiceId}`;

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #333;">Invoice ${invoiceNumber}</h1>
      <p>Dear ${clientName},</p>
      <p>Please find your invoice details below:</p>
      <div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">
        <p><strong>Invoice Number:</strong> ${invoiceNumber}</p>
        <p><strong>Total Amount:</strong> $${total.toFixed(2)}</p>
        ${dueDate ? `<p><strong>Due Date:</strong> ${dueDate}</p>` : ""}
      </div>
      <p>
        <a href="${viewUrl}" style="background: #0070f3; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
          View Invoice
        </a>
      </p>
      <p style="color: #666; font-size: 14px; margin-top: 30px;">
        If you have any questions, please don't hesitate to contact us.
      </p>
    </div>
  `;

  await transporter.sendMail({
    from: process.env.EMAIL_FROM,
    to,
    subject: `Invoice ${invoiceNumber} from Your Company`,
    html,
  });
}
