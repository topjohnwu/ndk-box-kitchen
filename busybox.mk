EXTRAVERSION = -topjohnwu
BB_VER = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)

include $(CLEAR_VARS)
LOCAL_MODULE := busybox

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
include $(LOCAL_PATH)/Android_src.mk

LOCAL_DISABLE_FORMAT_STRING_CHECKS := true
LOCAL_LDFLAGS := -static
LOCAL_CFLAGS := \
-w -include include/autoconf.h -D__USE_BSD \
-DBB_VER=\"$(BB_VER)\" -DBB_BT=AUTOCONF_TIMESTAMP \
-D"wait3(status, option, rusage)=wait4(-1, status, option, rusage)"

include $(BUILD_EXECUTABLE)
