ARG ROS_DISTRO=jazzy

FROM ros:${ROS_DISTRO}-ros-base

ARG USER_NAME=daneel
ARG USER_ID=1000
ARG GROUP_ID=1000

# ユーザ作成と sudo 設定
RUN groupadd -g "${GROUP_ID}" "${USER_NAME}" \
    && useradd -m -u "${USER_ID}" -g "${GROUP_ID}" -s /bin/bash "${USER_NAME}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && echo "${USER_NAME} ALL=(root) NOPASSWD:ALL" >/etc/sudoers.d/"${USER_NAME}" \
    && chmod 0440 /etc/sudoers.d/"${USER_NAME}" \
    && rm -rf /var/lib/apt/lists/*

# アップグレード
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends python3-pip \
    && rm -rf /var/lib/apt/lists/*

ENV SHELL=/bin/bash

# ワークスペース作成 + オーナー変更
RUN mkdir -p "/home/${USER_NAME}/ros2_ws" \
    && chown -R "${USER_NAME}:${GROUP_ID}" "/home/${USER_NAME}"

WORKDIR /home/${USER_NAME}/ros2_ws

USER ${USER_NAME}