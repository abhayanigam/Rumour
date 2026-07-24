#!/bin/bash

echo "flutter_build_script: starting..."

# Install Flutter SDK
if cd flutter; then
  git pull && cd ..
else
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Print Flutter version
flutter --version

# Enable web support (just in case, though usually enabled on stable)
flutter config --enable-web

# Get dependencies
flutter pub get

# Build the web project
# --release for production build
# --web-renderer html or canvaskit (default is auto, causing canvaskit download)
# often 'auto' is fine, but sometimes 'html' is preferred for initial load.
# Keeping default 'auto' for now.
echo $SECRET_ENV_JSON > .env.json
flutter build web --release --dart-define-from-file=.env.json

echo "flutter_build_script: build finished"