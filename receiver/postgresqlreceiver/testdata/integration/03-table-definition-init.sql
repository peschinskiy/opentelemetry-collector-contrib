CREATE USER otelu WITH PASSWORD 'otelp';
GRANT pg_monitor TO otelu;
-- No grants on the tables below: their definitions must be readable from the catalog alone.

CREATE ROLE app_owner;
COMMENT ON DATABASE otel IS 'Integration fixture';

CREATE TABLE public.accounts (
    id serial PRIMARY KEY,
    email text,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX accounts_email_idx ON public.accounts (email) WHERE email IS NOT NULL;

CREATE SCHEMA sales AUTHORIZATION app_owner;
CREATE TABLE sales.orders (
    id bigint NOT NULL,
    account_id integer NOT NULL REFERENCES public.accounts (id),
    created_at date NOT NULL
) PARTITION BY RANGE (created_at);
CREATE TABLE sales.orders_2025 PARTITION OF sales.orders FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE sales.orders_2026 PARTITION OF sales.orders FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
ALTER TABLE sales.orders OWNER TO app_owner;

-- Views are not tables and must not be reported.
CREATE VIEW public.account_emails AS SELECT email FROM public.accounts;
