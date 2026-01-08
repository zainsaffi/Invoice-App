-- Migration: Add item templates feature
-- This adds title field to invoice items and creates item_templates table for reusable titles/descriptions

-- Add title column to invoice_items (description already exists)
ALTER TABLE invoice_items ADD COLUMN IF NOT EXISTS title VARCHAR(200);

-- Migrate: Set title to 'Item' for existing items that don't have a title
UPDATE invoice_items SET title = 'Item' WHERE title IS NULL;

-- Make title NOT NULL after migration
ALTER TABLE invoice_items ALTER COLUMN title SET NOT NULL;

-- Create item_templates table for saved titles and descriptions
CREATE TABLE IF NOT EXISTS item_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('title', 'description')),
    content TEXT NOT NULL,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, type, content)
);

-- Index for faster lookups by user and type
CREATE INDEX IF NOT EXISTS idx_item_templates_user_type ON item_templates(user_id, type);
CREATE INDEX IF NOT EXISTS idx_item_templates_usage ON item_templates(user_id, type, usage_count DESC);
