export interface InvoiceItem {
  id?: string;
  description: string;
  quantity: number;
  unitPrice: number;
  total?: number;
}

export interface Receipt {
  id: string;
  filename: string;
  filepath: string;
  mimeType: string;
  size: number;
  createdAt: string | Date;
}

export interface Invoice {
  id: string;
  invoiceNumber: string;
  clientName: string;
  clientEmail: string;
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
  dueDate: string | Date | null;
  createdAt: string | Date;
  updatedAt: string | Date;
}

export interface InvoiceFormData {
  invoiceNumber?: string;
  clientName: string;
  clientEmail: string;
  clientAddress: string;
  description: string;
  items: InvoiceItem[];
  tax: number;
  dueDate: string;
}
