set -e

set -o pipefail && xcodebuild -project notes.xcodeproj -scheme notesTests -destination platform\=iOS\ Simulator,OS\=10.0,name\=iPhone\ X build test | xcpretty
