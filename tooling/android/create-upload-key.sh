#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ANDROID_DIR="$REPO_ROOT/android"
KEYSTORE_FILE="$ANDROID_DIR/upload-keystore.jks"
PROPERTIES_FILE="$ANDROID_DIR/key.properties"

if ! command -v keytool >/dev/null 2>&1 || ! command -v openssl >/dev/null 2>&1; then
  echo "Both keytool (JDK) and openssl are required." >&2
  exit 1
fi

if [[ -e "$KEYSTORE_FILE" || -e "$PROPERTIES_FILE" ]]; then
  echo "Refusing to overwrite an existing upload keystore or key.properties." >&2
  exit 1
fi

UPLOAD_SECRET="$(openssl rand -hex 24)"
export AUDIO_CUT_UPLOAD_PASSWORD="$UPLOAD_SECRET"
umask 077

cleanup() {
  local result="$?"
  unset AUDIO_CUT_UPLOAD_PASSWORD UPLOAD_SECRET
  if [[ "$result" -ne 0 ]]; then
    rm -f "$KEYSTORE_FILE" "$PROPERTIES_FILE"
  fi
}
trap cleanup EXIT

keytool -genkeypair -noprompt -v \
  -keystore "$KEYSTORE_FILE" \
  -storetype JKS \
  -alias audio_cut_upload \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000 \
  -dname "CN=Audio Cut Upload Key,O=Audio Cut" \
  -storepass:env AUDIO_CUT_UPLOAD_PASSWORD \
  -keypass:env AUDIO_CUT_UPLOAD_PASSWORD

cat > "$PROPERTIES_FILE" <<PROPERTIES
storeFile=upload-keystore.jks
storePassword=$UPLOAD_SECRET
keyAlias=audio_cut_upload
keyPassword=$UPLOAD_SECRET
PROPERTIES
chmod 600 "$KEYSTORE_FILE" "$PROPERTIES_FILE"
unset AUDIO_CUT_UPLOAD_PASSWORD UPLOAD_SECRET
trap - EXIT

cat <<'MESSAGE'
Created android/upload-keystore.jks and android/key.properties.
Both files are ignored by Git. Back them up together in a secure password manager or encrypted storage before uploading any release.
MESSAGE
