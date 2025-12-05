#!/usr/bin/env bash
set -euo pipefail

# ===== デフォルト値の設定 =====
: "${DISPLAY:=:0.0}"
: "${DISPLAY_WIDTH:=1470}"
: "${DISPLAY_HEIGHT:=956}"
: "${VNC_PORT:=5901}"
: "${WEB_PORT:=8080}"

# 壁紙パス（環境変数で上書きもできるようにしておく）
: "${DANEEL_WALLPAPER:=/app/wallpapers/daneel_wallpaper_ubuntu_default_1920x1080.png}"

if [ -z "${HOME:-}" ]; then
  export HOME="/home/${USER_NAME:-daneel}"
fi

export DANEEL_WALLPAPER

# ===== Fluxbox startup の生成 =====
STARTUP_FILE="${HOME}/.fluxbox/startup"
mkdir -p "$(dirname "${STARTUP_FILE}")"

cat > "${STARTUP_FILE}" <<'EOF'
#!/bin/sh
: "${DANEEL_WALLPAPER:=/app/wallpapers/daneel_wallpaper_ubuntu_default_2560x1440.png}"

# まず Fluxbox をバックグラウンドで起動
/usr/bin/fluxbox &
FB_PID=$!

# X/Fluxbox が立ち上がるのを少し待つ
sleep 1

# その後に壁紙を設定（Fluxbox に上書きされないように）
feh --bg-fill "$DANEEL_WALLPAPER"

# Fluxbox が落ちるまで待機
wait "$FB_PID"
EOF

chmod +x "${STARTUP_FILE}"

mkdir -p /var/log/supervisor

# ===== ここから分岐：引数があればそれを実行、なければGUIスタック起動 =====

if [ "$#" -gt 0 ]; then
  echo "Daneel desktop: running custom command: $*"
  exec "$@"
fi

# 引数が無いときだけ GUI スタック（supervisord）を起動
exec supervisord -c /app/supervisord.conf
