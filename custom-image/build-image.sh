#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-harness-ansible-with-awscli}"
IMAGE_TAG="${IMAGE_TAG:-1.0.0}"
BASE_IMAGE="${BASE_IMAGE:-docker.io/plugins/harness_ansible:latest}"
TARGET_REGISTRY_PREFIX="${TARGET_REGISTRY_PREFIX:-pkg.harness.io/n5dbefl9s4-ibnocsk8gbg/abc}"
TARGET_REPO="${TARGET_REGISTRY_PREFIX}/${IMAGE_NAME}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

metadata_file="$(mktemp)"
trap 'rm -f "${metadata_file}"' EXIT

echo "Pulling base image from Docker Hub: ${BASE_IMAGE}"
docker pull "${BASE_IMAGE}"

echo "Building and pushing multi-arch image to ${TARGET_REPO}:${IMAGE_TAG}"
docker buildx build \
  --pull \
  --platform "linux/amd64,linux/arm64" \
  --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
  --file Dockerfile \
  --tag "${TARGET_REPO}:${IMAGE_TAG}" \
  --tag "${TARGET_REPO}:latest" \
  --push \
  --metadata-file "${metadata_file}" \
  .

digest="$(
  python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("containerimage.digest") or d.get("containerimage.descriptor",{}).get("digest",""))' "${metadata_file}"
)"

if [[ -z "${digest}" ]]; then
  echo "Failed to resolve pushed image digest." >&2
  exit 1
fi

echo "Pushed immutable image reference:"
echo "${TARGET_REPO}@${digest}"