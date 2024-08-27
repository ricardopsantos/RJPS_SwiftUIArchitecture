#!/bin/bash

export PATH="$PATH:/opt/homebrew/bin"

executeSwiftlint() {
	if which swiftlint >/dev/null; then
		#swiftlint --quiet
		swiftlint --config .swiftlint.yml
		exit 0
	else
		echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    exit -1
	fi
}

if [ -n "$USER" ]; then
	if [ "$USER" == "runner" ]; then
		echo "AppCenter build. Ignored."
		exit 0
	else
		executeSwiftlint;
	fi
else
	echo "\$USER not set. Ignored."
fi


