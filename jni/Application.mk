APP_ABI := armeabi-v7a arm64-v8a x86 x86_64 riscv64
APP_PLATFORM := android-35
APP_CFLAGS := -Wall -Oz -fomit-frame-pointer -flto
# Disable all security features
APP_CFLAGS += -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-stack-protector -U_FORTIFY_SOURCE
APP_LDFLAGS := -flto -Wl,--icf=all
APP_SUPPORT_FLEXIBLE_PAGE_SIZES := true

ifeq ($(OS),Windows_NT)
APP_SHORT_COMMANDS := true
endif
