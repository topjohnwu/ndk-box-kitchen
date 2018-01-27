# ndk-busybox-kitchen

This repo is the kitchen used to create headers and Makefiles for the busybox repo [ndk-busybox](https://github.com/topjohnwu/ndk-busybox), which is meant to build busybox with the `ndk-build` command included in the NDK package (more info [here](https://developer.android.com/ndk/guides/ndk-build.html)).

### Introduction

Busybox uses the same configuration system as the Linux kernel, thus requires additional setup and configuration before you can build from the sources. As a result, people compiling busybox for Android used to use their own toolchain or NDK's standalone toolchain to cross compile with the Makefile shipped in official BusyBox sources. However, setting up a cross compiling environment is quite confusing, and you have to reconfigure every time you switch to another target architecture. To make things even worse, it's not Windows friendly - you need additional POSIX Environment setup like Cygwin to even be possible to start. Of course those willing to go deep can create an automation script to do all the heavy jobs for you, but the solution isn't really that portable and simple to use. 

This makes me wonder, why not utilize the `ndk-build` command, which is a helper script included in NDK that supports easy cross compiling? So this project is born, using some tricks to make `ndk-build` be able to compile busybox. This is also integrated into [Magisk](https://github.com/topjohnwu/Magisk)'s building system.

### Platforms

The generation script (`gen_makefile.sh`) is meant to run on Unix operating systems. It works out of the box on Linux, but requires some additional setup on macOS:
> The script depends on GNU core utilities and GNU sed. In order to install them on macOS, install via [homebrew](https://brew.sh/) with `brew install coreutils gnu-sed`. These tools by default are not available in `$PATH`, remember to call the following command before running `gen_makefile.sh`: `export PATH=$(brew --prefix coreutils)/libexec/gnubin:$(brew --prefix gnu-sed)/libexec/gnubin:$PATH`  

**Don't be confused**, the generated headers and Makefiles can be used on any platform that support NDK: Linux, macOS, and Windows, the **generation** itself is what requires a Unix system.

### Preparation

Before you can run the script, first you need to clone and setup busybox sources (place it in `busybox`). The official sources can be downloaded with `git clone git://busybox.net/busybox.git`. Next, you will need a series of patches to make things work properly: cherry-pick all commits started with `[PATCH]` from [ndk-busybox](https://github.com/topjohnwu/ndk-busybox). All of these patches are tweaked/modified from [osm0sis/android-busybox-ndk](https://github.com/osm0sis/android-busybox-ndk), full credits to him.

### Building BusyBox

This repo also ships with the minimal environment to compile busybox. If you simply just want to build busybox, you can just clone my prebuilt source with `git clone https://github.com/topjohnwu/ndk-busybox busybox busybox`. After the folder `busybox` is properly setup, call `<ndk-path>/ndk-build`, to start the build.
