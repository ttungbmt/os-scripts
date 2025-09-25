#!/usr/bin/env bash

PY_VERSION="${PY_VERSION:-3.12}"
ENABLE_SYMLINKS="${ENABLE_SYMLINKS:-0}"
SYMLINK_DIR="${SYMLINK_DIR:-/usr/local/bin}"
PIPX_INSTALL="${PIPX_INSTALL:-1}"

PY_PKGS=(
  "python${PY_VERSION}"
  "python${PY_VERSION}-pip"
  "python${PY_VERSION}-setuptools"
  "python${PY_VERSION}-wheel"
  "python${PY_VERSION}-devel"
)

dnf -y install --setopt=install_weak_deps=False --setopt=tsflags=nodocs "${PY_PKGS[@]}"

if [[ "${PIPX_INSTALL}" == "1" ]]; then
  "pip${PY_VERSION}" install --upgrade pip
  "pip${PY_VERSION}" install pipx
fi

if [[ "${ENABLE_SYMLINKS}" == "1" && "${PY_VERSION}" != "3" ]]; then
  mkdir -p "${SYMLINK_DIR}"
  ln -sf "/usr/bin/python${PY_VERSION}" "${SYMLINK_DIR}/python3"
  ln -sf "/usr/bin/pip${PY_VERSION}" "${SYMLINK_DIR}/pip3"
fi