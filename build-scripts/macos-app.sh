#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
OUT_DIR="${SCRIPT_DIR}/out"
STAGE_DIR="${OUT_DIR}/stage"
APP_DIR="${STAGE_DIR}/Playit.app"

CLI_BIN="${ROOT_DIR}/target/release/playit-cli"
DAEMON_BIN="${ROOT_DIR}/target/release/playitd"
DMG_PATH="${OUT_DIR}/playit.dmg"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must be run on macOS" >&2
  exit 1
fi

if ! command -v hdiutil >/dev/null 2>&1; then
  echo "hdiutil is required to create a .dmg" >&2
  exit 1
fi

if [[ ! -x "${CLI_BIN}" ]]; then
  echo "missing binary: ${CLI_BIN}" >&2
  echo "build it first with: cargo build --release --package playit-cli" >&2
  exit 1
fi

if [[ ! -x "${DAEMON_BIN}" ]]; then
  echo "missing binary: ${DAEMON_BIN}" >&2
  echo "build it first with: cargo build --release --package playitd" >&2
  exit 1
fi

rm -rf "${STAGE_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS" "${APP_DIR}/Contents/Resources"

cp "${CLI_BIN}" "${APP_DIR}/Contents/MacOS/playit"
cp "${DAEMON_BIN}" "${APP_DIR}/Contents/MacOS/playitd"
chmod 0755 "${APP_DIR}/Contents/MacOS/playit" "${APP_DIR}/Contents/MacOS/playitd"

cat > "${APP_DIR}/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>Playit</string>
  <key>CFBundleExecutable</key>
  <string>playit</string>
  <key>CFBundleIdentifier</key>
  <string>gg.playit.cli</string>
  <key>CFBundleName</key>
  <string>Playit</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>11.0</string>
</dict>
</plist>
PLIST

mkdir -p "${OUT_DIR}"
rm -f "${DMG_PATH}"

hdiutil create \
  -volname "Playit" \
  -srcfolder "${STAGE_DIR}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}"

echo "created ${DMG_PATH}"
