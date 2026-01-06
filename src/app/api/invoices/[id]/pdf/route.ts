import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import React from "react";
import { renderToBuffer } from "@react-pdf/renderer";
import { Document, Page, Text, View, StyleSheet, Image } from "@react-pdf/renderer";
import fs from "fs";
import path from "path";

// Create styles for PDF
const styles = StyleSheet.create({
  page: {
    padding: 40,
    fontFamily: "Helvetica",
    fontSize: 10,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 40,
  },
  logo: {
    fontSize: 24,
    fontWeight: "bold",
    color: "#4F46E5",
  },
  invoiceTitle: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#111827",
  },
  invoiceNumber: {
    fontSize: 12,
    color: "#6B7280",
    marginTop: 4,
  },
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 12,
    fontWeight: "bold",
    color: "#374151",
    marginBottom: 8,
    textTransform: "uppercase",
  },
  row: {
    flexDirection: "row",
    marginBottom: 4,
  },
  label: {
    color: "#6B7280",
    width: 100,
  },
  value: {
    color: "#111827",
    fontWeight: "bold",
  },
  table: {
    marginTop: 20,
  },
  tableHeader: {
    flexDirection: "row",
    backgroundColor: "#F3F4F6",
    padding: 10,
    borderBottomWidth: 1,
    borderBottomColor: "#E5E7EB",
  },
  tableRow: {
    flexDirection: "row",
    padding: 10,
    borderBottomWidth: 1,
    borderBottomColor: "#E5E7EB",
  },
  tableCol1: { width: "50%" },
  tableCol2: { width: "15%", textAlign: "right" },
  tableCol3: { width: "15%", textAlign: "right" },
  tableCol4: { width: "20%", textAlign: "right" },
  tableHeaderText: {
    fontSize: 9,
    fontWeight: "bold",
    color: "#6B7280",
    textTransform: "uppercase",
  },
  tableText: {
    fontSize: 10,
    color: "#374151",
  },
  totals: {
    marginTop: 20,
    alignItems: "flex-end",
  },
  totalRow: {
    flexDirection: "row",
    marginBottom: 8,
    width: 200,
    justifyContent: "space-between",
  },
  totalLabel: {
    color: "#6B7280",
  },
  totalValue: {
    color: "#111827",
    fontWeight: "bold",
  },
  grandTotal: {
    flexDirection: "row",
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 2,
    borderTopColor: "#4F46E5",
    width: 200,
    justifyContent: "space-between",
  },
  grandTotalLabel: {
    fontSize: 14,
    fontWeight: "bold",
    color: "#111827",
  },
  grandTotalValue: {
    fontSize: 14,
    fontWeight: "bold",
    color: "#4F46E5",
  },
  footer: {
    position: "absolute",
    bottom: 40,
    left: 40,
    right: 40,
    textAlign: "center",
    color: "#9CA3AF",
    fontSize: 9,
    borderTopWidth: 1,
    borderTopColor: "#E5E7EB",
    paddingTop: 20,
  },
  status: {
    padding: "4 12",
    borderRadius: 4,
    fontSize: 10,
    fontWeight: "bold",
  },
  statusDraft: {
    backgroundColor: "#F3F4F6",
    color: "#374151",
  },
  statusDue: {
    backgroundColor: "#FEF3C7",
    color: "#92400E",
  },
  statusOverdue: {
    backgroundColor: "#FEE2E2",
    color: "#991B1B",
  },
  statusPaid: {
    backgroundColor: "#D1FAE5",
    color: "#065F46",
  },
  statusCancelled: {
    backgroundColor: "#F3F4F6",
    color: "#6B7280",
  },
  // Attachment page styles
  attachmentPage: {
    padding: 40,
    fontFamily: "Helvetica",
  },
  attachmentHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 20,
    paddingBottom: 20,
    borderBottomWidth: 1,
    borderBottomColor: "#E5E7EB",
  },
  attachmentTitle: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#374151",
  },
  attachmentSubtitle: {
    fontSize: 10,
    color: "#6B7280",
    marginTop: 4,
  },
  attachmentImageContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  attachmentImage: {
    maxWidth: "100%",
    maxHeight: 650,
    objectFit: "contain",
  },
  attachmentFilename: {
    fontSize: 10,
    color: "#6B7280",
    textAlign: "center",
    marginTop: 10,
  },
  pageNumber: {
    position: "absolute",
    bottom: 30,
    right: 40,
    fontSize: 9,
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
    month: "long",
    day: "numeric",
  });
}

