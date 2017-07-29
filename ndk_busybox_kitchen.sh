#!/usr/bin/env bash

##################################################
#
# NDK Busybox Kitchen
# by @topjohnwu
#
##################################################

BBPATH=busybox
PATCHPATH=patch
COMMIT=false
CLEAN=false
UPDATE=false
GENERATE=false
BRANCH=1_27_stable
CONFIG=$PATCHPATH/osm0sis-full-64.config

usage() {
  echo "NDK BusyBox Kitchen - Auto Generate Files for ndk-build BusyBox"
  echo ""
  echo "Download BusyBox and apply patches for NDK, fetch the correct config,"
  echo "then finally generate all header files and Android.mk for NDK building"
  echo "Once all tasks are finished, simply call \"ndk-build\" to build busybox"
  echo ""
  echo "$0 [OPTIONS] [ACTION] [BRANCH]"
  echo ""
  echo "Options:"
  echo "   -h          Show this help message"
  echo "   -c <file>   Use provided file as config instead of default"
  echo "   --commit    Commit all the changes to branch \"android-ndk\""
  echo ""
  echo "Actions:"
  echo "   --cleanup   Remove everything and start from scratch"
  echo "   --update    Update current repos from upstream"
  echo "   --generate  Generate proper headers and Android.mk"
  echo ""
  echo "For the first two actions, the busybox repo will be checked-out to [BRANCH]"
  echo "If [BRANCH] is not specified, the default branch is \"$BRANCH\""
  echo ""
  exit
}

progress() {
  echo -e "\n\033[44m${1}\033[0m\n"
}

parse_kbuild() {
  for KBUILD in `find . -type f -name Kbuild`; do
    DIR=${KBUILD#./}
    DIR=${DIR%/*}
    cat $KBUILD | grep '^[^#].*\.o\b' | while read LINE; do
      FILE_LIST=${LINE#*+=}
      CONFIG=`echo ${LINE%+=*} | grep -o '$(.*)' | cut -d\( -f2 | cut -d\) -f1`
      eval [ -z \"$CONFIG\" -o \"\$$CONFIG\" = \"1\" ] && INCL=true || INCL=false
      if $INCL; then
        for FILE in `echo $FILE_LIST | grep -o '\b[a-zA-Z0-9_\-]*\.o\b'`; do
          echo $DIR/$FILE | sed 's/.o$/.c \\/g'
        done
      fi
    done
  done
}

# Commandline parsing
until [ $# -eq 0 ]; do
  if [ $1  = "-h" ]; then usage;
  elif [ $1 = "-c" ]; then shift; CONFIG=$1;
  elif [ $1 = "--commit" ]; then COMMIT=true;
  elif [ $1 = "--clean" ]; then CLEAN=true;
  elif [ $1 = "--update" ]; then UPDATE=true;
  elif [ $1 = "--generate" ]; then GENERATE=true;
  else BRANCH=$1; fi
  shift
done

$CLEAN || $UPDATE || $GENERATE || usage

# Wiping out current folders
$CLEAN && rm -rf $BBPATH $PATCHPATH 2>/dev/null

if [ ! -d $BBPATH ]; then
  progress "Downloading BusyBox source"
  git clone git://busybox.net/busybox.git $BBPATH
  UPDATE=true
fi

if [ ! -d $PATCHPATH ]; then
  progress "Downloading patches from osm0sis/android-busybox-ndk"
  git clone https://github.com/osm0sis/android-busybox-ndk.git $PATCHPATH
  UPDATE=true
fi

if $UPDATE; then
  progress "Updating sources from git"

  # Patches
  cd $PATCHPATH
  git reset --hard && git clean -dfx
  git pull

  # BusyBox
  cd ../$BBPATH
  git reset --hard && git clean -dfx
  git fetch
  git checkout $BRANCH
  git pull

  if $COMMIT; then
    # New branch
    git branch -D android-ndk 2>/dev/null
    git checkout -b android-ndk
  fi

  # Run patches from osm0sis's repo
  progress "Applying patches from osm0sis/android-busybox-ndk"
  for p in `head -n1 ../$PATCHPATH/osm0sis-full-64.config | grep -o 'patches .*$' | cut -c9- | sed -e 's/,//g' -e 's/*//g'`; do
    for k in ../$PATCHPATH/patches/$p*.patch; do
      # Exclude some patches
      echo $k | grep -E "000|001|002|012-a|012-c" >/dev/null 2>&1 && continue
      echo -e "\033[44mPatching with ${k##*/}\033[0m"
      patch -p1 -i $k
    done
  done

  if $COMMIT; then
    # A commit for osm0sis patches
    sleep 1
    git add .
    git commit -m "Apply patches from osm0sis/android-busybox-ndk"
  fi

  progress "Applying patches for ndk-build to work properly"
  patch -p1 -i ../ndk_build.patch

  if $COMMIT; then
    # A commit for ndk-build patches
    sleep 1
    git add .
    git commit -m "Apply patches for ndk-build to work properly"
  fi

  find . \( -type f -name "*.orig" -o -name "*.reg" \) -exec rm -f {} \;

  cd ../
  GENERATE=true
fi

if $GENERATE; then
  # Copy config and make config
  progress "Generating configuration files"
  cp $CONFIG $BBPATH/.config
  cd $BBPATH
  yes n | make oldconfig 2>/dev/null

  # Generate headers
  gcc applets/applet_tables.c -o applets/applet_tables
  applets/applet_tables include/applet_tables.h include/NUM_APPLETS.h
  gcc applets/usage.c -o applets/usage -Iinclude
  applets/usage_compressed include/usage_compressed.h applets
  scripts/mkconfigs include/bbconfigopts.h include/bbconfigopts_bz2.h
  scripts/generate_BUFSIZ.sh include/common_bufsiz.h

  progress "Generating Android_src.mk based on configs"

  # Load config into shell variables
  eval `grep -o 'CONFIG[_A-Z0-9]* 1' include/autoconf.h | sed 's/ 1/=1/g'`

  # Process Kbuild files
  echo "LOCAL_SRC_FILES := \\" > Android_src.mk
  parse_kbuild | sort -u >> Android_src.mk

  cp ../busybox.mk Android.mk 2>/dev/null

  if $COMMIT; then
    git add -f include
    git add *.mk
    git commit -m "Add generated files for ndk-build"
  fi

fi
