# Invoice Software - Project Audit

**Project ID:** ec39f229-042e-4c85-b6fe-c41a3285216a
**Project Name:** Invoice Software (Sosocial Invoice)
**Audit Date:** 2026-02-03

---

## Documentation Cards

### 1. Project Overview (text)

**Sosocial Invoice** is a full-stack invoice management application designed for small businesses and freelancers, with specialized features for aviation/charter services.

**Core Capabilities:**
- Create, edit, and manage invoices with line items
- Support for multiple service types (trips, meals, travel, standard)
- Trip leg tracking for aviation/charter services (airports, dates, passengers)
- Customer management with billing history
- Partial payment tracking
- Receipt and attachment uploads (JPEG, PNG, GIF, WebP, PDF)
- Email invoice delivery with professional HTML templates
- Stripe payment integration for online payments
- Dashboard with sales analytics and charts
- Status workflow: draft → due → sent → paid → shipped → completed

**Target Users:**
- Aviation/charter service providers (primary)
- Freelancers and small businesses
- Service providers needing trip/travel expense tracking

---

### 2. Technology Stack (text)

**Frontend:**
- Next.js 16.1.1 (App Router with React Server Components)
- React 19.2.3
- TypeScript 5.x
- Tailwind CSS (via globals.css)
- Recharts 3.6.0 (sales charts)
- Lucide React (icons)
- @react-pdf/renderer 4.3.2 (PDF generation)

**Backend:**
- Next.js API Routes (Route Handlers)
- PostgreSQL database (via pg driver)
- NextAuth.js 5.0.0-beta.30 (credentials authentication)
- bcryptjs (password hashing)
- Zod 4.3.5 (validation)

**Integrations:**
- Stripe 20.1.1 (payment processing)
- Nodemailer 7.0.12 (email delivery)
- SMTP email service

**Build & Deploy:**
- PM2 (ecosystem.config.js)
- Node.js runtime
- ESLint for linting

---

### 3. Architecture (code)

**Project Structure:**
```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth group (login, register)
│   ├── api/               # API Route Handlers
│   │   ├── auth/          # NextAuth endpoints
│   │   ├── customers/     # Customer CRUD
│   │   ├── invoices/      # Invoice CRUD + [id] operations
│   │   ├── item-templates/# Reusable templates
│   │   ├── pay/[token]/   # Public payment page
│   │   ├── public/invoice/# Public invoice view
│   │   ├── service-templates/
│   │   ├── settings/      # User settings
│   │   └── webhooks/stripe/# Stripe webhooks
│   ├── customers/         # Customer management page
│   ├── invoices/          # Invoice CRUD pages
│   ├── pay/[token]/       # Public payment flow
│   ├── payments/          # Payment history
│   ├── services/          # Service templates page
│   ├── settings/          # User settings page
│   ├── view/[token]/      # Public invoice view
│   └── page.tsx           # Dashboard (home)
├── components/            # React components
├── db/                    # Database layer
├── lib/                   # Utilities & services
└── types/                 # TypeScript definitions
```

**Design Patterns:**
- Server Components for data fetching (RSC)
- Client Components for interactivity ("use client")
- Repository pattern in db/index.ts (query helpers)
- Service layer in lib/ (auth, email, stripe, security)
- Zod schemas for input validation
- snake_case → camelCase converters for DB rows

**Database Schema:**
- 11 tables with proper foreign keys
- UUID primary keys
- Automatic updated_at triggers
- Indexes on frequently queried columns

---

### 4. Key Components (code)

**Database Layer (`src/db/index.ts`):**
- PostgreSQL connection pool (max: 20 connections)
- `query()`, `queryOne()`, `queryMany()` helpers
- Transaction support with rollback
- Row type definitions (UserRow, InvoiceRow, etc.)
- Conversion functions (toInvoice, toUser, etc.)

**Authentication (`src/lib/auth.ts`):**
- NextAuth.js with credentials provider
- bcrypt password verification
- Session-based auth with JWT
- `getAuthenticatedUser()` and `requireAuth()` helpers

**Security (`src/lib/security.ts`):**
- Rate limiting (60 req/min default)
- CSRF token validation (Origin/Referer check)
- Audit logging to database
- File type validation (magic bytes)
- Invoice ownership verification

