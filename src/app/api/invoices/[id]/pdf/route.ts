import { NextResponse } from "next/server";
import { queryOne, queryMany, InvoiceRow, InvoiceItemRow, ReceiptRow, UserRow, toInvoice, toInvoiceItem, toReceipt } from "@/db";
import React from "react";
import { renderToBuffer } from "@react-pdf/renderer";
import { Document, Page, Text, View, StyleSheet, Image } from "@react-pdf/renderer";
import fs from "fs";
import path from "path";

// Modern, clean PDF styles
const styles = StyleSheet.create({
  page: {
    padding: 0,
    fontFamily: "Helvetica",
    fontSize: 10,
    color: "#1F2937",
    backgroundColor: "#FFFFFF",
  },
  // Top accent bar
  accentBar: {
    height: 4,
    backgroundColor: "#4F46E5",
  },
  // Main content container
  content: {
    padding: "20 35",
    paddingBottom: 60,
  },
  // Header section
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    marginBottom: 18,
  },
  brandSection: {
    flex: 1,
  },
  logo: {
    fontSize: 22,
    fontFamily: "Helvetica-Bold",
    color: "#4F46E5",
    marginBottom: 4,
  },
  tagline: {
    fontSize: 9,
    color: "#9CA3AF",
    letterSpacing: 0.5,
  },
  invoiceInfo: {
    alignItems: "flex-end",
  },
  invoiceLabel: {
    fontSize: 32,
    fontFamily: "Helvetica-Bold",
    color: "#111827",
    letterSpacing: 2,
  },
  invoiceNumber: {
    fontSize: 11,
    color: "#6B7280",
    marginTop: 4,
    marginBottom: 10,
  },
  // Status badge
  statusBadge: {
    paddingVertical: 4,
    paddingHorizontal: 12,
    borderRadius: 12,
    fontSize: 9,
    fontFamily: "Helvetica-Bold",
    letterSpacing: 0.5,
  },
  statusDraft: { backgroundColor: "#F3F4F6", color: "#4B5563" },
  statusDue: { backgroundColor: "#FEF3C7", color: "#B45309" },
  statusOverdue: { backgroundColor: "#FEE2E2", color: "#DC2626" },
  statusPaid: { backgroundColor: "#D1FAE5", color: "#059669" },
  statusCancelled: { backgroundColor: "#F3F4F6", color: "#9CA3AF" },
  statusPartial: { backgroundColor: "#DBEAFE", color: "#1D4ED8" },
  // Info cards row
  infoRow: {
    flexDirection: "row",
    gap: 15,
    marginBottom: 15,
  },
  infoCard: {
    flex: 1,
    backgroundColor: "#F9FAFB",
    borderRadius: 8,
    padding: 12,
    borderLeftWidth: 3,
    borderLeftColor: "#4F46E5",
  },
  infoCardTitle: {
    fontSize: 8,
    fontFamily: "Helvetica-Bold",
    color: "#6B7280",
    textTransform: "uppercase",
    letterSpacing: 1,
    marginBottom: 5,
  },
  infoCardName: {
    fontSize: 11,
    fontFamily: "Helvetica-Bold",
    color: "#111827",
    marginBottom: 2,
  },
  infoCardText: {
    fontSize: 9,
    color: "#6B7280",
    marginBottom: 2,
  },
  // Details card (right side)
  detailsCard: {
    flex: 1,
    backgroundColor: "#F9FAFB",
    borderRadius: 8,
    padding: 12,
  },
  detailRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 6,
  },
  detailLabel: {
    fontSize: 9,
    color: "#6B7280",
  },
  detailValue: {
    fontSize: 9,
    fontFamily: "Helvetica-Bold",
    color: "#111827",
  },
  // Description section
  descriptionSection: {
    marginBottom: 12,
  },
  descriptionLabel: {
    fontSize: 8,
    fontFamily: "Helvetica-Bold",
    color: "#6B7280",
    textTransform: "uppercase",
    letterSpacing: 1,
    marginBottom: 6,
  },
  descriptionText: {
    fontSize: 10,
    color: "#374151",
    lineHeight: 1.5,
  },
  // Items table
  table: {
    marginBottom: 12,
  },
  tableHeader: {
    flexDirection: "row",
    backgroundColor: "#4F46E5",
    paddingVertical: 8,
    paddingHorizontal: 10,
    borderRadius: 6,
  },
  tableHeaderText: {
    fontSize: 8,
    fontFamily: "Helvetica-Bold",
    color: "#FFFFFF",
    textTransform: "uppercase",
    letterSpacing: 0.5,
  },
  tableRow: {
    flexDirection: "row",
    paddingVertical: 8,
    paddingHorizontal: 10,
    borderBottomWidth: 1,
    borderBottomColor: "#F3F4F6",
  },
  tableRowAlt: {
    backgroundColor: "#FAFAFA",
  },
  tableCol1: { width: "45%" },
  tableCol2: { width: "15%", textAlign: "center" },
  tableCol3: { width: "20%", textAlign: "right" },
  tableCol4: { width: "20%", textAlign: "right" },
  tableText: {
    fontSize: 10,
    color: "#374151",
  },
  tableTextBold: {
    fontSize: 10,
    fontFamily: "Helvetica-Bold",
    color: "#111827",
  },
  itemTitle: {
    fontSize: 10,
    fontFamily: "Helvetica-Bold",
    color: "#111827",
    marginBottom: 2,
  },
  itemDescription: {
    fontSize: 9,
    color: "#6B7280",
    lineHeight: 1.4,
  },
  itemDescriptionLine: {
    flexDirection: "row",
    flexWrap: "wrap",
    marginBottom: 2,
  },
  itemDescriptionLabel: {
    fontSize: 9,
    fontFamily: "Helvetica-Bold",
    color: "#374151",
  },
  itemDescriptionValue: {
    fontSize: 9,
    color: "#6B7280",
  },
  // Totals section
  totalsContainer: {
    flexDirection: "row",
    justifyContent: "flex-end",
    marginBottom: 12,
  },
  totalsBox: {
    width: 220,
    backgroundColor: "#F9FAFB",
    borderRadius: 8,
    padding: 12,
  },
  totalRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 6,
  },
  totalLabel: {
    fontSize: 10,
    color: "#6B7280",
  },
  totalValue: {
    fontSize: 10,
    color: "#111827",
  },
  totalDivider: {
    height: 1,
    backgroundColor: "#E5E7EB",
    marginVertical: 6,
  },
  grandTotalRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    paddingTop: 6,
  },
  grandTotalLabel: {
    fontSize: 12,
    fontFamily: "Helvetica-Bold",
    color: "#111827",
  },
  grandTotalValue: {
    fontSize: 14,
    fontFamily: "Helvetica-Bold",
    color: "#4F46E5",
  },
  paidRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 6,
    paddingTop: 6,
    borderTopWidth: 1,
    borderTopColor: "#E5E7EB",
  },
  paidLabel: {
    fontSize: 10,
    color: "#059669",
  },
  paidValue: {
    fontSize: 10,
    fontFamily: "Helvetica-Bold",
    color: "#059669",
  },
  balanceLabel: {
    fontSize: 11,
    fontFamily: "Helvetica-Bold",
    color: "#DC2626",
  },
  balanceValue: {
    fontSize: 12,
    fontFamily: "Helvetica-Bold",
    color: "#DC2626",
  },
  // Payment instructions
  paymentInstructionsBox: {
    backgroundColor: "#FFFBEB",
    borderRadius: 8,
    padding: 12,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: "#FDE68A",
  },
  paymentInstructionsTitle: {
    fontSize: 9,
    fontFamily: "Helvetica-Bold",
    color: "#B45309",
    textTransform: "uppercase",
    letterSpacing: 0.5,
    marginBottom: 5,
  },
  paymentInstructionsText: {
    fontSize: 9,
    color: "#78350F",
    lineHeight: 1.5,
  },
  // Footer
  footer: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: "#F9FAFB",
    paddingVertical: 12,
    paddingHorizontal: 35,
    borderTopWidth: 1,
    borderTopColor: "#E5E7EB",
  },
  footerContent: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  footerText: {
    fontSize: 8,
    color: "#9CA3AF",
  },
  footerThankYou: {
    fontSize: 9,
    fontFamily: "Helvetica-Bold",
    color: "#4F46E5",
  },
  // Attachment page styles
  attachmentPage: {
    padding: 0,
    fontFamily: "Helvetica",
    display: "flex",
    flexDirection: "column",
  },
  attachmentContent: {
    flex: 1,
    padding: 40,
    paddingTop: 30,
    display: "flex",
    flexDirection: "column",
  },
  attachmentHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 25,
    paddingBottom: 15,
    borderBottomWidth: 1,
    borderBottomColor: "#E5E7EB",
  },
  attachmentTitle: {
    fontSize: 14,
    fontFamily: "Helvetica-Bold",
    color: "#374151",
  },
  attachmentSubtitle: {
    fontSize: 9,
    color: "#9CA3AF",
    marginTop: 3,
  },
  attachmentCounter: {
    fontSize: 9,
    color: "#6B7280",
    backgroundColor: "#F3F4F6",
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 10,
  },
  attachmentImageContainer: {
    flex: 1,
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
  },
  attachmentImage: {
    maxWidth: "100%",
    maxHeight: 650,
    objectFit: "contain",
  },
  attachmentFilename: {
    fontSize: 9,
    color: "#9CA3AF",
    textAlign: "center",
    marginTop: 15,
    fontStyle: "italic",
  },
  pageNumber: {
    position: "absolute",
    bottom: 25,
    right: 40,
    fontSize: 8,
    color: "#9CA3AF",
  },
});

