#!/bin/bash

clear

displayCompilerInfo() {
    printf "\n"
    echo -n "### Current Compiler"
    printf "\n"
    eval xcrun swift -version
    eval xcode-select --print-path
}

build() {
    xcodebuild build -project SmartApp.xcodeproj -scheme "SmartApp Dev" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
}

openSimulator() {

    # Close all open simulators
	killall "Simulator"

    sleep 1

    # Open the iOS simulator
	open -a Simulator && xcrun simctl boot 'iPhone 15 Pro'

    # Wait a few seconds to ensure the simulator is fully opened
    sleep 5

    # List all simulators and extract the ID of the booted simulator
    BOOTED_SIMULATOR_ID=$(xcrun simctl list | grep -m1 '(Booted)' | awk -F '[()]' '{print $2}')

    # Check if a booted simulator was found
    if [ -n "$BOOTED_SIMULATOR_ID" ]; then
        echo "Booted Simulator ID: $BOOTED_SIMULATOR_ID"
    else
        echo "No booted simulator found."
    fi
}

test() {
    local simulator_id=$1
    if [ -n "$simulator_id" ]; then
        xcodebuild clean test -project SmartApp.xcodeproj -scheme "SmartApp Dev" -destination "id=$simulator_id" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
    else
        echo "No simulator ID provided."
    fi
}

################################################################################

printf "\n"

echo "### Build"
echo " [1] : Build"
echo " [2] : Skip (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) build ;;
    * ) echo "Ignored...." ;;
esac

printf "\n"

echo "### Test"
echo " [1] : Test"
echo " [2] : Skip (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) 
        openSimulator
        test $BOOTED_SIMULATOR_ID ;;
    * ) echo "Ignored...." ;;
esac
