import { z } from "zod";

// Email validation regex
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Invoice item schema
export const invoiceItemSchema = z.object({
  description: z
    .string()
    .min(1, "Description is required")
    .max(500, "Description must be less than 500 characters")
    .trim(),
  quantity: z
    .number()
    .min(1, "Quantity must be at least 1")
    .max(999999, "Quantity must be less than 999,999"),
  unitPrice: z
    .number()
    .min(0, "Unit price cannot be negative")
    .max(999999.99, "Unit price must be less than $999,999.99"),
});

// Create invoice schema
export const createInvoiceSchema = z.object({
  clientName: z
    .string()
    .min(1, "Client name is required")
    .max(255, "Client name must be less than 255 characters")
    .trim(),
  clientEmail: z
    .string()
    .min(1, "Client email is required")
    .max(255, "Email must be less than 255 characters")
    .regex(emailRegex, "Invalid email format")
    .trim()
    .toLowerCase(),
  clientAddress: z
    .string()
    .max(1000, "Address must be less than 1000 characters")
    .trim()
    .optional()
    .default(""),
  description: z
    .string()
    .min(1, "Description is required")
    .max(500, "Description must be less than 500 characters")
    .trim(),
  items: z
    .array(invoiceItemSchema)
    .min(1, "At least one item is required")
    .max(100, "Cannot have more than 100 items"),
  tax: z
    .number()
    .min(0, "Tax cannot be negative")
    .max(999999.99, "Tax must be less than $999,999.99")
    .optional()
    .default(0),
  dueDate: z
    .string()
    .optional()
    .refine(
      (val) => {
        if (!val) return true;
        const date = new Date(val);
        return !isNaN(date.getTime());
      },
      { message: "Invalid date format" }
    ),
});

// Update invoice schema (includes invoiceNumber)
export const updateInvoiceSchema = createInvoiceSchema.extend({
  invoiceNumber: z
    .string()
    .min(1, "Invoice number is required")
    .max(50, "Invoice number must be less than 50 characters")
    .trim()
    .optional(),
});

// Payment schema
export const paymentSchema = z.object({
  paymentMethod: z
    .enum(["cash", "check", "bank_transfer", "credit_card", "other"])
    .optional()
    .default("other"),
});

// UUID validation
export const uuidSchema = z
  .string()
  .uuid("Invalid ID format")
  .or(z.string().regex(/^[a-zA-Z0-9_-]+$/, "Invalid ID format"));

// File upload validation
export const fileUploadSchema = z.object({
  filename: z.string().max(255, "Filename too long"),
  size: z
    .number()
    .max(10 * 1024 * 1024, "File size must be less than 10MB"),
  mimeType: z.enum(
    [
      "image/jpeg",
      "image/png",
      "image/gif",
      "image/webp",
      "application/pdf",
    ] as const,
    { message: "Invalid file type. Allowed: JPEG, PNG, GIF, WebP, PDF" }
  ),
});

// Settings schema
export const settingsSchema = z.object({
  businessName: z
    .string()
    .max(255, "Business name must be less than 255 characters")
    .trim()
    .optional(),
  businessEmail: z
    .string()
    .regex(emailRegex, "Invalid email format")
    .optional()
    .or(z.literal("")),
  businessPhone: z
    .string()
    .max(50, "Phone must be less than 50 characters")
    .trim()
    .optional(),
  businessAddress: z
    .string()
    .max(1000, "Address must be less than 1000 characters")
    .trim()
    .optional(),
  taxId: z
    .string()
    .max(50, "Tax ID must be less than 50 characters")
    .trim()
    .optional(),
  currency: z.enum(["USD", "EUR", "GBP", "CAD", "AUD"]).optional().default("USD"),
  invoicePrefix: z
    .string()
    .max(20, "Prefix must be less than 20 characters")
    .regex(/^[a-zA-Z0-9-_]*$/, "Prefix can only contain letters, numbers, hyphens, and underscores")
    .optional(),
  defaultDueDays: z
    .number()
    .min(1, "Due days must be at least 1")
    .max(365, "Due days must be less than 365")
    .optional()
    .default(30),
});

// Helper function to validate and parse with better error messages
export function validateInput<T>(
  schema: z.ZodSchema<T>,
  data: unknown
): { success: true; data: T } | { success: false; error: string } {
  const result = schema.safeParse(data);
  if (!result.success) {
    const errors = result.error.issues.map((e) => e.message).join(", ");
    return { success: false, error: errors };
  }
  return { success: true, data: result.data };
}
