# ndk-box-kitchen

This repo is the kitchen used to create headers and Makefiles for building \*box with the command [`ndk-build`](https://developer.android.com/ndk/guides/ndk-build.html) in NDK. All scripts in this repo expect to run on Linux, however the generated code and Makefiles can be used on all NDK supported platforms.

## Download Sources

To build BusyBox, clone the following repos:

```
git clone https://git.busybox.net/busybox/
git clone https://github.com/SELinuxProject/selinux.git jni/selinux
git clone https://android.googlesource.com/platform/external/pcre jni/pcre
```

Currently, the script supports BusyBox version `1.33.1`, please checkout to the correct tags before running scripts

To build ToyBox, clone the following repo:

```
git clone https://github.com/landley/toybox.git
```

## How to use

```
root@kali:~/ndk-box-kitchen# python3 ndk-box.py -h
usage: ndk-box.py [-h] --target {busybox,toybox} [--patch]
                  [--generate] [--commit]

A manager for busybox and toybox.

required arguments:
  --target {busybox,toybox}
                        specify busybox or toybox as target to patch
                        and generate files for ndk-build

optional arguments:
  -h, --help            show this help message and exit
  --patch               apply busybox or toybox patches to the
                        absolute source of busybox or toybox
  --generate            generate required files for ndk-build in the
                        absolute source path of busybox or toybox
  --commit              git commit the patches and generated files
                        for ndk-build automatically
```

* requirements:
  * Linux Machine
  * Python-3.6 or Above
* git clone this repository.
* git clone busybox and its dependencies(selinux and pcre) or toybox inside this repository dir from
above mentioned sources to their mentioned path.
* use the script to generate necessary files for ndk-build.

`ndk-box.py` can handle busybox and toybox alone. if user passes necessary information to the script,
it will apply the patches, generate required makefiles and header files using `ndk-box.sh` and commit the changes
automatically.

`ndk-box.sh` should not be used alone. It is the helping script of orginal script `ndk-build.py`.

## Busybox

To apply patches:
```
python3 ndk-box.py --target busybox --patch
```

To generate required Makefiles and headers:
```
python3 ndk-box.py --target busybox --generate
```

All in One:
```
python3 ndk-box.py --target busybox --patch --generate --commit
```

## Toybox

To apply patches:
```
python3 ndk-box.py --target toybox --patch
```

To generate required Makefiles and headers:
```
python3 ndk-box.py --target toybox --generate
```

All in One:
```
python3 ndk-box.py --target toybox --patch --generate --commit
```

## Credits

All files in `busybox_patches` are directly copied from [osm0sis/android-busybox-ndk](https://github.com/osm0sis/android-busybox-ndk). Theses patches are required for a fully functioning BusyBox building with NDK + Bionic libc.
