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
  viewToken: string;
  businessName?: string;
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
  viewToken,
  businessName,
}: SendInvoiceEmailParams) {
  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(to)) {
    throw new Error("Invalid email address");
  }

  // Sanitize all user-provided content
  const safeInvoiceNumber = sanitizeForHtml(invoiceNumber);
  const safeClientName = sanitizeForHtml(clientName);
  const safeBusinessName = businessName ? sanitizeForHtml(businessName) : "Your Service Provider";

  const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";
  const viewUrl = `${appUrl}/view/${viewToken}`;
  const paymentUrl = paymentToken ? `${appUrl}/pay/${paymentToken}` : null;

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin: 0; padding: 0; background-color: #f3f4f6; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
      <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f4f6; padding: 40px 20px;">
        <tr>
          <td align="center">
            <table width="600" cellpadding="0" cellspacing="0" style="max-width: 600px; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">
              <!-- Header -->
              <tr>
                <td style="background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%); padding: 40px; text-align: center;">
                  <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 700;">New Invoice</h1>
                  <p style="margin: 8px 0 0; color: rgba(255,255,255,0.9); font-size: 16px;">${safeInvoiceNumber}</p>
                </td>
              </tr>

              <!-- Content -->
              <tr>
                <td style="padding: 40px;">
                  <p style="margin: 0 0 20px; color: #374151; font-size: 16px; line-height: 1.6;">
                    Hi ${safeClientName},
                  </p>
                  <p style="margin: 0 0 30px; color: #6b7280; font-size: 15px; line-height: 1.6;">
                    ${safeBusinessName} has sent you an invoice. Please review the details below and proceed with payment at your earliest convenience.
                  </p>

                  <!-- Invoice Summary Box -->
                  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f9fafb; border-radius: 12px; margin-bottom: 30px;">
                    <tr>
                      <td style="padding: 24px;">
                        <table width="100%" cellpadding="0" cellspacing="0">
                          <tr>
                            <td style="padding-bottom: 12px; border-bottom: 1px solid #e5e7eb;">
                              <span style="color: #6b7280; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Invoice Number</span>
                              <p style="margin: 4px 0 0; color: #111827; font-size: 16px; font-weight: 600;">${safeInvoiceNumber}</p>
                            </td>
                          </tr>
                          ${dueDate ? `
                          <tr>
                            <td style="padding: 12px 0; border-bottom: 1px solid #e5e7eb;">
                              <span style="color: #6b7280; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Due Date</span>
                              <p style="margin: 4px 0 0; color: #111827; font-size: 16px; font-weight: 600;">${sanitizeForHtml(dueDate)}</p>
                            </td>
                          </tr>
                          ` : ""}
                          <tr>
                            <td style="padding-top: 12px;">
                              <span style="color: #6b7280; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Amount Due</span>
                              <p style="margin: 4px 0 0; color: #4f46e5; font-size: 28px; font-weight: 700;">$${total.toFixed(2)}</p>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>

                  <!-- CTA Button -->
                  <table width="100%" cellpadding="0" cellspacing="0">
                    <tr>
                      <td align="center" style="padding-bottom: 20px;">
                        <a href="${viewUrl}" style="display: inline-block; background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%); color: #ffffff; text-decoration: none; padding: 16px 40px; border-radius: 10px; font-size: 16px; font-weight: 600; box-shadow: 0 4px 14px rgba(79, 70, 229, 0.4);">
                          View Invoice
                        </a>
                      </td>
                    </tr>
                    ${paymentUrl ? `
                    <tr>
                      <td align="center">
                        <a href="${paymentUrl}" style="display: inline-block; background: #10b981; color: #ffffff; text-decoration: none; padding: 14px 32px; border-radius: 10px; font-size: 15px; font-weight: 600; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.4);">
                          Pay Now
                        </a>
                      </td>
                    </tr>
                    ` : ""}
                  </table>
                </td>
              </tr>

              <!-- Footer -->
              <tr>
                <td style="background-color: #f9fafb; padding: 24px 40px; text-align: center; border-top: 1px solid #e5e7eb;">
                  <p style="margin: 0; color: #9ca3af; font-size: 13px; line-height: 1.6;">
                    If you have any questions about this invoice, please contact ${safeBusinessName}.
                  </p>
                  <p style="margin: 12px 0 0; color: #9ca3af; font-size: 12px;">
                    Powered by Sosocial Invoice
                  </p>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
  `;

  const transporter = createTransporter();

  await transporter.sendMail({
    from: process.env.EMAIL_FROM,
    to,
    subject: `Invoice ${safeInvoiceNumber} from ${safeBusinessName}`,
    html,
  });
}
