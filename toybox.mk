LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := toybox
include $(LOCAL_PATH)/Android_src.mk

LOCAL_CFLAGS := \
	-Wno-char-subscripts \
	-Wno-gnu-variable-sized-type-not-at-end \
	-Wno-missing-field-initializers \
	-Wno-sign-compare \
	-Wno-string-plus-int \
	-Wno-unused-parameter \
	-funsigned-char \
	-ffunction-sections \
	-fdata-sections \
	-fno-asynchronous-unwind-tables
LOCAL_LDFLAGS := -lz -static

include $(BUILD_EXECUTABLE)
