#!/usr/bin/env bash
set -euo pipefail

# このスクリプトの場所からリポジトリルートを計算
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# テスト対象の ROS ディストリビューション
ROS_DISTROS=("humble" "jazzy" "rolling")

# イメージ名のプレフィックス（必要なら環境変数で上書きできるようにしておく）
IMAGE_PREFIX="${IMAGE_PREFIX:-daneel}"

echo "== Daneel CI test start =="
echo "Repo root: ${REPO_ROOT}"
echo "ROS distros: ${ROS_DISTROS[*]}"
echo

for distro in "${ROS_DISTROS[@]}"; do
  echo "-----------------------------"
  echo ">>> Testing ROS_DISTRO=${distro}"
  echo "-----------------------------"

  # 1) base イメージのビルド
  BASE_IMAGE="${IMAGE_PREFIX}/base:${distro}"
  echo "[1] Building base image: ${BASE_IMAGE}"
  docker build \
    -t "${BASE_IMAGE}" \
    --build-arg "ROS_DISTRO=${distro}" \
    -f "${REPO_ROOT}/docker/base/Dockerfile" \
    "${REPO_ROOT}/docker/base"

  # 2) desktop イメージのビルド（base を前提とする想定）
  DESKTOP_IMAGE="${IMAGE_PREFIX}/desktop:${distro}"
  echo "[2] Building desktop image: ${DESKTOP_IMAGE}"
  docker build \
    -t "${DESKTOP_IMAGE}" \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    -f "${REPO_ROOT}/docker/desktop/Dockerfile" \
    "${REPO_ROOT}/docker/desktop"

  # 3) ベースイメージのスモークテスト
  echo "[3] Smoke test: base image (ros2 -h)"
  docker run --rm "${BASE_IMAGE}" bash -lc 'ros2 -h >/dev/null 2>&1'

  # 4) デスクトップイメージのスモークテスト
  echo "[4] Smoke test: desktop image (ros2 -h)"
  docker run --rm --entrypoint bash "${DESKTOP_IMAGE}" -lc "source /opt/ros/${distro}/setup.bash && ros2 -h >/dev/null 2>&1"

  echo ">>> OK: ROS_DISTRO=${distro} (base + desktop)"
  echo
done

echo "== All tests for Daneel passed ✅ =="
