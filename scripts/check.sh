#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/checks
swiftc -parse-as-library -target arm64-apple-macos15.0 \
  Sources/LalaTranslate/Models/*.swift \
  Sources/LalaTranslate/Services/SelectedTextProvider.swift \
  Sources/LalaTranslate/Services/TranslationService.swift \
  Checks/CoreChecks.swift -o .build/checks/CoreChecks
.build/checks/CoreChecks
