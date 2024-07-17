# ndk-box-kitchen

This repo is the kitchen used to create headers and Makefiles for building BusyBox with the command [`ndk-build`](https://developer.android.com/ndk/guides/ndk-build.html) in NDK. Scripts in this repo expect to run on Linux, however the generated code and Makefiles can be used on all NDK supported platforms.

## Usage

Clone the following repos:

```
git clone https://git.busybox.net/busybox/
git clone https://android.googlesource.com/platform/external/selinux jni/selinux
git clone https://android.googlesource.com/platform/external/pcre jni/pcre
```

We currently support BusyBox version `1.36.1`, please checkout to the correct tags before running scripts

`./run.sh patch` to apply patches

`./run.sh generate` to generate required Makefiles and headers

`$NDK/ndk-build -j$(nproc)` to build the executables

`./run.sh archive` to archive all built artifacts into `busybox.zip`
