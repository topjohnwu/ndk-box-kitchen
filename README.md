# ndk-busybox-kitchen

This repo is the kitchen used to create and update the pre-generated busybox repo [ndk-busybox](https://github.com/topjohnwu/ndk-busybox), which is meant to be built with the `ndk-build` command included in the NDK package (more info [here](https://developer.android.com/ndk/guides/ndk-build.html)).

### Introduction

The busybox uses the same configuration system as the Linux kernel, thus requires additional setup and configuration before you can build from the sources. As a result, people compiling busybox for Android used to use their own toolchain or NDK's standalone toolchain to cross compile with the Makefile shipped in official BusyBox sources. However, cross compiling requires setting up the environment for your specific device, re-doing configuration for each target architecture, and finally it's not Windows friendly - you need to install POSIX Environment like Cygwin to setup and compile. Of course those willing to go deep can create an automation script to do all the heavy jobs for you, but the solution isn't really that portable and simple to use. Most importantly, that setup process doesn't fit in the build process I created for [Magisk](https://github.com/topjohnwu/Magisk). As a result, this repo is born!

### Platforms

The script is meant to run on Unix operating systems. On Linux, it works out of the box; on macOS, which I personally use as daily driver, requires additional setup.  
Install [homebrew](https://brew.sh/), and install GNU utilities using `brew install coreutils gnu-sed`. Before you call the script, make sure to make the GNU tools in `PATH` by calling  
`export PATH=$(brew --prefix coreutils)/libexec/gnubin:$(brew --prefix gnu-sed)/libexec/gnubin:$PATH`  
After these commands, the script should work just like it is in Linux environments.

**Not to be confused**, the generated result can be used on any platform that support NDK: Linux, macOS, and Windows. It's just the header/Makefile generation that requires Unix OS to work, which is what the script in this repo does.

### Brief Explanation

This project is inspired by [osm0sis/android-busybox-ndk](https://github.com/osm0sis/android-busybox-ndk), and heavily depends on the patches and the config file in the repo. The script `ndk_busybox_kitchen.sh` will download BusyBox, download `osm0sis/android-busybox-ndk`, apply patches for NDK, fetch the correct config, then finally generates all header files and Android.mk for NDK building.

### Building BusyBox

This repo also ships with the minimal environment to compile busybox. Once you have properly run `ndk_busybox_kitchen.sh`, the folder `busybox` should be ready for compilation. If you simply just want to build busybox using this repo but don't want / cannot (e.g. you're on Windows) run the script, you can also clone my prebuilt source with `git clone https://github.com/topjohnwu/ndk-busybox busybox`.

After the folder `busybox` is properly setup, simply call `<ndk-path>/ndk-build`, then BusyBox should build graciously :)
