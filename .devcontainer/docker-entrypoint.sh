#!/bin/bash
set -e

DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)

if [ "${DOCKER_GID}" != "0" ]; then
    # The socket's GID may already belong to another group (e.g. the user's own group)
    SOCK_GROUP=$(getent group "${DOCKER_GID}" | cut -d: -f1 || true)
    if [ -n "${SOCK_GROUP}" ]; then
        sudo usermod -aG "${SOCK_GROUP}" "$USER"
    else
        if ! getent group docker >/dev/null; then
            sudo groupadd -g "${DOCKER_GID}" docker
        else
            sudo groupmod -g "${DOCKER_GID}" docker
        fi
        sudo usermod -aG docker "$USER"
    fi
fi

# Codex: generate the OpenRouter config from the environment (.env), if there is none yet.
# The API key is not written to the file: Codex reads it from the environment at runtime.
# Delete ~/.codex/config.toml to have it regenerated.
if [ -n "${OPENROUTER_API_KEY:-}" ] && [ -n "${OPENROUTER_BASE_URL:-}" ] && [ ! -f "$HOME/.codex/config.toml" ]; then
    mkdir -p "$HOME/.codex"
    cat > "$HOME/.codex/config.toml" <<EOF
model_provider = "openrouter"
model_reasoning_effort = "high"
model = "z-ai/glm-5.3-flash"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "${OPENROUTER_BASE_URL}"
wire_api = "responses"

[model_providers.openrouter.auth]
command = "sh"
args = ["-c", "echo \$OPENROUTER_API_KEY"]

[projects."/home/developer/develop"]
trust_level = "trusted"
EOF
fi

# uncomment if you have node modules
# sudo chown $USER:$USER /home/$USER/develop/node_modules

exec "$@"
