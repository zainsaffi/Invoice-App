-- Migration: Add attachment types to receipts
-- Run this migration to add attachment type categorization

-- Add attachment_type column to receipts table
-- Types: 'receipt', 'contract', 'quote', 'supporting_document', 'photo', 'other'
ALTER TABLE receipts ADD COLUMN IF NOT EXISTS attachment_type VARCHAR(50) NOT NULL DEFAULT 'other';

-- Update existing receipts to have 'receipt' as default type (since they were uploaded as receipts)
UPDATE receipts SET attachment_type = 'receipt' WHERE attachment_type = 'other';
