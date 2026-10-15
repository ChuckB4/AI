# APIs Pack

Skills and standards for designing, documenting, and consuming APIs — primarily
HTTP/REST, with room for RPC and event-driven interfaces.

## Purpose

Encode durable API design practices so an agent produces interfaces that are
consistent, versioned, secure, and well-documented, and consumes external APIs
defensively.

## Scope

In scope:

- Resource modeling, URL and method conventions, status codes.
- Request/response schemas, validation, and error-response shape.
- Versioning, pagination, filtering, and idempotency.
- Authentication/authorization patterns at the API boundary (defer deep
  security to the `security` pack and cross-reference).
- Contract documentation (OpenAPI) and contract testing.
- Resilient consumption: timeouts, retries with backoff, rate-limit handling.

Out of scope:

- UI concerns (see `react`).
- Transport-specific infra provisioning (see release/infra concerns).

## Planned contents

| Item | Type | Status |
| --- | --- | --- |
| REST design conventions | skill | planned |
| Error model & validation | skill | planned |
| Versioning, pagination, idempotency | skill | planned |
| OpenAPI documentation & contract tests | skill | planned |
| Resilient API consumption | skill | planned |

No item is marked done until its file exists and is reviewed.

## Quality requirements

- A consistent, documented error model is mandatory.
- Security-sensitive guidance must cross-reference the `security` pack.
- Examples include a schema/contract artifact where relevant.
- Consumption examples must handle timeouts and failure explicitly.

## Completion criteria

- [ ] All planned skills exist as detailed `SKILL.md` files with examples.
- [ ] At least one documented contract (OpenAPI) example is included.
- [ ] This table matches the files on disk.
