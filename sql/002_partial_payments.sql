-- Migration: Add partial payments and payment instructions
-- Run this migration to add partial payment tracking

-- Payments table for tracking partial payments
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Reference to invoice
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,

    -- Payment details
    amount DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(50),
    reference VARCHAR(255),
    notes TEXT,

    -- Timestamps
    paid_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Add payment instructions to invoices
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS payment_instructions TEXT;

-- Add amount_paid column to track total paid (denormalized for performance)
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS amount_paid DECIMAL(12, 2) NOT NULL DEFAULT 0;

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX IF NOT EXISTS idx_payments_paid_at ON payments(paid_at DESC);
