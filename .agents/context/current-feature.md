# Current Feature

> Skeleton — no feature is currently active. `ticket-solve` overwrites this file when implementation starts.
> See `INSTRUCTIONS.md` for how this file is used. Omit sections that have nothing in them.

- **Ticket:** [generic-agent-installation](../../../tickets/in-progress/generic-agent-installation.md)
- **Branch:** `generic-agent-installation`
- **Updated:** 2026-09-04 (first implementation pass was committed before the working memory; this file records the resumed state)

## Goal

A target repository receives one generic instruction payload under `.agents/`, discovered by all supported agents through compatibility entries, with safe refresh and switch handling. Existing agent-specific installations are refused rather than migrated.

## Build Plan

- [x] Decide layout: replace agent-specific installation with `.agents/` as canonical root.
- [x] Design compatibility entries for `.github/copilot-instructions.md`, `CLAUDE.md`, and `AGENTS.md`.
- [x] Redesign `utils/onboard/onboarding.sh` CLI and path/token resolution.
- [x] Refuse existing agent-specific roots instead of migrating them.
- [x] Rework refresh, switch, backup, pointer, symlink, and stale-root handling.
- [x] Extract compatibility-entry handling into `utils/onboard/lib/agent_compatibility_entry.sh`.
- [ ] Test fresh, refresh, and workflow-switch flows on symlink-supporting filesystems.
- [ ] Verify pointer-file fallback on a Windows-mounted repository without symlink support.
- [x] Update workflow READMEs, root README, agent guidelines/skill references, and token tables.

## Open Questions

Unanswered questions block the steps that depend on them. Keep them listed until answered.

- [x] Should the generic `.agents/` layout replace all agent-specific installations immediately, or remain alongside compatibility flags during a transition? — **Answer:** Replace all agent-specific installation now; no automatic migration.
- [x] For Codex, should the installed canonical root remain `.agents/` with `.codex` as a directory symlink, or should `.codex` contain compatibility links pointing into `.agents/`? — **Answer:** Keep `.agents/` as the foundation and point all other agent entries to it with symlinks; do not overcomplicate the installer.

## Decisions

Provisional until promoted to `README.md` during Reconcile.

- Install one canonical payload in `.agents/`, because it is already the repository's maintainer convention and avoids divergent parallel roots.
- Prefer symlinks for Linux-native and Linux dev-container use, with an explicit preflight failure for mounted filesystems where symlinks cannot be created.
- Existing agent-specific installs are refused rather than migrated.
- No migration path for existing agent-specific installations; the developer will manually copy `project.md`, token mapping, and working memory from the few existing repositories.
- Remove the interactive agent choice rather than retaining legacy flags.
- Make `.github/copilot-instructions.md`, `CLAUDE.md`, and `AGENTS.md` symlinks to `.agents/AGENTS.md`. Do not create `.codex/`; Codex discovers the canonical `AGENTS.md` directly.
- When symlinks are unsupported, create compatibility files containing exactly `Read .agents/AGENTS.md.` so agents perform one additional hop to the canonical instructions.
- Current Copilot discovers `.agents/skills/` natively, so no skills-folder compatibility entry is needed.
- Pointer-file fallback still needs verification on the developer's Windows-mounted repository.
- Moved each workflow's `AGENTS.md` from `agent/guidelines/AGENTS.md` to `agent/AGENTS.md`, because the compatibility entries and `CANONICAL` in `onboarding.sh` always pointed at `.agents/AGENTS.md` — the `guidelines/` subfolder made that a dangling reference. Dropped the dead `{{GUIDELINES_FILE}}` token and the equally dead `{{AGENT_ROOT}}` "pass-1 placeholder" wording from `onboarding.sh`, both onboarding skills, and the root `AGENTS.md`/`README.md`, since `.agents/` is now a fixed path, never a substituted token.

## Flags

New problems or Technical Debt spotted along the way. Hand to `ticket-draft` before clearing.

- What, where (file + function), why it matters
