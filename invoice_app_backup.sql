--
-- PostgreSQL database dump
--

\restrict en6BcjY6wzUlFaKFbzD0GGXqik0fhINfupf5R19X5DrREgXi9h4RJbkMGxrlZeq

-- Dumped from database version 16.10 (Homebrew)
-- Dumped by pg_dump version 16.10 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.trip_legs DROP CONSTRAINT IF EXISTS trip_legs_invoice_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.status_history DROP CONSTRAINT IF EXISTS status_history_invoice_id_fkey;
ALTER TABLE IF EXISTS ONLY public.service_templates DROP CONSTRAINT IF EXISTS service_templates_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.receipts DROP CONSTRAINT IF EXISTS receipts_invoice_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_invoice_id_fkey;
ALTER TABLE IF EXISTS ONLY public.item_templates DROP CONSTRAINT IF EXISTS item_templates_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invoice_items DROP CONSTRAINT IF EXISTS invoice_items_invoice_id_fkey;
ALTER TABLE IF EXISTS ONLY public.customers DROP CONSTRAINT IF EXISTS customers_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_user_id_fkey;
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_service_templates_updated_at ON public.service_templates;
DROP TRIGGER IF EXISTS update_invoices_updated_at ON public.invoices;
DROP TRIGGER IF EXISTS update_customers_updated_at ON public.customers;
DROP INDEX IF EXISTS public.idx_trip_legs_order;
DROP INDEX IF EXISTS public.idx_trip_legs_item;
DROP INDEX IF EXISTS public.idx_status_history_invoice_id;
DROP INDEX IF EXISTS public.idx_status_history_changed_at;
DROP INDEX IF EXISTS public.idx_service_templates_user;
DROP INDEX IF EXISTS public.idx_service_templates_usage;
DROP INDEX IF EXISTS public.idx_service_templates_type;
DROP INDEX IF EXISTS public.idx_receipts_invoice_id;
DROP INDEX IF EXISTS public.idx_rate_limits_key;
DROP INDEX IF EXISTS public.idx_payments_paid_at;
DROP INDEX IF EXISTS public.idx_payments_invoice_id;
DROP INDEX IF EXISTS public.idx_item_templates_user_type;
DROP INDEX IF EXISTS public.idx_item_templates_usage;
DROP INDEX IF EXISTS public.idx_invoices_user_id;
DROP INDEX IF EXISTS public.idx_invoices_status;
DROP INDEX IF EXISTS public.idx_invoices_payment_token;
DROP INDEX IF EXISTS public.idx_invoices_customer;
DROP INDEX IF EXISTS public.idx_invoices_created_at;
DROP INDEX IF EXISTS public.idx_invoice_items_invoice_id;
DROP INDEX IF EXISTS public.idx_customers_user;
DROP INDEX IF EXISTS public.idx_customers_name;
DROP INDEX IF EXISTS public.idx_customers_email;
DROP INDEX IF EXISTS public.idx_audit_logs_user_id;
DROP INDEX IF EXISTS public.idx_audit_logs_created_at;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.trip_legs DROP CONSTRAINT IF EXISTS trip_legs_pkey;
ALTER TABLE IF EXISTS ONLY public.status_history DROP CONSTRAINT IF EXISTS status_history_pkey;
ALTER TABLE IF EXISTS ONLY public.service_templates DROP CONSTRAINT IF EXISTS service_templates_pkey;
ALTER TABLE IF EXISTS ONLY public.receipts DROP CONSTRAINT IF EXISTS receipts_pkey;
ALTER TABLE IF EXISTS ONLY public.rate_limits DROP CONSTRAINT IF EXISTS rate_limits_pkey;
ALTER TABLE IF EXISTS ONLY public.rate_limits DROP CONSTRAINT IF EXISTS rate_limits_key_key;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_pkey;
ALTER TABLE IF EXISTS ONLY public.item_templates DROP CONSTRAINT IF EXISTS item_templates_user_id_type_content_key;
ALTER TABLE IF EXISTS ONLY public.item_templates DROP CONSTRAINT IF EXISTS item_templates_pkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_pkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_payment_token_key;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_invoice_number_key;
ALTER TABLE IF EXISTS ONLY public.invoice_items DROP CONSTRAINT IF EXISTS invoice_items_pkey;
ALTER TABLE IF EXISTS ONLY public.customers DROP CONSTRAINT IF EXISTS customers_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_pkey;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.trip_legs;
DROP TABLE IF EXISTS public.status_history;
DROP TABLE IF EXISTS public.service_templates;
DROP TABLE IF EXISTS public.receipts;
DROP TABLE IF EXISTS public.rate_limits;
DROP TABLE IF EXISTS public.payments;
DROP TABLE IF EXISTS public.item_templates;
DROP TABLE IF EXISTS public.invoices;
DROP TABLE IF EXISTS public.invoice_items;
DROP TABLE IF EXISTS public.customers;
DROP TABLE IF EXISTS public.audit_logs;
DROP FUNCTION IF EXISTS public.update_updated_at_column();
DROP EXTENSION IF EXISTS "uuid-ossp";
--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: mac
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO mac;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    action character varying(100) NOT NULL,
    entity character varying(100) NOT NULL,
    entity_id character varying(255),
    details jsonb,
    ip_address character varying(45),
    user_agent text,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO mac;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.customers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    business_name character varying(255),
    address text,
    phone character varying(50),
    notes text,
    invoice_count integer DEFAULT 0,
    total_billed numeric(12,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.customers OWNER TO mac;

--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.invoice_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    description text NOT NULL,
    quantity numeric(10,2) NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    total numeric(12,2) NOT NULL,
    invoice_id uuid NOT NULL,
    title character varying(200) NOT NULL,
    service_type character varying(50) DEFAULT 'standard'::character varying,
    travel_subtype character varying(50)
);


ALTER TABLE public.invoice_items OWNER TO mac;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.invoices (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    invoice_number character varying(50) NOT NULL,
    user_id uuid NOT NULL,
    client_name character varying(255) NOT NULL,
    client_email character varying(255) NOT NULL,
    client_business_name character varying(255),
    client_address text,
    description text,
    subtotal numeric(12,2) NOT NULL,
    tax numeric(12,2) DEFAULT 0 NOT NULL,
    total numeric(12,2) NOT NULL,
    status character varying(50) DEFAULT 'draft'::character varying NOT NULL,
    email_sent_at timestamp with time zone,
    email_sent_to character varying(255),
    paid_at timestamp with time zone,
    payment_method character varying(50),
    stripe_checkout_session_id character varying(255),
    stripe_payment_intent_id character varying(255),
    payment_token character varying(255),
    due_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    payment_instructions text,
    amount_paid numeric(12,2) DEFAULT 0 NOT NULL,
    view_count integer DEFAULT 0,
    last_viewed_at timestamp with time zone,
    view_token character varying(64),
    customer_id uuid
);


ALTER TABLE public.invoices OWNER TO mac;

--
-- Name: item_templates; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.item_templates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    type character varying(20) NOT NULL,
    content text NOT NULL,
    usage_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT item_templates_type_check CHECK (((type)::text = ANY (ARRAY[('title'::character varying)::text, ('description'::character varying)::text])))
);


ALTER TABLE public.item_templates OWNER TO mac;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.payments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    invoice_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL,
    payment_method character varying(50),
    reference character varying(255),
    notes text,
    paid_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payments OWNER TO mac;

--
-- Name: rate_limits; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.rate_limits (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying(255) NOT NULL,
    count integer DEFAULT 0 NOT NULL,
    window_start timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.rate_limits OWNER TO mac;

--
-- Name: receipts; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.receipts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    filename character varying(255) NOT NULL,
    filepath character varying(500) NOT NULL,
    mime_type character varying(100) NOT NULL,
    size integer NOT NULL,
    invoice_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    attachment_type character varying(50) DEFAULT 'other'::character varying NOT NULL
);


ALTER TABLE public.receipts OWNER TO mac;

--
-- Name: service_templates; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.service_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    description text DEFAULT ''::text,
    service_type character varying(50) DEFAULT 'standard'::character varying NOT NULL,
    default_price numeric(10,2) DEFAULT 0 NOT NULL,
    travel_subtype character varying(50),
    usage_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.service_templates OWNER TO mac;

--
-- Name: status_history; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.status_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    invoice_id uuid NOT NULL,
    status character varying(50) NOT NULL,
    changed_at timestamp with time zone DEFAULT now(),
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.status_history OWNER TO mac;

--
-- Name: trip_legs; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.trip_legs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    invoice_item_id uuid NOT NULL,
    leg_order integer DEFAULT 1 NOT NULL,
    from_airport character varying(10) NOT NULL,
    to_airport character varying(10) NOT NULL,
    trip_date date,
    trip_date_end date,
    passengers text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.trip_legs OWNER TO mac;

--
-- Name: users; Type: TABLE; Schema: public; Owner: mac
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    name character varying(255),
    business_name character varying(255),
    business_email character varying(255),
    business_phone character varying(50),
    business_address text,
    tax_id character varying(50),
    currency character varying(10) DEFAULT 'USD'::character varying NOT NULL,
    invoice_prefix character varying(20) DEFAULT 'INV'::character varying NOT NULL,
    default_due_days integer DEFAULT 30 NOT NULL,
    bank_name character varying(255),
    account_name character varying(255),
    account_number character varying(255),
    routing_number character varying(255),
    iban character varying(50),
    paypal_email character varying(255),
    payment_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO mac;

