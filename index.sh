#!/usr/bin/env sh

RELEASE="19.4-Matrix";

while getopts "h?r:" opt; do
  case "$opt" in
    h|\?)
      exit 0
      ;;
    r) RELEASE=$OPTARG
      ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

if [ ! -d kodi ]; then
  echo "Cloning KODI";
  git clone https://github.com/xbmc/xbmc.git -b "$RELEASE" kodi;
else
  echo "Resetting code"
  git -C kodi reset --hard
  echo "Updating KODI"
  git -C kodi fetch --prune
  echo "Changing release"
  git -C kodi checkout "$RELEASE"
fi

echo "Applying patches"

for FILE in "$PWD"/patches/*.patch
do
  echo "Applying $FILE"
  git -C kodi apply "$FILE" || exit 1
done

SKIN_LOCATION="/sdcard/Android/data/org.xbmc.kodi/files/.kodi/addons/skin.estuary"

adb shell rm -r $SKIN_LOCATION

echo "Uploading files"
adb push "$PWD"/kodi/addons/skin.estuary $SKIN_LOCATION
