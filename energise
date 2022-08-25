#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ansible-playbook -i "${SCRIPT_DIR}/hosts" "${SCRIPT_DIR}/site.yml" --tags "homelab" --extra-vars '{"include_vars_path":"/etc/energise.yml"}'