**Email Service (`src/lib/email.ts`):**
- Nodemailer with TLS/STARTTLS
- Professional HTML email templates
- Content sanitization (XSS prevention)
- View and Pay links in emails

**Stripe Integration (`src/lib/stripe.ts`):**
- Conditional Stripe client initialization
- Webhook handling for payment events
- Support for card and ACH payments

**Key Components:**
- `InvoiceForm.tsx` - Complex form with templates
- `InvoiceList.tsx` - Invoice listing with filters
- `InvoiceTable.tsx` - Tabular invoice display
- `SalesChart.tsx` - Revenue visualization
- `Sidebar.tsx` - Navigation
- `TripLegsEditor.tsx` - Aviation trip leg management
- `ReceiptUpload.tsx` - File upload handling

---

### 5. Data Flow (code)

**Invoice Creation Flow:**
```
1. User fills InvoiceForm (client component)
2. Form submits to POST /api/invoices
3. Server validates with Zod schema
4. Checks auth, rate limit, CSRF
5. Inserts invoice → invoice_items → trip_legs
6. Returns created invoice with items
7. Audit log entry created
```

**Payment Flow (Stripe):**
```
1. Client views invoice via /view/[token]
2. Clicks "Pay Now" → /pay/[token]
3. Creates Stripe Checkout session
4. User completes payment on Stripe
5. Webhook POST /api/webhooks/stripe
6. Invoice status updated to "paid"
```

**Email Flow:**
```
1. User clicks "Send Invoice" on invoice detail
2. POST /api/invoices/[id]/send
3. Generates view token and payment token
4. Sends email via Nodemailer/SMTP
5. Updates email_sent_at, email_sent_to
```

**Authentication Flow:**
```
1. User visits protected route
2. Middleware checks NextAuth session
3. Unauthenticated → redirect to /login
4. Login form → POST /api/auth/callback/credentials
5. Session created, user redirected
```

---

### 6. Configuration (text)

**Environment Variables Required:**

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `NEXTAUTH_SECRET` | JWT signing secret | Yes |
| `NEXTAUTH_URL` | App base URL for auth | Yes |
| `NEXT_PUBLIC_APP_URL` | Public app URL for links | Yes |
| `SMTP_HOST` | SMTP server hostname | Yes |
| `SMTP_PORT` | SMTP port (587 or 465) | Yes |
| `SMTP_USER` | SMTP username | Yes |
| `SMTP_PASS` | SMTP password | Yes |
| `EMAIL_FROM` | Sender email address | Yes |
| `STRIPE_SECRET_KEY` | Stripe secret API key | No |
| `STRIPE_PUBLISHABLE_KEY` | Stripe public key | No |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret | No |

**Database Migrations:**
Located in `/sql/` directory, must be run in order:
1. `001_init.sql` - Core schema
2. `002_partial_payments.sql` - Payment tracking
3. `003_attachment_types.sql` - Attachment categorization
4. `004_item_templates.sql` - Reusable templates
5. `005_service_templates.sql` - Service presets
6. `006_customers.sql` - Customer management
7. `007_status_history.sql` - Status audit trail

**PM2 Configuration:** `ecosystem.config.js`
- App name: sosocial-invoice
- Port: 3000
- Watch mode: disabled
- Max memory: 1GB restart

---

### 7. Areas to Investigate (question)

1. **View tracking implementation** - `scripts/add-view-tracking.js` exists but usage unclear. Is view tracking fully implemented?

2. **dev.db SQLite file** - There's a `dev.db` file present alongside PostgreSQL config. Is this legacy or used for testing?

3. **User creation script** - `scripts/create-user.js` exists. Is this for initial setup or admin user creation?

4. **Partial payment edge cases** - What happens when partial payments exceed invoice total? Is there validation?

5. **Status history triggers** - Status history tracking was added in migration 007. Is it populated on all status changes?

6. **File upload security** - Uploads go to `/uploads/` directory. Is this properly secured in production?

7. **Rate limit table cleanup** - Rate limit entries accumulate. Is there a cleanup process?

8. **Multi-currency support** - Currency setting exists but is it used in formatting and calculations?

9. **PDF generation** - @react-pdf/renderer is installed but no PDF component found. Is this implemented?

