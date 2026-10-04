# Project Profile

The onboarding result for **this** repository — the one repo-specific file in the agent instruction
set. Everything else under `.agents/` is generic and is replaced when the instruction set is
re-installed; this file is preserved.

Owned by the `onboarding` skill. Read it before the first task of a session.

Builds and publishes the base images for development containers: `fullstack` (Go, Node, Python,
Kubernetes) and `web` (homepage builder: PHP, Node, gulp, Lighthouse, Chrome). The Dockerfiles live in
`base/`, builds and uploads are Taskfiles, and the images go to Docker Hub (`mibreit/mibreit-fullstack`,
`mibreit/mibreit-homepage-builder`). The repository's own dev container uses the latest published
fullstack image.

## Documentation Map

The architecture documentation is the single source of truth. Each file has one scope; content is
never duplicated across files.

| File | Scope |
|---|---|
| `README.md` | Overview, base images, tooling, dev container usage, and build/publish flow |

## Conventions

| Setting | Value |
|---|---|
| Documentation root | `README.md` |
| Trunk branch | `master` |
| Scratch directory | `temp/` |

The scratch directory holds throwaway output (drafts, generated reports, scratch notes) and must be
git-ignored. Never write throwaway files anywhere else in the repository.

## Ticket System

| Setting | Value |
|---|---|
| System | local |
| Profile | `ticket-systems/local.md` |

The profile is the file under `.agents/ticket-systems/` that defines the id format and how
tickets are fetched and created. Exactly one profile is active. Skills read only its five sections,
so swapping the backend means changing the line above — no skill is touched.

## Commands

| Command | Purpose |
|---|---|
| `task deploy:build:fullstack VERSION=X.Y.Z` | Build the fullstack image |
| `task deploy:build:web VERSION=X.Y.Z` | Build the web image |
| `task deploy:build:all FULLSTACK_VERSION=X.Y.Z WEB_VERSION=X.Y.Z` | Build both images |

The `task deploy:upload:*` tasks push to Docker Hub; do not run them unattended.

