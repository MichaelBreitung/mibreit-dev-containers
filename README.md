# Dev Container Base Images

## About

This project builds and publishes the base images for my development containers. Each image has its own Dockerfile in [base/](base/) and its own version. Building and publishing is done with [Task](https://taskfile.dev/).
The repository's own dev container is built on the latest published fullstack image.

| Image | Dockerfile | Docker Hub | Purpose | Platforms |
|---|---|---|---|---|
| fullstack | [base/Dockerfile.fullstack](base/Dockerfile.fullstack) | [mibreit/mibreit-fullstack](https://hub.docker.com/r/mibreit/mibreit-fullstack) | Fullstack development (Go, Node, Python, Kubernetes) | amd64, arm64 |
| web | [base/Dockerfile.web](base/Dockerfile.web) | [mibreit/mibreit-homepage-builder](https://hub.docker.com/r/mibreit/mibreit-homepage-builder) | Building static homepages (PHP, Node, gulp, Lighthouse, Chrome) | amd64 only |

The web image is amd64 only, because Google Chrome has no arm64 Linux build.

Both images are built on Ubuntu 24.04.

## Included Tooling

### Fullstack image

| Area | Tools |
|---|---|
| Python | Python 3.12 (`python3` and `python`), pip, venv, pytest, pytest-asyncio, black, isort, mypy |
| Node | Node.js v24.21.0 via NVM (other versions can be installed with `nvm`), npm, npx, Codex CLI 0.160.0 |
| Go | Go 1.27.1, Delve (`dlv`) |
| Containers and Kubernetes | Docker CLI (with buildx and compose plugins; the engine comes from the host via the mounted socket), kubectl v1.37.1, Helm 3.22.0 |
| Other | Taskfile (with bash completion), git, git-lfs, jq, PostgreSQL client, OpenSSH client, build-essential, gnupg |

### Web image

| Area | Tools |
|---|---|
| PHP | PHP CLI (with mbstring and curl), Composer |
| Node | Node.js v24.21.0 via NVM, npm, npx, gulp-cli 3.1.0, lighthouse 13.5.0, @lhci/cli 0.15.1, Codex CLI 0.160.0 |
| Browser | Google Chrome |
| Python | Python 3.12, pip, venv, pytest, pytest-asyncio, black, isort, mypy, requests, Jinja2 |
| Containers | Docker CLI (with buildx and compose plugins) |
| Other | Taskfile (with bash completion), Stripe CLI, ExifTool, git, git-lfs, jq, OpenSSH client |

The web image has no Go, Helm or Kubernetes tooling.

### Dev container of this repository

The dev container image ([.devcontainer/Dockerfile](.devcontainer/Dockerfile)) is based on the published base image and adds:

- the `developer` user with passwordless `sudo`, matching your host `UID`/`GID`
- `bash-completion`, a bash prompt that shows the git branch, and Taskfile completion
- the entrypoint [.devcontainer/docker-entrypoint.sh](.devcontainer/docker-entrypoint.sh) (see [Using the Base Images in Your Own Projects](#using-the-base-images-in-your-own-projects))

[.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) configures the VS Code extensions and settings used inside the container.

## Dev Containers

To use the Dev Container you must have [VSCode](https://code.visualstudio.com/) and the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed on your host machine together with the [Docker Engine](https://docs.docker.com/engine/install/ubuntu/). 

Open the repository in VS Code and run **Dev Containers: Reopen in Container**. The project folder is mounted at `/home/developer/develop`, and the host Docker socket is mounted so Docker can be used from inside the container.

Optional scripts in [scripts/](scripts/), for the dev container of this repository:

- `init-dev.sh`: hook for custom project initialization, for example `npm install` or `pip install`. It is empty by default.
- `init-dev-host-win.sh`: changes the ownership of the Docker socket (required on Windows hosts), then calls `init-dev.sh`.

Here are three video tutorials that will get you started with Docker and Dev Containers:

- [Where Dev Containers are helpful](https://youtu.be/9F-jbT-pHkg?si=yW4RThXZNC0SMIyl)
- [How to create a custom Dev Container](https://youtu.be/7P0pTECkiN8?si=51YPKbUzL7OlAs80)
- [How to configure VS Code Extenstions and Settings in a Dev Container](https://youtu.be/W84R1CxtF0c?si=YBhBRzKk1lgCKEyz)

## Using the Base Images in Your Own Projects

The base images contain tooling only: they have no project user and no entrypoint. A project adds both in its own `.devcontainer/` folder. The files of this repository's [.devcontainer/](.devcontainer/) folder are a working template:

| File | Purpose |
|---|---|
| [Dockerfile](.devcontainer/Dockerfile) | `FROM` a base image, creates the user, installs the entrypoint |
| [docker-entrypoint.sh](.devcontainer/docker-entrypoint.sh) | Runs on every container start |
| [docker-compose.yml](.devcontainer/docker-compose.yml) | Build arguments, project mount, Docker socket mount, `.env` |
| [devcontainer.json](.devcontainer/devcontainer.json) | VS Code extensions and settings |

To set up a new project:

1. Copy the four files into `<project>/.devcontainer/`.
2. In the `Dockerfile`, change the `FROM` line to the base image you need: `mibreit/mibreit-fullstack` or `mibreit/mibreit-homepage-builder`. `latest` always works; a fixed version tag (for example `mibreit/mibreit-fullstack:0.7.0`) keeps the container reproducible.
3. In `docker-compose.yml` and `devcontainer.json`, adjust the service name, the project folder mount and `workspaceFolder`.
4. Optional: put variables into a `.env` file in the project root and keep it out of git.
5. Run **Dev Containers: Reopen in Container**.

### The Entrypoint

[.devcontainer/docker-entrypoint.sh](.devcontainer/docker-entrypoint.sh) does two things on every container start:

- **Docker socket access:** it reads the group ID of the mounted `/var/run/docker.sock` and adds the container user to a group with that ID, creating the group if necessary. This lets the non-root container user run `docker` against the host engine, whatever group ID the host assigns to the socket.
- **Codex with OpenRouter:** if `OPENROUTER_API_KEY` and `OPENROUTER_BASE_URL` are set, and `~/.codex/config.toml` does not exist yet, it generates that file so that Codex uses OpenRouter. The API key is not written to the file; Codex reads it from the environment. An existing config is never overwritten, and deleting the file regenerates it. Without these variables nothing happens.

The script has these requirements, which the template files already fulfil:

- the environment variable `USER` holds the container user (set in the `Dockerfile` from the `USER` build argument)
- that user has passwordless `sudo`
- the host Docker socket is mounted at `/var/run/docker.sock` (the script fails without it)
- the variables from `.env` reach the container, which `docker-compose.yml` does with `env_file` (optional file)

The `Dockerfile` has to be the one that copies the script to `/usr/local/bin/`, makes it executable and sets it as `ENTRYPOINT`, with `CMD ["sleep", "infinity"]` to keep the container running.

The environment variables are read when the container starts. After changing `.env`, restart the container.

## Building and Publishing Base Images

The tasks are defined in [taskfiles/Deploy.Taskfile.yaml](taskfiles/Deploy.Taskfile.yaml) and included in [Taskfile.yaml](Taskfile.yaml) under the `deploy:` namespace. Run `task --list` to see them.

| Task | Required variables | Effect |
|---|---|---|
| `task deploy:build:fullstack` | `VERSION` | Builds `mibreit/mibreit-fullstack:VERSION` |
| `task deploy:build:web` | `VERSION` | Builds `mibreit/mibreit-homepage-builder:VERSION` |
| `task deploy:build:all` | `FULLSTACK_VERSION`, `WEB_VERSION` | Builds both images |
| `task deploy:upload:fullstack` | `VERSION` | Pushes `VERSION` and `latest` of the fullstack image |
| `task deploy:upload:web` | `VERSION` | Pushes `VERSION` and `latest` of the web image |
| `task deploy:upload:all` | `FULLSTACK_VERSION`, `WEB_VERSION` | Pushes both images |

Whenever new tools are required:

1. Edit the Dockerfile in [base/](base/). Pin downloaded tools and Python packages to fixed versions; apt packages are intentionally unpinned, because Ubuntu removes superseded versions from its mirrors.
2. Build the image with a new version, for example `task deploy:build:web VERSION=X.Y.Z`. The version is also stored in the image label `version`.
3. Log in to Docker Hub: `docker login`.
4. Push it with the same version: `task deploy:upload:web VERSION=X.Y.Z`. The task aborts if the version already exists in the registry, then pushes `X.Y.Z` and moves `latest` to it.
5. Rebuild the Dev Container. `.devcontainer/Dockerfile` uses the fullstack image with the `latest` tag.

The images are versioned independently of each other.

The registry paths are set as `FULLSTACK_IMAGE` and `WEB_IMAGE` in [taskfiles/Deploy.Taskfile.yaml](taskfiles/Deploy.Taskfile.yaml). To publish to your own registry, change them there.
