# G3 — Frontend & Backend
- Typed routes; server logic in server functions; webhooks under a public API prefix with signature checks.
- Every table: explicit grants + row-level security + policies.
- Roles in a separate table, checked server-side.
- Triggers for timestamps/audit; indexes on foreign keys and filters.
- Input validation (schema) on every server entry point.
- Secrets in the platform vault; publishable keys only in the client.