function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(amount);
}

function formatDate(date: Date | string | null): string {
  if (!date) return "-";
  return new Date(date).toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

function getDisplayStatus(invoice: {
  status: string;
  dueDate: Date | string | null;
  emailSentAt: Date | string | null;
  amountPaid?: number;
  total?: number;
}): string {
  if (invoice.status === "cancelled") return "cancelled";

  // Check for partial payment
  if (invoice.amountPaid && invoice.total && invoice.amountPaid > 0 && invoice.amountPaid < invoice.total) {
    return "partial";
  }

  // Fully paid
  if (invoice.status === "paid" || (invoice.amountPaid && invoice.total && invoice.amountPaid >= invoice.total)) {
    return "paid";
  }

  if (invoice.status === "draft" || !invoice.emailSentAt) return "draft";
  if (invoice.dueDate) {
    const now = new Date();
    const dueDate = new Date(invoice.dueDate);
    dueDate.setHours(23, 59, 59, 999);
    if (now > dueDate) return "overdue";
    return "due";
  }
  return "sent";
}

function isImageFile(mimeType: string): boolean {
  return mimeType.startsWith("image/");
}

// Helper to render item description with labels in bold
function renderFormattedDescription(description: string, styles: any): React.ReactElement[] {
  const lines = description.split('\n').filter(line => line.trim() !== '');

  return lines.map((line, lineIndex) => {
    // Check if the line has a label pattern (text followed by colon)
    const colonIndex = line.indexOf(':');

    if (colonIndex > 0 && colonIndex < 30) {
      // This line has a label - split into label and value
      const label = line.substring(0, colonIndex + 1); // Include the colon
      const value = line.substring(colonIndex + 1).trim();

      return React.createElement(
        View,
        { key: lineIndex, style: styles.itemDescriptionLine },
        React.createElement(Text, { style: styles.itemDescriptionLabel }, label + ' '),
        value && React.createElement(Text, { style: styles.itemDescriptionValue }, value)
      );
    } else {
      // Regular line without label - just render as normal text
      return React.createElement(
        View,
        { key: lineIndex, style: styles.itemDescriptionLine },
        React.createElement(Text, { style: styles.itemDescriptionValue }, line)
      );
    }
  });
}

// Helper to render multi-line text (preserves line breaks)
function renderMultilineText(text: string, textStyle: any): React.ReactElement[] {
  const lines = text.split('\n');
  return lines.map((line, index) =>
    React.createElement(Text, { key: index, style: textStyle }, line || ' ')
  );
}

// Get attachment type label for PDF
function getAttachmentTypeLabel(type: string): string {
  const labels: Record<string, string> = {
    'receipt': 'Receipt',
    'contract': 'Contract',
    'quote': 'Quote',
    'supporting_document': 'Supporting Document',
    'photo': 'Photo',
    'other': 'Attachment',
  };
  return labels[type] || 'Attachment';
}

// Payment details type
type PaymentDetails = {
  businessName?: string | null;
  bankName?: string | null;
  accountName?: string | null;
  accountNumber?: string | null;
  routingNumber?: string | null;
  iban?: string | null;
  paypalEmail?: string | null;
  paymentNotes?: string | null;
};

// Invoice PDF Component
const InvoicePDF = ({ invoice, imageAttachments, paymentDetails }: {
  invoice: any;
  imageAttachments: { filename: string; data: string; mimeType: string; attachmentType: string }[];
  paymentDetails: PaymentDetails;
}) => {
  const status = getDisplayStatus(invoice);
  const statusStyle = {
    draft: styles.statusDraft,
    due: styles.statusDue,
    overdue: styles.statusOverdue,
    partial: styles.statusPartial,
    paid: styles.statusPaid,
    cancelled: styles.statusCancelled,
    sent: styles.statusDue,
  }[status] || styles.statusDraft;

  const statusLabels: Record<string, string> = {
    draft: "DRAFT",
    due: "PENDING",
    overdue: "OVERDUE",
    partial: "PARTIAL",
    paid: "PAID",
    cancelled: "CANCELLED",
    sent: "SENT",
  };

  const pages = [];

  // Main invoice page
  pages.push(
    React.createElement(
      Page,
      { key: "main", size: "A4", style: styles.page },
      // Top accent bar
      React.createElement(View, { style: styles.accentBar }),
      // Main content
      React.createElement(
        View,
        { style: styles.content },
        // Header
        React.createElement(
          View,
          { style: styles.header },
          React.createElement(
            View,
            { style: styles.brandSection },
            React.createElement(Text, { style: styles.logo }, paymentDetails.businessName || "Invoice"),
            React.createElement(Text, { style: styles.tagline }, "Professional Invoice")
          ),
          React.createElement(
            View,
            { style: styles.invoiceInfo },
            React.createElement(Text, { style: styles.invoiceLabel }, "INVOICE"),
            React.createElement(Text, { style: styles.invoiceNumber }, invoice.invoiceNumber),
            React.createElement(
              View,
              { style: [styles.statusBadge, statusStyle] },
              React.createElement(Text, null, statusLabels[status] || status.toUpperCase())
            )
          )
        ),
        // Info cards row
        React.createElement(
          View,
          { style: styles.infoRow },
          // Bill To card
          React.createElement(
            View,
            { style: styles.infoCard },
            React.createElement(Text, { style: styles.infoCardTitle }, "Bill To"),
            React.createElement(Text, { style: styles.infoCardName }, invoice.clientName),
            React.createElement(Text, { style: styles.infoCardText }, invoice.clientEmail),
            invoice.clientBusinessName && React.createElement(Text, { style: styles.infoCardText }, invoice.clientBusinessName),
            invoice.clientAddress && React.createElement(Text, { style: styles.infoCardText }, invoice.clientAddress)
          ),
          // Invoice Details card
          React.createElement(
            View,
            { style: styles.detailsCard },
            React.createElement(Text, { style: styles.infoCardTitle }, "Invoice Details"),
            React.createElement(
              View,
              { style: styles.detailRow },
              React.createElement(Text, { style: styles.detailLabel }, "Issue Date"),
              React.createElement(Text, { style: styles.detailValue }, formatDate(invoice.createdAt))
            ),
            invoice.dueDate && React.createElement(
              View,
              { style: styles.detailRow },
              React.createElement(Text, { style: styles.detailLabel }, "Due Date"),
              React.createElement(Text, { style: styles.detailValue }, formatDate(invoice.dueDate))
            ),
            React.createElement(
              View,
              { style: styles.detailRow },
              React.createElement(Text, { style: styles.detailLabel }, "Invoice #"),
              React.createElement(Text, { style: styles.detailValue }, invoice.invoiceNumber)
            )
          )
        ),
        // Description (if exists)
        invoice.description && React.createElement(
          View,
          { style: styles.descriptionSection },
          React.createElement(Text, { style: styles.descriptionLabel }, "Description"),
          ...renderMultilineText(invoice.description, styles.descriptionText)
        ),
        // Items Table
        React.createElement(
          View,
          { style: styles.table },
          // Table Header
          React.createElement(
            View,
            { style: styles.tableHeader },
            React.createElement(Text, { style: [styles.tableHeaderText, styles.tableCol1] }, "Item"),
            React.createElement(Text, { style: [styles.tableHeaderText, styles.tableCol2] }, "Qty"),
            React.createElement(Text, { style: [styles.tableHeaderText, styles.tableCol3] }, "Unit Price"),
            React.createElement(Text, { style: [styles.tableHeaderText, styles.tableCol4] }, "Amount")
          ),
          // Table Rows
          invoice.items.map((item: any, index: number) =>
            React.createElement(
              View,
              { key: index, style: [styles.tableRow, index % 2 === 1 ? styles.tableRowAlt : {}] },
              React.createElement(
                View,
                { style: styles.tableCol1 },
                React.createElement(Text, { style: styles.itemTitle }, item.title || "Item"),
                item.description && React.createElement(
                  View,
                  { style: { marginTop: 4 } },
                  ...renderFormattedDescription(item.description, styles)
                )
              ),
              React.createElement(Text, { style: [styles.tableText, styles.tableCol2] }, item.quantity.toString()),
              React.createElement(Text, { style: [styles.tableText, styles.tableCol3] }, formatCurrency(item.unitPrice)),
              React.createElement(Text, { style: [styles.tableTextBold, styles.tableCol4] }, formatCurrency(item.total || item.quantity * item.unitPrice))
            )
          )
        ),
        // Totals
        React.createElement(
          View,
          { style: styles.totalsContainer },
          React.createElement(
            View,
            { style: styles.totalsBox },
            React.createElement(
              View,
              { style: styles.totalRow },
              React.createElement(Text, { style: styles.totalLabel }, "Subtotal"),
              React.createElement(Text, { style: styles.totalValue }, formatCurrency(invoice.subtotal))
            ),
            React.createElement(
              View,
              { style: styles.totalRow },
              React.createElement(Text, { style: styles.totalLabel }, "Tax"),
              React.createElement(Text, { style: styles.totalValue }, formatCurrency(invoice.tax))
            ),
            React.createElement(View, { style: styles.totalDivider }),
            React.createElement(
              View,
              { style: styles.grandTotalRow },
              React.createElement(Text, { style: styles.grandTotalLabel }, "Total"),
              React.createElement(Text, { style: styles.grandTotalValue }, formatCurrency(invoice.total))
            ),
            // Amount Paid (if any)
            (invoice.amountPaid > 0) && React.createElement(
              View,
              { style: styles.paidRow },
              React.createElement(Text, { style: styles.paidLabel }, "Amount Paid"),
              React.createElement(Text, { style: styles.paidValue }, formatCurrency(invoice.amountPaid))
            ),
            // Balance Due (if partial)
            (invoice.amountPaid > 0 && invoice.amountPaid < invoice.total) && React.createElement(
              View,
              { style: [styles.totalRow, { marginTop: 8 }] },
              React.createElement(Text, { style: styles.balanceLabel }, "Balance Due"),
              React.createElement(Text, { style: styles.balanceValue }, formatCurrency(invoice.total - invoice.amountPaid))
            )
          )
        ),
        // Payment Instructions (if exists)
        invoice.paymentInstructions && React.createElement(
          View,
          { style: styles.paymentInstructionsBox, wrap: false },
          React.createElement(Text, { style: styles.paymentInstructionsTitle }, "Payment Instructions"),
          ...renderMultilineText(invoice.paymentInstructions, styles.paymentInstructionsText)
        )
      ),
      // Footer
      React.createElement(
        View,
        { style: styles.footer },
        React.createElement(
          View,
          { style: styles.footerContent },
          React.createElement(Text, { style: styles.footerThankYou }, "Thank you for your business!"),
          React.createElement(
            View,
            { style: { alignItems: "flex-end" } },
            React.createElement(Text, { style: styles.footerText }, `Generated on ${formatDate(new Date())}`),
            imageAttachments.length > 0 && React.createElement(
              Text,
              { style: styles.footerText },
              `${imageAttachments.length} attachment${imageAttachments.length > 1 ? 's' : ''} included`
            )
          )
        )
      )
    )
  );

  // Add attachment pages for each image
  imageAttachments.forEach((attachment, index) => {
    const typeLabel = getAttachmentTypeLabel(attachment.attachmentType);
    pages.push(
      React.createElement(
        Page,
        { key: `attachment-${index}`, size: "A4", style: styles.attachmentPage },
        // Top accent bar
        React.createElement(View, { style: styles.accentBar }),
        // Content
        React.createElement(
          View,
          { style: styles.attachmentContent },
          // Header
          React.createElement(
            View,
            { style: styles.attachmentHeader },
            React.createElement(
              View,
              null,
              React.createElement(Text, { style: styles.attachmentTitle }, typeLabel),
              React.createElement(Text, { style: styles.attachmentSubtitle }, invoice.invoiceNumber)
            ),
            React.createElement(Text, { style: styles.attachmentCounter }, `${index + 1} of ${imageAttachments.length}`)
          ),
          // Image
          React.createElement(
            View,
            { style: styles.attachmentImageContainer },
            React.createElement(Image, {
              style: styles.attachmentImage,
              src: attachment.data,
            }),
            React.createElement(Text, { style: styles.attachmentFilename }, attachment.filename)
          )
        ),
        // Page number
        React.createElement(Text, { style: styles.pageNumber }, `Page ${index + 2}`)
      )
    );
  });

  return React.createElement(Document, null, ...pages);
};

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    // Fetch invoice
    const invoiceRow = await queryOne<InvoiceRow>(
      "SELECT * FROM invoices WHERE id = $1",
      [id]
    );

    if (!invoiceRow) {
      return NextResponse.json(
        { error: "Invoice not found" },
        { status: 404 }
      );
    }

    const invoice = toInvoice(invoiceRow);

    // Fetch items
    const itemRows = await queryMany<InvoiceItemRow>(
      "SELECT * FROM invoice_items WHERE invoice_id = $1",
      [id]
    );

    // Fetch receipts
    const receiptRows = await queryMany<ReceiptRow>(
      "SELECT * FROM receipts WHERE invoice_id = $1",
      [id]
    );

    // Fetch user payment details
    const userRow = await queryOne<Pick<UserRow, 'business_name' | 'bank_name' | 'account_name' | 'account_number' | 'routing_number' | 'iban' | 'paypal_email' | 'payment_notes'>>(
      `SELECT business_name, bank_name, account_name, account_number, routing_number, iban, paypal_email, payment_notes
      FROM users WHERE id = $1`,
      [invoice.userId]
    );

    const invoiceWithRelations = {
      ...invoice,
      items: itemRows.map(toInvoiceItem),
      receipts: receiptRows.map(toReceipt),
    };

    // Load image attachments
    const imageAttachments: { filename: string; data: string; mimeType: string; attachmentType: string }[] = [];

    for (const receipt of invoiceWithRelations.receipts) {
      if (isImageFile(receipt.mimeType)) {
        try {
          // Extract the actual file path from the stored API path
          // Format: /api/receipts/{userId}/{invoiceId}/{filename}
          const pathParts = receipt.filepath.split("/");
          const filename = pathParts[pathParts.length - 1];
          const invoiceId = pathParts[pathParts.length - 2];
          const userId = pathParts[pathParts.length - 3];

          // Build the actual file path in uploads folder
          const filePath = path.join(process.cwd(), "uploads", userId, invoiceId, filename);

          if (fs.existsSync(filePath)) {
            const fileBuffer = fs.readFileSync(filePath);
            const base64Data = fileBuffer.toString("base64");
            const dataUri = `data:${receipt.mimeType};base64,${base64Data}`;

            imageAttachments.push({
              filename: receipt.filename,
              data: dataUri,
              mimeType: receipt.mimeType,
              attachmentType: receipt.attachmentType,
            });
          } else {
            console.error(`Attachment file not found: ${filePath}`);
          }
        } catch (err) {
          console.error(`Error loading attachment ${receipt.filename}:`, err);
        }
      }
    }

    // Extract payment details from user
    const paymentDetails: PaymentDetails = userRow ? {
      businessName: userRow.business_name,
      bankName: userRow.bank_name,
      accountName: userRow.account_name,
      accountNumber: userRow.account_number,
      routingNumber: userRow.routing_number,
      iban: userRow.iban,
      paypalEmail: userRow.paypal_email,
      paymentNotes: userRow.payment_notes,
    } : {};

    // Generate PDF
    const pdfBuffer = await renderToBuffer(
      React.createElement(InvoicePDF, { invoice: invoiceWithRelations, imageAttachments, paymentDetails }) as any
    );

    // Return PDF as response
    return new NextResponse(Buffer.from(pdfBuffer), {
      headers: {
        "Content-Type": "application/pdf",
        "Content-Disposition": `attachment; filename="${invoice.invoiceNumber}.pdf"`,
      },
    });
  } catch (error) {
    console.error("Error generating PDF:", error);
    return NextResponse.json(
      { error: "Failed to generate PDF" },
      { status: 500 }
    );
  }
}
