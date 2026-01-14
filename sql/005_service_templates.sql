-- Service Templates Migration
-- Adds service templates for preset services and trip legs for itinerary tracking

-- Service Templates table
CREATE TABLE IF NOT EXISTS service_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL,
  description TEXT DEFAULT '',
  service_type VARCHAR(50) NOT NULL DEFAULT 'standard',
  default_price DECIMAL(10,2) NOT NULL DEFAULT 0,
  travel_subtype VARCHAR(50),
  usage_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Trip Legs table (for trip-type invoice items)
CREATE TABLE IF NOT EXISTS trip_legs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_item_id UUID NOT NULL REFERENCES invoice_items(id) ON DELETE CASCADE,
  leg_order INT NOT NULL DEFAULT 1,
  from_airport VARCHAR(10) NOT NULL,
  to_airport VARCHAR(10) NOT NULL,
  trip_date DATE,
  trip_date_end DATE,
  passengers TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Add service_type to invoice_items
ALTER TABLE invoice_items ADD COLUMN IF NOT EXISTS service_type VARCHAR(50) DEFAULT 'standard';
ALTER TABLE invoice_items ADD COLUMN IF NOT EXISTS travel_subtype VARCHAR(50);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_service_templates_user ON service_templates(user_id);
CREATE INDEX IF NOT EXISTS idx_service_templates_type ON service_templates(service_type);
CREATE INDEX IF NOT EXISTS idx_service_templates_usage ON service_templates(usage_count DESC);
CREATE INDEX IF NOT EXISTS idx_trip_legs_item ON trip_legs(invoice_item_id);
CREATE INDEX IF NOT EXISTS idx_trip_legs_order ON trip_legs(invoice_item_id, leg_order);

-- Update trigger for service_templates
DROP TRIGGER IF EXISTS update_service_templates_updated_at ON service_templates;
CREATE TRIGGER update_service_templates_updated_at
  BEFORE UPDATE ON service_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
