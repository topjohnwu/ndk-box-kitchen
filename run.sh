#!/usr/bin/env bash

BUSYBOX_TAG='1_34_1'

progress() {
  echo -e "\n\033[44m${1}\033[0m\n"
}

parse_kbuild() {
  # Load config into shell variables
  eval `grep -o 'CONFIG[_A-Z0-9]* 1' include/autoconf.h | sed 's/ 1/=1/g'`

  for KBUILD in `find . -type f -name Kbuild`; do
    DIR=${KBUILD#./}
    DIR=${DIR%/*}
    grep '^[^#].*\.o\b' $KBUILD | while read LINE; do
      FILE_LIST=${LINE#*+=}
      CONFIG=`echo ${LINE%+=*} | grep -o '$(.*)' | cut -d\( -f2 | cut -d\) -f1`
      if eval [ -z \"$CONFIG\" -o \"\$$CONFIG\" = \"1\" ]; then
        for FILE in `echo $FILE_LIST | grep -o '\S*\.o\b'`; do
          readlink -f $DIR/$FILE | sed -e "s:${CWD}/::" -e 's/.o$/.c \\/g'
        done
      fi
    done
  done
}

generate_files() {
  # Copy config and make config
  progress "Generating configuration files"
  cp ../busybox.config .config
  yes n | make oldconfig >/dev/null 2>&1

  # Generate headers
  gcc applets/applet_tables.c -o applets/applet_tables
  applets/applet_tables include/applet_tables.h include/NUM_APPLETS.h
  gcc applets/usage.c -o applets/usage -Iinclude
  applets/usage_compressed include/usage_compressed.h applets
  scripts/mkconfigs include/bbconfigopts.h include/bbconfigopts_bz2.h
  scripts/generate_BUFSIZ.sh include/common_bufsiz.h
  srctree=$CWD HOSTCC=gcc scripts/embedded_scripts include/embedded_scripts.h embed applets_sh

  progress "Generating Android.mk based on configs"

  # Build Android.mk
  echo 'LOCAL_PATH := $(call my-dir)' > Android.mk
  cat Makefile | head -n 3 >> Android.mk
  cat ../busybox.mk >> Android.mk
  parse_kbuild | sort -u >> Android.mk
  echo -e '\ninclude $(BUILD_EXECUTABLE)' >> Android.mk

  if $COMMIT; then
    progress "Commit headers and Makefiles"
    git add -f include/*.h
    git add *.mk
    git commit -m "Add generated files for ndk-build" -m "Auto generated by ndk-box-kitchen"
  fi
}

apply_patches() {
  for p in ../patches/*; do
    if ! git am -3 < $p; then
      # Force use fuzzy patch
      patch -p1 < $p
      git add .
      git am --continue
    fi
  done
}

create_patches() {
  git format-patch ${BUSYBOX_TAG}..HEAD -o ../patches.new
  rm -rf ../patches
  mv ../patches.new ../patches
}

if [ ! -d busybox ]; then
  progress "Please clone busybox, checkout to desired tag, apply patches, then run this script"
  exit 1
fi

cd busybox
CWD=`pwd -P`

case "$1" in
  generate )
    [ "$2" = "--commit" ] && COMMIT=true || COMMIT=false
    generate_files
    ;;
  patch )
    apply_patches
    ;;
  create )
    create_patches
    ;;
  * )
    echo "Usage:"
    echo "$0 patch"
    echo "   Apply patches to busybox"
    echo "$0 create"
    echo "   Create patch files from busybox"
    echo "$0 generate [--commit]"
    echo "   Generate Makefiles"
    ;;
esac

cd ..
