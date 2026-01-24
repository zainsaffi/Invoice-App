// Service Types
export type ServiceType = 'trip' | 'meals' | 'travel' | 'standard';
export type TravelSubtype = 'rental_car' | 'uber' | 'hotel' | 'flight' | 'parking' | 'other';

export const SERVICE_TYPES: { value: ServiceType; label: string }[] = [
  { value: 'trip', label: 'Trip' },
  { value: 'meals', label: 'Meals' },
  { value: 'travel', label: 'Travel' },
  { value: 'standard', label: 'Standard' },
];

export const TRAVEL_SUBTYPES: { value: TravelSubtype; label: string }[] = [
  { value: 'rental_car', label: 'Rental Car' },
  { value: 'uber', label: 'Uber/Lyft' },
  { value: 'hotel', label: 'Hotel' },
  { value: 'flight', label: 'Flight' },
  { value: 'parking', label: 'Parking' },
  { value: 'other', label: 'Other' },
];

// Trip Leg for itinerary tracking
export interface TripLeg {
  id?: string;
  legOrder: number;
  fromAirport: string;
  toAirport: string;
  tripDate?: string;
  tripDateEnd?: string;
  passengers?: string;
}

// Service Template for preset services
export interface ServiceTemplate {
  id: string;
  name: string;
  description: string;
  serviceType: ServiceType;
  defaultPrice: number;
  travelSubtype?: TravelSubtype;
  usageCount: number;
  createdAt: string | Date;
  updatedAt: string | Date;
}

export interface InvoiceItem {
  id?: string;
  title: string;
  description: string;
  quantity: number;
  unitPrice: number;
  total?: number;
  serviceType?: ServiceType;
  travelSubtype?: TravelSubtype;
  legs?: TripLeg[];
}

export type ItemTemplateType = 'title' | 'description';

export interface ItemTemplate {
  id: string;
  type: ItemTemplateType;
  content: string;
  usageCount: number;
  createdAt: string | Date;
  updatedAt: string | Date;
}

export type AttachmentType = 'receipt' | 'contract' | 'quote' | 'supporting_document' | 'photo' | 'other';

export const ATTACHMENT_TYPES: { value: AttachmentType; label: string }[] = [
  { value: 'receipt', label: 'Receipt' },
  { value: 'contract', label: 'Contract' },
  { value: 'quote', label: 'Quote' },
  { value: 'supporting_document', label: 'Supporting Document' },
  { value: 'photo', label: 'Photo' },
  { value: 'other', label: 'Other' },
];

export function getAttachmentTypeLabel(type: AttachmentType | string): string {
  const found = ATTACHMENT_TYPES.find(t => t.value === type);
  return found?.label || 'Other';
}

export interface Receipt {
  id: string;
  filename: string;
  filepath: string;
  mimeType: string;
  size: number;
  attachmentType: AttachmentType | string;
  createdAt: string | Date;
}

export interface Payment {
  id: string;
  invoiceId: string;
  amount: number;
  paymentMethod: string | null;
  reference: string | null;
  notes: string | null;
  paidAt: string | Date;
  createdAt: string | Date;
}

export interface InvoiceUser {
  id: string;
  name: string | null;
  businessName: string | null;
  currency: string;
}

export interface Invoice {
  id: string;
  invoiceNumber: string;
  clientName: string;
  clientEmail: string;
  clientBusinessName: string | null;
  clientAddress: string | null;
  description: string;
  items: InvoiceItem[];
  subtotal: number;
  tax: number;
  total: number;
  status: string;
  emailSentAt: string | Date | null;
  emailSentTo: string | null;
  paidAt: string | Date | null;
  paymentMethod: string | null;
  receipts: Receipt[];
  payments: Payment[];
  amountPaid: number;
  paymentInstructions: string | null;
  dueDate: string | Date | null;
  viewCount: number;
  lastViewedAt: string | Date | null;
  viewToken: string | null;
  createdAt: string | Date;
  updatedAt: string | Date;
  user?: InvoiceUser;
  statusHistory?: StatusHistory[];
}

export type InvoiceStatus = 'draft' | 'due' | 'sent' | 'paid' | 'shipped' | 'completed' | 'refunded' | 'cancelled' | 'in_progress';

export const INVOICE_STATUSES: { value: InvoiceStatus; label: string }[] = [
  { value: 'due', label: 'Due' },
  { value: 'sent', label: 'Sent' },
  { value: 'paid', label: 'Paid' },
  { value: 'shipped', label: 'Shipped' },
  { value: 'completed', label: 'Completed' },
  { value: 'refunded', label: 'Refunded' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'draft', label: 'Draft' },
];

// Status History for tracking status changes
export interface StatusHistory {
  id: string;
  invoiceId: string;
  status: InvoiceStatus;
  changedAt: string | Date;
  notes?: string;
}

export interface InvoiceFormData {
  invoiceNumber?: string;
  clientName: string;
  clientEmail: string;
  clientBusinessName: string;
  clientAddress: string;
  items: InvoiceItem[];
  tax: number;
  dueDate: string;
  paymentInstructions?: string;
  status?: InvoiceStatus;
  customerId?: string;
}

// Customer for reusable client information
export interface Customer {
  id: string;
  name: string;
  email: string;
  businessName?: string;
  address?: string;
  phone?: string;
  notes?: string;
  invoiceCount: number;
  totalBilled: number;
  createdAt: string | Date;
  updatedAt: string | Date;
}
