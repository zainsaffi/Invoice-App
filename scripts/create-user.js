const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const { v4: uuid } = require('uuid');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://localhost:5432/invoice_app',
});

async function createUser() {
  const email = process.argv[2];
  const password = process.argv[3];
  const name = process.argv[4] || 'User';

  if (!email || !password) {
    console.log('Usage: node scripts/create-user.js <email> <password> [name]');
    process.exit(1);
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const id = uuid();

    await pool.query(
      `INSERT INTO users (id, email, password, name, currency, invoice_prefix, default_due_days, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())`,
      [id, email, hashedPassword, name, 'USD', 'INV', 30]
    );

    console.log('User created successfully!');
    console.log('Email:', email);
    console.log('User ID:', id);
  } catch (error) {
    console.error('Error creating user:', error.message);
  } finally {
    await pool.end();
  }
}

createUser();
