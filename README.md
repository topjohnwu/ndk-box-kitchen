# ndk-box-kitchen

This repo is the kitchen used to create headers and Makefiles for building \*box with the command [`ndk-build`](https://developer.android.com/ndk/guides/ndk-build.html) in NDK. All scripts in this repo expect to run on Linux, however the generated code and Makefiles can be used on all NDK supported platforms.

## Download Sources

To build BusyBox, clone the following repos:

```
git clone https://git.busybox.net/busybox/
git clone https://github.com/SELinuxProject/selinux.git jni/selinux
git clone https://android.googlesource.com/platform/external/pcre jni/pcre
```

Currently, the script supports BusyBox version `1.31.1`, please checkout to the correct tags before running scripts

To build ToyBox, clone the following repo:

```
git clone https://github.com/landley/toybox.git
```

## Busybox

`./busybox.sh patch` to apply patches

`./busybox.sh generate` to generate required Makefiles and headers

## Toybox

`./toybox.sh patch` to apply patches

`./toybox.sh generate` to generate required Makefiles and headers

## Credits

All files in `busybox_patches` are directly copied from [osm0sis/android-busybox-ndk](https://github.com/osm0sis/android-busybox-ndk). Theses patches are required for a fully functioning BusyBox building with NDK + Bionic libc.
