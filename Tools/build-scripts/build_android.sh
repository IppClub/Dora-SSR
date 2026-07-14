#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="${1:-debug}"

select_gradle_java() {
	local java_version=""
	local java_home_candidate=""

	if command -v java >/dev/null 2>&1; then
		java_version="$(java -version 2>&1 | sed -n '1s/.*version "\([0-9][0-9]*\).*/\1/p')"
	fi
	if [ -n "$java_version" ] && [ "$java_version" -ge 17 ] && [ "$java_version" -le 20 ]; then
		return
	fi

	if [ "$(uname -s)" = "Darwin" ]; then
		for java_home_candidate in \
			"/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
			"/Applications/Android Studio Preview.app/Contents/jbr/Contents/Home"; do
			if [ -x "$java_home_candidate/bin/java" ]; then
				export JAVA_HOME="$java_home_candidate"
				export PATH="$JAVA_HOME/bin:$PATH"
				return
			fi
		done
		if java_home_candidate="$(/usr/libexec/java_home -v 17 2>/dev/null)" && [ -x "$java_home_candidate/bin/java" ]; then
			export JAVA_HOME="$java_home_candidate"
			export PATH="$JAVA_HOME/bin:$PATH"
			return
		fi
	fi

	echo "Android Gradle build requires Java 17-20; found ${java_version:-unknown}." >&2
	exit 1
}

case "$BUILD_MODE" in
	debug|--debug|-d)
		BUILD_MODE="debug"
		GRADLE_TASK="assembleDebug"
		OUTPUT_DIR="debug"
		;;
	release|--release|-r)
		BUILD_MODE="release"
		GRADLE_TASK="assembleRelease"
		OUTPUT_DIR="release"
		;;
	*)
		echo "Usage: $0 [debug|release]" >&2
		exit 1
		;;
esac

select_gradle_java

"$SCRIPT_DIR/build_lib_android.sh" "$BUILD_MODE"

cd "$SCRIPT_DIR/../../Projects/Android/Dora"
./gradlew "$GRADLE_TASK"

echo "Built APP in 'Projects/Android/Dora/app/build/outputs/apk/$OUTPUT_DIR'"
