import { z } from "zod";

// Email validation regex
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Service type schema (defined early for use in invoiceItemSchema)
const serviceTypeSchemaBase = z.enum(["trip", "meals", "travel", "standard"]);
const travelSubtypeSchemaBase = z.enum(["rental_car", "uber", "hotel", "flight", "parking", "other"]);

// Trip leg schema (defined early for use in invoiceItemSchema)
const tripLegSchemaBase = z.object({
  id: z.string().uuid().optional(),
  legOrder: z.number().min(1).max(100),
  fromAirport: z
    .string()
    .min(3, "Airport code must be at least 3 characters")
    .max(10, "Airport code must be less than 10 characters"),
  toAirport: z
    .string()
    .min(3, "Airport code must be at least 3 characters")
    .max(10, "Airport code must be less than 10 characters"),
  tripDate: z.string().optional(),
  tripDateEnd: z.string().optional(),
  passengers: z.string().max(500).optional(),
});

// Invoice item schema
export const invoiceItemSchema = z.object({
  title: z
    .string()
    .min(1, "Title is required")
    .max(200, "Title must be less than 200 characters")
    .trim(),
  description: z
    .string()
    .max(2000, "Description must be less than 2000 characters")
    .trim()
    .optional()
    .default(""),
  quantity: z
    .number()
    .min(1, "Quantity must be at least 1")
    .max(999999, "Quantity must be less than 999,999"),
  unitPrice: z
    .number()
    .min(0, "Unit price cannot be negative")
    .max(999999.99, "Unit price must be less than $999,999.99"),
  serviceType: serviceTypeSchemaBase.optional(),
  travelSubtype: travelSubtypeSchemaBase.optional(),
  legs: z.array(tripLegSchemaBase).optional(),
});

// Item template schema
export const itemTemplateSchema = z.object({
  type: z.enum(["title", "description"], { message: "Type must be 'title' or 'description'" }),
  content: z
    .string()
    .min(1, "Content is required")
    .max(2000, "Content must be less than 2000 characters")
    .trim(),
});

// Export service type and travel subtype schemas
export const serviceTypeSchema = serviceTypeSchemaBase;
export const travelSubtypeSchema = travelSubtypeSchemaBase;
export const tripLegSchema = tripLegSchemaBase;

// Service template schema
export const serviceTemplateSchema = z.object({
  name: z
    .string()
    .min(1, "Name is required")
    .max(200, "Name must be less than 200 characters")
    .trim(),
  description: z
    .string()
    .max(2000, "Description must be less than 2000 characters")
    .trim()
    .optional()
    .default(""),
  serviceType: serviceTypeSchema.default("standard"),
  defaultPrice: z
    .number()
    .min(0, "Price cannot be negative")
    .max(999999.99, "Price must be less than $999,999.99")
    .default(0),
  travelSubtype: travelSubtypeSchema.optional(),
});

// Invoice status values
export const invoiceStatusSchema = z.enum([
  "draft", "due", "paid", "shipped", "completed", "refunded", "cancelled", "in_progress"
]);

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
  clientBusinessName: z
    .string()
    .max(255, "Business name must be less than 255 characters")
    .trim()
    .optional()
    .default(""),
  clientAddress: z
    .string()
    .max(1000, "Address must be less than 1000 characters")
    .trim()
    .optional()
    .default(""),
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
  paymentInstructions: z
    .string()
    .max(2000, "Payment instructions must be less than 2000 characters")
    .trim()
    .optional(),
  status: invoiceStatusSchema
    .optional()
    .default("draft"),
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

// Partial payment schema
export const partialPaymentSchema = z.object({
  amount: z
    .number()
    .min(0.01, "Amount must be at least $0.01")
    .max(999999.99, "Amount must be less than $999,999.99"),
  paymentMethod: z
    .string()
    .max(50, "Payment method must be less than 50 characters")
    .optional(),
  reference: z
    .string()
    .max(255, "Reference must be less than 255 characters")
    .trim()
    .optional(),
  notes: z
    .string()
    .max(1000, "Notes must be less than 1000 characters")
    .trim()
    .optional(),
  paidAt: z
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