10. **Webhook retry handling** - Does Stripe webhook handler support idempotency for retried events?

---

### 8. Improvements (idea)

1. **Add automated testing** - No test files found. Add Jest/Vitest for unit tests and Playwright for E2E.

2. **Implement PDF invoice download** - Use @react-pdf/renderer to generate downloadable PDFs.

3. **Add invoice templating** - Allow users to create and save invoice templates.

4. **Multi-currency formatting** - Actually use the currency setting for proper formatting.

5. **Add invoice reminders** - Automated email reminders for overdue invoices.

6. **Implement recurring invoices** - Add ability to schedule recurring invoices.

7. **Add client portal** - Dedicated portal for clients to view their invoices/payments.

8. **Add search functionality** - Full-text search across invoices, customers, items.

9. **Implement bulk operations** - Bulk status updates, bulk email sending.

10. **Add export features** - CSV/Excel export for invoices and payments.

11. **Add dashboard customization** - Configurable date ranges and metrics.

12. **Implement soft deletes** - Archive instead of hard delete for audit purposes.

---

## Tasks

### Documentation Tasks

| Priority | Task | Category |
|----------|------|----------|
| High | Write API documentation for all endpoints | Documentation |
| High | Update README with setup instructions | Documentation |
| Medium | Document database schema with ER diagram | Documentation |
| Medium | Create user guide for invoice workflow | Documentation |
| Low | Add JSDoc comments to utility functions | Documentation |

### Technical Debt

| Priority | Task | Category |
|----------|------|----------|
| High | Add comprehensive input validation tests | Technical Debt |
| High | Implement proper error boundaries in React components | Technical Debt |
| Medium | Remove unused dev.db SQLite file if not needed | Technical Debt |
| Medium | Add TypeScript strict mode checks | Technical Debt |
| Medium | Consolidate duplicate form handling logic | Technical Debt |
| Low | Remove deprecated description field from invoices table | Technical Debt |

### Security Tasks

| Priority | Task | Category |
|----------|------|----------|
| High | Implement proper file upload path sanitization | Security |
| High | Add CAPTCHA to public payment page | Security |
| Medium | Implement webhook signature verification for all events | Security |
| Medium | Add rate limiting to public invoice view endpoint | Security |
| Medium | Review and secure uploads directory access | Security |
| Low | Add CSP headers to prevent XSS | Security |

### Performance Tasks

| Priority | Task | Category |
|----------|------|----------|
| Medium | Add database query caching with Redis | Performance |
| Medium | Implement pagination for invoice lists | Performance |
| Medium | Add database connection pooling monitoring | Performance |
| Low | Optimize dashboard queries with materialized views | Performance |
| Low | Add image optimization for receipt thumbnails | Performance |

### Feature Tasks

| Priority | Task | Category |
|----------|------|----------|
| High | Implement PDF invoice generation | Feature |
| High | Add automated invoice reminders | Feature |
| Medium | Add bulk invoice operations | Feature |
| Medium | Implement invoice search | Feature |
| Medium | Add invoice export (CSV/Excel) | Feature |
| Low | Add recurring invoice support | Feature |
| Low | Implement client portal | Feature |

### Testing Tasks

| Priority | Task | Category |
|----------|------|----------|
| High | Add unit tests for validation schemas | Testing |
| High | Add integration tests for API routes | Testing |
| Medium | Add E2E tests for critical flows | Testing |
| Medium | Add tests for Stripe webhook handling | Testing |
| Low | Add visual regression tests for email templates | Testing |

---

## Summary Statistics

- **Total Files:** ~50+ source files
- **API Endpoints:** 15+ route handlers
- **Database Tables:** 11
- **Components:** 9 major React components
- **Dependencies:** 20 production + 10 dev dependencies

## Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| No automated tests | High | Implement testing suite immediately |
| File upload security | Medium | Review upload handling and add sandboxing |
| NextAuth beta version | Medium | Monitor for breaking changes, plan upgrade |
| Missing error boundaries | Medium | Add error handling throughout app |
| No backup strategy documented | Medium | Document and implement backup procedures |

---

*This audit was generated to provide comprehensive documentation for the Invoice Software project. Regular updates recommended as the project evolves.*
