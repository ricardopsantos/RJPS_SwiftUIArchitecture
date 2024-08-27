execute() {
	rm -rf "Pods/TspEdgeIOVSDK/TspEdgeIOVSDK.framework"
	cp -f "Frameworks-PreCompiled/TspEdgeIOVSDK.zip" "Pods/TspEdgeIOVSDK"
	cd Pods/TspEdgeIOVSDK
	unzip TspEdgeIOVSDK.zip
	rm TspEdgeIOVSDK.zip
}

if [ -n "$USER" ]; then
	if [ "$USER" == "runner" ]; then
		echo "AppCenter build. Not running copy frameworks."
		exit 0
	else
		execute
	fi
else
	echo "\$USER not set. Not running swiftlint copy frameworks."
fi


