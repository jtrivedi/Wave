#!/bin/zsh

set -euo pipefail

cd "$(dirname "$0")"

if ! command -v jazzy >/dev/null 2>&1; then
    echo "jazzy is not installed or not on PATH" >&2
    exit 1
fi

jazzy_args=(
    --author="Janum Trivedi"
    --author_url https://github.com/jtrivedi
    --title Wave
    --sdk iphonesimulator
    --swift-build-tool xcodebuild
    --build-tool-arguments -scheme,Wave,-destination,generic/platform=iOS\ Simulator
    --theme=fullwidth
    --readme=README.md
)

if [[ -f "Sources/Wave/Documentation.docc/Documentation.md" ]]; then
    jazzy_args+=(--documentation "Sources/Wave/Documentation.docc/*.md")
fi

"$(command -v jazzy)" "${jazzy_args[@]}"

if [[ -f "./Assets/jazzy.css" ]]; then
    mkdir -p ./docs/css
    cp -f ./Assets/jazzy.css ./docs/css
fi

if [[ -f "./docs/index.html" ]] && command -v open >/dev/null 2>&1; then
    open ./docs/index.html || true
fi
