---
name: Vector observability pipeline initiative — driver
description: Why Sir Charles is evaluating self-hosted Vector — the goal is avoiding Datadog's sensitive-data-scanner license, not replacing all of DD
type: project
originSessionId: 196bb65a-160d-45ea-ac3e-7c8376a4bf8f
---
Sir Charles is standing up self-hosted Vector primarily to **avoid paying for Datadog's sensitive data scanner**. Initial framing was "extract rules from DD Observability Pipelines into Vector," but the real driver is cost avoidance on PII redaction specifically — not general DD UI replacement.

**Why:** Datadog charges separately for the sensitive data scanner feature, and the rules it produces are *exactly* the rules that are not freely exportable. Translating other DD pipeline config to Vector YAML doesn't help here.

**How to apply:**
- Drop the "translate DD pipeline JSON → Vector YAML" thread unless a *different* driver shows up later. There's nothing useful to translate for this goal.
- Architecture landed (2026-05-01): **otelcol does redaction at the edge, Vector aggregates downstream over OTLP.** otelcol is already deployed in Sir Charles's environment — use what's there.
  - otelcol `transform` processor with OTTL `replace_pattern()` is the workhorse for regex-based content scrubbing.
  - otelcol `redaction` processor for allowlist-of-keys semantics with hashing.
  - Vector ingests via native `opentelemetry` source/sink. No redaction in Vector for OTLP-sourced data — only for non-OTel ingest paths (syslog, file tail, Kafka).
- **Don't propose Microsoft Presidio.** Sir Charles wants to use the existing otelcol deployment, not introduce new sidecars. Accepting the no-NER tradeoff is a known and accepted limitation.
- Don't recommend Datadog OP Worker `customConfig` mode for this — it adds DD baggage with no benefit when the sensitive scanner is the thing being avoided.
- A single Git-hosted YAML rule library that emits both OTTL (for otelcol) and VRL (for Vector non-OTel paths) is the planned pattern, to keep the two dialects from drifting.
