#!/usr/bin/env bash
set -euo pipefail

# ===== デフォルト値の設定 =====
: "${DISPLAY:=:1}"
: "${DISPLAY_WIDTH:=1470}"
: "${DISPLAY_HEIGHT:=956}"
: "${VNC_PORT:=5901}"
: "${WEB_PORT:=8080}"

: "${DANEEL_WALLPAPER:=/app/wallpapers/daneel_wallpaper_ubuntu_default_1920x1080.png}"

if [ -z "${HOME:-}" ]; then
  export HOME="/home/${USER_NAME:-daneel}"
fi

# ===== Fluxbox startup の自動生成 =====
STARTUP_FILE="${HOME}/.fluxbox/startup"

if [ ! -f "${STARTUP_FILE}" ]; then
  echo "Creating default Fluxbox startup at ${STARTUP_FILE}"
  mkdir -p "$(dirname "${STARTUP_FILE}")"

  cat > "${STARTUP_FILE}" <<'EOF'
#!/bin/sh
: "${DANEEL_WALLPAPER:=/app/wallpapers/daneel_wallpaper_ubuntu_default_1920x1080.png}"

feh --bg-fill "$DANEEL_WALLPAPER" &

exec fluxbox
EOF

  chmod +x "${STARTUP_FILE}"
fi

chown -R "$(id -u)":"$(id -g)" "${HOME}/.fluxbox" || true
mkdir -p /var/log/supervisor

# ===== ここから分岐：引数があればそれを実行、なければGUIスタック起動 =====

if [ "$#" -gt 0 ]; then
  echo "Daneel desktop: running custom command: $*"
  exec "$@"
fi

# 引数が無いときだけ GUI スタック（supervisord）を起動
exec supervisord -c /app/supervisord.conf
