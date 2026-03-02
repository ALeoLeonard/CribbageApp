#!/usr/bin/env bash
#
# archive_and_upload.sh — Build a release archive and optionally upload to App Store Connect.
#
# Usage:
#   ./scripts/archive_and_upload.sh            # Archive only (no upload)
#   ./scripts/archive_and_upload.sh --upload   # Archive + export + upload
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/Config/Local.xcconfig"
EXPORT_OPTIONS="$PROJECT_ROOT/Config/ExportOptions.plist"
ARCHIVE_DIR="$PROJECT_ROOT/build"
ARCHIVE_PATH="$ARCHIVE_DIR/CribbageApp.xcarchive"
EXPORT_PATH="$ARCHIVE_DIR/Export"
SCHEME="CribbageApp"
PROJECT="$PROJECT_ROOT/CribbageApp.xcodeproj"

# --- Read Team ID from Local.xcconfig ---
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: $CONFIG_FILE not found."
    echo "  cp Config/Local.xcconfig.template Config/Local.xcconfig"
    echo "  Then fill in your DEVELOPMENT_TEAM."
    exit 1
fi

TEAM_ID=$(grep '^DEVELOPMENT_TEAM' "$CONFIG_FILE" | sed 's/.*= *//' | tr -d '[:space:]')

if [[ -z "$TEAM_ID" || "$TEAM_ID" == "XXXXXXXXXX" ]]; then
    echo "ERROR: DEVELOPMENT_TEAM is not set in $CONFIG_FILE."
    echo ""
    echo "  1. Open Config/Local.xcconfig"
    echo "  2. Set DEVELOPMENT_TEAM to your Apple Developer Team ID"
    echo "     (Find it at https://developer.apple.com/account → Membership Details)"
    echo "  3. Re-run this script."
    exit 1
fi

echo "==> Team ID: $TEAM_ID"

# --- Generate Xcode project ---
echo "==> Generating Xcode project..."
cd "$PROJECT_ROOT"
xcodegen generate

# --- Resolve SPM dependencies ---
echo "==> Resolving SPM dependencies..."
xcodebuild -resolvePackageDependencies \
    -scheme "$SCHEME" \
    -project "$PROJECT"

# --- Archive ---
echo "==> Archiving (Release)..."
mkdir -p "$ARCHIVE_DIR"
xcodebuild archive \
    -scheme "$SCHEME" \
    -project "$PROJECT" \
    -archivePath "$ARCHIVE_PATH" \
    -configuration Release \
    DEVELOPMENT_TEAM="$TEAM_ID"

echo "==> Archive created at $ARCHIVE_PATH"

# --- Upload (optional) ---
if [[ "${1:-}" == "--upload" ]]; then
    echo "==> Exporting for App Store Connect..."

    # Inject real Team ID into ExportOptions
    TEMP_EXPORT="$ARCHIVE_DIR/ExportOptions.plist"
    sed "s/XXXXXXXXXX/$TEAM_ID/g" "$EXPORT_OPTIONS" > "$TEMP_EXPORT"

    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportOptionsPlist "$TEMP_EXPORT" \
        -exportPath "$EXPORT_PATH"

    echo "==> Uploading to App Store Connect..."
    xcrun altool --upload-app \
        -f "$EXPORT_PATH/CribbageApp.ipa" \
        -t ios \
        --apiKey "${APP_STORE_API_KEY:-}" \
        --apiIssuer "${APP_STORE_API_ISSUER:-}" \
        || echo "NOTE: If upload failed, ensure APP_STORE_API_KEY and APP_STORE_API_ISSUER env vars are set."

    echo "==> Done! Check App Store Connect for the build."
else
    echo "==> Archive complete. Run with --upload to export and upload."
fi
