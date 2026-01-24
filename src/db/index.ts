import { Pool, QueryResult, QueryResultRow } from "pg";

// PostgreSQL connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || "postgresql://localhost:5432/invoice_app",
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Query helper with typed results
export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params?: unknown[]
): Promise<QueryResult<T>> {
  const start = Date.now();
  const result = await pool.query<T>(text, params);
  const duration = Date.now() - start;

  if (process.env.NODE_ENV === "development") {
    console.log("Executed query", { text: text.substring(0, 100), duration, rows: result.rowCount });
  }

  return result;
}

// Get a single row
export async function queryOne<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params?: unknown[]
): Promise<T | null> {
  const result = await query<T>(text, params);
  return result.rows[0] || null;
}

// Get multiple rows
export async function queryMany<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params?: unknown[]
): Promise<T[]> {
  const result = await query<T>(text, params);
  return result.rows;
}

// Transaction client interface
export interface TransactionClient {
  query: (text: string, params?: unknown[]) => Promise<QueryResult>;
  queryOne: <R extends QueryResultRow = QueryResultRow>(text: string, params?: unknown[]) => Promise<R | null>;
  queryMany: <R extends QueryResultRow = QueryResultRow>(text: string, params?: unknown[]) => Promise<R[]>;
}

// Transaction helper
export async function transaction<T>(
  callback: (client: TransactionClient) => Promise<T>
): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const transactionClient: TransactionClient = {
      query: (text: string, params?: unknown[]) => client.query(text, params),
      queryOne: async <R extends QueryResultRow = QueryResultRow>(text: string, params?: unknown[]): Promise<R | null> => {
        const result = await client.query<R>(text, params);
        return result.rows[0] || null;
      },
      queryMany: async <R extends QueryResultRow = QueryResultRow>(text: string, params?: unknown[]): Promise<R[]> => {
        const result = await client.query<R>(text, params);
        return result.rows;
      },
    };

    const result = await callback(transactionClient);
    await client.query("COMMIT");
    return result;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

// Export pool for direct access if needed
export { pool };

