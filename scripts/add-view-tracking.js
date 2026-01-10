const { Pool } = require('pg');
const { v4: uuid } = require('uuid');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://localhost:5432/invoice_app',
});

async function migrate() {
  try {
    // Add view tracking columns to invoices table
    await pool.query(`
      ALTER TABLE invoices
      ADD COLUMN IF NOT EXISTS view_count INTEGER DEFAULT 0;
    `);
    console.log('Added view_count column');

    await pool.query(`
      ALTER TABLE invoices
      ADD COLUMN IF NOT EXISTS last_viewed_at TIMESTAMP WITH TIME ZONE;
    `);
    console.log('Added last_viewed_at column');

    await pool.query(`
      ALTER TABLE invoices
      ADD COLUMN IF NOT EXISTS view_token VARCHAR(64);
    `);
    console.log('Added view_token column');

    // Generate view tokens for existing invoices that don't have one
    const { rows } = await pool.query(`SELECT id FROM invoices WHERE view_token IS NULL`);
    for (const row of rows) {
      const viewToken = uuid().replace(/-/g, '') + uuid().replace(/-/g, '').substring(0, 32);
      await pool.query(`UPDATE invoices SET view_token = $1 WHERE id = $2`, [viewToken.substring(0, 64), row.id]);
    }
    console.log(`Generated view tokens for ${rows.length} invoices`);

    console.log('Migration completed successfully!');
  } catch (error) {
    console.error('Migration error:', error.message);
  } finally {
    await pool.end();
  }
}

migrate();
