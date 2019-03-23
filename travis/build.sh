cd ${TRAVIS_BUILD_DIR}/src

set -e

set -o pipefail && xcodebuild -project notes.xcodeproj -scheme notesTests -destination platform\=iOS\ Simulator,OS\=10.0,name\=iPhone\ 6 build test | xcpretty
