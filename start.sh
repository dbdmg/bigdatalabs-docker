#!/usr/bin/env bash
shopt -s dotglob

if ! [ -d "$VSCODE_SRV_DIR/workspace" ]; then
    mkdir "$VSCODE_SRV_DIR/workspace"
fi

exec \
code-server \
--disable-update-check \
--auth none \
--bind-addr 0.0.0.0:"${BIGDATA_LISTEN_PORT}" \
--user-data-dir "$VSCODE_SRV_DIR/data" \
--extensions-dir "$VSCODE_SRV_DIR/extensions" \
--disable-telemetry \
"$VSCODE_SRV_DIR/workspace"
