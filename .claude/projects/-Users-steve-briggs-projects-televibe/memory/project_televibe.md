---
name: televibe project
description: Greenfield Teleport access plugin built in Go that AI-risk-scores access requests and conditionally files ITSM Jira tickets
type: project
originSessionId: b94f12fe-9fb8-45ba-8dd5-65f49e81db87
---
televibe is a new Go-based Teleport access plugin (modeled on the official Jira access plugin) living at /Users/steve.briggs/projects/televibe. Initialized 2026-04-22.

**What it does:** watches Teleport access requests; sends request reason + roles to a configurable AI provider (Anthropic direct API, AWS Bedrock, or generic webhook — one at a time) for a risk assessment; combines AI scores with structural checks (CUSTX-### ticket regex in description, description length, off-hours timing) into a 0-100 score; maps to Gen-Z slang tiers (no cap / sus / mad sus fr / straight L, touch grass).

**Behavior:** below configurable `ticket_threshold` → auto-approve via `SubmitAccessReview`. At or above → create ticket in configurable Jira project (defaults to "ITSM") and hold the Teleport request in PENDING. A poller reconciles ITSM ticket status to Teleport approval/denial — an SRE transitioning the ITSM ticket to the approved or rejected status drives the Teleport decision.

**Why:** User wants to gate privileged access through AI review + SRE-controlled Jira workflow, with low-risk requests bypassing the Jira overhead entirely.

**How to apply:** When extending or debugging, remember:
- Module path is plain `televibe` (no github prefix yet) — user must run `go mod tidy` to pull deps.
- Top-level `Config` in config.go composes per-package `Config` types from ai/, risk/, jira/.
- Anthropic provider uses direct HTTP (not the SDK) with prompt caching on the system block.
- State recovery across restarts is via `jira.ListOpenTeleportTickets` (JQL search for `labels = televibe`), parsing Teleport request ID out of the ticket description.
- ITSM ticket description uses Jira wiki markup, not ADF — will need adjustment if targeting Jira Cloud REST v3.
