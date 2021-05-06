EXTRAVERSION = -Magisk
BB_VER = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)

include $(CLEAR_VARS)
LOCAL_MODULE := busybox
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_STATIC_LIBRARIES := libselinux

include $(LOCAL_PATH)/Android_src.mk

LOCAL_DISABLE_FORMAT_STRING_CHECKS := true
LOCAL_LDFLAGS := -static
LOCAL_CFLAGS := \
-w -include include/autoconf.h -D__USE_BSD \
-DBB_VER=\"$(BB_VER)\" -DBB_BT=AUTOCONF_TIMESTAMP

ifeq ($(OS),Windows_NT)
LOCAL_SHORT_COMMANDS := true
endif

include $(BUILD_EXECUTABLE)
