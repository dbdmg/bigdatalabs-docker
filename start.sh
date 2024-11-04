#!/usr/bin/env bash
shopt -s dotglob

exec \
code-server \
--disable-update-check \
--auth none \
--bind-addr 0.0.0.0:"${BIGDATA_LISTEN_PORT}" \
--user-data-dir "$VSCODE_SRV_DIR/data" \
--extensions-dir "$VSCODE_SRV_DIR/extensions" \
--disable-telemetry \
"$VSCODE_SRV_DIR/workspace"
