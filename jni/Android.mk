LOCAL_PATH := $(call my-dir)

# Define include paths for external.mk
LIBSELINUX := jni/selinux/libselinux/include
LIBPCRE2 := jni/pcre/include

# Uncomment to build BusyBox
include $(LOCAL_PATH)/../external.mk
include $(LOCAL_PATH)/../busybox/Android.mk

# Uncomment to build ToyBox
# include $(LOCAL_PATH)/../toybox/Android.mk
