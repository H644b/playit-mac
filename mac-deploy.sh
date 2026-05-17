#!/usr/bin/env bash
set -euo pipefail

# SHOULD BE RUN ON M1 MAC

FOLDER="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
VERSION="$(toml get "${FOLDER}/packages/playit-cli/Cargo.toml" package.version | sed "s/\"//g")"

bash "${FOLDER}/build-scripts/macos-app.sh"

mkdir -p "${FOLDER}/build-deploy"

cp "${FOLDER}/build-scripts/out/playit.dmg" "${FOLDER}/build-deploy/playit-${VERSION}.dmg"
cp "${FOLDER}/target/release/playit-cli" "${FOLDER}/build-deploy/playit-${VERSION}-apple-m1"
cp "${FOLDER}/target/x86_64-apple-darwin/release/playit-cli" "${FOLDER}/build-deploy/playit-${VERSION}-apple-intel"
