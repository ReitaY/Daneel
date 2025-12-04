ARG ROS_DISTRO=jazzy

FROM ros:${ROS_DISTRO}-ros-base

ARG USER_NAME=daneel
ARG USER_ID=1000
ARG GROUP_ID=1000

# ユーザ作成と sudo 設定
RUN set -eux; \
    # 1) 同じ UID を持つ別ユーザがいたら削除
    if getent passwd "${USER_ID}" >/dev/null; then \
        old_user="$(getent passwd "${USER_ID}" | cut -d: -f1)"; \
        if [ "${old_user}" != "${USER_NAME}" ] && [ "${USER_ID}" -ne 0 ]; then \
            echo "Deleting existing user ${old_user} with UID=${USER_ID}"; \
            userdel -r "${old_user}" || true; \
        fi; \
    fi; \
    \
    # 2) 同じ GID を持つ別グループがいたら削除
    if getent group "${GROUP_ID}" >/dev/null; then \
        old_group="$(getent group "${GROUP_ID}" | cut -d: -f1)"; \
        if [ "${old_group}" != "${USER_NAME}" ] && [ "${GROUP_ID}" -ne 0 ]; then \
            echo "Deleting existing group ${old_group} with GID=${GROUP_ID}"; \
            groupdel "${old_group}" || true; \
        fi; \
    fi; \
    \
    # 3) 改めてグループ＆ユーザを作成
    echo "Creating group ${USER_NAME} (GID=${GROUP_ID})"; \
    groupadd -g "${GROUP_ID}" "${USER_NAME}"; \
    echo "Creating user  ${USER_NAME} (UID=${USER_ID}, GID=${GROUP_ID})"; \
    useradd -m -u "${USER_ID}" -g "${GROUP_ID}" -s /bin/bash "${USER_NAME}"; \
    \
    # 4) sudo 設定
    apt-get update; \
    apt-get install -y --no-install-recommends sudo; \
    echo "${USER_NAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/"${USER_NAME}"; \
    chmod 0440 /etc/sudoers.d/"${USER_NAME}"; \
    rm -rf /var/lib/apt/lists/*

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