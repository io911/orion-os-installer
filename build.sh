#!/usr/bin/env bash
set -euo pipefail

# Local build helper to produce a hybrid live+installer ISO for Orion OS.
# Requires: podman (or docker), and network access to pull the BASE_IMAGE.
# This script follows the same approach as the CI workflow: build the container image
# from the repository Containerfile, then run the bootc base image's imagectl tool
# to create an installer ISO.

IMAGE_TAG="localhost/orion-bootc:iso-build"
BASE_IMAGE="quay.io/fedora/fedora-bootc:44"

# Date suffix in YYMMDD form, e.g. 260822 for 2026-08-22
DATE_SUFFIX=$(date +"%y%m%d")
OUT_FILE="$(pwd)/orion-os-installer-${DATE_SUFFIX}.iso"

echo "Building container image (${IMAGE_TAG}) from Containerfile..."
podman build -t ${IMAGE_TAG} -f Containerfile .

echo "Creating hybrid installer ISO at ${OUT_FILE}..."
# Use the base image which provides /usr/libexec/bootc-base-imagectl
# Mount the current repo root as /output so the ISO is written beside Containerfile
podman run --rm --privileged \
  -v /var/lib/containers:/var/lib/containers \
  -v "$(pwd)":/output \
  ${BASE_IMAGE} \
  /usr/libexec/bootc-base-imagectl create-installer-iso --image ${IMAGE_TAG} --output /output/orion-os-installer-${DATE_SUFFIX}.iso

if [ -f "${OUT_FILE}" ]; then
  echo "ISO created: ${OUT_FILE}"
else
  echo "ISO creation failed"
  exit 1
fi

echo "To write to a USB device (careful: this will overwrite the device):"
echo "  sudo dd if=${OUT_FILE} of=/dev/sdX bs=4M status=progress oflag=sync"