function getDisplayStatus(invoice: {
  status: string;
  dueDate: Date | string | null;
  emailSentAt: Date | string | null;
}): string {
  if (invoice.status === "cancelled") return "cancelled";
  if (invoice.status === "paid") return "paid";
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

// Invoice PDF Component
const InvoicePDF = ({ invoice, imageAttachments }: { invoice: any; imageAttachments: { filename: string; data: string; mimeType: string }[] }) => {
  const status = getDisplayStatus(invoice);
  const statusStyle = {
    draft: styles.statusDraft,
    due: styles.statusDue,
    overdue: styles.statusOverdue,
    paid: styles.statusPaid,
    cancelled: styles.statusCancelled,
    sent: styles.statusDue,
  }[status] || styles.statusDraft;

  const pages = [];

  // Main invoice page
  pages.push(
    React.createElement(
      Page,
      { key: "main", size: "A4", style: styles.page },
      // Header
      React.createElement(
        View,
        { style: styles.header },
        React.createElement(
          View,
          null,
          React.createElement(Text, { style: styles.logo }, "InvoiceApp"),
          React.createElement(Text, { style: { fontSize: 9, color: "#6B7280", marginTop: 4 } }, "Professional Invoicing")
        ),
        React.createElement(
          View,
          { style: { alignItems: "flex-end" } },
          React.createElement(Text, { style: styles.invoiceTitle }, "INVOICE"),
          React.createElement(Text, { style: styles.invoiceNumber }, invoice.invoiceNumber),
          React.createElement(
            View,
            { style: [styles.status, statusStyle, { marginTop: 8 }] },
            React.createElement(Text, null, status.toUpperCase())
          )
        )
      ),
      // Bill To & Invoice Details
      React.createElement(
        View,
        { style: { flexDirection: "row", marginBottom: 30 } },
        React.createElement(
          View,
          { style: { flex: 1 } },
          React.createElement(Text, { style: styles.sectionTitle }, "Bill To"),
          React.createElement(Text, { style: { fontWeight: "bold", marginBottom: 4 } }, invoice.clientName),
          React.createElement(Text, { style: { color: "#6B7280" } }, invoice.clientEmail),
          invoice.clientAddress && React.createElement(Text, { style: { color: "#6B7280", marginTop: 4 } }, invoice.clientAddress)
        ),
        React.createElement(
          View,
          { style: { flex: 1, alignItems: "flex-end" } },
          React.createElement(Text, { style: styles.sectionTitle }, "Invoice Details"),
          React.createElement(
            View,
            { style: styles.row },
            React.createElement(Text, { style: styles.label }, "Date:"),
            React.createElement(Text, { style: styles.value }, formatDate(invoice.createdAt))
          ),
          invoice.dueDate && React.createElement(
            View,
            { style: styles.row },
            React.createElement(Text, { style: styles.label }, "Due Date:"),
            React.createElement(Text, { style: styles.value }, formatDate(invoice.dueDate))
          )
        )
      ),
      // Description
      invoice.description && React.createElement(
        View,
        { style: styles.section },
        React.createElement(Text, { style: styles.sectionTitle }, "Description"),
        React.createElement(Text, { style: { color: "#374151" } }, invoice.description)
      ),
      // Items Table
      React.createElement(
        View,
        { style: styles.table },
        React.createElement(
          View,
          { style: styles.tableHeader },
          React.createElement(Text, { style: [styles.tableHeaderText, styles.tableCol1] }, "Description"),
          React.createElement(Text, { style: [styles.tableHeaderText, styles.tableCol2] }, "Qty"),
          React.createElement(Text, { style: [styles.tableHeaderText, styles.tableCol3] }, "Price"),
          React.createElement(Text, { style: [styles.tableHeaderText, styles.tableCol4] }, "Total")
        ),
        invoice.items.map((item: any, index: number) =>
          React.createElement(
            View,
            { key: index, style: styles.tableRow },
            React.createElement(Text, { style: [styles.tableText, styles.tableCol1] }, item.description),
            React.createElement(Text, { style: [styles.tableText, styles.tableCol2] }, item.quantity.toString()),
            React.createElement(Text, { style: [styles.tableText, styles.tableCol3] }, formatCurrency(item.unitPrice)),
            React.createElement(Text, { style: [styles.tableText, styles.tableCol4] }, formatCurrency(item.total || item.quantity * item.unitPrice))
          )
        )
      ),
      // Totals
      React.createElement(
        View,
        { style: styles.totals },
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
        React.createElement(
          View,
          { style: styles.grandTotal },
          React.createElement(Text, { style: styles.grandTotalLabel }, "Total"),
          React.createElement(Text, { style: styles.grandTotalValue }, formatCurrency(invoice.total))
        )
      ),
      // Footer
      React.createElement(
        View,
        { style: styles.footer },
        React.createElement(Text, null, "Thank you for your business!"),
        React.createElement(Text, { style: { marginTop: 4 } }, `Generated on ${formatDate(new Date())}`),
        imageAttachments.length > 0 && React.createElement(
          Text,
          { style: { marginTop: 4 } },
          `${imageAttachments.length} attachment${imageAttachments.length > 1 ? 's' : ''} included`
        )
      )
    )
  );

  // Add attachment pages for each image
  imageAttachments.forEach((attachment, index) => {
    pages.push(
      React.createElement(
        Page,
        { key: `attachment-${index}`, size: "A4", style: styles.attachmentPage },
        // Header
        React.createElement(
          View,
          { style: styles.attachmentHeader },
          React.createElement(
            View,
            null,
            React.createElement(Text, { style: styles.attachmentTitle }, "Attachment"),
            React.createElement(Text, { style: styles.attachmentSubtitle }, `${invoice.invoiceNumber} - Page ${index + 2}`)
          ),
          React.createElement(
            View,
            { style: { alignItems: "flex-end" } },
            React.createElement(Text, { style: { fontSize: 10, color: "#6B7280" } }, `${index + 1} of ${imageAttachments.length}`)
          )
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
        ),
        // Page number
        React.createElement(
          Text,
          { style: styles.pageNumber },
          `Page ${index + 2}`
        )
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

    const invoice = await prisma.invoice.findUnique({
      where: { id },
      include: {
        items: true,
        receipts: true,
      },
    });

    if (!invoice) {
      return NextResponse.json(
        { error: "Invoice not found" },
        { status: 404 }
      );
    }

    // Load image attachments
    const imageAttachments: { filename: string; data: string; mimeType: string }[] = [];

    for (const receipt of invoice.receipts) {
      if (isImageFile(receipt.mimeType)) {
        try {
          // Get the absolute path to the file
          const filePath = path.join(process.cwd(), "public", receipt.filepath);

          if (fs.existsSync(filePath)) {
            const fileBuffer = fs.readFileSync(filePath);
            const base64Data = fileBuffer.toString("base64");
            const dataUri = `data:${receipt.mimeType};base64,${base64Data}`;

            imageAttachments.push({
              filename: receipt.filename,
              data: dataUri,
              mimeType: receipt.mimeType,
            });
          }
        } catch (err) {
          console.error(`Error loading attachment ${receipt.filename}:`, err);
        }
      }
    }

    // Generate PDF
    const pdfBuffer = await renderToBuffer(
      React.createElement(InvoicePDF, { invoice, imageAttachments }) as any
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
