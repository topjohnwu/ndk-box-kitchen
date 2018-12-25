# ndk-box-kitchen

This repo is the kitchen used to create headers and Makefiles for building \*box with the command `ndk-build` in NDK (more info [here](https://developer.android.com/ndk/guides/ndk-build.html)).

You have to clone sources of \*box to the current directory and checkout to your desired tag before running the scripts here.

## Busybox
Building busybox requires an excessive amount of source code patching, and Makefiles are extremely difficult to create.

`./busybox.sh patch` to apply required patches

`./busybox.sh generate` to generate required Makefiles and headers


## Toybox
Toybox is used in AOSP, so it is much easier to compile using NDK.

`./toybox.sh patch` to apply required patches

`./toybox.sh generate` to generate required Makefiles and headers
