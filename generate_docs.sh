jazzy \
    --author="Janum Trivedi" \
    --author_url https://github.com/jtrivedi \
    --title Wave \
    --sdk iphoneos \
    --swift-build-tool xcodebuild \
    --build-tool-arguments -scheme,Wave,-target,Wave,-destination,id=$(xcrun simctl list devices | grep -v unavailable | grep -m 1 -o '[0-9A-F\-]\{36\}') \
    --theme=fullwidth \
    --readme=README.md \
    --documentation Guides/*.md && \
cp -fr ./Assets/jazzy.css ./docs/css && \
open ./docs/index.html
