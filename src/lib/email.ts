import nodemailer from "nodemailer";

// Secure email configuration with TLS
const createTransporter = () => {
  const port = parseInt(process.env.SMTP_PORT || "587");
  const isSecurePort = port === 465;

  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port,
    secure: isSecurePort, // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
    // Enable STARTTLS for non-465 ports
    ...(!isSecurePort && {
      requireTLS: true,
      tls: {
        minVersion: "TLSv1.2",
        rejectUnauthorized: process.env.NODE_ENV === "production", // Strict in production
      },
    }),
  });
};

interface SendInvoiceEmailParams {
  to: string;
  invoiceNumber: string;
  clientName: string;
  total: number;
  dueDate: string | null;
  invoiceId: string;
  paymentToken?: string;
}

// Sanitize email content to prevent injection
function sanitizeForHtml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

export async function sendInvoiceEmail({
  to,
  invoiceNumber,
  clientName,
  total,
  dueDate,
  invoiceId,
  paymentToken,
}: SendInvoiceEmailParams) {
  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(to)) {
    throw new Error("Invalid email address");
  }

  // Sanitize all user-provided content
  const safeInvoiceNumber = sanitizeForHtml(invoiceNumber);
  const safeClientName = sanitizeForHtml(clientName);
  const safeInvoiceId = encodeURIComponent(invoiceId);

  const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";
  const viewUrl = `${appUrl}/invoices/${safeInvoiceId}`;
  const paymentUrl = paymentToken ? `${appUrl}/pay/${paymentToken}` : null;

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #333;">Invoice ${safeInvoiceNumber}</h1>
      <p>Dear ${safeClientName},</p>
      <p>Please find your invoice details below:</p>
      <div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">
        <p><strong>Invoice Number:</strong> ${safeInvoiceNumber}</p>
        <p><strong>Total Amount:</strong> $${total.toFixed(2)}</p>
        ${dueDate ? `<p><strong>Due Date:</strong> ${sanitizeForHtml(dueDate)}</p>` : ""}
      </div>
      ${
        paymentUrl
          ? `
      <p style="margin-bottom: 16px;">
        <a href="${paymentUrl}" style="background: #22c55e; color: white; padding: 14px 32px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: bold; font-size: 16px;">
          Pay Invoice Now
        </a>
      </p>
      `
          : ""
      }
      <p>
        <a href="${viewUrl}" style="background: ${paymentUrl ? "#6b7280" : "#0070f3"}; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
          View Invoice Details
        </a>
      </p>
      <p style="color: #666; font-size: 14px; margin-top: 30px;">
        If you have any questions, please don't hesitate to contact us.
      </p>
    </div>
  `;

  const transporter = createTransporter();

  await transporter.sendMail({
    from: process.env.EMAIL_FROM,
    to,
    subject: `Invoice ${safeInvoiceNumber} from Your Company`,
    html,
  });
}
