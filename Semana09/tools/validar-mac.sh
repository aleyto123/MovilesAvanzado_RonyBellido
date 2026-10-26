#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift test
swift run boleta-check tools/verification.json
xcodebuild -project BoletaPago.xcodeproj -scheme BoletaPago \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO build
echo 'Motor probado y app compilada para simulador.'
