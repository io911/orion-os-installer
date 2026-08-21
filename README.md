# Orion OS Installer

This directory contains scripts and instructions to build a hybrid live+installer ISO for Orion OS.

The ISO produced by the workflow includes the exact filesystem and packages configured by the repository Containerfile and build.yml (it builds the same container image and produces an installer ISO from it).

Files:
- build.sh — local build script (uses podman)
- README.md — this file

Notes:
- Installer is interactive: users set their own username/password and partitioning during installation.
- The ISO will be written to the repository root and named orion-os-installer-<date>.iso where <date> is a compact YYMMDD format (e.g. 260822 for 2026-08-22). The build will overwrite an existing file with the same name if it already exists that day.

See .github/workflows/orion-os-installer.yml for the CI workflow that builds and uploads the ISO as a workflow artifact.
