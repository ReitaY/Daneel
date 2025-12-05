#!/usr/bin/env bash
set -euo pipefail

: "${DISPLAY:=:0.0}"
: "${DISPLAY_WIDTH:=1470}"
: "${DISPLAY_HEIGHT:=956}"
: "${VNC_PORT:=5901}"
: "${WEB_PORT:=8080}"

# 壁紙 & style（環境変数で差し替えも出来るようにしておく）
: "${DANEEL_WALLPAPER:=/app/wallpapers/daneel_wallpaper_ubuntu_default_1920x1080.png}"
: "${FLUXBOX_STYLE:=zimek_darkblue}"

if [ -z "${HOME:-}" ]; then
  export HOME="/home/${USER_NAME:-daneel}"
fi

export DANEEL_WALLPAPER

# ===== style を init に書き込む =====
STYLE_PATH="/usr/share/fluxbox/styles/${FLUXBOX_STYLE}"

INIT_FILE="${HOME}/.fluxbox/init"

mkdir -p "$(dirname "${INIT_FILE}")"

if [ -d "${STYLE_PATH}" ]; then
  if grep -q '^session.styleFile:' "${INIT_FILE}" 2>/dev/null; then
    # 既存の行を差し替え
    sed -i "s|^session.styleFile:.*|session.styleFile:    ${STYLE_PATH}|" "${INIT_FILE}"
  else
    # なければ追記
    echo "session.styleFile:    ${STYLE_PATH}" >> "${INIT_FILE}"
  fi
else
  echo "WARNING: style not found: ${STYLE_PATH}" >&2
fi

# ===== terminator をデフォルト端末に設定 =====
if grep -q '^session.terminal:' "${INIT_FILE}" 2>/dev/null; then
  sed -i 's|^session.terminal:.*|session.terminal:    terminator|' "${INIT_FILE}"
else
  echo 'session.terminal:    terminator' >> "${INIT_FILE}"
fi

# ===== startup の生成（いままでのやつ） =====
STARTUP_FILE="${HOME}/.fluxbox/startup"
mkdir -p "$(dirname "${STARTUP_FILE}")"

cat > "${STARTUP_FILE}" <<'EOF'
#!/bin/sh
: "${DANEEL_WALLPAPER:=/app/wallpapers/daneel_wallpaper_ubuntu_default_2460x1440.png}"

# Fluxbox をバックグラウンドで起動
/usr/bin/fluxbox &
FB_PID=$!

# 立ち上がるのを少し待つ
sleep 1

# その後に壁紙を設定
feh --bg-fill "$DANEEL_WALLPAPER"

# Fluxbox が落ちるまで待機
wait "$FB_PID"
EOF

chmod +x "${STARTUP_FILE}"
mkdir -p /var/log/supervisor

# 引数ありならそのコマンド、なしなら GUI スタック
if [ "$#" -gt 0 ]; then
  echo "Daneel desktop: running custom command: $*"
  exec "$@"
fi

exec supervisord -c /app/supervisord.conf
