# Daneel desktop layer
ARG BASE_IMAGE=daneel/base:humble
FROM ${BASE_IMAGE}

# base 側で作ったユーザー名を再利用
ARG USER_NAME=daneel

# いったん root に戻してパッケージインストール
USER root

# 最低限のデスクトップ環境 + TigerVNC + noVNC + supervisord
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      fluxbox \
      tigervnc-standalone-server \
      novnc \
      websockify \
      supervisor \
      xterm \
      feh \
      net-tools \
      terminator \
      locales; \
    locale-gen en_US.UTF-8; \
    rm -rf /var/lib/apt/lists/*

# ROS デスクトップもここで追加（base は ros-*-ros-base 想定）
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ros-${ROS_DISTRO}-desktop \
      ros-${ROS_DISTRO}-rqt \
      ros-${ROS_DISTRO}-rqt-common-plugins \
      ros-${ROS_DISTRO}-rqt-tf-tree \
      ros-${ROS_DISTRO}-plotjuggler-ros; \
    rm -rf /var/lib/apt/lists/*

# ロケールと表示系のデフォルト
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# VNC / noVNC / 画面サイズのデフォルト
ENV DISPLAY=:1 \
    DISPLAY_WIDTH=1470 \
    DISPLAY_HEIGHT=956 \
    VNC_PORT=5901 \
    WEB_PORT=8080

# アプリ類を /app にまとめる
COPY app /app

RUN set -eux; \
    chmod +x /app/entrypoint.sh; \
    mkdir -p /var/log/supervisor; \
    chown -R "${USER_NAME}:${USER_NAME}" /app /var/log/supervisor

# runtime は base と同じ一般ユーザで
USER ${USER_NAME}
ENV HOME=/home/${USER_NAME}
WORKDIR /home/${USER_NAME}/ros2_ws

# コンテナ起動 = GUI スタック起動
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]