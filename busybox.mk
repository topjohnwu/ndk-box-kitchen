EXTRAVERSION = -Magisk
BB_VER = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)

include $(CLEAR_VARS)
LOCAL_MODULE := busybox
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_STATIC_LIBRARIES := libselinux
LOCAL_DISABLE_FORMAT_STRING_CHECKS := true
LOCAL_LDFLAGS := -static -Wl,--wrap=realpath -Wl,--wrap=rename -Wl,--wrap=renameat
LOCAL_CFLAGS := \
-w -include include/autoconf.h -D__USE_BSD -D__USE_GNU \
-DBB_VER=\"$(BB_VER)\" -DBB_BT=AUTOCONF_TIMESTAMP \
-Wno-implicit-function-declaration

LOCAL_SRC_FILES := \
