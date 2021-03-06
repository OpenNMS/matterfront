#!/bin/bash -e

MYDIR=`dirname $0`
TOPDIR=`cd $MYDIR; pwd`
DISTDIR="$TOPDIR/dist"
APP="opennms-chat"
APP_PATH="$DISTDIR/opennms-chat-darwin-x64/opennms-chat.app"
RESULT_PATH="$HOME/Desktop/opennms-chat.pkg"

INSTALLER_KEY="Developer ID Installer: The OpenNMS Group, Inc. (N7VNY4MNDW)"

echo "* making sure dependencies are up-to-date"
npm install

echo "* cleaning $DISTDIR"
sudo rm -rf "$DISTDIR"/*

echo "* building"
npm run build

echo "* creating dist archive(s)"
pushd dist
	for dir in opennms-chat-darwin* opennms-chat-win32*; do
		zip -9 -r $dir.zip $dir
	done
	for dir in opennms-chat-linux*; do
		tar -cvzf $dir.tar.gz $dir
	done
	rsync -avzr --progress *.zip *.tar.gz ranger@www.opennms.org:/var/www/sites/opennms.org/site/www/mattermost/
popd dist

