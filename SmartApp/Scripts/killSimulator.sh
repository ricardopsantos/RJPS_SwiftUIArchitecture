if [ -n "$USER" ]; then
	if [ "$USER" == "runner" ]; then
		echo "AppCenter build."
		exit 0
	else
		xcrun simctl shutdown all
	fi
else
	echo "\$USER not set."
fi


