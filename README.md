# ndk-box-kitchen

This repo is the kitchen used to create headers and Makefiles for building BusyBox with the command [`ndk-build`](https://developer.android.com/ndk/guides/ndk-build.html) in NDK. Scripts in this repo expect to run on Linux, however the generated code and Makefiles can be used on all NDK supported platforms.

## Download Sources

Clone the following repos:

```
git clone https://git.busybox.net/busybox/
git clone https://android.googlesource.com/platform/external/selinux jni/selinux
git clone https://android.googlesource.com/platform/external/pcre jni/pcre
```

Currently, the script supports BusyBox version `1.36.1`, please checkout to the correct tags before running scripts

## Busybox

`./run.sh patch` to apply patches

`./run.sh generate` to generate required Makefiles and headers

## Credits

Some files in `patches` are modified from [osm0sis/android-busybox-ndk](https://github.com/osm0sis/android-busybox-ndk).
