#!/bin/bash

clear


displayCompilerInfo() {
	printf "\n"
	echo -n "### Current Compiler"
	printf "\n"
	eval xcrun swift -version
	eval xcode-select --print-path
}

################################################################################

echo "### Brew"
echo " [1] : Install"
echo " [2] : Update"
echo " [3] : Skip (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ;;
    [2] ) eval brew update ;;
   *) echo "Ignored...."
;;
esac

################################################################################

#printf "\n"

#echo "### CocoaPods"
#echo " [1] : Install"
#echo " [2] : Skip (Default)"
#echo -n "Option? "
#read option
#case $option in
#    [1] ) sudo gem install cocoapods ;;
#   *) echo "Ignored...."
#;;
#esac

################################################################################

printf "\n"

echo "### Swiftlint"
echo " [1] : Install"
echo " [2] : Skip (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) brew install swiftlint ;;
   *) echo "Ignored...."
;;
esac

################################################################################

printf "\n"

echo "### Swiftformat"
echo " [1] : Install"
echo " [2] : Skip (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) brew install swiftformat ;;
   *) echo "Ignored...."
;;
esac

################################################################################

printf "\n"

echo "### Xcodegen"
echo " [1] : Install"
echo " [2] : Upgrade"
echo " [3] : Skip (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) brew install xcodegen ;;
    [2] ) brew upgrade xcodegen ;;
   *) echo "Ignored...."
;;
esac

################################################################################

displayCompilerInfo

printf "\n"

################################################################################

echo "### Kill Xcode?"
echo " [1] : No"
echo " [2] : Yes (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) echo "Ignored...." ;;
   *) killall Xcode
;;
esac

################################################################################

printf "\n\n"

echo "### Clean DerivedData?"
echo " [1] : Yes"
echo " [2] : No (Default)"
echo -n "Option? "
read option
case $option in
    [1] ) rm -rf ~/Library/Developer/Xcode/DerivedData/* ;;
   *) echo "Ignored...."
;;
esac

################################################################################

printf "\n"

echo "### Run XcodeGen?"
echo " [1] : Yes (Default)"
echo " [2] : No"
echo -n "Option? "
read option
case $option in
    [1] )xcodegen -s ./XcodeGen/SmartApp.yml -p ./ ;;
    [2] ) echo "Ignored...." ;;
   *) xcodegen -s ./XcodeGen/SmartApp.yml -p ./ 
;;
esac

################################################################################

printf "\n"

#echo "Instaling pods...."
#pod cache clean --all 
#pod install
#pod update

################################################################################

echo "Generating graphviz...."
xcodegen dump --spec ./XcodeGen/SmartApp.yml --type graphviz --file ./_Documents/Graph.viz
xcodegen dump --spec ./XcodeGen/SmartApp.yml --type json --file ./_Documents/Graph.json

################################################################################

echo ""
echo "↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ WARNING ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓"
echo "↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ WARNING ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓"
echo ""
echo " Dont forget to:"
echo "  - For SmartApp target: Remove Info.plist from target Membership!!"
echo "  - For SmartAppUnitTests target: Set Host Application to SmartApp"
echo ""
echo "↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ WARNING ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑"
echo "↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ WARNING ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑"
echo ""
echo " ╔═══════════════════════╗"
echo " ║ Done! You're all set! ║"
echo " ╚═══════════════════════╝"

#open SmartApp.xcworkspace
open SmartApp.xcodeproj