// TypeScript interfaces for database rows
export interface UserRow {
  id: string;
  email: string;
  password: string;
  name: string | null;
  business_name: string | null;
  business_email: string | null;
  business_phone: string | null;
  business_address: string | null;
  tax_id: string | null;
  currency: string;
  invoice_prefix: string;
  default_due_days: number;
  bank_name: string | null;
  account_name: string | null;
  account_number: string | null;
  routing_number: string | null;
  iban: string | null;
  paypal_email: string | null;
  payment_notes: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface InvoiceRow {
  id: string;
  invoice_number: string;
  user_id: string;
  client_name: string;
  client_email: string;
  client_business_name: string | null;
  client_address: string | null;
  description: string;
  subtotal: number;
  tax: number;
  total: number;
  status: string;
  email_sent_at: Date | null;
  email_sent_to: string | null;
  paid_at: Date | null;
  payment_method: string | null;
  stripe_checkout_session_id: string | null;
  stripe_payment_intent_id: string | null;
  payment_token: string | null;
  amount_paid: number;
  payment_instructions: string | null;
  due_date: Date | null;
  view_count: number;
  last_viewed_at: Date | null;
  view_token: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface PaymentRow {
  id: string;
  invoice_id: string;
  amount: number;
  payment_method: string | null;
  reference: string | null;
  notes: string | null;
  paid_at: Date;
  created_at: Date;
}

export interface InvoiceItemRow {
  id: string;
  title: string;
  description: string;
  quantity: number;
  unit_price: number;
  total: number;
  invoice_id: string;
  service_type: string | null;
  travel_subtype: string | null;
}

export interface ItemTemplateRow {
  id: string;
  user_id: string;
  type: 'title' | 'description';
  content: string;
  usage_count: number;
  created_at: Date;
  updated_at: Date;
}

export interface ReceiptRow {
  id: string;
  filename: string;
  filepath: string;
  mime_type: string;
  size: number;
  invoice_id: string;
  attachment_type: string;
  created_at: Date;
}

export interface AuditLogRow {
  id: string;
  action: string;
  entity: string;
  entity_id: string | null;
  details: string | null;
  ip_address: string | null;
  user_agent: string | null;
  user_id: string;
  created_at: Date;
}

export interface RateLimitRow {
  id: string;
  key: string;
  count: number;
  window_start: Date;
}

export interface ServiceTemplateRow {
  id: string;
  user_id: string;
  name: string;
  description: string | null;
  service_type: string;
  default_price: number;
  travel_subtype: string | null;
  usage_count: number;
  created_at: Date;
  updated_at: Date;
}

export interface TripLegRow {
  id: string;
  invoice_item_id: string;
  leg_order: number;
  from_airport: string;
  to_airport: string;
  trip_date: Date | null;
  trip_date_end: Date | null;
  passengers: string | null;
  created_at: Date;
}

export interface CustomerRow {
  id: string;
  user_id: string;
  name: string;
  email: string;
  business_name: string | null;
  address: string | null;
  phone: string | null;
  notes: string | null;
  invoice_count: number;
  total_billed: number;
  created_at: Date;
  updated_at: Date;
}

export interface StatusHistoryRow {
  id: string;
  invoice_id: string;
  status: string;
  changed_at: Date;
  notes: string | null;
  created_at: Date;
}

// Convert invoice row to camelCase
export function toInvoice(row: InvoiceRow) {
  return {
    id: row.id,
    invoiceNumber: row.invoice_number,
    userId: row.user_id,
    clientName: row.client_name,
    clientEmail: row.client_email,
    clientBusinessName: row.client_business_name,
    clientAddress: row.client_address,
    description: row.description,
    subtotal: Number(row.subtotal),
    tax: Number(row.tax),
    total: Number(row.total),
    status: row.status,
    emailSentAt: row.email_sent_at,
    emailSentTo: row.email_sent_to,
    paidAt: row.paid_at,
    paymentMethod: row.payment_method,
    stripeCheckoutSessionId: row.stripe_checkout_session_id,
    stripePaymentIntentId: row.stripe_payment_intent_id,
    paymentToken: row.payment_token,
    amountPaid: Number(row.amount_paid || 0),
    paymentInstructions: row.payment_instructions,
    dueDate: row.due_date,
    viewCount: Number(row.view_count || 0),
    lastViewedAt: row.last_viewed_at,
    viewToken: row.view_token,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// Convert payment row to camelCase
export function toPayment(row: PaymentRow) {
  return {
    id: row.id,
    invoiceId: row.invoice_id,
    amount: Number(row.amount),
    paymentMethod: row.payment_method,
    reference: row.reference,
    notes: row.notes,
    paidAt: row.paid_at,
    createdAt: row.created_at,
  };
}

// Convert user row to camelCase
export function toUser(row: UserRow) {
  return {
    id: row.id,
    email: row.email,
    password: row.password,
    name: row.name,
    businessName: row.business_name,
    businessEmail: row.business_email,
    businessPhone: row.business_phone,
    businessAddress: row.business_address,
    taxId: row.tax_id,
    currency: row.currency,
    invoicePrefix: row.invoice_prefix,
    defaultDueDays: row.default_due_days,
    bankName: row.bank_name,
    accountName: row.account_name,
    accountNumber: row.account_number,
    routingNumber: row.routing_number,
    iban: row.iban,
    paypalEmail: row.paypal_email,
    paymentNotes: row.payment_notes,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// Convert invoice item row to camelCase
export function toInvoiceItem(row: InvoiceItemRow) {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    quantity: Number(row.quantity),
    unitPrice: Number(row.unit_price),
    total: Number(row.total),
    invoiceId: row.invoice_id,
    serviceType: row.service_type,
    travelSubtype: row.travel_subtype,
  };
}

// Convert item template row to camelCase
export function toItemTemplate(row: ItemTemplateRow) {
  return {
    id: row.id,
    userId: row.user_id,
    type: row.type,
    content: row.content,
    usageCount: row.usage_count,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// Convert receipt row to camelCase
export function toReceipt(row: ReceiptRow) {
  return {
    id: row.id,
    filename: row.filename,
    filepath: row.filepath,
    mimeType: row.mime_type,
    size: row.size,
    invoiceId: row.invoice_id,
    attachmentType: row.attachment_type,
    createdAt: row.created_at,
  };
}

// Convert service template row to camelCase
export function toServiceTemplate(row: ServiceTemplateRow) {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    description: row.description || "",
    serviceType: row.service_type,
    defaultPrice: Number(row.default_price),
    travelSubtype: row.travel_subtype,
    usageCount: Number(row.usage_count),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// Convert trip leg row to camelCase
export function toTripLeg(row: TripLegRow) {
  return {
    id: row.id,
    invoiceItemId: row.invoice_item_id,
    legOrder: Number(row.leg_order),
    fromAirport: row.from_airport,
    toAirport: row.to_airport,
    tripDate: row.trip_date ? row.trip_date.toISOString().split('T')[0] : null,
    tripDateEnd: row.trip_date_end ? row.trip_date_end.toISOString().split('T')[0] : null,
    passengers: row.passengers,
    createdAt: row.created_at,
  };
}

// Convert customer row to camelCase
export function toCustomer(row: CustomerRow) {
  return {
    id: row.id,
    userId: row.user_id,
    name: row.name,
    email: row.email,
    businessName: row.business_name,
    address: row.address,
    phone: row.phone,
    notes: row.notes,
    invoiceCount: Number(row.invoice_count || 0),
    totalBilled: Number(row.total_billed || 0),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

// Convert status history row to camelCase
export function toStatusHistory(row: StatusHistoryRow) {
  return {
    id: row.id,
    invoiceId: row.invoice_id,
    status: row.status,
    changedAt: row.changed_at,
    notes: row.notes,
    createdAt: row.created_at,
  };
}
