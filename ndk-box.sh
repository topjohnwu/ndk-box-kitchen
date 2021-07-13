#!/usr/bin/env bash

function parse_parameters() {
    while ((${#})); do
        case ${1} in
            "--target")
                shift
                TARGET=${1}
                ;;
            "--src_path")
                shift
                SRC_PATH=${1}
                ;;
            "--ndk-box_dir")
                # pass the ndk-box-kitchen actual directory
                shift
                NDK_BOX_DIR=${1}
                ;;
        esac
        shift
    done
}

function progress() {
    echo -e "\n\033[44m${1}\033[0m\n"
}

function parse_kbuild() {
    # Load config into shell variables
    eval $(grep -o 'CONFIG[_A-Z0-9]* 1' include/autoconf.h | sed 's/ 1/=1/g')

    for KBUILD in $(find . -type f -name Kbuild); do
        DIR=${KBUILD#./}
        DIR=${DIR%/*}
        grep '^[^#].*\.o\b' $KBUILD | while read LINE; do
            FILE_LIST=${LINE#*+=}
            CONFIG=$(echo ${LINE%+=*} | grep -o '$(.*)' | cut -d\( -f2 | cut -d\) -f1)
            if eval [ -z \"$CONFIG\" -o \"\$$CONFIG\" = \"1\" ]; then
                for FILE in $(echo $FILE_LIST | grep -o '\S*\.o\b'); do
                    readlink -f "$DIR/$FILE" | sed -e "s:${CWD}/::" -e 's/.o$/.c \\/g'
                done
            fi
        done
    done
}

function generate_busybox_files() {

    progress "Generating configuration files for busybox"
    # Copy config and make config
    cp "${NDK_BOX_DIR}"/busybox.config .config
    yes n | make oldconfig >/dev/null 2>&1

    # Generate headers
    gcc applets/applet_tables.c -o applets/applet_tables
    applets/applet_tables include/applet_tables.h include/NUM_APPLETS.h
    gcc applets/usage.c -o applets/usage -Iinclude
    applets/usage_compressed include/usage_compressed.h applets
    scripts/mkconfigs include/bbconfigopts.h include/bbconfigopts_bz2.h
    scripts/generate_BUFSIZ.sh include/common_bufsiz.h
    srctree=${CWD} HOSTCC=gcc scripts/embedded_scripts include/embedded_scripts.h embed applets_sh

    progress "Generating Android_src.mk based on busybox configs"
    # Process Kbuild files
    echo "LOCAL_SRC_FILES := \\" >Android_src.mk
    parse_kbuild | sort -u >>Android_src.mk

    # Build Android.mk
    echo 'LOCAL_PATH := $(call my-dir)' >Android.mk
    cat Makefile | head -n 3 >>Android.mk
    cat "${NDK_BOX_DIR}"/busybox.mk >>Android.mk
}

function generate_toybox_files() {

    progress "Generating configuration files for toybox"
    cp "${NDK_BOX_DIR}"/toybox.config .config
    scripts/genconfig.sh
    export NOBUILD=1
    scripts/make.sh >/dev/null 2>&1

    progress "Generating Android_src.mk based on toybox configs"

    # Stolen from scripts/make.sh
    TOYFILES="$(sed -n 's/^CONFIG_\([^=]*\)=.*/\1/p' .config | xargs | tr ' [A-Z]' '|[a-z]')"
    TOYFILES="$(egrep -l "TOY[(]($TOYFILES)[ ,]" toys/*/*.c)"
    LIBFILES="$(ls lib/*.c)"

    echo "LOCAL_SRC_FILES := main.c \\" >Android_src.mk
    for SRC in $(echo $LIBFILES $TOYFILES | sort); do
        echo "$SRC \\" >>Android_src.mk
    done

    cp "${NDK_BOX_DIR}"/toybox.mk Android.mk
}

parse_parameters "${@}"
cd ${SRC_PATH}
CWD=$(pwd -P)
generate_${TARGET}_files
cd - >/dev/null 2>&1
