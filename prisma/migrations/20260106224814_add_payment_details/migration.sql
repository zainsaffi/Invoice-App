-- AlterTable
ALTER TABLE "User" ADD COLUMN "accountName" TEXT;
ALTER TABLE "User" ADD COLUMN "accountNumber" TEXT;
ALTER TABLE "User" ADD COLUMN "bankName" TEXT;
ALTER TABLE "User" ADD COLUMN "iban" TEXT;
ALTER TABLE "User" ADD COLUMN "paymentNotes" TEXT;
ALTER TABLE "User" ADD COLUMN "paypalEmail" TEXT;
ALTER TABLE "User" ADD COLUMN "routingNumber" TEXT;

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Invoice" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "invoiceNumber" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "clientName" TEXT NOT NULL,
    "clientEmail" TEXT NOT NULL,
    "clientAddress" TEXT,
    "description" TEXT NOT NULL,
    "subtotal" REAL NOT NULL,
    "tax" REAL NOT NULL DEFAULT 0,
    "total" REAL NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "emailSentAt" DATETIME,
    "emailSentTo" TEXT,
    "paidAt" DATETIME,
    "paymentMethod" TEXT,
    "dueDate" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Invoice_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_Invoice" ("clientAddress", "clientEmail", "clientName", "createdAt", "description", "dueDate", "emailSentAt", "emailSentTo", "id", "invoiceNumber", "paidAt", "paymentMethod", "status", "subtotal", "tax", "total", "updatedAt", "userId") SELECT "clientAddress", "clientEmail", "clientName", "createdAt", "description", "dueDate", "emailSentAt", "emailSentTo", "id", "invoiceNumber", "paidAt", "paymentMethod", "status", "subtotal", "tax", "total", "updatedAt", "userId" FROM "Invoice";
DROP TABLE "Invoice";
ALTER TABLE "new_Invoice" RENAME TO "Invoice";
CREATE UNIQUE INDEX "Invoice_invoiceNumber_key" ON "Invoice"("invoiceNumber");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