--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.audit_logs (id, action, entity, entity_id, details, ip_address, user_agent, user_id, created_at) FROM stdin;
73aa7de3-9695-40c6-9089-9cba8efe92e5	create	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	{"total": 1470.49, "invoiceNumber": "INV-202601-6242"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:40:29.621576+05
18c51575-b994-4340-9397-17f12829c5b5	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:40:32.214239+05
c91ccae2-1207-4f65-839a-da106535aae0	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:40:32.227435+05
dfb27610-7dad-40db-ad8e-99bcef53aeab	create	receipt	396fe33c-ba96-4384-95a5-7e0029f664d2	{"size": 1624753, "filename": "1-6-1.png", "invoiceId": "930ecd25-40cd-49cc-8df8-ab06d96d302b"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:40:42.11595+05
e3479217-c983-4b7c-866f-8b5479e92b25	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:40:42.170714+05
f6fefaa4-bdf6-4d3d-ab64-684afd75cf94	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:45:59.280085+05
872c66a2-541f-4be9-9769-13728b9432b4	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:47:46.021341+05
e5ced7be-caa2-4e18-91f4-6e2e43246743	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:47:46.023348+05
fb482cee-98ee-4812-a302-1507b9eec366	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:51:27.936884+05
13e574e2-a6d3-4434-8bb6-2c0ec8a5cf37	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 20:52:28.009665+05
db794aea-1863-4a58-8ccf-4ae4775f9115	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:20:27.999143+05
4ccdc11b-ea8d-487b-953c-cfcff9b87914	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:20:49.725733+05
cb4c51f1-371d-4a6c-bc2f-747fbe600609	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:20:49.745645+05
e056528a-1ac0-49ff-bfb4-cf5614bce876	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:25:31.928098+05
1fb3a201-aa85-41b6-abcf-e0d481d5716f	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:25:41.957116+05
02cafc7d-193c-4d2e-8d07-4d480173d542	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:25:41.989617+05
fa6f4e01-b6a3-407c-9197-ef58a57b10ba	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:25:44.509657+05
7ab8d326-7dd8-4b02-996a-9bd7058c6188	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:25:44.528506+05
d41ad524-eb08-4ddd-981c-a63274399030	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:25:53.439803+05
c34903bf-597d-4457-9b86-e1fc239988dd	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:25:54.440962+05
8e79e002-c452-4b32-92db-76ebddeba063	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:29:25.864533+05
5f4e5463-9ae5-40c1-99a8-1da45a18651c	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:29:42.621718+05
d2a39755-aa60-4a9b-a678-7b178ca7afa3	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:33:51.977641+05
27811a6e-2654-4b97-b1d0-b6c6503d4c8a	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:39:50.946854+05
082372c1-09b7-432f-9b6e-812cbbdd570b	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:43:03.972444+05
6f77b2d2-0b13-4586-8b45-c90ff61d330e	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:45:08.686248+05
0355461b-2570-4aa3-a393-c309cc3343e7	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:47:07.602906+05
234b2091-db5e-4ddf-8f39-b318c6e30d43	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:50:44.250944+05
63462129-5bc5-4478-ab6b-7fa519f204ec	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:50:44.272096+05
0c0b374e-6adf-4efb-a0ee-57397afdd1ec	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:52:00.687944+05
0770d372-70f9-4873-894a-168144c8d52e	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:53:26.372121+05
838ad870-3793-4cec-a853-15ca49ce38de	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:53:26.372906+05
e71b1bc1-0032-481b-93eb-da8830a194c7	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 21:59:55.14276+05
742d5288-795f-4fad-95c0-2a39b8d14f5b	update	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	{"invoiceNumber": "INV-202601-6242"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:00:00.27628+05
5ad965e7-4c2c-4293-a3d4-33a4136bad37	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:00:00.636912+05
d7ceebfd-48fa-4cfd-8adb-6dbc1e726ca1	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:00:00.663977+05
97f57543-446f-49fb-b3b1-b6a9c7a52d09	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:04:41.976428+05
17e7f889-55fe-4dd0-a1ff-a6cc4a3e17e2	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:34:05.801808+05
027bef64-8f58-4986-b77c-4fe4203bc628	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:34:12.544974+05
46bcdf27-a224-4042-b615-ae9dc9dd120a	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:34:12.583133+05
9dc0e2aa-d6d6-4742-a6e3-5b8ced29df3f	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:34:18.99031+05
9b320ed4-1145-48e1-ac8b-8141ffd01aa7	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:34:18.998525+05
7748f3d7-f7e7-4104-86d0-33ddb54c27a2	view	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:34:53.099361+05
f4f28a06-bfd1-4bd0-bbaa-0643249b1971	delete	invoice	930ecd25-40cd-49cc-8df8-ab06d96d302b	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:34:59.058102+05
c35e095c-b990-442c-91db-dd8c832dd3c4	create	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	{"total": 540, "invoiceNumber": "INV-202601-4527"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:36:56.224415+05
b0735a28-c7db-4a89-a63d-60c9d34ec02b	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:36:56.616923+05
80f85419-2d1c-4101-b686-7190c8ae5be4	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:36:56.75186+05
0b3b1561-33cb-44c1-9890-4f4a68b8617d	create	receipt	69ccefaf-0670-4d13-ae48-2811f80afe61	{"size": 1624753, "filename": "1-6-1.png", "invoiceId": "69c5301b-dbe5-48e2-aeb6-b7e314ae3dae"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:37:11.196809+05
122dd2f0-9363-4598-850a-ef12e2859773	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:37:11.235474+05
bb55941a-c433-49b3-b78e-8adca759c624	delete	receipt	69ccefaf-0670-4d13-ae48-2811f80afe61	{"invoiceId": "69c5301b-dbe5-48e2-aeb6-b7e314ae3dae"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:37:56.679044+05
c88d11f9-f004-423e-92ce-b80a0b63c8e5	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:37:56.734364+05
25ba1103-7377-42a3-bbe0-cd789a9cb55a	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:39:17.355384+05
26ad53d3-c150-4ad2-8efe-f9179d4a0894	create	receipt	9d6fc0dc-caf4-4544-bc7d-8e0b66ef96ec	{"size": 1614368, "filename": "1-3.png", "invoiceId": "69c5301b-dbe5-48e2-aeb6-b7e314ae3dae"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:39:31.748452+05
29f5970c-c890-45ce-88ae-ccdb9627d554	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:39:31.793787+05
235d0242-787a-49b4-aeea-0e309330335f	delete	receipt	9d6fc0dc-caf4-4544-bc7d-8e0b66ef96ec	{"invoiceId": "69c5301b-dbe5-48e2-aeb6-b7e314ae3dae"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:39:47.415669+05
e5ea85a6-1eb8-4afe-ae12-1086e748ed38	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:39:47.468251+05
2530a733-f440-43ca-80c8-923e671283c9	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:40:41.942292+05
4581d682-0e07-4cf7-9330-ef2db021bfa7	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:51:35.596631+05
5a1e0630-7e20-47ae-82d9-cb7166fc5af8	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:51:35.595794+05
a321b769-1f86-4628-8dc3-491a7626a3ee	create	receipt	ef3b5365-9f93-421b-9280-4b8daeca4874	{"size": 1702606, "filename": "1-5-1.png", "invoiceId": "69c5301b-dbe5-48e2-aeb6-b7e314ae3dae"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:52:10.717944+05
237822c8-5cd6-4530-bd83-61bf28623aeb	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:52:10.779294+05
f3cec157-a1fc-4f5c-8ec0-d4312e599b34	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 22:55:05.527779+05
40ab25c7-d73a-4c23-aacb-e58434b7a33e	create	receipt	338148f7-1fc2-4f2f-9dc5-b11bd06620b9	{"size": 1702606, "filename": "1-5-1.png", "invoiceId": "69c5301b-dbe5-48e2-aeb6-b7e314ae3dae"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:17:34.986966+05
75b2694c-b2bd-45bf-b632-8adf63bfccf2	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:17:35.098988+05
1fb546c1-6d8d-4fc7-8f6a-46f4872be96f	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:36:23.066807+05
72c693b7-f725-4a29-9116-5dc83ca36438	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:36:23.066784+05
679257a7-98d1-4ad2-9580-94a9a3ea51cb	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:37:06.03218+05
fff4a232-a89f-41a4-ab90-c06cba7716c1	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:37:19.335172+05
39667d44-ee94-4a83-aa14-9d7f19653f34	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:37:19.388957+05
0dbf7bb7-d976-4267-873f-9e993783743f	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:38:50.783085+05
7c544564-d61a-434f-a735-36f737049040	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-08 23:38:50.784017+05
928b63b8-891b-4ccd-aaff-a8c2a991f6f4	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:11:31.884661+05
01709d3c-e966-4f6d-91fb-e3b5eb145820	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:11:31.885721+05
426264f8-1c34-4c5a-a25a-a775de3349c3	create	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	{"total": 1500, "invoiceNumber": "INV-202601-9601"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:13:45.328759+05
52330d69-40c3-4bda-bd14-784a19751a0b	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:13:45.586623+05
6f28c9ae-3046-4ed6-af90-370878b5d587	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:13:45.633438+05
3a984a0e-e086-439f-abaa-e0a235da9b78	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:02.386955+05
14b83fb0-a649-49a8-9ff4-8b49abd44dda	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:02.392593+05
e4720c0f-ba9e-4c84-ad2d-9ea539da485d	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:09.787771+05
0fe30a84-1b5b-464e-94b8-15ae06837e2a	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:09.797598+05
395cc586-8055-480a-9788-3fcdd6c26aeb	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:19.150691+05
3daf9802-8eb5-4172-8c7f-9de8bbf79731	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:19.151812+05
e60c8ed2-f518-478a-b646-a7dad7d96470	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:28.036652+05
9f3fa5a8-d910-4a27-bfd6-eca85c3196cb	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:28.038472+05
c80d2c77-03f1-4bf3-9fef-50d17d35afe0	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:40.233576+05
20fa2f2b-7313-4c29-ad94-977e7b4df7fa	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:14:40.235046+05
bf9ddbc5-5415-40de-bdad-93d5ae02c0ef	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:19:35.227503+05
bd44991c-0ea0-4afa-8275-c7f1b876c109	update	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	{"invoiceNumber": "INV-202601-9601"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:20:09.235613+05
79b9bc33-b204-4b95-bace-02e6b8b02401	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:20:09.489314+05
715c5c6e-ef23-4188-9a78-52483204e338	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:20:09.53162+05
f01a1e3c-5c27-4bfd-b05d-023e798e3bbd	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:23:13.887234+05
ab989451-2d14-4b78-b0fd-0ebeb6a07fc2	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:24:26.241413+05
003c1f39-4be7-4399-affd-dbcf3e760080	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:24:26.24238+05
6ff69167-bafa-4bfc-b6a6-3ddd80435852	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:24:31.015915+05
03687511-a146-4a76-8bf6-7bd8ef5d7163	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:24:40.602588+05
d81abc69-5935-40a1-b5d6-db83e4f60278	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:24:31.041901+05
1930d74e-3f4f-461d-a71e-fcdaf6e24de1	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:24:40.597222+05
ef936fdd-b6ce-4008-9e05-d558b308a4e9	create	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	{"total": 1500, "invoiceNumber": "INV-202601-1935"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:26:36.020512+05
205b0d8b-0de0-49aa-97ea-186926e2185e	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:26:36.220835+05
076cee4c-e9c7-4b2c-ac81-3155f4beef2d	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:26:36.252908+05
b7652285-3b8e-4cb5-bced-d45d5e440a38	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:26:42.396923+05
41cf98c5-c01b-48b1-8ad6-b249bb031db1	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:26:42.398483+05
652de571-6e80-438f-8252-3397cca18684	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:26:50.966598+05
0b4dc022-2681-453b-96c0-679966b50de2	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:26:50.967445+05
c4eed182-4c66-4206-977c-bdd5a70e7d73	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:27:40.222642+05
98aeaa1f-0639-4a56-aef7-11b431f1a32b	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:30:16.016514+05
145365a2-2faf-47f1-b4d8-bb158269c934	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-09 01:30:16.017555+05
c8eb133b-802f-472d-989f-3c1e41214653	create	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	{"total": 1595, "invoiceNumber": "INV-202601-3624"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:03:04.421233+05
dbd82e4a-c2d5-42fa-8132-c322d84deefd	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:03:06.043284+05
23231c99-f454-4f12-8828-5cfbb4aafd96	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:03:06.046366+05
de470321-82f4-4bc3-84a7-f7a9d43d75d1	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:04:00.840226+05
bb0c9e42-9c18-49f1-9e60-65ff3b7c4b24	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:04:36.846758+05
3e3b3af2-fc55-4b3f-9e02-b204855f98d5	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:04:36.867324+05
1adf78f8-9618-40cc-bb09-4bee04ce1460	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:05:55.357257+05
49e5d5a4-fa19-4a18-bdc5-0aba5ecaff30	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:05:55.357936+05
396533a7-2740-48c7-aefb-614b6bb3e475	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:05:59.488965+05
81dd0f45-d41e-4ef6-97fe-bf468dddb877	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:05:59.497294+05
bd771ece-8ef6-46d2-9ee5-3f5276f61453	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:06:01.462313+05
e81b7562-2725-4b4c-943e-298d75b3dbc0	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-10 23:06:01.473543+05
92e99944-ca3f-4c12-85d6-f3be13268af4	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-12 15:11:02.059233+05
26d980fd-a3a6-4abf-a390-9a2f1a8833c7	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-12 15:11:02.058637+05
93af7730-0323-45db-9ddc-b74d62e91a43	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 01:17:34.921332+05
69a35f2d-eb50-42f4-8840-b3451eeb37eb	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 01:17:34.92079+05
2940b059-2759-472d-8036-8a47d3f3198c	create	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	{"total": 3387.48, "invoiceNumber": "INV-202601-8928"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:20:55.542894+05
49c3039a-0839-4abf-b751-d857b5696dfd	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:20:55.972018+05
73fd2125-431b-4485-80f0-1e46f7f142bc	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:20:55.972942+05
bb461484-f6a2-4ddc-be0c-7829e245cbc2	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:21:35.605462+05
2435645e-84e5-4006-8f25-32b777d6c22c	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:21:35.602282+05
3f1d7d9a-854b-4bea-a86d-23ffb91b5640	create	receipt	da4ea6ce-c43c-4a84-a177-e85c2f3ad3d0	{"size": 36598, "filename": "5cb0674e273e4639b702faf68ab550d0.jpeg", "invoiceId": "7f5b34be-afa3-4112-a16f-5a2b7eda9352"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:22:35.157196+05
662802eb-4fc2-4896-991e-42981e9ee084	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:22:35.20788+05
0ad6d8b1-092f-46d6-85e8-62e31ed5505c	create	receipt	4a435eb1-e443-454a-b008-ffd486643ffa	{"size": 31460, "filename": "0b743bb1947d4387be21f20ad76726d7.jpeg", "invoiceId": "7f5b34be-afa3-4112-a16f-5a2b7eda9352"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:22:59.371114+05
79bea851-bb26-49a3-985b-7d50e29ed422	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:22:59.417561+05
6d9ee655-d248-45e6-8639-07290f65e386	create	receipt	f39cba8f-c2b1-4755-a38b-4e95867164c4	{"size": 31082, "filename": "96a3f5a90993408b8a9552745c7f62a2.jpeg", "invoiceId": "7f5b34be-afa3-4112-a16f-5a2b7eda9352"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:23:34.291874+05
ceb5bf88-9657-4aea-9901-b79a4d54489e	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:23:34.365267+05
981fdd2b-7066-47a5-a901-701cc4633115	create	receipt	4bccecb4-d1f6-4f99-86c7-56f9326d1d27	{"size": 34022, "filename": "26959c3413fe46d2a4b0af7df482d870.jpeg", "invoiceId": "7f5b34be-afa3-4112-a16f-5a2b7eda9352"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:23:58.378672+05
63152e14-3f13-40ce-872c-d5f2a1834d7d	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:23:58.425264+05
0ad6738b-4b5c-4d27-b5bc-d1dab85be264	create	receipt	7b650aa9-c349-4d96-8ac8-6aafd612809c	{"size": 32697, "filename": "01a1dc3a141646a9a86abcb1cec2eb42.jpeg", "invoiceId": "7f5b34be-afa3-4112-a16f-5a2b7eda9352"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:24:29.835782+05
3f6cf80b-d759-4cbd-9f5f-3864328d1f7c	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:24:29.90402+05
a9fca0b4-86cd-48b0-a793-a22b0614059d	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:31:01.143259+05
c0deb904-91a2-475a-93c3-d9640550d4b5	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:31:01.142609+05
077daee3-5793-4762-b0b3-fb5ccd5441e3	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:34:19.816351+05
0793f744-9f90-4356-a965-310956203037	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:36:28.617151+05
ae087f44-48e5-4a7d-b934-9c91d9a26844	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:36:36.88715+05
2026b527-480c-4ca6-99c1-51f253971cdd	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:36:36.902358+05
816c2184-66e9-4cba-a1d2-0942bb4f853a	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:36:44.627335+05
230ab483-2513-4935-a29b-b0239dc71427	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:36:44.62793+05
e30e000f-ef0e-48e3-80f7-a5e30f9e149d	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:40:50.818699+05
c41ad3ca-1d48-4ee6-a9a9-24013a5ac401	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:43:14.165352+05
7956b14a-d6da-4ca6-b6a8-89acb4d0bc1d	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:43:23.59049+05
53929057-a090-45ea-ab86-33f41837df81	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:43:23.60408+05
392f8e58-5763-48ef-a210-009d58810215	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:43:35.301995+05
8e09044f-959f-4645-9ddd-b1b4aec4ffab	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:43:35.314204+05
a063395c-1a60-4f89-a963-ed9a1c969166	update	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	{"invoiceNumber": "INV-202601-8928"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:43:52.548961+05
08c5aa61-77ad-4169-854c-ce0318c9e299	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:43:52.675533+05
297fd70d-0b03-4321-8850-fd7e23f2026e	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:43:52.685205+05
0676a4ec-4e0e-461d-ac57-69937bf32838	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:44:26.58879+05
5ac4c1d5-67ee-4b30-8f58-ba06a4e39050	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:44:26.589984+05
c8ec7b02-e958-4e68-9eff-3cb26c50df46	update	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	{"invoiceNumber": "INV-202601-8928"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:44:39.456213+05
022e2c2a-4142-4149-b495-8b35d09de7bc	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:44:39.578481+05
41543ab7-ac17-4078-9b34-51a4e5aaeddc	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:44:39.581192+05
28fc7230-63ac-48cf-9856-7367b6cd62d0	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:47:05.769535+05
5a34fca7-8b19-4b35-a412-9f16716721c5	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:47:14.055472+05
fa55e2f6-fab0-49d9-9829-c487e2581ebb	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:47:14.071586+05
160a9a3f-e97d-4679-a7e0-49687e814eed	update	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	{"invoiceNumber": "INV-202601-8928"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:47:24.025667+05
629cc0db-d9ca-45c4-bdd2-5a75d0978bea	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:47:24.166775+05
2dcb7848-3ff0-4d36-94b9-0fba12381156	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:47:24.16737+05
b83a8357-59df-44b3-b9df-7984f5a0e1ca	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:51:47.416828+05
a349510a-22c1-4a02-bc43-1a7fde52fd78	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:51:47.416198+05
4c5a8f7f-0caa-4467-9717-ccbd0c87ed2f	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:54:36.457384+05
00785196-234d-4ec5-b7a5-43f4f9f39bdf	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-13 23:56:38.510528+05
ab4fcb2f-c515-478c-be32-dd472ec6ac29	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-15 23:24:39.443533+05
72179a73-276a-4a21-a92c-f7a098410700	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-15 23:24:39.442404+05
3f478dc6-5305-42b8-889c-e41c6d13ce2e	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-16 19:49:06.714967+05
69f2e36d-444c-4b7b-81c2-029fc899bd42	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-16 19:49:06.715718+05
e16b7d16-d900-47ff-958a-c30151fa0e5c	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-16 19:49:37.598669+05
d80b4977-5692-4cb5-9833-daa87d57c07a	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-16 19:49:37.597298+05
a5eb73b6-7432-4dd5-b6ed-1dc5a311467b	update	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	{"invoiceNumber": "INV001075"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-16 19:53:09.348672+05
fdb73cec-98d9-4c4d-891b-4ce7235405b3	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-16 19:53:09.700134+05
f7fd196a-6d99-4a21-a7cd-7d7b20b853a4	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-16 19:53:09.746669+05
c40a3c7b-fa4d-4fa9-9942-24a6237d17c5	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-19 23:43:48.427101+05
b5742a59-c106-4325-b45c-0ede8116777d	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-19 23:43:48.426193+05
537fe8ff-2b23-48e2-b8f2-8be5b9149a7a	create	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"total": 1520.74, "invoiceNumber": "INV-202601-3505"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:24:59.076687+05
9695f17f-2550-4a51-812c-0ea8b1ecc577	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:24:59.92495+05
1df8ad9e-0491-4542-a556-580ecbeef15f	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:24:59.925802+05
dd0d8a23-0e63-4e60-9513-99b3adf47a2f	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:26:19.915505+05
73c3cbb3-fd41-4c4a-899d-c1da4daff97d	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:26:19.91456+05
92954882-def3-4b58-b35c-3776ac52aba2	create	receipt	405e2a8a-22da-47cf-b548-87acc317bdd5	{"size": 32255, "filename": "5d15131156f4419e9665ba140069c358.jpeg", "invoiceId": "3181ddd4-96e2-4972-81de-2cd306bd4c28"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:27:00.828866+05
f2117ba5-aa3e-4f5c-a506-6476ed0ff789	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:27:00.931735+05
ec2d33f6-1b2e-438f-ad08-1574f35974a0	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:27:45.034703+05
bc0dde66-f574-425d-9673-8730af70b08d	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:27:45.066897+05
1c04043d-3040-4faf-986f-158f9ea4ae52	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:28:13.207778+05
cc94586c-acee-4052-9297-976c118266c5	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:28:13.209344+05
7c3e87c9-76dc-497d-bb88-5bdadb811d10	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:28:45.935388+05
873ef4d4-9d87-4291-bba5-a21efce3d8e8	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:28:45.938303+05
d3ceba8f-1839-414e-905d-b4590e8f69df	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:28:59.761792+05
906b1107-9090-4146-a463-8913a3a3f095	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:29:00.026596+05
8628b097-eb36-4169-bba9-e9319926c7f4	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:29:00.027372+05
c42bc23b-1396-44b8-a8ff-4433a2acb819	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:35:35.808944+05
224c0e0d-3d79-455b-8723-30eecbec6ff4	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:35:35.808239+05
04b2fddd-88d5-4cd4-9293-f5e75a43d5b1	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:35:46.513791+05
85c854c2-e88a-48aa-a972-b4b58f3402c5	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:35:46.898037+05
4a9d5123-4449-4db7-9f58-de75a0200531	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:35:46.877448+05
d4f43859-9cfe-440b-8033-66c592030a39	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:38:25.518433+05
51641136-d530-46b7-a2ca-a37dc230ac66	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:38:25.519107+05
a7545161-353d-4ec2-acaa-5d7068738ea8	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:38:28.227513+05
17b8f44f-5835-4166-829e-6ef9dc1de54a	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:38:28.228301+05
2b93cb00-bbfb-4808-aa6c-827686ae42cb	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:38:45.693015+05
195f61ea-55a6-4a1b-ba43-4276a30080bb	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:38:45.917097+05
5e905356-9db4-4535-a6aa-168355459b5e	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:38:45.918031+05
2fe64506-2a05-4096-b2ab-94ad6d0313cb	create	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	{"total": 1500, "invoiceNumber": "INV-202601-9107"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:49:11.190388+05
d513b4a2-a114-444d-940f-647d997e3e0a	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:49:11.560943+05
cd036950-cb65-4f73-add0-6c8a69d5be0c	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:49:11.561583+05
2a707fb9-0be9-4225-b410-d5bed0a79628	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:49:17.941221+05
e796bfef-611e-4736-914d-4568a63d207c	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:49:17.957752+05
1cc6d85b-8d8f-4c59-9dca-d52fbadbdeba	update	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	{"invoiceNumber": "INV001081"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:49:42.248939+05
afb5a43c-f54b-42c6-af7f-47676b2b613f	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:49:42.462919+05
ffd2e4c3-2d91-4f4e-8e3d-73c8877230d9	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-21 23:49:42.593649+05
3e8418d6-348e-41af-9ee7-a47edb0d3b8a	create	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	{"total": 3383.61, "invoiceNumber": "INV-202601-3214"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:04:22.653862+05
ef2243a2-8168-4491-a020-101ef1d60b58	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:04:24.302854+05
3289d9f3-5760-40a2-ae07-ebc7374769e8	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:04:24.30372+05
16b3e659-0621-4afd-846e-0ea09adfab3f	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:04:34.032108+05
b036b803-8827-4388-9da9-cab440ccafc8	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:04:34.032931+05
68caaa96-7bba-4e9b-86ff-0841ae2c1fd9	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:04:46.439416+05
b0a82af0-f93c-4ef2-8e32-87447e9a9450	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:04:46.449008+05
2cb5ed34-65d9-45af-95f7-e05a1cd0eebc	create	receipt	ae21d82f-32d0-4596-872e-7497e19da2bf	{"size": 35014, "filename": "WhatsApp Image 2026-01-21 at 22.16.31.jpeg", "invoiceId": "c96d8142-4e0d-4f4b-93f7-01612b4ebcd8"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:06:44.772212+05
80edb756-2d6d-47ec-ac5c-42efc3ac5f4e	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:06:44.97018+05
c8e4fe32-fa1f-431c-b04e-1739f150612d	create	receipt	94670181-0469-486e-860f-99f1f24133b6	{"size": 33937, "filename": "WhatsApp Image 2026-01-21 at 22.16.32.jpeg", "invoiceId": "c96d8142-4e0d-4f4b-93f7-01612b4ebcd8"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:06:51.923414+05
517314f2-975f-4c3d-9eb7-054f33d0c0da	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:06:51.994076+05
59f87aed-cb69-4b9d-ae33-763176c03477	create	receipt	7b7f4f23-f31e-49a4-9739-801340df9cf8	{"size": 32642, "filename": "WhatsApp Image 2026-01-21 at 22.16.35.jpeg", "invoiceId": "c96d8142-4e0d-4f4b-93f7-01612b4ebcd8"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:06:57.337964+05
df57a707-11b8-41be-a389-49bdbef92972	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:06:57.429443+05
f8963936-041e-4d7b-8b4e-a9dab271e107	create	receipt	111ff159-5a21-4934-8fa5-3b8fe1297f03	{"size": 36712, "filename": "WhatsApp Image 2026-01-21 at 22.16.38.jpeg", "invoiceId": "c96d8142-4e0d-4f4b-93f7-01612b4ebcd8"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:07:02.983517+05
2b2988c4-d0c7-44af-8408-afe5f0a33491	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:07:03.075034+05
82c7ff3f-a7e8-4255-aa3a-9e9a9fa23e98	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:07:18.881184+05
55bafa36-d57b-4273-bbf6-048acc99de6f	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:07:18.897193+05
9877c881-c5d0-45f5-95a0-16519b5499c6	update	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	{"invoiceNumber": "INV001082"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:07:28.945519+05
5fd80b6a-c1f6-4e27-8315-cb0a07cf6022	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:07:29.482084+05
516d7c4c-885a-4bfe-aa3a-7c01be481e41	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 00:07:29.482624+05
5e531ae6-8006-49fb-8a76-3c3e37d0e563	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:08:10.833726+05
25f1c150-024f-4cf7-931b-9d1be73d9460	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:08:10.832723+05
d0593c4a-71c9-434e-a631-8f2d71db2796	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:08:14.877697+05
50de5b4c-9751-4ce6-b0a5-a3d35b4e1923	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:08:14.92257+05
fd981662-c3ef-458d-9876-879a46dcacb0	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:13:54.788314+05
d69b34f4-0594-4ff2-bbe8-8dfe8b0547fd	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:13:55.126431+05
8f1e6dfa-acae-441f-9212-b7723ce3cc7d	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:13:55.169066+05
a31f25c7-f066-408e-93ae-12ab28f29d8d	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:02.829308+05
3a9758d0-f148-4439-ae5f-88abdf41c056	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:02.830199+05
6cc55660-20b7-4380-820a-9bf2df67df44	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:07.666119+05
ad74dd07-2bed-44da-b9f7-0ed42adb8c35	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:07.709856+05
215ac437-abf5-42c8-af20-1470c51f0d78	update	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	{"invoiceNumber": "INV001081"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:23.925576+05
63428366-13a6-4430-956a-230574558a4f	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:24.11193+05
06bcc8db-ee68-4bd2-82f9-2e35be41e2c8	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:24.11624+05
c6aedfe3-a704-4ebc-bdf6-54bb3ee26313	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:35.738499+05
e51f9d7e-d378-4656-942d-0ea29bfac375	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-22 23:14:35.814346+05
02a73ea3-6e8d-4162-8210-d38b8e1c248a	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 20:33:15.167818+05
aac9462a-05b3-40ca-b6f6-c4cc06399f39	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 20:33:21.448892+05
1ba1a0f5-fdbb-4386-91e4-82cd981a2c7f	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 20:33:21.83772+05
976d4382-7ae8-4ba7-8f0a-4ffb1fdcc98a	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 20:33:26.59631+05
fe24b343-45fd-4276-8031-20bbeb4cb1ec	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 20:33:26.597287+05
1d01c684-df8f-49f1-b7c1-c95467bb9171	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 21:05:18.078157+05
cf5217b2-d262-452e-80bf-91c2fc573fa0	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 21:05:18.296512+05
bebdebc1-7765-49ca-b7b3-a37fbb5c16d8	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 21:05:18.329568+05
71b7af3d-00c7-429e-86a8-70bbdecc5ab9	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 21:05:33.836806+05
ffb85659-55ab-4b9c-910e-b26be0685fb2	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 21:05:33.841553+05
5b71b60c-073c-4827-8ae1-ead6ef5e9bfa	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 22:43:51.389331+05
35c7e637-ec7c-4649-af74-0a6790323aba	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 22:43:51.389943+05
dbbc2572-781a-41ba-a479-ef0ee6e103dc	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 22:44:10.929826+05
b78f35dd-15e0-4f4b-8e80-3ee544e6b3c6	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 22:44:11.09371+05
b0ea107a-5f29-4185-ab7c-00c26029f1cc	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-24 22:44:11.098692+05
2c6ed4f8-976e-4025-a7fd-ac3d00f8a8f4	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:53:27.58565+05
3d723e3f-fc61-46b4-bc25-c4b5a364acaf	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:53:27.586428+05
afd7ac83-1c68-4db8-828e-b2fb39f5f521	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:53:31.1513+05
2bb6aa03-fbe3-445f-9b93-c7481ed8bb2a	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:53:31.152008+05
7b049a6f-a1ba-4b66-8a11-1b24e0f7bdbd	update	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	{"invoiceNumber": "INV001081"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:53:44.858057+05
9c7c2965-2892-46e6-91a7-6546d09e5d9d	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:53:45.036695+05
a8df2daa-12cd-405b-87eb-672edd78ea7e	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:53:45.043635+05
565412cc-7a94-41f0-840b-cbcae287f518	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:54:25.066392+05
4a2c65c6-fe6e-43cd-85b5-e02022dc89cf	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:54:25.066999+05
53f006c7-6ead-4c29-afbe-2aa0754e9c51	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:54:29.692207+05
04dbea67-43c3-4331-8a9b-9a51b7b30aec	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:54:29.692818+05
f024c385-e1b5-487e-8b13-42cfa70e14e3	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:54:44.893686+05
d31bd0fa-987d-4572-9686-8ef6e4b9f6ec	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:54:45.062691+05
5c63663a-a785-498c-81b5-a0d16289d7cc	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:54:45.06841+05
ad44ac13-8e24-4148-804b-fefdecbaf828	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:56:09.31437+05
14220c71-cc41-46f4-9d75-a479542a1bb3	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:56:09.314854+05
78ebc550-73dd-479a-b652-7e09d005fbbb	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:56:14.341536+05
5e1c82d7-41a3-4082-8527-1bd33471c4a6	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:56:17.329431+05
0dc93063-1868-4805-9c25-86281e5cba59	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:56:39.456623+05
c27ea84b-b716-4870-ae1e-dd1e411b2eaf	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:56:14.342227+05
694d74bd-6dd9-470e-a874-07c389573df1	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:56:17.328854+05
dc6722e2-edbb-484f-a0e8-580353cc177d	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 00:56:39.457943+05
d436d4c8-c002-48da-b9c4-72ae25587416	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:05:30.271798+05
b1ca64ee-df3a-4949-a163-e3007a12ec76	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:05:30.272472+05
ef1e612c-7f93-4b26-8bc3-b7723fd901bf	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:06:03.453267+05
7d2691e2-ae97-49f3-a5ec-52a4a6f9d24a	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:06:03.454228+05
57530b57-6663-4b96-8f72-971cbd2fc69a	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:07:43.051645+05
0aaa4e4a-b5b8-40ae-a0c0-afda52b6b549	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:07:43.051063+05
f40c6460-8e8f-489f-8ef2-5862262be9f3	update	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	{"invoiceNumber": "INV001081"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:07:58.673974+05
539edc80-c52e-4323-b031-e6bd4aa5e6f3	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:07:58.794391+05
291930a6-b2e3-4f31-bdd0-bb0531720b3b	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:07:58.798634+05
004deb47-8edc-412e-8ffc-f65e22abeac9	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:23:34.975172+05
1eb7c292-c2d1-4441-a0ae-cde8af5c9a5e	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:23:34.975796+05
b657dfe3-dcb3-4fd2-9fe5-b3c9fdb434e9	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:23:37.523495+05
8c30487c-c6c2-44e3-8d45-583419fb5ef6	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:23:37.525221+05
136b696d-b020-4cfb-adb6-88ca065846a3	update	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	{"invoiceNumber": "INV001075"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:24:19.547229+05
50b57202-5f81-4e00-ade9-9f390223d436	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:24:19.661892+05
0415be60-93de-442f-a912-11e09441ef98	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:24:19.675642+05
1698284d-e137-4149-9a9b-876d0e689881	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:25:30.050454+05
081be11f-3efc-4cf8-b6b6-eae5bd709fa2	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:25:30.051036+05
41ac9b0e-ace5-4f2e-b392-fa8f14e530c9	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:25:32.738019+05
16af90d3-3e42-4fd9-9cf4-309e88deecf7	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:25:32.753142+05
cdf18486-88b0-497c-835b-0635bb87f9f3	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:25:43.31531+05
34e8200c-f091-49b3-8464-7cbce75f0bdf	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:25:43.422589+05
dd089703-efd8-47e0-9c4f-c328a5b28e68	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:25:43.423257+05
b871325e-6aad-4f2f-8dba-e2e7f14ce688	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:37.575021+05
fc78a241-8536-4870-b740-890aed1512d1	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:37.575621+05
6bd8fe8f-fe10-4f64-90cb-e235253abf2b	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:40.290495+05
379ae7b1-8a3d-4634-93d3-3d531a43a5d8	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:40.289752+05
a4b3fa9d-65ee-4507-97bd-01ddf7b08c5c	update	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	{"invoiceNumber": "INV001082"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:43.757497+05
ccd69d91-1a74-4004-b1dd-1e1ffab664aa	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:43.929054+05
402267c2-d1d7-45c0-9227-4910fb73a714	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:54.479197+05
62c50743-2da3-4e1d-b608-6d08bca55067	update	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	{"invoiceNumber": "INV001082"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:27:01.598581+05
8d263405-c726-4f3a-91ed-7d248f5c1fd2	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:27:01.737667+05
41a2f7e5-4aa3-4753-9f8d-805dad98551f	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:43.929875+05
7039dfbc-859f-4e8c-8dd0-655e7f03d930	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:26:54.475358+05
8dde84d6-3be1-48a2-adc2-0c081f673791	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:27:01.738856+05
c06d3bc7-a72c-4dfe-ab10-0d522da20d26	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:28:35.69338+05
3d8e7963-6c3f-48d9-b952-8b896cf3d68f	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:28:35.697729+05
e6a6e0df-2bab-4757-97e9-4c2d69fc0093	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:28:48.801696+05
49f7a377-6f55-4cc2-ae03-ccc27f58e903	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:28:48.804768+05
1c04a2ff-c4e5-417a-a8c3-e9e8695a1c2e	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:29:01.605604+05
9546fed7-252d-43ee-a23f-760ca55fbfce	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:29:01.60622+05
26aa37cb-84a4-4552-a145-fa92d69c3bc6	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:30:14.648602+05
b181f322-d93a-4528-b039-b8fafe978125	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:30:14.649228+05
14d4b6cd-47d2-4f02-bd97-7fb8e35fd620	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:30:16.98068+05
94a5e4e8-1b18-4734-91cd-94ccc3d4aa96	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:30:16.981398+05
8b902443-c59f-4ddb-ad7b-76b9214839e4	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:39:40.670136+05
64c0743d-834a-471f-8b4e-c47d18fb357a	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:39:47.547313+05
4e698440-b00d-4999-a2a6-a510d9670ba4	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:39:47.579206+05
5b483db1-b886-4d8c-96ba-3fa50a3eb4c4	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:39:50.492436+05
e38d8ccf-b1de-4be7-8756-b98212e54153	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:39:50.4934+05
f10c9a7a-28fd-47cc-9969-74fa23cfedc3	update	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	{"invoiceNumber": "INV001075"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:39:57.277784+05
9a0c407e-0ca2-4ef9-b939-7422862666f3	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:39:57.446339+05
e3c4143e-882e-4bf9-b345-987eeae87ce2	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:39:57.458584+05
068adb96-4ae9-48b2-b8ac-81c763e79e6a	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:12.060362+05
9f28d91c-5b42-4a98-8220-7169e9a9d4e6	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:12.062791+05
ea05bbad-6402-4143-bb47-20249f454a3e	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:14.42991+05
6c0a03e9-47d8-46ce-9ca3-a79b3dd10ed1	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:14.438956+05
d830e051-a260-4ca1-a661-c9f270462b91	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:19.107717+05
6fcb4d00-9477-4dd0-891e-649ad53ee45b	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:19.286417+05
e7438b4c-7d9b-45b9-b4ce-2630d6f7fa90	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:19.292974+05
7f990ab3-3170-4c43-aaa7-043cb26ed778	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:24.256548+05
47f8af6d-63df-461c-8c47-f448a907ef29	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:24.257687+05
ea3eda6d-9b79-4d3d-81a3-06673707ca6e	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:26.567321+05
298c1ced-b222-4fdc-9ac7-ec997df971d6	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:26.574567+05
270deedd-d49a-49e8-94c2-b6fd59ddf506	update	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	{"invoiceNumber": "INV001081"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:37.998773+05
0ba75559-0a6e-4474-9aaa-dec90b79a824	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:38.423298+05
7754113b-65f2-4a41-accd-497ab6005b89	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:48.237644+05
7978209a-f679-4c9c-90d7-cd31f1340d1d	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:50.129483+05
f7480cdb-4a48-47da-b0e8-065fc0ab9bbb	update	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	{"invoiceNumber": "INV001082"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:54.856883+05
e16804bb-f3de-4b3b-86fa-15def5b36b4a	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:55.068859+05
a9dc771c-e3b0-4a99-81c5-517230a5617f	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:38.422217+05
1894cd26-6125-46f3-9121-535440f4804a	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:48.243193+05
ee52637e-58d6-4cc7-801c-73dc2f079893	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:50.128415+05
c2a257a9-ff4a-42ca-a4b9-2d740610e749	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-25 01:40:55.069992+05
64bcd1be-b65b-47b4-b450-be7227e2848f	create	invoice	72379e88-a26b-41a9-9c96-29e34db41621	{"total": 1500, "invoiceNumber": "INV-202601-9136"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:33:19.870678+05
ed28e7fa-99a7-4a42-a92a-236386db7e9f	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:33:21.919256+05
969c7b75-e6c7-48b0-9451-18ecb63a9514	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:33:21.924497+05
7bcbf90a-51ed-4dbf-8d6a-7542b6e530f5	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:33:32.643131+05
19df4e4b-d974-4c21-8fca-242fb8708d11	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:33:32.644157+05
81e8eeb4-b25c-4b32-9b6c-f65a8fb10de7	update	invoice	72379e88-a26b-41a9-9c96-29e34db41621	{"invoiceNumber": "INV001083"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:33:38.597475+05
22c6dc5e-d98f-440f-86c1-900b4d2d8531	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:33:38.729733+05
bec89b10-867c-4619-93c2-5e27e7c9d945	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:33:38.731475+05
6ae0e04e-4924-43dc-9571-d1f09f340a71	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:37:19.860067+05
c9804a27-4233-4b8c-b20a-6d9cc7d878ae	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:37:19.85916+05
3872728e-46b3-4796-b2eb-a5611eb298c2	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:37:25.574184+05
afd96feb-cdbc-49b6-80b7-3a25004b5319	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:37:25.576109+05
7653af64-8378-4038-acd3-3623c7b808ab	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:05.543629+05
7046bfb0-567c-4881-9f3a-18373687373d	view	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:05.542997+05
7b9cbd5d-359d-402c-b1b7-9bf361343726	delete	invoice	abe08e63-7277-4844-8e8b-926f1e3c0c37	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:10.340626+05
a34e3c54-6fe3-4a9c-8d77-dd2d0ee4b92f	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:18.087158+05
10ce9e68-1d23-4057-b5a8-1bae96c17b52	view	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:18.0878+05
ff41fb74-8554-4f45-82b3-0811d005ea89	delete	invoice	d9ca19b4-e02e-4a29-a25b-c0ce4e52fc41	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:22.09536+05
e4093670-8df7-4233-980b-fe7aa287e002	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:25.342067+05
76962d9d-6cfe-495f-bb32-0e0bd2799c7b	view	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:25.346013+05
02b5d70e-607b-4811-912f-2f60a63e2fe9	delete	invoice	c2435b33-51fc-4992-9d46-6a8047bf4e4a	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:28.189067+05
6d761d37-0cdb-4383-afae-10b803408a5e	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:32.169122+05
305a2224-8d69-4989-a246-1a95796933e4	view	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:32.173893+05
509169f5-832d-4840-b030-cb8a880dfccd	delete	invoice	69c5301b-dbe5-48e2-aeb6-b7e314ae3dae	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:58:35.386213+05
7097f5f1-795c-4873-9cf4-1e65e603f502	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:59:21.437875+05
21875a8c-9e7c-4d69-a0dd-59f56848955e	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:59:21.44627+05
641fafdf-b1e6-449c-9d82-6a5a2e89ee28	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:59:30.680546+05
669351c5-c005-434d-8466-a6ae35a8e5a8	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 17:59:30.692077+05
5ffcef7c-8f0c-489c-b6b1-d8b0b5852f2b	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:03:17.366825+05
07cbde96-d192-4c61-9d53-837ed6b07793	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:03:25.710191+05
495e9b37-131b-447d-8ef5-d108c6aefc9d	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:03:28.217817+05
9047412b-fd7a-4c2c-90d9-cccf8c2ff6af	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:03:17.367489+05
27dbeff6-544f-4ae8-a043-7cced6fb643b	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:03:25.725985+05
af1b9e3f-7e68-44b3-97b9-81eaad5d4ba0	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:03:28.216109+05
65eadf24-7fb0-4238-b075-0181a6516d1f	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:50:29.722693+05
18474566-3311-4326-8138-83b0b71fff9d	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:50:29.722118+05
f0485096-d9a5-4fdb-b072-c3172a0a0b29	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:50:32.217706+05
6b43e4bb-1edd-40ed-9495-ac7251140ba2	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-28 18:50:32.22171+05
f38dbfd2-6084-49fe-ae5e-3aff4d5b7798	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-31 04:24:49.766709+05
fb6e0962-fd9b-4ef1-92b5-3293e5b00f9b	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-31 04:24:49.765949+05
5c0732e1-74f2-440a-a915-425057b633e0	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-31 04:24:54.653345+05
614c9521-12ba-4f79-9ac8-245d82ffe6bf	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-31 04:24:54.653964+05
713e252d-281a-46ae-becf-8104025547b6	update	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	{"invoiceNumber": "INV001081"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-31 04:25:01.001624+05
61ce2752-3ff8-43b4-b721-1b33a4c1e436	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-31 04:25:02.203014+05
650b2bfc-109c-4c75-93a0-39e9a08d43ec	view	invoice	254dd0cb-04de-4072-9d68-0d967be1ac15	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-01-31 04:25:02.363563+05
67764f9d-3a0a-477e-8c8b-9aa19f270f08	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:21.318614+05
edf115bf-20ae-441e-aac5-c0c2cd8a0b3a	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:21.317866+05
079784f9-796f-4bee-b397-8ba61d8ef873	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:25.150928+05
bcee814b-ac33-4b85-bdb4-4889c4efec17	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:25.152033+05
3b9e705d-e132-4f67-a0f2-51245701c472	update	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	{"invoiceNumber": "INV001075"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:30.954261+05
316a20ff-d9b6-41ea-a0e7-d7f3f7954c78	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:31.098951+05
30528ed4-e169-4030-be60-c594a78add96	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:31.100101+05
42a90d81-a2fa-4de8-981b-39e4a9071329	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:35.515501+05
ca60ad41-54f8-4e85-86b3-38a7b93e7da5	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:35.527508+05
aff99fa5-0be5-4af0-b829-05d6c9ca0c89	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:37.904976+05
6d6cbf15-11da-4075-8e2d-20616d97d10e	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:37.906447+05
6d27562f-b0a2-4e46-80b1-f2fb4f2b3298	update	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	{"invoiceNumber": "INV001082"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:45.885272+05
5d28e884-170e-4208-9632-bf1fc7857fb4	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:46.016814+05
48cd1958-e9ac-490f-a12e-0ed338e6f948	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:46.019243+05
b14e1f79-107a-4ea4-8b12-b0d339bb7366	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:49.38078+05
7bf383e6-6189-40ae-b5e5-e10667cfce5e	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:49.381506+05
2017c772-b935-4ce4-bc34-e5bdd09fe5c2	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:53.361606+05
028aa939-d33a-4f84-8d44-4cd182276b5a	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:32:53.362677+05
08143df7-46f4-411c-862d-837b7f9045b1	update	invoice	72379e88-a26b-41a9-9c96-29e34db41621	{"invoiceNumber": "INV001083"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:33:00.2222+05
4c98dbab-50c8-4082-ab88-22ff62023121	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:33:00.345142+05
02eb3765-fa63-4350-8691-a9343d78ca54	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 20:33:00.345966+05
acf21adb-8dbe-4718-8b88-69ee1a669329	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 21:43:08.343542+05
f0aa2f54-4012-4bd4-892e-9a1c78c494fa	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 21:43:08.343761+05
1476d76c-e2ec-420a-9abb-857e1cc120ac	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 21:43:30.931276+05
67bedf8d-afbe-4d3a-b5b3-410e7e4b4a71	view	invoice	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 21:43:30.948691+05
3244158e-2a64-43ad-88c6-e6cb9df17e87	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 21:43:38.574553+05
fa4f38c8-f637-4749-848d-963f05499a1a	view	invoice	7f5b34be-afa3-4112-a16f-5a2b7eda9352	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-02 21:43:38.687645+05
b3c3d87b-cb56-4390-9e1a-4a106013c5d0	create	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	{"total": 199, "invoiceNumber": "INV-202602-8461"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:37:58.812897+05
fb810c76-cf39-4684-bf11-14ab85df555a	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:37:59.324776+05
48bbe2a1-39e5-4b08-9466-8ce3b9bf54b5	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:37:59.326097+05
bb367f9f-c3d9-480d-a883-54527e154e8a	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:38:02.569377+05
640adc32-c6d8-4b48-bdb7-12f6b0dc74cd	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:38:02.640615+05
e5e81029-a1eb-4957-8c14-e11ec3b94e23	update	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	{"invoiceNumber": "INV001084"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:38:13.833373+05
93c2d8f2-efb4-4be4-aaa1-5c4ba354cf4a	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:38:13.975628+05
b4261cac-31eb-4b57-8388-a9f06398a063	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:38:13.978426+05
19227222-3891-450b-8e8d-6b2dcfb03c73	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:42:20.92344+05
f0fe554a-a9a7-4cd8-9c42-388718ce4eff	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:42:20.924084+05
1a747daf-71b5-4f78-aea6-9543bfff93de	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:42:22.425173+05
5123a02d-d3cc-452d-b20a-b513aa167dc6	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:42:22.430196+05
f08873e0-dee0-425b-87e7-01f23ee45c29	update	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	{"invoiceNumber": "INV001084"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:42:31.170487+05
1fcae1b1-952a-4862-b954-dd0a4732eb56	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:42:31.290323+05
c3cc2820-85b7-4076-a55f-5f22606e846e	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-03 00:42:31.319091+05
9a092d7c-7918-4fb8-9353-21e40f8c4ce1	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:22:11.172584+05
b0374fa8-d272-42e2-8e8a-e5c2750723fe	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:22:11.173324+05
d6ff592b-8021-4c0b-bfe3-747224dac862	create	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	{"total": 1500, "invoiceNumber": "INV-202602-3474"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:34:26.493834+05
b19b91d8-7983-49ff-b056-fbd021339148	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:34:27.065056+05
12e91a5c-c78c-47e9-a437-191588da8bb2	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:34:27.064538+05
8cd7dd31-a3fc-48ba-a18f-086cda591afc	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:34:29.681636+05
aa830d51-cafb-46f6-807f-db1b9fcc7166	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:34:29.805667+05
116b8ba2-927d-460e-8235-a060e6ba28c3	update	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	{"invoiceNumber": "INV001085"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:34:43.181836+05
d85350c4-a3ab-43d9-8945-dc6ce4f545d5	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:34:43.385827+05
fc51b772-ea35-4308-9a15-2b56b303b110	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-06 19:34:43.397796+05
579392c2-15d0-4348-b17e-50ee37fe2044	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 00:49:23.654681+05
15a6c53c-0763-489c-81b6-6e6a38c49ec9	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 01:05:01.105023+05
c5c5ea25-8b40-44d3-b1b9-895b16a8105c	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 01:05:01.105664+05
c846fdec-7327-4f3a-8cbf-7f50ea7dbe4d	update	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	{"invoiceNumber": "INV001085"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 01:05:07.076625+05
b452fd2e-6793-4ac2-907f-b9851ec72679	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 01:05:07.246129+05
2444eccb-51f5-4058-ac24-812dc2144297	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 01:05:07.247489+05
39f3c579-0dfc-4dde-93c9-05ae9798ec83	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:52:47.992905+05
4f137fd4-8f72-45ad-b903-35ba9d5fddce	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:52:47.991736+05
6193d897-8d97-4e8b-b2f6-e2a6b215765f	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:53:49.73117+05
a60f8ff2-5801-4fcf-88d0-496f8ab04341	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:53:49.741593+05
75c1d4cd-4e78-42c8-86d2-f3995fb95898	create	receipt	016c8971-3b29-45a5-ac84-cb4e90510575	{"size": 30141, "filename": "Meal receipt.jpeg", "invoiceId": "99102b7d-0114-449b-a55d-0d54ee58dd90"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:56:01.80046+05
229ae23f-4a01-44bc-bce3-69fca073100e	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:56:02.189196+05
07115219-3490-4804-b469-0d181012dd70	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:56:11.654608+05
e4bbcc03-45b6-4976-bac8-943edad0f6c5	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:56:12.184692+05
b1595e77-3a60-4146-a3f1-a8c7a1bb7709	update	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	{"invoiceNumber": "INV001085"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:57:25.481723+05
df6f3b4e-20c4-426e-85a5-b1fe5bc277fe	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:57:25.73732+05
7f1ccfd7-7f0e-4870-928c-051f6751d1b7	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 22:57:25.779399+05
b0e52826-5b60-4ca6-aeb5-176cabcccc7b	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:01:14.2428+05
02e797e9-7af1-416d-8859-241c420bbf6e	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:01:14.248141+05
528ce103-9ea2-4907-b967-8bb8ee9adc85	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:01:25.128746+05
842aca25-bc85-4b76-879f-7b05ea395e03	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:01:25.129364+05
712dab6c-2c15-4069-882e-872990f493e4	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:02.729098+05
88cb88f7-45b1-4985-b8cd-66e2945bb496	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:02.72907+05
03622f83-08af-4800-9291-70c44e83aab2	create	receipt	ab100d44-86dd-42a8-9244-a423459b13fd	{"size": 27047, "filename": "Hundley Meal.jpeg", "invoiceId": "72379e88-a26b-41a9-9c96-29e34db41621"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:15.18967+05
2515d8f1-c020-46f1-b3d2-a7c36f6143c1	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:15.23991+05
408d50e8-906a-46eb-a04d-d422b208c641	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:24.541389+05
fe1b4b08-60ae-4d85-85a8-9744c96fda4b	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:24.544957+05
0e2ecfe3-8a87-43ab-a96b-154875657629	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:30.787399+05
44ef5d04-47c9-46b5-9b96-6f08a951fdb8	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:30.788011+05
09abcf1c-9c66-4b72-b6e4-c3ca3b8830e6	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:32.089581+05
43714d46-b93d-478d-a2be-2edcce479bbe	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:03:32.102358+05
668e95f3-d014-41b3-9d28-9812c9c82ae4	update	invoice	72379e88-a26b-41a9-9c96-29e34db41621	{"invoiceNumber": "INV001083"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:04:43.435401+05
e7442a7a-7aea-4399-a37c-af95718a7b8d	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:04:43.733544+05
cd29d4e5-e20c-4edb-bad0-e61afd79334d	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:04:43.735927+05
559611f6-ce42-47a8-a2e7-b477d5eb869b	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:07:04.714372+05
943327d7-d6db-4a4b-94cf-e5eb6562a015	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:07:04.713585+05
2a2bdd34-c41b-43ca-8cbe-aa4e4ab06c7e	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:07:12.791235+05
284395cf-5265-49f8-a47b-c1da30ac5828	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:07:12.791989+05
f6afda86-8d88-48b6-be62-68edad23e417	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:07:24.911294+05
cf47377d-d625-4400-97e0-bf99741cc186	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:07:24.92139+05
01ec449f-3554-43cb-93a4-e0ced5dd7afd	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:07:35.621976+05
b3e18205-82b4-4581-8a16-66d617707f61	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:07:35.623373+05
31e371b7-12cb-4e3f-b16a-84ecfcd56199	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:09:38.973742+05
0fceaafc-9537-45fc-abc5-2a99b08ef27b	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:09:38.99378+05
2506aa46-7eed-4da8-b18d-5dbfb7387c03	update	invoice	72379e88-a26b-41a9-9c96-29e34db41621	{"invoiceNumber": "INV001083"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:09:44.972+05
8ba522ee-f4cc-443d-9d91-773b2d2fe791	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:09:45.226597+05
8fae7e42-18a2-4cff-b64e-8c0c29329541	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-07 23:09:45.22848+05
06300ad8-17d2-43e9-833b-a6b84476a45f	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:37:59.477113+05
48a8317e-7327-4019-af77-2b4d4732a499	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:37:59.477796+05
750cbbd4-95d6-449e-887d-fa730a356761	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:38:03.640592+05
407cda46-5661-47b7-b025-7537be40108c	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:38:03.641069+05
88670f2d-79ed-4668-89a7-0399bca1d1c3	update	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	{"invoiceNumber": "INV001085"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:38:16.153275+05
a20254cb-ada4-4d46-853d-6f9079f17185	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:38:16.630084+05
737cb0b4-0f9e-4b1b-9b62-d25948610064	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:38:16.640951+05
09c5a7ca-5245-4bef-9b7c-bad0b524bb9e	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:49:37.92912+05
744f911c-3673-4b8e-849d-59bb94a9227f	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 02:49:37.929957+05
872bc458-1f02-495b-b403-b8768b6ea65e	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 03:16:39.900217+05
2a4814da-2636-4c70-9206-c8a0ddf0bec2	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 03:16:39.899666+05
2d1eb51c-0dde-400b-bc52-edfd3606fccc	update	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	{"invoiceNumber": "INV001080"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 03:16:45.04497+05
e8b01289-a99a-47e5-8a4a-40a580ee3f33	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 03:16:45.259654+05
0cf51639-d0db-4ca9-bd1b-a33b3d8202c6	view	invoice	3181ddd4-96e2-4972-81de-2cd306bd4c28	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-08 03:16:45.283073+05
2471fd05-4911-4231-9ca8-2dc61e5839e8	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 16:04:40.92781+05
7a55fd3d-bd4a-4c9a-96f5-5dd4c5067187	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 16:04:40.928362+05
1642c566-3691-4f0a-8b7e-68c70c665de1	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 19:08:06.440767+05
52e25be3-ae1d-4c51-80da-781ac29219b8	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 19:08:06.440142+05
b3fe6d63-d060-46e7-9ce5-8846ae258168	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 19:08:10.855119+05
5e155258-956d-49b2-8523-5c53f4361fc0	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 19:08:10.857285+05
6430a82b-989a-4ec2-b20a-4415fc3ac061	update	invoice	72379e88-a26b-41a9-9c96-29e34db41621	{"invoiceNumber": "INV001083"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 19:08:21.881496+05
61469c96-e0f6-4ca1-a8b4-4c029aff3120	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 19:08:22.130193+05
29171428-53c6-41ea-9172-674a5ddb16f8	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-09 19:08:22.180516+05
ba8b7bbd-4bba-4f07-9065-a807bfe9fecc	create	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	{"total": 1500, "invoiceNumber": "INV001086"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-10 16:15:15.402414+05
e4d70df8-44f2-4830-afb3-5e236168f8fb	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-10 16:15:15.966033+05
06ea52d3-c661-4368-a2de-50de843f9165	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-10 16:15:16.015159+05
a03f0e3b-92ed-4451-bc6d-f597a73a0d0a	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-10 16:15:28.812423+05
abc3a0e5-17c8-4f17-a9ab-0b16b27cc85a	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-10 16:15:28.812939+05
7149864d-c6cd-4b57-8f9b-965f02b10aa0	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:03:35.652642+05
70c6064b-9d27-4e6c-b1d4-c8d55f13deef	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:03:35.653426+05
7ea377de-b726-4756-b7a5-5591384e74d4	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:04:21.929621+05
7823be85-0436-4e52-9e5e-d6b6f5d05ed7	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:04:21.985578+05
d9cbc68a-b583-4952-bd90-c8603687126a	create	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	{"total": 1520.9, "invoiceNumber": "INV001087"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:09:45.843504+05
3db6530e-b55c-41d6-93ec-ffe2807abee7	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:09:46.230005+05
941e55be-789d-4c0a-9a97-8a585b61b5ba	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:09:46.277473+05
a88f5b8d-dbc4-4e13-a9cf-5b3bad1fc49b	create	receipt	3b185cf3-3254-4e17-aa6b-0b2d101b79a9	{"size": 32369, "filename": "Image 1.jpeg", "invoiceId": "1d3a6ab6-3dee-47d9-b4ae-5d518448fb53"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:12:20.842145+05
fc1d46fa-b7bf-4ea3-af1b-354f02163f3e	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:12:20.953115+05
06f38734-524c-4983-9b75-0f6afb226fa2	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:12:47.780559+05
e4862659-e816-4876-98c8-09bff8becc9a	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:12:47.974689+05
0f2a98c8-db82-4449-9320-98d6c6daa4de	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:13:39.304904+05
e50ffede-3036-4ec7-9139-22e1104f8700	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:13:39.321614+05
e218e603-add4-4f34-b06e-b3efb75e61b4	update	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	{"invoiceNumber": "INV001087"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:13:44.584492+05
1e2ad4d3-ce1a-44d0-a561-9f48e67cbb67	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:13:44.825801+05
3beba2ff-0c85-4b17-8396-274ae3a1b0ca	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 01:13:44.82482+05
69dbcb86-c34f-4f1d-b887-51957718d4a1	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:35:36.711194+05
8a3cab01-df44-4a75-bc3b-88e3d0365b17	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:35:36.710347+05
13177cfc-e469-40da-ae32-4f4d09620a59	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:36:23.252263+05
29bcec8a-75ab-4d5f-b1ef-59c327996fce	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:36:23.252947+05
a81bec86-4b79-447f-b2fd-b5656c88b299	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:36:56.70482+05
861ca282-0da2-43a9-a515-eabb213755de	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:36:56.707974+05
aed7e8dd-b73c-472d-9770-35ac47c9ac14	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:37:04.621315+05
d1a1ba6a-e91c-4312-ad29-0d1fabc397a2	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:37:04.622328+05
eab179b0-2e97-44c6-8fa6-21a334b8d89a	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:47:09.372695+05
89e91fbc-ffa4-4257-9b72-58f4349126a3	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 19:47:09.37426+05
269e8b0a-d583-4206-8103-847b0d07719b	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:07:22.625832+05
6c8a5ce3-cc51-4c02-a900-e82c9bda0d55	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:07:22.625111+05
7f2027da-27f5-4543-b613-a8a17fe61332	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:07:37.9308+05
68de432c-0e1d-42a1-bb2d-4a6268af9732	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:07:37.925873+05
759cf3e0-c867-4806-aa7d-8d31901413bf	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:07:54.652067+05
8d5f3ea8-34a1-4e67-836a-1ac75dc68794	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:07:54.653178+05
946a601d-8181-4fe1-a188-4802b3f73663	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:08:05.255672+05
8ce08b25-6f48-492b-9c3b-25105b553436	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:08:05.254566+05
c18540b0-b7ca-4398-9ccf-e05dcd7315ac	create	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	{"total": 1520.02, "invoiceNumber": "INV001088"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:11:56.94393+05
5effe329-7efa-4d9a-874b-87898aabd4d4	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:11:57.27208+05
b3d7a78e-5e0b-4bf5-9464-3273b5ac7e15	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:11:57.323477+05
5afe0762-c4f7-424a-95db-7e3be44f341f	create	receipt	9a6b1c4d-df93-461f-a95c-5b7241f69746	{"size": 32332, "filename": "Image 2.jpeg", "invoiceId": "06b9be76-a502-47d5-8d2b-1322687a1c46"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:12:54.724934+05
e5bd3d94-af6d-4583-b55b-aa8ba8a17e9e	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:12:54.786951+05
9e252eb8-76e5-4ca3-a65d-01fca76c5e4c	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:13:19.215886+05
b95cdad0-e4da-49b8-be9b-6e01ec7325f3	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-02-26 20:13:19.282486+05
5e718a13-eee6-48c6-8246-571fafee5be2	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:15.457264+05
9ebbeadd-8acf-41ab-a6b3-d84d6d7f68ca	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:15.457262+05
2f7fa3ce-8000-4ec5-b484-ee600e773ae5	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:18.266473+05
dc1e24db-b614-4a55-b360-fd9c55f62ca3	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:18.278359+05
2cc7b479-8b75-4db0-843d-f81117defb47	update	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	{"invoiceNumber": "INV001084"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:24.982268+05
e6ffe908-bf5f-43fe-8208-8075dcbc794c	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:26.459757+05
fb5884c1-ddc2-4c67-8871-692b62f2de22	view	invoice	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:26.928578+05
b30b9eef-ba54-4307-80ee-db0fce4f5ed1	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:43.31615+05
64e10a6b-081e-410d-84d9-892512520e42	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:17:43.330733+05
2180ddfe-1f25-45dd-95b8-07125623c73d	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:18:02.879857+05
232e34e3-d0c1-4f37-af8b-1f74c9a8d86b	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:18:10.477783+05
57c6e1a2-1b78-4a3d-93af-ed91a509307c	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:18:02.883478+05
5cf93500-9836-4a7f-aa3a-b0297ced340d	view	invoice	72379e88-a26b-41a9-9c96-29e34db41621	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:18:10.478542+05
e942f892-a04f-4ee2-b48e-c34173c11039	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:20:02.332325+05
b05b0f2a-4502-40d3-be56-6bf934434be2	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:20:02.331478+05
c5e1fed4-d463-466d-aee5-6a6cdec05061	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:20:13.072505+05
6170f6dc-e95a-416d-ab92-9fdf2d8bb9b2	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 20:20:13.112095+05
b195fcd7-6c91-4228-a3ff-afe2f8bd8ec2	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 21:10:29.681457+05
16943a82-9151-4f6f-b551-2e880cf95620	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 21:10:29.680543+05
2c909b9d-ee4d-41a8-bfa3-c14037256068	create	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	{"total": 2000, "invoiceNumber": "INV001089"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 22:49:13.288066+05
777bf93f-9505-44d1-aaa3-c05664c962bc	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 22:49:13.729822+05
e0e1a62c-6bd6-48dd-9f43-8e0093fe5807	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 22:49:13.730504+05
58c68885-c2f5-4d5a-a778-88feb67d9043	create	receipt	25dc0529-c990-4b26-8fba-f128151e9af9	{"size": 55237, "filename": "Julianna P Project Tracker - February Projects.pdf", "invoiceId": "453973a5-cb38-4dcf-9e4f-f37e9ddce551"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 22:49:52.431294+05
a86458ec-367a-413c-ad22-b6f5e8744c4b	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 22:49:52.542557+05
800f8a3f-09d7-46d2-a166-128fce44494c	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-02 22:59:17.278013+05
dccf58a1-d9f2-4d22-802c-3f244ac2de49	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:02:11.711989+05
7826b77b-2653-494e-86bb-a16fded9dd45	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:02:11.711938+05
1499a5aa-265c-43ab-8c1b-b60ede64b23e	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:02:15.079773+05
d4b401b9-af5b-4bc1-854b-8e11d97ba40f	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:02:15.125509+05
3cfb4375-d5fc-4040-92e0-b3b8f762553d	update	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	{"invoiceNumber": "INV001089"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:02:41.490907+05
467696e7-dc3f-46b5-ba71-28ac16e4bcd5	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:02:42.190321+05
b4a5bf09-0efe-4f8b-b281-85779a365191	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:02:42.433465+05
33325898-a9d0-4f1d-831a-6b108bbcffea	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:05:26.038364+05
c86cbdbc-9c5d-4739-bd10-92d3df0b4faa	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:13:10.616005+05
e33279ac-af96-4765-8f8e-96fb30f18ad2	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:14:10.037264+05
ec51d28e-7a50-480f-b111-72786225d429	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:18:36.488021+05
e2d80b89-047c-4279-88f0-5f339c546a5d	view	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:18:36.504665+05
8e7d5c87-ab19-40c2-bc30-f0671c7e75ee	delete	invoice	453973a5-cb38-4dcf-9e4f-f37e9ddce551	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:18:40.17155+05
1ecfbf73-92f8-45f2-980c-0a8936e92860	create	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	{"total": 2000, "invoiceNumber": "INV001089"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:20:45.261522+05
5dfd9f53-6702-4ec7-9f2f-5c3ee094db3d	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:20:46.106131+05
83067fad-b78b-4f3c-a64c-90dd264b2508	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:20:46.219525+05
529e0ec2-a15a-4cf6-a25a-ab65745cccc1	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:20:50.806647+05
3e9f0544-e87f-42d9-9cc3-6fed6c5c17e5	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:20:50.807849+05
ccdb6236-ab92-43df-9739-34085541c38f	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:20:56.157112+05
3ef8a62e-49e6-4bc0-91e2-982af7a7c87a	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:20:56.160473+05
e348426f-d110-44de-818d-16737db70f03	create	receipt	2ac757cd-4fd8-4f42-bf5d-86856619072c	{"size": 55237, "filename": "0882268c-ea67-411b-9a23-e10366054cbd.pdf", "invoiceId": "5fcde7ff-2222-4555-aaa9-3259db2b56a3"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:21:35.108026+05
642fabc4-5b88-4ae2-a472-eae3365f17a9	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:21:35.427522+05
31e7f1d2-8e9b-44cf-bf95-8556de5c3f6d	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:24:58.129916+05
c536302f-adb6-41b3-a4ba-7c697be81f24	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:24:58.128837+05
2180499d-5555-48f2-9e14-21aafef6b096	update	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	{"invoiceNumber": "INV001089"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:25:33.282039+05
1802b812-de44-42a5-adc1-68937ab1165f	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:25:33.471843+05
ff6d64c7-84d1-46c9-b70f-539ff8cc4be7	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 01:25:33.50404+05
d66e6a8a-4342-479d-add1-56c906f3507b	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 02:07:23.908285+05
44e82ea6-cd7a-4659-bc5d-325f31eea226	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 02:07:23.909035+05
74ccf905-8ed3-4ee0-9472-6042fe8de587	update	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	{"invoiceNumber": "INV001089"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 02:07:50.638716+05
b050e58c-3126-4a3f-b81e-5b807cc96e78	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 02:07:50.896541+05
7cafd973-e373-431f-9dd6-c882f517490e	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 02:07:50.951956+05
8b80a59f-8ccc-48c6-9f30-8ae62befb25f	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 02:17:03.584465+05
515a90fa-82e1-46b2-9f1b-6b1206d965c3	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 02:19:00.933234+05
6d2a8861-cdb2-46ae-a9ab-e2a5c2e7cb97	create	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	{"total": 1556.1000000000001, "invoiceNumber": "INV001090"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:49:08.475171+05
4047d67b-95c6-41bf-b127-e3f239ee1149	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:49:08.789224+05
a3acbf1c-7d76-4912-87bc-2d728a46a423	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:49:08.81889+05
b1eede0f-703a-426d-b3b5-c0ca1a58f72b	create	receipt	60bc5d16-d22b-42bd-9bdd-8d8015667d5f	{"size": 127963, "filename": "339eeb1ebcef4c7083ce02c61c65f078.png", "invoiceId": "a7c110a5-637a-49af-9ae0-e269484daf4f"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:49:59.462149+05
c91c5803-a7c1-497c-aa1a-d8c47ad02ecf	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:49:59.574631+05
da89a745-c096-4a23-b00c-a21cc81c2935	create	receipt	f89b52ce-f14c-4483-8b69-f66a5189ce6b	{"size": 217464, "filename": "edc2ad4e5d494651bc1a6c98de9026ca.png", "invoiceId": "a7c110a5-637a-49af-9ae0-e269484daf4f"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:50:23.284897+05
368bf6cb-e877-423d-80cb-c842c80342d1	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:50:23.337046+05
3627458b-3e07-41e6-a447-9b283cef170c	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:50:47.679097+05
4f0f5c30-523e-415b-aad9-78e6decc1654	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:50:47.719179+05
880b88a8-c199-4a88-b5ea-426cd8229ed5	update	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	{"invoiceNumber": "INV001090"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:50:57.3137+05
90a26f52-81e0-4cc7-a1c6-10643d4aa492	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:50:57.574744+05
27b12ad8-93be-4bd7-ab47-df1d5242a700	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:50:57.594575+05
fe1d5281-8a6c-489f-9550-41d7129800e2	create	invoice	df9740a3-a833-4871-94e3-07a3974620f2	{"total": 1520.9, "invoiceNumber": "INV001091"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:56:10.403992+05
d06672ee-3ae4-4203-bb82-ee896f9cf19a	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:56:10.685477+05
05f307f9-6d5d-4c32-8e48-1d8497f9456f	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:56:10.69504+05
0fd4ff13-d2b2-494d-95c5-8369531be020	create	receipt	cdea8405-86fd-40d3-8815-a52af40b9d2d	{"size": 780788, "filename": "b19088b98c884852878e4da125915c35.jpg", "invoiceId": "df9740a3-a833-4871-94e3-07a3974620f2"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:56:26.748459+05
b8c4ebda-6443-4f6f-9826-f7671ed55670	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-03 21:56:26.838933+05
0822b706-4622-42f2-8e90-6a94172415ee	create	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"total": 1500, "invoiceNumber": "INV001092"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:24:47.52181+05
b9648012-4ff7-4e72-ab89-8007bd292e75	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:24:47.881154+05
fe9616d4-c24a-4890-a203-05a9c89ffef4	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:24:47.881919+05
be2e6db0-7d4b-4169-b158-0424d2d905fb	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:24:51.993254+05
afe0458c-8842-4313-96f9-432f0e248693	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:24:51.99408+05
1ce6994b-8994-4948-afe7-8d0c7acb2464	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:26:53.090631+05
d075ad96-6bd8-4169-ac28-74f6d253c8db	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:26:53.0927+05
4420b5f5-904a-468c-8700-bb8d4a758551	update	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"invoiceNumber": "INV001092"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:27:06.808091+05
1b52b871-c93d-4f45-96ea-3193727ebf6f	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:27:06.937227+05
29113aba-6bc7-4f9b-a87b-57e90962a646	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-08 04:27:06.944772+05
c9b010bb-64b3-4b49-b378-e785282ca901	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:13:24.169244+05
f708dff3-ad10-4986-a7c6-a7ee403804a2	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:13:24.169244+05
fe344a26-1a22-4d03-83e4-166d950ff76b	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:17:21.279257+05
817c7c21-637f-4704-9afd-7a0d97e081ad	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:17:21.280064+05
0e9cfb12-a492-4cbf-bdc3-a937aa87de13	update	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"invoiceNumber": "INV001092"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:18:57.730782+05
14eb2454-2626-437e-b03e-3c7d5a2d1cf7	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:18:57.989332+05
484469cb-6a76-4f06-84ba-5a20af98dde6	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:18:58.000675+05
697722ca-3e20-479b-820c-c400bab40190	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:22:51.498482+05
80716c41-5382-4563-a2b4-d59a5d2612aa	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:22:51.499236+05
43a96358-a15f-447f-9c91-212bb321c996	update	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"invoiceNumber": "INV001092"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:22:57.954133+05
a8f917ac-41a2-4a1f-b48d-42b3d877c37b	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:22:58.126262+05
e5e0f4b2-595a-42f3-9061-e6f5170e8c4c	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-09 22:22:58.129833+05
93a40d63-8990-4add-8490-619d8f378302	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-11 03:36:16.36906+05
d096cf5e-6efe-46cc-8e5e-edc36b73c654	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:07:33.501787+05
9e333b13-3b8e-4beb-9b25-5b8fe1bde6c7	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:07:33.502383+05
0a56f7c7-925a-4cc9-83e8-fe279afa2611	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:07:41.212733+05
4708290f-d7d4-4058-9cdb-4247badbe5d8	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:07:41.213828+05
23d8013c-116e-48db-86a1-741b4eca0440	update	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	{"invoiceNumber": "INV001089"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:07:46.166762+05
ce1dfcde-a02e-460c-a328-91ea6ab19ef6	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:07:46.309492+05
bb58aa40-e870-43ec-90ee-a68b452cbd38	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:07:46.313636+05
7cbe45d1-8061-48ce-951d-ad2d3368d4f6	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:08:45.54852+05
b018ed46-8f6d-4123-a7cf-e757572020fa	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 20:08:45.54852+05
c8f5755a-8118-4934-b2f8-135fd199be2f	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:35:18.054131+05
875deda2-534e-4a50-896c-20d7fd22d481	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:35:18.049009+05
e2b36e0a-384f-4425-a1c9-a5c28e61a395	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:35:20.129728+05
ad94e0e8-c8c8-4c2b-973e-37756650f25b	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:35:20.131833+05
d7f42dda-6ff1-447b-a672-5fa9160bed2e	update	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"invoiceNumber": "INV001092"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:36:12.035113+05
2420dece-2177-46d8-928b-eace272c4273	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:36:12.175642+05
b7642199-3979-464e-bfdc-1bf8f0f3b309	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:36:12.220746+05
e4b6396b-88c9-4a30-9a9d-596ba10474a6	create	receipt	3ad2a236-d76f-4c97-ac11-5d6162b2ea8a	{"size": 30161, "filename": "WhatsApp Image 2026-03-16 at 21.42.48.jpeg", "invoiceId": "fbc93fc2-e6f9-4903-b562-683797b25286"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:36:59.300306+05
ef15d95f-a424-488b-bcb1-ec7cfb9f6cea	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:36:59.35109+05
eba276ba-195a-4500-8db1-97bb2f53b51c	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:37:09.896788+05
c1a99e91-33c7-4c6e-85b0-c7f274080303	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:37:09.945268+05
5f82741b-f118-4da0-983a-e3d288fbb9b9	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:39:43.742667+05
c4e9eac4-9902-4690-a31b-86edf0a012d5	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:39:43.743404+05
2381502e-98fc-4abb-8384-5a141357a1ce	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:39:45.935494+05
c63a5b76-7ce3-4f68-b796-5664c8c64880	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:39:45.941141+05
51206cef-6572-40a1-b37e-ac580210b551	update	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	{"invoiceNumber": "INV001087"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:39:50.134513+05
31dd42e2-c1d4-43f1-98e2-d05f6db51cb1	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:39:50.382064+05
3252f41c-22ec-4f40-96d8-491ba84cf609	view	invoice	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 21:39:50.383882+05
f9ac423b-37cf-4237-a1fd-7db5b5b575c2	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:04:13.519692+05
302901d2-2539-4e1e-8960-0b2b5851df7d	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:04:13.520561+05
d36baa4d-95b6-4926-9bcf-ed36b41af4d1	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:04:15.482249+05
097c41ba-6db6-4064-8084-6cba9691b513	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:04:15.482853+05
488eec73-43fa-407e-8eea-c75b198f2876	update	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"invoiceNumber": "INV001092"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:05:22.230542+05
2cdebf27-f37d-4942-8fef-217f0aa6a231	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:05:22.381585+05
b9a0b895-4c1e-4498-b51a-355798ce9d6d	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:05:22.396001+05
5dea771d-cab6-47f3-86d7-a29fb7c020e7	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:10:10.915012+05
7b01e7e6-0360-4d42-b8eb-9114293f32a9	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:10:10.916018+05
427ca3c3-0366-416c-834b-313a07e8f0ac	update	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"invoiceNumber": "INV001092"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:10:15.265163+05
b69f27cc-e116-4c2e-b1f1-771a4d1e6308	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:10:15.457874+05
341b4541-7d09-4432-81d3-dcf18423ee50	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:10:15.458581+05
1c2e67b2-4b46-4db2-9d3f-872f55182625	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:18:50.774116+05
ce2450ef-4e7e-41ce-bc99-d2ab2fb57f28	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-16 22:18:50.774682+05
fa92e755-4a9a-4d68-9531-b469aa7339f2	create	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	{"total": 2000, "invoiceNumber": "INV001093"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-23 20:50:11.634211+05
da6fb579-81a7-4d80-9079-8bed5c3f0256	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-23 20:50:12.032445+05
78e389eb-a7da-4c6c-a253-f5c634ddfd4b	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-23 20:50:12.0342+05
ddcc4fc6-6b2b-49e3-a019-3e2eb18c174f	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-23 20:51:37.480958+05
8cc978c5-d844-432e-93ed-d00ffbb1235f	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-23 20:51:37.484101+05
09bc053c-eebc-4914-a24c-be65f6fc4be8	update	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	{"invoiceNumber": "INV001093"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-23 20:53:53.830343+05
861800e2-53a3-4d36-aa4e-009abbfa29fb	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-23 20:53:54.07319+05
60207588-500d-4aa0-baa2-f5898025e448	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-23 20:53:54.136136+05
2627e0d5-3f00-4ddf-a386-909f4bfdc58b	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-24 22:23:16.631313+05
ed8ed5db-c322-4c9a-a10a-5e5af116f849	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-24 22:23:16.630553+05
2b437d34-71ff-4986-8edf-44fab81cb3d5	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:22.403804+05
4795054f-fbdb-4096-b2f0-cfb411e4a2c7	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:22.404391+05
7f8ee9b8-b00b-42ec-a7d0-ecbc36f3961f	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:25.011912+05
6a5fcf63-8792-497f-97d7-797c06253a3a	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:25.01283+05
3f147f39-bc11-4601-9f89-a5492877aeca	update	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	{"invoiceNumber": "INV001088"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:30.495227+05
b51544a9-9d09-4e11-8791-1ebd58a63390	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:30.687569+05
c71e2b80-b926-4248-b437-a4fdec7ff867	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:30.691582+05
dc03e9b0-c3d4-4dc7-828a-dae624c15a67	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:53.493061+05
2c3a5b4d-d02e-4a77-92bb-1fc3df49d6b0	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:53.493871+05
788e38d5-a160-4e2c-a497-250d4be73791	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:56.598592+05
c62fdf6c-9d22-40f8-a18d-95e05af14ccf	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:56.595887+05
5989bfe6-b152-4032-9a47-34dc93ff9020	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:59.460852+05
2d274040-556f-446d-ba7d-bc49e087aca6	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:08:59.461492+05
67e89248-701d-45ab-b1a0-66a29942081e	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:09:24.062671+05
e82aab50-4903-4f97-a645-d8b0d0865518	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 00:09:24.063219+05
f36d2eda-54da-474c-84b1-0b9604a7ff46	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:04.098972+05
cc254387-dbd6-4533-bc45-8773e6ccc5c5	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:04.099724+05
17cb413e-29ad-4ff2-86d0-c23bbaf03f7e	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:08.516675+05
cc0df46a-503a-4ff3-926d-26933c7a5198	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:08.520815+05
7badc978-ed38-4b31-b26f-e6f692dfe036	update	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	{"invoiceNumber": "INV001090"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:13.527067+05
5db72e79-30bc-4206-8850-360057a66c36	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:13.790221+05
a1943be4-377c-4d71-9079-848f8746cbc2	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:19.755513+05
759773de-811b-47a3-86a4-e307d993bcdc	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:22.397699+05
96f141c0-1e27-4f53-96ca-1f146199ebd4	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:25.983539+05
cfa5a872-8ec2-4bb5-9c05-5237fcc27479	view	invoice	a7c110a5-637a-49af-9ae0-e269484daf4f	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:13.792972+05
38ccd082-5668-462c-a443-605da918c43f	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:19.754775+05
6bd0ad0c-291e-49d9-93fa-7393d5cf497d	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:22.398675+05
2a1469fb-b187-4bf2-8919-335f7ff5b397	update	invoice	df9740a3-a833-4871-94e3-07a3974620f2	{"invoiceNumber": "INV001091"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:25.815908+05
41940c28-8149-468d-b50f-eeefee2e7785	view	invoice	df9740a3-a833-4871-94e3-07a3974620f2	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:07:25.978283+05
301fe00b-3062-4aac-81de-7d4c864953db	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:08:09.496552+05
31a579ec-592b-4819-8239-24eeeb7dbd2f	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:08:09.497372+05
c71b95dc-6248-4447-9969-e9ab11943c82	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:08:11.277676+05
55988a65-c995-4b42-8ace-b1cca212af3d	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:08:11.2813+05
3363e438-9205-477e-97df-ac0c81d73c37	update	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	{"invoiceNumber": "INV001088"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:08:13.906048+05
ea786d6f-bbc8-4b43-a166-82c25503a555	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:08:14.04523+05
e4023a3a-c02c-45d0-8091-584419711436	view	invoice	06b9be76-a502-47d5-8d2b-1322687a1c46	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 01:08:14.045837+05
a4475288-7323-4a5a-97e9-64674df1d032	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 02:04:12.442422+05
c16bb06f-9a40-4b44-a277-53d4f74deb72	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-03-26 02:04:12.443587+05
00d5e135-2b7b-43ae-b1c6-5d3f05f6d788	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:44:30.036479+05
ad44d279-3c89-48c6-a480-df75f1bd9fcb	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:44:30.037096+05
a56811bd-e17c-423c-a61a-d5e28a07a866	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:44:33.084815+05
82af9c20-25ba-4b0c-ba56-f51b202f1150	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:44:33.084233+05
47aba015-b235-4d44-b461-092d4caae33c	update	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"invoiceNumber": "INV001092"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:44:51.219763+05
bd449c59-1e69-49db-ab72-97d57ed4d094	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:44:51.422432+05
07a464d8-36e0-47a9-9060-8aa8d0dd0878	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:44:51.42321+05
413961f8-ec28-4385-8381-8f013d5f1a6e	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:47:12.933443+05
b22627dc-1f06-49ef-9900-f5adefc70ba5	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:47:12.938851+05
b09ffe3b-038c-4f59-9d65-88a1b22ce385	update	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	{"invoiceNumber": "INV001092"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:47:23.078666+05
a69b36e4-8eb1-4398-883b-79389facd0fb	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:47:23.227453+05
8c9360e4-082e-43c7-b95b-eb18204e1b8d	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 22:47:23.228171+05
13d9b47b-1d1d-4684-8e3b-48c916408e57	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:16:00.598943+05
f00095e7-76ff-4ff3-81b8-03391843c431	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:16:00.59963+05
ba078044-955b-46c8-bd9d-650e4dff90aa	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:16:04.712732+05
497c07eb-c845-4137-a790-2a853d1ebbce	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:16:04.713479+05
ee87684c-4fa2-4128-a066-86bbf6dcf7f3	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:16:07.995068+05
002197b9-df1a-454d-8d03-6152b16ee3c4	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:16:07.99572+05
9461005a-934f-472c-bf4d-8178a75390be	view	invoice	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:10.611752+05
365d1cac-48b5-4002-8dfd-5821d3c91427	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:19.120344+05
38c7fee2-6787-4647-8b1d-e48648ec342d	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:19.131671+05
74f2a5e8-e95e-4f35-beb4-260d43f68adf	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:24.025648+05
79006194-b590-4e26-bafd-0858402745fc	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:24.030466+05
90962a78-2469-4f68-aa95-640dca26528f	update	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	{"invoiceNumber": "INV001086"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:27.465696+05
bc66589a-8dbf-417c-aa2e-b4ff9eff39b7	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:27.638123+05
756bd7f5-f857-41cb-8a9b-84844bc816d2	view	invoice	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:27.639063+05
48b947af-6f15-4658-9fb3-925ceeb288c5	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:32.685648+05
e8cb35b9-ad97-4d4e-8854-15a723f50547	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:32.686272+05
8d607fdd-6fc7-44a4-a4aa-c4b9a7073cb9	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:33.869945+05
71e2b976-2e56-4ee5-9620-b10803321a3f	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:33.870622+05
92f86ff7-4526-489f-9d5d-f5d281710ea6	update	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	{"invoiceNumber": "INV001085"}	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:37.629709+05
eddc39e0-025d-47e1-87cf-b9be9471cc03	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:37.770536+05
dd95e47c-055d-4216-b594-ce157e00982e	view	invoice	99102b7d-0114-449b-a55d-0d54ee58dd90	\N	::ffff:127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-01 23:20:37.771171+05
4b9b75ff-dfe2-46f5-8863-a5eb87955e59	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:13:33.150667+05
6f408bec-4b79-430c-b3d7-92c45630d337	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:13:33.151374+05
f0882539-a4f6-4341-8d91-b3c9e1b0947b	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:13:39.20272+05
8afd071e-ae3d-440f-b252-50b7f80cd3f4	view	invoice	5fcde7ff-2222-4555-aaa9-3259db2b56a3	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:13:39.203299+05
333eb043-dbca-4ad9-beb0-ecce2b693e65	create	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	{"total": 962.5, "invoiceNumber": "INV001094"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:16:13.044544+05
b69192d8-b1a9-477a-8286-e25a59ad1aa4	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:16:13.298611+05
69aa804c-b192-414d-8e82-cae4adb1239f	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:16:13.312571+05
a89b807e-2b72-4401-8705-6448be0399c6	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:16:17.44906+05
8a42e7bc-b83e-46db-94ad-dc3ea080463d	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:16:17.450932+05
5b3faffa-a509-469c-922f-c756b0592b81	update	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	{"invoiceNumber": "INV001094"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:19:20.77857+05
eb7a3e65-3d2c-4f44-bd76-9b92d2bdbcc6	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:19:20.933842+05
72abc738-61a0-4b35-be01-c9da58265a0d	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:19:20.946799+05
28140bd0-177b-406f-ba02-a3f7a7d4a556	create	invoice	f8745777-3bfb-40ea-8c56-d54c8ff0faea	{"total": 1500, "invoiceNumber": "INV001095"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:35:36.012438+05
4b6a502d-02a5-4a51-b8ec-6cd5a13d99cc	view	invoice	f8745777-3bfb-40ea-8c56-d54c8ff0faea	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:35:36.414029+05
a4135654-fae2-4532-8083-faccd9c76545	view	invoice	f8745777-3bfb-40ea-8c56-d54c8ff0faea	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-02 23:35:36.414694+05
b44ab64f-5779-4d85-8f57-ec90655c4315	view	invoice	f8745777-3bfb-40ea-8c56-d54c8ff0faea	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-07 00:57:20.374182+05
5fc3ce62-084b-4c66-a051-da75f0f6cb58	view	invoice	f8745777-3bfb-40ea-8c56-d54c8ff0faea	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-07 00:57:20.373626+05
978bcad7-1485-4fd6-911c-26d5991c15c4	view	invoice	f8745777-3bfb-40ea-8c56-d54c8ff0faea	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:00:12.210346+05
b42662b9-c10f-42cf-888f-37e7ba48b74a	view	invoice	f8745777-3bfb-40ea-8c56-d54c8ff0faea	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:00:12.286075+05
57f8c75b-bb60-45de-9f39-3ebf6ccd790f	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:01:36.463574+05
a7cfc519-c020-4a28-8c10-17f5d9167543	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:01:36.487948+05
3a339c6a-e1e4-4cca-851c-2c85b76450f1	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:01:39.794363+05
5806c4d0-eeb2-4c1c-b700-695f8c89290f	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:01:39.811857+05
ac97efc2-100d-4c10-9439-44ad6029280c	update	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	{"invoiceNumber": "INV001094"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:01:44.178217+05
ef0beea1-0487-4160-9804-3ac8d0d59272	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:01:44.240028+05
ff93d5c9-a355-4824-83d4-2e08712f5823	view	invoice	89d7f088-757c-4f14-ac2e-4bedc675cddd	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 21:01:44.264941+05
1c946505-716e-4a06-980e-a7cd3fd7581c	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 23:22:30.560903+05
6d69e75a-9ccf-4357-a571-1fcf9bc8a102	view	invoice	fbc93fc2-e6f9-4903-b562-683797b25286	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 23:22:30.597667+05
4fd70c3f-cf30-476e-9486-4d13dbc8dd94	create	invoice	7540f34a-efe8-413a-aa48-00e98cf4bce4	{"total": 1500, "invoiceNumber": "INV001096"}	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 23:26:21.623366+05
b13304d3-789b-4feb-9dca-dbb761bf81c0	view	invoice	7540f34a-efe8-413a-aa48-00e98cf4bce4	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 23:26:21.730823+05
043ccefb-3b7b-42f1-bec0-f1cc52bd297c	view	invoice	7540f34a-efe8-413a-aa48-00e98cf4bce4	\N	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	1c2242c0-c801-448c-9bb2-e295d7c218b5	2026-04-13 23:26:21.752043+05
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.customers (id, user_id, name, email, business_name, address, phone, notes, invoice_count, total_billed, created_at, updated_at) FROM stdin;
73c2bf44-57f0-4116-969a-1a96f2004756	1c2242c0-c801-448c-9bb2-e295d7c218b5	John Scott Hundley	accounting@helijetusa.com	Hundley Farms, LLC	P.O. Box H, Loxahatchee, Florida 33470, USA	\N	\N	1	1500.00	2026-01-28 17:57:38.619957	2026-01-28 18:06:20.951826
a75d879e-26f1-47a5-ae5b-9bdde612b7f0	1c2242c0-c801-448c-9bb2-e295d7c218b5	Jon Ortlieb	accounting@helijetusa.com	ROMUXBE CONSULTING LLC	455 NE 5th Ave, Suite 328, Delray Beach 33483	\N	\N	3	7541.83	2026-01-15 23:26:19.27236	2026-01-28 18:06:34.920499
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.invoice_items (id, description, quantity, unit_price, total, invoice_id, title, service_type, travel_subtype) FROM stdin;
c878d61a-fc55-45a7-baf3-15a206d5774b	Pilot: Jordan Hardison\nTrip Dates: Jan 27, 2026\nItinerary:\nLNA - F45\nF45 - TLH\nTLH - F45\nF45 - LNA\nLead Passenger: John Scott Hundley	1.00	1500.00	1500.00	72379e88-a26b-41a9-9c96-29e34db41621	CJ - PIC - Day Rate	standard	\N
bbe86a18-2009-4576-b64e-f288d4a446f1	Big Kahuna Cheese Steak\nCookie	1.00	40.43	40.43	72379e88-a26b-41a9-9c96-29e34db41621	Meals	standard	\N
d15124b6-0c1b-4966-9546-e8c2af42f413	Studio Recording Services on 20th Feb, 2026	1.00	199.00	199.00	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	Studio Recording Services	standard	\N
3400e627-2a6f-4829-b58f-734ad310003a	Brand\tProject Name\tActual Hours\nCIR\tIVF Clinic Checklist Redesign\t4:00:00\nCIR\t1-Circle Surrogacy_half page Ad\t0:30:00\nCIR\tCIR Freelance Battlecard 2026\t2:00:00\nCIR\tUnderstanding Surrogacy Costs\t4:30:00\nCIR\tCircle Surrogacys Mentorship Program\t3:35:00\nEE\tEverie Website\t2:40:00\nCIR\tUpdating 'Termination FAQs' document\t2:35:00\nGG\tGG: Influencer Guide\t6:15:00\nCIR\t30 Years content update\t3:30:00\nGG\tSurrogacy by State - Overview Mockup\t4:30:00\nGG\tSurrogacy by State - FL Mockup\t5:55:00	40.00	50.00	2000.00	5fcde7ff-2222-4555-aaa9-3259db2b56a3	February Billing	standard	\N
e37bf07c-2ba6-4ebd-afc1-26680acdf5e0	Pilot: Jordan Hardison\nTrip Dates: Feb 24, 2026\nItinerary:\nLNA - FD38\nFD38 - OCF\nOCF - LNA\nLead Passenger: Kent Farrington	1.00	1500.00	1500.00	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	CJ - PIC - Day Rate	standard	\N
ffd5597a-7df4-4a5b-a709-fb73d29d4b2b	Chick - Fil - A	1.00	20.90	20.90	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	Meals	standard	\N
060bf80b-b9c0-4669-867d-48cd7ad7a936	Project Description: Custom Website & E-Commerce Platform (Public site, B2C, B2B, Inventory, Admin, Integrations)	1.00	2000.00	2000.00	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	Custom Website & E-Commerce Platform Build (Project Kickoff)	standard	\N
52c7c4ad-9762-4d01-9096-43a8482a0c4e	TikTok Shop Setup + Website Integration (includes 3 launch posts)	1.00	1000.00	1000.00	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	TikTok Shop	standard	\N
75a2f847-8f5a-437b-99d3-1ea30fe98870	Project Description: Custom Website & E-Commerce Platform (Public site, B2C, B2B, Inventory, Admin, Integrations)	1.00	2000.00	2000.00	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	Custom Website & E-Commerce Platform Build (Project Completion)	standard	\N
b12b8264-2ee8-461b-91eb-9f27f22f51dd	Pilot: Jordan Hardison\nTrip Dates: 23 October, 2025\nItinerary: KLNA - F45 - KRDU - F45 - KLNA\nLead Passenger: Michael Wall	1.00	1500.00	1500.00	a7c110a5-637a-49af-9ae0-e269484daf4f	CJ - PIC - Day Rate	standard	\N
f4632002-f76b-4e61-9198-c17758288c79	Chick Fil A	1.00	14.20	14.20	a7c110a5-637a-49af-9ae0-e269484daf4f	Meals	standard	\N
5fb47484-193b-4f3f-bdae-43dc09aaa6f0		1.00	41.90	41.90	a7c110a5-637a-49af-9ae0-e269484daf4f	Uber	standard	\N
4a92a726-7fc8-4383-9a5f-d50befab83b2	Pilot: Jordan Hardison\nTrip Dates: 7 October, 2025\nItinerary:  KLNA - KVDI - KLNA\nLead Passenger: Jason Jarriel	1.00	1500.00	1500.00	df9740a3-a833-4871-94e3-07a3974620f2	CJ - PIC - Day Rate	standard	\N
3b09cd5e-9227-4192-b509-2fb0ab572123		1.00	20.90	20.90	df9740a3-a833-4871-94e3-07a3974620f2	Meals	standard	\N
4b6ee689-6795-4400-85b8-cb6bcf4b6c56	Pilot: Jordan Hardison\nTrip Dates: Jan 16, 2026\nItinerary:\nJAX - KOCF\nKOCF - FD38\nFD38 - F45\nLead Passenger: Laura Kraut	0.50	1500.00	750.00	254dd0cb-04de-4072-9d68-0d967be1ac15	CJ - PIC - Day Rate	standard	\N
6b81bebd-87ef-4fba-99eb-09596c3ac451	Pilot: Jordan Hardison\nTrip Dates: Dec 18, 2025 - Dec 19, 2025\nItinerary:\nLNA - BCT\nBCT - ORL\nORL - BCT\nLead Passenger: Jon Ortlieb	2.00	1500.00	3000.00	7f5b34be-afa3-4112-a16f-5a2b7eda9352	CJ - PIC - Day Rate	standard	\N
7b65bd6e-01f6-41f0-8f97-c4ff72980176	Springhill Suites - $147.38\nHertz Car Rental - $103.22\nUber - $33.54	1.00	284.14	284.14	7f5b34be-afa3-4112-a16f-5a2b7eda9352	Travel	standard	\N
936de8b1-cde5-4936-9e77-67ca938b2a5f	Outback - $92.59\nWawa - $10.75	1.00	103.34	103.34	7f5b34be-afa3-4112-a16f-5a2b7eda9352	Meals	standard	\N
7d668be5-9926-4b78-86c1-c7345491b385	Pilot: Jordan Hardison\nTrip Dates: Jan 18, 2026 - January 19,2026\nItinerary:\nF45 - BCT\nBCT - JAX\nJAX - BCT\nBCT - F45\nLead Passenger: Jon Ortlieb	2.00	1500.00	3000.00	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	CJ - PIC - Day Rate	standard	\N
d1abde22-1ab9-4997-ac0b-0baf982f7150	Hertz Car Rental - $133.34\nCourtyard Jacksonville Airport Northeast - $160.04	1.00	293.38	293.38	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	Travel	standard	\N
9211e9e6-b8f7-496c-89c5-050921bbc9f2	BJS Restaurant Brewhouse - $45.66\nFujiyama Japanese Steak - $44.57	1.00	90.23	90.23	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	Meals	standard	\N
46333f71-99c0-4226-aedb-f2ceb70777e0	Pilot: Jordan Hardison\nTrip Dates: February 12, 2026\nItinerary:\nLNA - BGE\nBGE - LNA\nLNA - F45\nLead Passenger: John Scott Hundley	1.00	1500.00	1500.00	06b9be76-a502-47d5-8d2b-1322687a1c46	CJ - PIC - Day Rate	standard	\N
2377cbc7-dee3-48fd-8674-ed42c8a35f54	Bainbridge GA FSU04421	1.00	20.02	20.02	06b9be76-a502-47d5-8d2b-1322687a1c46	Meals	standard	\N
c705610f-adfa-4d21-ac31-b7ad1ec5e6a6	Pilot: Jordan Hardison\nTrip Dates: 6-7 March, 2026\nItinerary:\nKLNA - KHVN\nKHVN - KILM\nKILM - F45\nLead Passenger: Dave Peterson	2.00	1500.00	3000.00	fbc93fc2-e6f9-4903-b562-683797b25286	CJ - PIC - Day Rate	standard	\N
1f8b2503-f239-4d5a-8f1c-6ca2fce99493	Chick-Fil-A	1.00	20.80	20.80	fbc93fc2-e6f9-4903-b562-683797b25286	Meal	standard	\N
69a5fcbf-d5c7-4c5f-9987-5eeb55b09a14	Pilot: Jordan Hardison\nTrip Dates: Feb 09, 2025\nItinerary:\nLNA - VRB\nVRB - BNA\nBNA - LNA\nLead Passenger: Ava Steinfurth	1.00	1500.00	1500.00	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	CJ - PIC - Day Rate	standard	\N
aed37998-1525-4321-80cd-7274000604e7	Pilot: Jordan Hardison\nTrip Dates: Feb 4, 2025\nItinerary:\nLNA - BNA\nBNA - VRB\nVRB - LNA\nLead Passenger: Ava Steinfurth	1.00	1500.00	1500.00	99102b7d-0114-449b-a55d-0d54ee58dd90	CJ - PIC - Day Rate	standard	\N
1db9073f-6efb-4843-a004-85bd3ae47ff9	Chick-Fill-A - $20.80	1.00	20.80	20.80	99102b7d-0114-449b-a55d-0d54ee58dd90	Meal	standard	\N
e974b860-cbf1-4c1c-b169-85e0d0064be8	Pilot: Jordan Hardison\nTrip Dates: Jan 16, 2026\nItinerary:\nLNA - BCT\nBCT - JAX\nLead Passenger: Yarah Ortlieb	0.50	1500.00	750.00	3181ddd4-96e2-4972-81de-2cd306bd4c28	CJ - PIC - Day Rate	standard	\N
6e48df04-6d2f-4034-8694-620a92d24227	Chick - Fil - A	1.00	20.74	20.74	3181ddd4-96e2-4972-81de-2cd306bd4c28	Meals	standard	\N
d73de70b-0915-457a-8907-022589f912bc	Pilot: Jordan Hardison\nTrip Dates: 12 March, 2026\nItinerary:\nLNA - FD38\nFD38 - LNA\nLead Passenger: Jim Ward	1.00	1500.00	1500.00	f8745777-3bfb-40ea-8c56-d54c8ff0faea	CJ - PIC - Day Rate	trip	\N
6a0c94d9-4c09-4552-89b2-d24fe226b952	Brand\tProject Name\tActual Hours\nGG\tPress Page Mockup\t4:00:00\nGG\tInfluencer Guide Edits\t0:45:00\nCIR\tAdditional Ad Sizes (RFSA)\t4:30:00\nCIR\tUpdate Compsenation\t1:00:00\nGG\tSurrogacy by State - Overview Mockup\t3:50:00\nGG\tSurrogacy by State - FL Mockup\t4:10:00\nCIR\tAdditional Ad Sizes (RFSA) Pt 2\t1:00:00	19.25	50.00	962.50	89d7f088-757c-4f14-ac2e-4bedc675cddd	March Billing	standard	\N
09b41ca9-ca4e-4457-928f-1d4201cc2a13	Pilot: Jordan Hardison\nTrip Dates: April 03, 2026\nItinerary:\nLNA-TLH\nTLH-VDF\nVDF-TLH\nTLH-BKV\nLead Passenger: Ben Albritton	1.00	1500.00	1500.00	7540f34a-efe8-413a-aa48-00e98cf4bce4	CJ - PIC - Day Rate	trip	\N
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.invoices (id, invoice_number, user_id, client_name, client_email, client_business_name, client_address, description, subtotal, tax, total, status, email_sent_at, email_sent_to, paid_at, payment_method, stripe_checkout_session_id, stripe_payment_intent_id, payment_token, due_date, created_at, updated_at, payment_instructions, amount_paid, view_count, last_viewed_at, view_token, customer_id) FROM stdin;
254dd0cb-04de-4072-9d68-0d967be1ac15	INV001081	1c2242c0-c801-448c-9bb2-e295d7c218b5	Kent Farrington	acounting@helijetusa.com	HeliJet USA	\N	\N	750.00	0.00	750.00	paid	\N	\N	2026-01-31 04:27:49.749661+05	\N	\N	\N	\N	2026-01-16 05:00:00+05	2026-01-21 23:49:11.140838+05	2026-01-31 04:27:49.749661+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	0.00	0	\N	\N	\N
7f5b34be-afa3-4112-a16f-5a2b7eda9352	INV001075	1c2242c0-c801-448c-9bb2-e295d7c218b5	Jon Ortlieb	accounting@helijetusa.com	ROMUXBE CONSULTING LLC	455 NE 5th Avenue, Suite No. 328, Delray Beach 33483, USA	Issued On: jan 13, 2026	3387.48	0.00	3387.48	paid	\N	\N	2026-02-02 20:32:30.93235+05	\N	\N	\N	\N	2026-01-04 05:00:00+05	2026-01-13 23:20:55.4784+05	2026-02-02 20:32:30.93235+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 Sunset Blvd. Fort Pierce, FL. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	0.00	0	\N	\N	a75d879e-26f1-47a5-ae5b-9bdde612b7f0
3181ddd4-96e2-4972-81de-2cd306bd4c28	INV001080	1c2242c0-c801-448c-9bb2-e295d7c218b5	Jon Ortlieb	accounting@helijetusa.com	ROMUXBE CONSULTING LLC	455 NE 5th Ave, Suite 328, Delray Beach 33483, USA	\N	770.74	0.00	770.74	paid	\N	\N	2026-02-08 03:16:45.030655+05	\N	\N	\N	\N	2026-01-16 05:00:00+05	2026-01-21 23:24:59.002001+05	2026-02-08 03:16:45.030655+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	0.00	0	\N	\N	a75d879e-26f1-47a5-ae5b-9bdde612b7f0
72379e88-a26b-41a9-9c96-29e34db41621	INV001083	1c2242c0-c801-448c-9bb2-e295d7c218b5	John Scott Hundley	accounting@helijetusa.com	Hundley Farms, Inc	P.O. Box H, Loxahatchee, Florida 33470, USA	\N	1540.43	0.00	1540.43	paid	\N	\N	2026-02-02 20:33:00.215809+05	\N	\N	\N	\N	2026-01-27 05:00:00+05	2026-01-28 17:33:19.833482+05	2026-03-02 20:20:13.585583+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	1540.43	0	\N	\N	73c2bf44-57f0-4116-969a-1a96f2004756
c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	INV001082	1c2242c0-c801-448c-9bb2-e295d7c218b5	Jon Ortlieb	accounting@helijetusa.com	ROMUXBE CONSULTING LLC	455 NE 5th Ave, Suite 328, Delray Beach 33483	\N	3383.61	0.00	3383.61	paid	\N	\N	2026-02-02 20:32:45.871202+05	\N	\N	\N	\N	2026-01-19 05:00:00+05	2026-01-22 00:04:22.223285+05	2026-02-02 20:32:45.871202+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	0.00	0	\N	\N	a75d879e-26f1-47a5-ae5b-9bdde612b7f0
d8d58067-ee16-4e4d-b4e9-6f914c14ea56	INV001084	1c2242c0-c801-448c-9bb2-e295d7c218b5	Natalie Leone	taliee09@gmail.com	\N	\N	\N	199.00	0.00	199.00	paid	\N	\N	2026-03-02 20:17:24.960871+05	\N	\N	\N	\N	2026-02-03 05:00:00+05	2026-02-03 00:37:58.737918+05	2026-03-02 20:17:24.960871+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: Sosocial\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4363	0.00	0	\N	\N	\N
1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	INV001087	1c2242c0-c801-448c-9bb2-e295d7c218b5	Kent Farrington	accounting@helijetusa.com	HeliJet Solutions	\N	\N	1520.90	0.00	1520.90	paid	\N	\N	2026-03-16 21:39:50.105015+05	\N	\N	\N	\N	2026-02-24 05:00:00+05	2026-02-26 01:09:45.794949+05	2026-03-16 21:39:50.105015+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	1520.90	0	\N	\N	\N
06b9be76-a502-47d5-8d2b-1322687a1c46	INV001088	1c2242c0-c801-448c-9bb2-e295d7c218b5	John Scott Hundley	accounting@helijetusa.com	Hundley Farms, Inc	P.O. Box H, Loxahatchee, Florida 33470, USA	\N	1520.02	0.00	1520.02	sent	\N	\N	\N	\N	\N	\N	\N	2026-02-12 05:00:00+05	2026-02-26 20:11:56.922739+05	2026-03-26 01:08:13.882738+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	0.00	0	\N	\N	\N
5fcde7ff-2222-4555-aaa9-3259db2b56a3	INV001089	1c2242c0-c801-448c-9bb2-e295d7c218b5	North Star Fertility	mlugria@nsfertility.com	\N	\N	\N	2000.00	0.00	2000.00	paid	\N	\N	2026-03-16 20:07:46.157264+05	\N	\N	\N	\N	2026-03-03 05:00:00+05	2026-03-03 01:20:45.180814+05	2026-03-16 20:07:46.157264+05	Sosocial.media\nPhone: +1 (772) 834-6484\nEmail: juliannampereira03@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: Sosocial\nBank Name: Bluevine Bank\nACH/Routing: 125109019\nAccount #: 875106924363	2000.00	0	\N	\N	\N
a7c110a5-637a-49af-9ae0-e269484daf4f	INV001090	1c2242c0-c801-448c-9bb2-e295d7c218b5	Michale Wall	mw@leanonthewall.com	Wall Wealth	\N	\N	1556.10	0.00	1556.10	paid	\N	\N	2026-03-26 01:07:13.518239+05	\N	\N	\N	\N	2025-10-27 05:00:00+05	2026-03-03 21:49:08.383401+05	2026-03-26 01:07:13.518239+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	1556.10	0	\N	\N	\N
39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	INV001086	1c2242c0-c801-448c-9bb2-e295d7c218b5	AV1	accounting@helijetusa.com	AV1	\N	\N	1500.00	0.00	1500.00	paid	\N	\N	2026-04-01 23:20:27.438233+05	\N	\N	\N	\N	2026-02-09 05:00:00+05	2026-02-10 16:15:15.328745+05	2026-04-01 23:20:27.438233+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	1500.00	0	\N	\N	\N
df9740a3-a833-4871-94e3-07a3974620f2	INV001091	1c2242c0-c801-448c-9bb2-e295d7c218b5	Jasson Jarriel	accounting@helijetusa.com	Commodity Transportation Services, LLC	1213 Merchat Way, Suite 103, Statesboro, Georgia 30458, USA	\N	1520.90	0.00	1520.90	paid	\N	\N	2026-03-26 01:07:25.80316+05	\N	\N	\N	\N	2025-10-16 05:00:00+05	2026-03-03 21:56:10.380081+05	2026-03-26 01:07:25.80316+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	1520.90	0	\N	\N	\N
fbc93fc2-e6f9-4903-b562-683797b25286	INV001092	1c2242c0-c801-448c-9bb2-e295d7c218b5	Dave Peterson	accounting@helijetusa.com	Reel Marketing LLC.	10 Fairway Drive, Suite 217, Deerfield Beach, Florida, 33441, United States of America	\N	3020.80	0.00	3020.80	due	\N	\N	\N	\N	\N	\N	\N	2026-03-07 05:00:00+05	2026-03-08 04:24:47.497213+05	2026-04-01 22:47:23.064515+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	0.00	0	\N	\N	\N
b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	INV001093	1c2242c0-c801-448c-9bb2-e295d7c218b5	Patrick Rayburn	patrick@vetrimaxanimalhealth.com	VetriMax	\N	\N	5000.00	0.00	5000.00	due	\N	\N	\N	\N	\N	\N	\N	2026-03-23 05:00:00+05	2026-03-23 20:50:11.573063+05	2026-04-01 23:20:10.373836+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	2000.00	0	\N	\N	\N
99102b7d-0114-449b-a55d-0d54ee58dd90	INV001085	1c2242c0-c801-448c-9bb2-e295d7c218b5	AV1	accounting@helijetusa.com	AV1	\N	\N	1520.80	0.00	1520.80	paid	\N	\N	2026-04-01 23:20:37.620245+05	\N	\N	\N	\N	2026-02-06 05:00:00+05	2026-02-06 19:34:26.451733+05	2026-04-01 23:20:37.620245+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	1520.80	0	\N	\N	\N
f8745777-3bfb-40ea-8c56-d54c8ff0faea	INV001095	1c2242c0-c801-448c-9bb2-e295d7c218b5	MT Citation	accounting@helijet.com	\N	\N	\N	1500.00	0.00	1500.00	due	\N	\N	\N	\N	\N	\N	\N	2026-03-12 05:00:00+05	2026-04-02 23:35:35.999099+05	2026-04-02 23:35:35.999099+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	0.00	0	\N	\N	\N
89d7f088-757c-4f14-ac2e-4bedc675cddd	INV001094	1c2242c0-c801-448c-9bb2-e295d7c218b5	North Star Fertility	mlugria@nsfertility.com	\N	\N	\N	962.50	0.00	962.50	paid	\N	\N	2026-04-13 21:01:44.171996+05	\N	\N	\N	\N	2026-04-04 05:00:00+05	2026-04-02 23:16:13.00033+05	2026-04-13 21:01:44.171996+05	Sosocial.media\nPhone: +1 (772) 834-6484\nEmail: juliannampereira03@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: Sosocial\nBank Name: Bluevine Bank\nACH/Routing: 125109019\nAccount #: 875106924363	962.50	0	\N	\N	\N
7540f34a-efe8-413a-aa48-00e98cf4bce4	INV001096	1c2242c0-c801-448c-9bb2-e295d7c218b5	Dave Petterson	accounting@helijetusa.com	\N	10 Fairway Drive, Suite 217, Deerfield Beach, Florida, 33441, United States of America	\N	1500.00	0.00	1500.00	due	\N	\N	\N	\N	\N	\N	\N	2026-04-13 05:00:00+05	2026-04-13 23:26:21.615669+05	2026-04-13 23:26:21.615669+05	Jordan Hardison / Sosocial.media\nPhone: 772-323-5828\nEmail: jordanahardison@gmail.com\nMailing Address: 5809 sunset blvd. Fort Pierce, Fl. 34982\n\nBank Info:\nCompany Name: AIO.Church\nBank Name: Coastal Community Bank\nACH/Routing: 125109019\nAccount #: 8751-0692-4355	0.00	0	\N	\N	\N
\.


--
-- Data for Name: item_templates; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.item_templates (id, user_id, type, content, usage_count, created_at, updated_at) FROM stdin;
67660c80-456f-4e22-8c5e-e7d0e31b68af	1c2242c0-c801-448c-9bb2-e295d7c218b5	title	CJ - PIC - Day Rate	2	2026-01-09 01:26:36.018351+05	2026-01-09 01:26:36.018351+05
5e0f7a14-51aa-4346-8bde-9fef6e9cff2e	1c2242c0-c801-448c-9bb2-e295d7c218b5	title	Travel	5	2026-01-10 21:03:24.418686+05	2026-01-10 21:03:24.418686+05
0db5e4f5-3e69-42f4-8b37-92f7ba930a36	1c2242c0-c801-448c-9bb2-e295d7c218b5	title	Meals	5	2026-01-10 21:03:24.418686+05	2026-01-10 21:03:24.418686+05
25bf5434-f7ea-4b1e-aa0d-d42143125c17	1c2242c0-c801-448c-9bb2-e295d7c218b5	description	Pilot:\nTrip Dates:\nItinerary:\nLead Passenger:	10	2026-01-10 21:03:24.418686+05	2026-01-10 21:03:24.418686+05
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.payments (id, invoice_id, amount, payment_method, reference, notes, paid_at, created_at) FROM stdin;
cc3eae27-b29f-4bd4-8288-7cf748796d19	b2ca4c8e-5916-4ae7-88bc-7ba5b36e5c9d	2000.00	bank_transfer	\N	Payment Made for Milestone 1	2026-04-01 05:00:00+05	2026-04-01 23:20:10.373836+05
\.


--
-- Data for Name: rate_limits; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.rate_limits (id, key, count, window_start) FROM stdin;
1da6aea1-d3c5-4862-9fca-c9ffaba55bf3	invoices:create:459e5046-db6a-45ab-8922-6a39e92e14fc	2	2026-01-08 20:32:44.573+05
64f8e015-0c45-4cd3-986e-4dece3b45cff	service-template:create:1c2242c0-c801-448c-9bb2-e295d7c218b5	1	2026-01-15 21:07:27.051+05
08da934a-995d-4ad7-baa0-42ca7102e349	invoice:delete:1c2242c0-c801-448c-9bb2-e295d7c218b5	1	2026-03-03 01:18:39.704+05
0edb863a-da30-42d2-9de4-566ce9c364f5	item-template:create:1c2242c0-c801-448c-9bb2-e295d7c218b5	1	2026-01-09 01:26:35.941+05
0bc93f15-c90a-4628-af7a-f01ce5e16d18	receipt:delete:1c2242c0-c801-448c-9bb2-e295d7c218b5	1	2026-01-08 22:39:47.406+05
4e1d5fa9-533d-40bb-92b3-d664c7debcec	receipt:upload:1c2242c0-c801-448c-9bb2-e295d7c218b5	1	2026-03-16 21:36:59.269+05
0c2cf87a-e8c2-46b5-a69b-37c45a7d5111	invoice:get:04384543-32b3-43b0-ab98-8be08c0c080b	14	2026-04-13 20:58:42.781+05
0e6fd471-a706-4297-893f-2c4833754a2f	invoice:update:1c2242c0-c801-448c-9bb2-e295d7c218b5	1	2026-04-13 21:01:44.118+05
56e4fdfe-cdf7-4fe4-9ac3-1bc0cc672636	invoices:create:1c2242c0-c801-448c-9bb2-e295d7c218b5	1	2026-04-13 23:26:21.554+05
a2647310-9055-4635-a504-5669196ad058	invoice:get:1c2242c0-c801-448c-9bb2-e295d7c218b5	2	2026-04-13 23:26:21.723+05
\.


--
-- Data for Name: receipts; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.receipts (id, filename, filepath, mime_type, size, invoice_id, created_at, attachment_type) FROM stdin;
da4ea6ce-c43c-4a84-a177-e85c2f3ad3d0	5cb0674e273e4639b702faf68ab550d0.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/7f5b34be-afa3-4112-a16f-5a2b7eda9352/7cdb2c4d-0289-4e1a-a406-4406b57f9f2d.jpeg	image/jpeg	36598	7f5b34be-afa3-4112-a16f-5a2b7eda9352	2026-01-13 23:22:35.149+05	receipt
4a435eb1-e443-454a-b008-ffd486643ffa	0b743bb1947d4387be21f20ad76726d7.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/7f5b34be-afa3-4112-a16f-5a2b7eda9352/c40efeaf-b79f-4eb4-b013-40b4f528f984.jpeg	image/jpeg	31460	7f5b34be-afa3-4112-a16f-5a2b7eda9352	2026-01-13 23:22:59.367+05	receipt
f39cba8f-c2b1-4755-a38b-4e95867164c4	96a3f5a90993408b8a9552745c7f62a2.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/7f5b34be-afa3-4112-a16f-5a2b7eda9352/1c177a32-32aa-4621-ae2e-681170a4747c.jpeg	image/jpeg	31082	7f5b34be-afa3-4112-a16f-5a2b7eda9352	2026-01-13 23:23:34.282+05	receipt
4bccecb4-d1f6-4f99-86c7-56f9326d1d27	26959c3413fe46d2a4b0af7df482d870.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/7f5b34be-afa3-4112-a16f-5a2b7eda9352/14c701e5-2a9e-4120-9129-2102cf276fc4.jpeg	image/jpeg	34022	7f5b34be-afa3-4112-a16f-5a2b7eda9352	2026-01-13 23:23:58.375+05	receipt
7b650aa9-c349-4d96-8ac8-6aafd612809c	01a1dc3a141646a9a86abcb1cec2eb42.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/7f5b34be-afa3-4112-a16f-5a2b7eda9352/e0be2d7a-9aea-4adf-80c5-23a0019888b8.jpeg	image/jpeg	32697	7f5b34be-afa3-4112-a16f-5a2b7eda9352	2026-01-13 23:24:29.832+05	receipt
405e2a8a-22da-47cf-b548-87acc317bdd5	5d15131156f4419e9665ba140069c358.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/3181ddd4-96e2-4972-81de-2cd306bd4c28/371082c3-11ab-49ff-9213-b8db95274270.jpeg	image/jpeg	32255	3181ddd4-96e2-4972-81de-2cd306bd4c28	2026-01-21 23:27:00.817+05	receipt
ae21d82f-32d0-4596-872e-7497e19da2bf	WhatsApp Image 2026-01-21 at 22.16.31.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/c96d8142-4e0d-4f4b-93f7-01612b4ebcd8/2433b704-06f4-46b0-ad7e-55beea1da818.jpeg	image/jpeg	35014	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	2026-01-22 00:06:44.749+05	receipt
94670181-0469-486e-860f-99f1f24133b6	WhatsApp Image 2026-01-21 at 22.16.32.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/c96d8142-4e0d-4f4b-93f7-01612b4ebcd8/f48731f9-b16d-4e0d-9fd3-d3b7e4ccd033.jpeg	image/jpeg	33937	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	2026-01-22 00:06:51.909+05	receipt
7b7f4f23-f31e-49a4-9739-801340df9cf8	WhatsApp Image 2026-01-21 at 22.16.35.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/c96d8142-4e0d-4f4b-93f7-01612b4ebcd8/82e72906-e011-4ed9-a377-255a52dba2d6.jpeg	image/jpeg	32642	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	2026-01-22 00:06:57.333+05	receipt
111ff159-5a21-4934-8fa5-3b8fe1297f03	WhatsApp Image 2026-01-21 at 22.16.38.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/c96d8142-4e0d-4f4b-93f7-01612b4ebcd8/b8553bd7-c2d2-498e-80e3-9f6874335699.jpeg	image/jpeg	36712	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	2026-01-22 00:07:02.979+05	receipt
016c8971-3b29-45a5-ac84-cb4e90510575	Meal receipt.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/99102b7d-0114-449b-a55d-0d54ee58dd90/af5a56f9-d9b2-4509-9cf3-77824c8ad03a.jpeg	image/jpeg	30141	99102b7d-0114-449b-a55d-0d54ee58dd90	2026-02-07 22:56:01.762+05	receipt
ab100d44-86dd-42a8-9244-a423459b13fd	Hundley Meal.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/72379e88-a26b-41a9-9c96-29e34db41621/b55d1843-56b0-4019-a9cd-86e4bb02fbaf.jpeg	image/jpeg	27047	72379e88-a26b-41a9-9c96-29e34db41621	2026-02-07 23:03:15.185+05	receipt
3b185cf3-3254-4e17-aa6b-0b2d101b79a9	Image 1.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/1d3a6ab6-3dee-47d9-b4ae-5d518448fb53/682e4fa6-c7cc-4d94-a2f5-7061f13f5c16.jpeg	image/jpeg	32369	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	2026-02-26 01:12:20.829+05	receipt
9a6b1c4d-df93-461f-a95c-5b7241f69746	Image 2.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/06b9be76-a502-47d5-8d2b-1322687a1c46/f25d5b5b-638c-42c0-903f-13dd5da118f2.jpeg	image/jpeg	32332	06b9be76-a502-47d5-8d2b-1322687a1c46	2026-02-26 20:12:54.699+05	receipt
2ac757cd-4fd8-4f42-bf5d-86856619072c	0882268c-ea67-411b-9a23-e10366054cbd.pdf	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/5fcde7ff-2222-4555-aaa9-3259db2b56a3/01117b47-c3ce-4dff-a2e8-ad99a1d0507f.pdf	application/pdf	55237	5fcde7ff-2222-4555-aaa9-3259db2b56a3	2026-03-03 01:21:35.078+05	other
60bc5d16-d22b-42bd-9bdd-8d8015667d5f	339eeb1ebcef4c7083ce02c61c65f078.png	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/a7c110a5-637a-49af-9ae0-e269484daf4f/f90af4db-f809-4013-a504-4890d6b67ece.png	image/png	127963	a7c110a5-637a-49af-9ae0-e269484daf4f	2026-03-03 21:49:59.4+05	receipt
f89b52ce-f14c-4483-8b69-f66a5189ce6b	edc2ad4e5d494651bc1a6c98de9026ca.png	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/a7c110a5-637a-49af-9ae0-e269484daf4f/496c0fe3-cc4d-4432-a823-a09ae33c9f64.png	image/png	217464	a7c110a5-637a-49af-9ae0-e269484daf4f	2026-03-03 21:50:23.281+05	receipt
cdea8405-86fd-40d3-8815-a52af40b9d2d	b19088b98c884852878e4da125915c35.jpg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/df9740a3-a833-4871-94e3-07a3974620f2/5e150e16-9c82-4696-929d-64f7d2f9a47c.jpg	image/jpeg	780788	df9740a3-a833-4871-94e3-07a3974620f2	2026-03-03 21:56:26.743+05	receipt
3ad2a236-d76f-4c97-ac11-5d6162b2ea8a	WhatsApp Image 2026-03-16 at 21.42.48.jpeg	/api/receipts/1c2242c0-c801-448c-9bb2-e295d7c218b5/fbc93fc2-e6f9-4903-b562-683797b25286/9254297b-efd1-4429-bdc4-a49014c6279a.jpeg	image/jpeg	30161	fbc93fc2-e6f9-4903-b562-683797b25286	2026-03-16 21:36:59.295+05	receipt
\.


--
-- Data for Name: service_templates; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.service_templates (id, user_id, name, description, service_type, default_price, travel_subtype, usage_count, created_at, updated_at) FROM stdin;
0b950cc0-9489-42ca-a74c-e6d3a3afb92e	1c2242c0-c801-448c-9bb2-e295d7c218b5	CJ - PIC - DAY RATE	Test Description	trip	1500.00	\N	5	2026-01-15 21:07:27.058752	2026-01-28 18:19:05.323239
\.


--
-- Data for Name: status_history; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.status_history (id, invoice_id, status, changed_at, notes, created_at) FROM stdin;
1c4a6bf9-b59b-4c50-b4f5-a163cdc8a126	7f5b34be-afa3-4112-a16f-5a2b7eda9352	sent	2026-01-25 01:39:57.264+05	\N	2026-01-25 01:39:57.265008+05
f3d21649-a96b-4d95-a56a-ceba4e384d0c	3181ddd4-96e2-4972-81de-2cd306bd4c28	sent	2026-01-25 01:40:19.088+05	\N	2026-01-25 01:40:19.089112+05
d8d409d2-c4d9-4ac4-a453-9f454789b5e5	254dd0cb-04de-4072-9d68-0d967be1ac15	sent	2026-01-25 01:40:37.983+05	\N	2026-01-25 01:40:37.983886+05
f52fc34e-b699-4a5f-b0c6-6309dad31f77	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	sent	2026-01-25 01:40:54.841+05	\N	2026-01-25 01:40:54.841998+05
fb181722-f70e-4bf8-b840-c33df8f9d435	254dd0cb-04de-4072-9d68-0d967be1ac15	paid	2026-01-31 04:25:00.969+05	\N	2026-01-31 04:25:00.970069+05
dfe97b66-9e7e-44b2-b041-9cb0801ea206	7f5b34be-afa3-4112-a16f-5a2b7eda9352	paid	2026-02-02 20:32:30.928+05	\N	2026-02-02 20:32:30.928635+05
f40be60b-5af3-4ee9-800a-da3eff95e3d7	c96d8142-4e0d-4f4b-93f7-01612b4ebcd8	paid	2026-02-02 20:32:45.867+05	\N	2026-02-02 20:32:45.867873+05
2e092336-fc02-4106-bc66-f7c342794a2b	72379e88-a26b-41a9-9c96-29e34db41621	paid	2026-02-02 20:33:00.213+05	\N	2026-02-02 20:33:00.213722+05
c830c3b5-7b0f-4780-b777-c6c9bace0879	72379e88-a26b-41a9-9c96-29e34db41621	due	2026-02-07 23:09:44.96+05	\N	2026-02-07 23:09:44.960621+05
beade963-b0b1-4eef-bade-9794adde5efa	3181ddd4-96e2-4972-81de-2cd306bd4c28	paid	2026-02-08 03:16:45.023+05	\N	2026-02-08 03:16:45.023838+05
05ce5e2a-0e96-45fb-8f5d-60a9b1059270	d8d58067-ee16-4e4d-b4e9-6f914c14ea56	paid	2026-03-02 20:17:24.936+05	\N	2026-03-02 20:17:24.936896+05
2d4d740a-a5cc-470e-a177-05d7eb911e49	5fcde7ff-2222-4555-aaa9-3259db2b56a3	paid	2026-03-16 20:07:46.153+05	\N	2026-03-16 20:07:46.153702+05
44e62ce1-4333-46e1-a050-9028199a428e	1d3a6ab6-3dee-47d9-b4ae-5d518448fb53	paid	2026-03-16 21:39:50.099+05	\N	2026-03-16 21:39:50.100605+05
5c683020-9b2b-44a6-9d93-b91945f9b67f	06b9be76-a502-47d5-8d2b-1322687a1c46	sent	2026-03-26 00:08:30.463+05	\N	2026-03-26 00:08:30.463285+05
b914d3ce-5287-46de-affa-1bddcc7e8b57	a7c110a5-637a-49af-9ae0-e269484daf4f	paid	2026-03-26 01:07:13.516+05	\N	2026-03-26 01:07:13.516706+05
e9a0c764-6ca2-4d51-bf62-7436ef073f96	df9740a3-a833-4871-94e3-07a3974620f2	paid	2026-03-26 01:07:25.796+05	\N	2026-03-26 01:07:25.796516+05
4369dc73-e910-4f84-abcb-a29bc41eaabb	39dfb43a-e6aa-4a5b-87a4-7d30a7b59597	paid	2026-04-01 23:20:27.435+05	\N	2026-04-01 23:20:27.435739+05
ca4af6b5-3606-491d-a5c2-bb0eb2bc4747	99102b7d-0114-449b-a55d-0d54ee58dd90	paid	2026-04-01 23:20:37.618+05	\N	2026-04-01 23:20:37.618986+05
1ccbf0e2-90fe-41b5-890e-06de2fdfd94c	89d7f088-757c-4f14-ac2e-4bedc675cddd	paid	2026-04-13 21:01:44.167+05	\N	2026-04-13 21:01:44.167486+05
\.


--
-- Data for Name: trip_legs; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.trip_legs (id, invoice_item_id, leg_order, from_airport, to_airport, trip_date, trip_date_end, passengers, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: mac
--

COPY public.users (id, email, password, name, business_name, business_email, business_phone, business_address, tax_id, currency, invoice_prefix, default_due_days, bank_name, account_name, account_number, routing_number, iban, paypal_email, payment_notes, created_at, updated_at) FROM stdin;
1c2242c0-c801-448c-9bb2-e295d7c218b5	test@example.com	$2b$10$V8tGCsJWLp1eVKS7e8fOgOxFH4gDTaEwYadASazAfcAn.ox.6ra66	Test User	\N	\N	\N	\N	\N	USD	INV	30	\N	\N	\N	\N	\N	\N	\N	2026-01-08 20:36:31.666192+05	2026-04-13 20:57:04.872426+05
\.


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_payment_token_key; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_payment_token_key UNIQUE (payment_token);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: item_templates item_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.item_templates
    ADD CONSTRAINT item_templates_pkey PRIMARY KEY (id);


--
-- Name: item_templates item_templates_user_id_type_content_key; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.item_templates
    ADD CONSTRAINT item_templates_user_id_type_content_key UNIQUE (user_id, type, content);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: rate_limits rate_limits_key_key; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.rate_limits
    ADD CONSTRAINT rate_limits_key_key UNIQUE (key);


--
-- Name: rate_limits rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.rate_limits
    ADD CONSTRAINT rate_limits_pkey PRIMARY KEY (id);


--
-- Name: receipts receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: service_templates service_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.service_templates
    ADD CONSTRAINT service_templates_pkey PRIMARY KEY (id);


--
-- Name: status_history status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.status_history
    ADD CONSTRAINT status_history_pkey PRIMARY KEY (id);


--
-- Name: trip_legs trip_legs_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.trip_legs
    ADD CONSTRAINT trip_legs_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_logs_created_at; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_audit_logs_created_at ON public.audit_logs USING btree (created_at DESC);


--
-- Name: idx_audit_logs_user_id; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_audit_logs_user_id ON public.audit_logs USING btree (user_id);


--
-- Name: idx_customers_email; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_customers_email ON public.customers USING btree (email);


--
-- Name: idx_customers_name; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_customers_name ON public.customers USING btree (name);


--
-- Name: idx_customers_user; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_customers_user ON public.customers USING btree (user_id);


--
-- Name: idx_invoice_items_invoice_id; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_invoice_items_invoice_id ON public.invoice_items USING btree (invoice_id);


--
-- Name: idx_invoices_created_at; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_invoices_created_at ON public.invoices USING btree (created_at DESC);


--
-- Name: idx_invoices_customer; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_invoices_customer ON public.invoices USING btree (customer_id);


--
-- Name: idx_invoices_payment_token; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_invoices_payment_token ON public.invoices USING btree (payment_token);


--
-- Name: idx_invoices_status; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_invoices_status ON public.invoices USING btree (status);


--
-- Name: idx_invoices_user_id; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_invoices_user_id ON public.invoices USING btree (user_id);


--
-- Name: idx_item_templates_usage; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_item_templates_usage ON public.item_templates USING btree (user_id, type, usage_count DESC);


--
-- Name: idx_item_templates_user_type; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_item_templates_user_type ON public.item_templates USING btree (user_id, type);


--
-- Name: idx_payments_invoice_id; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_payments_invoice_id ON public.payments USING btree (invoice_id);


--
-- Name: idx_payments_paid_at; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_payments_paid_at ON public.payments USING btree (paid_at DESC);


--
-- Name: idx_rate_limits_key; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_rate_limits_key ON public.rate_limits USING btree (key);


--
-- Name: idx_receipts_invoice_id; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_receipts_invoice_id ON public.receipts USING btree (invoice_id);


--
-- Name: idx_service_templates_type; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_service_templates_type ON public.service_templates USING btree (service_type);


--
-- Name: idx_service_templates_usage; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_service_templates_usage ON public.service_templates USING btree (usage_count DESC);


--
-- Name: idx_service_templates_user; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_service_templates_user ON public.service_templates USING btree (user_id);


--
-- Name: idx_status_history_changed_at; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_status_history_changed_at ON public.status_history USING btree (changed_at);


--
-- Name: idx_status_history_invoice_id; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_status_history_invoice_id ON public.status_history USING btree (invoice_id);


--
-- Name: idx_trip_legs_item; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_trip_legs_item ON public.trip_legs USING btree (invoice_item_id);


--
-- Name: idx_trip_legs_order; Type: INDEX; Schema: public; Owner: mac
--

CREATE INDEX idx_trip_legs_order ON public.trip_legs USING btree (invoice_item_id, leg_order);


--
-- Name: customers update_customers_updated_at; Type: TRIGGER; Schema: public; Owner: mac
--

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: invoices update_invoices_updated_at; Type: TRIGGER; Schema: public; Owner: mac
--

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: service_templates update_service_templates_updated_at; Type: TRIGGER; Schema: public; Owner: mac
--

CREATE TRIGGER update_service_templates_updated_at BEFORE UPDATE ON public.service_templates FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: mac
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: customers customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: item_templates item_templates_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.item_templates
    ADD CONSTRAINT item_templates_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: receipts receipts_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: service_templates service_templates_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.service_templates
    ADD CONSTRAINT service_templates_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: status_history status_history_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.status_history
    ADD CONSTRAINT status_history_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: trip_legs trip_legs_invoice_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mac
--

ALTER TABLE ONLY public.trip_legs
    ADD CONSTRAINT trip_legs_invoice_item_id_fkey FOREIGN KEY (invoice_item_id) REFERENCES public.invoice_items(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict en6BcjY6wzUlFaKFbzD0GGXqik0fhINfupf5R19X5DrREgXi9h4RJbkMGxrlZeq

