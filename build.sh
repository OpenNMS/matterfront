#!/bin/bash -e

MYDIR=`dirname $0`
TOPDIR=`cd $MYDIR; pwd`

# Name of your app.
APP="opennms-chat"
# dist directory
DISTDIR="$TOPDIR/dist"
# The path of you app to sign.
APP_PATH="$DISTDIR/opennms-chat-darwin-x64/opennms-chat.app"
# The path to the location you want to put the signed package.
RESULT_PATH="/Users/ranger/Desktop/opennms-chat.pkg"
# The name of certificates you requested.
APP_KEY="Developer ID Application: The OpenNMS Group, Inc. (N7VNY4MNDW)"
INSTALLER_KEY="Developer ID Installer: The OpenNMS Group, Inc. (N7VNY4MNDW)"

FRAMEWORKS_PATH="$APP_PATH/Contents/Frameworks"

echo "* making sure dependencies are up-to-date"
npm install

echo "* cleaning $DISTDIR"
rm -rf "$DISTDIR"/*

echo "* building"
npm run build

echo "* signing Mach-O contents"
find "$FRAMEWORKS_PATH" -type f | while read FILE; do
	if [ `file "$FILE" 2>/dev/null | grep -c 'Mach-O'` -gt 0 ]; then
		codesign --deep -fs "$APP_KEY" --entitlements child.plist "$FILE"
	fi
done

echo "* signing other internals"
for FRAMEWORK in "$FRAMEWORKS_PATH"/*; do
	if [ -d "$FRAMEWORK"/Versions ]; then
		for FILE in "$FRAMEWORK"/Versions/*; do
			codesign --deep -fs "$APP_KEY" --entitlements child.plist "$FILE"
		done
	fi
	codesign --deep -fs "$APP_KEY" --entitlements child.plist "$FRAMEWORK"/
done

echo "* signing app bundle"
codesign  -fs "$APP_KEY" --entitlements parent.plist "$APP_PATH"

echo "* codesign verification"
codesign -vvvv -d "$APP_PATH"

echo "* spctl assess"
spctl --assess -vvvv "$APP_PATH"

echo "* building package"
productbuild --component "$APP_PATH" /Applications --sign "$INSTALLER_KEY" "$RESULT_PATH"
