---
name: Platform-tier components in IAC use Terraform, not Flux
description: When deploying telemetry/observability/platform infra in this repo, prefer Terraform/helm-provider over Flux even when Flux is available
type: feedback
originSessionId: 9c7db84f-6d53-4918-8d06-638ada15b7e9
---
For platform-tier components in the IAC repo (telemetry, observability, anything that lives alongside otel-collector / cilium / external-secrets / fluxcd in `terraform/iac-library/aws/compute/eks-cluster-applications/`), prefer **Terraform with the helm provider** over deploying via Flux — even when the user's first instinct mentions Flux.

**Why:** Sir Charles asked "what are the benefits of deploying X via Flux vs Terraform" while planning the Vector redaction layer (2026-05-05). I had initially proposed Flux because the user said "using flux" in their original ask. He pushed back, noted that OTel itself is Terraform-managed and Vector is plumbing rather than an application, and chose Terraform after I laid out the tradeoffs honestly. Co-locating telemetry components keeps the wire diagram in one place and lets atomic terraform applies coordinate cross-component changes (e.g. version-bumping the OTel module's exporter target alongside the new Vector deployment).

**How to apply:** When designing new platform-tier components for clusters managed by `eks-cluster-applications`, propose Terraform/helm-provider as the default. Flux is the right answer for *applications* (license-manager, crow, saas-tenant-manager, etc. — things in `application-deployment*/flux/`), not for plumbing. If the user explicitly says "use Flux" for a platform component, surface the tradeoff before just doing it — they may not have considered the Terraform alternative.
