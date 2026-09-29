# Lightweight pre-launch security audit
Suggested before each launch with a single question; runs only if accepted. Never fixes without approval.
1. Secrets: none in code, history or client bundle.
2. Access: RLS enabled and policies scoped on every table.
3. Roles: checked server-side from a role table.
4. Inputs: schema validation on all server entry points.
5. Public endpoints: signature checks, rate limits.
6. Headers & dependencies: known vulnerable packages.
Output: max 10 findings, each with severity → verdict "Ready to publish" / "Fix before publishing".
