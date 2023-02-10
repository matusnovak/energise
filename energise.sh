#!/usr/bin/env bash

set -e

DIR="$(dirname "$(realpath "$0")")"

helm upgrade \
    --install \
    --values ./energise.yaml \
    --namespace homelab \
    --create-namespace \
    homelab "${DIR}"
