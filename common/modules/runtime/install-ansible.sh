#!/usr/bin/env bash

ANSIBLE_VERSION="${ANSIBLE_VERSION:-11.9.0}"

pipx install --global --include-deps ansible=="${ANSIBLE_VERSION}"