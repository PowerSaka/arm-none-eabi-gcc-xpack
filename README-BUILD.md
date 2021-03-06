# How to build the xPack GNU Arm Embedded GCC binaries

## Introduction

This project includes the scripts and additional files required to
build and publish the
[xPack GNU Arm Embedded GCC](https://xpack.github.io/arm-none-eabi-gcc/) binaries.

It follows the official
[Arm](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm)
distribution, and it is planned to make a new release after each future
Arm release.

Currently the build procedure uses the _Source Invariant_ archive and
the configure options are the same as in the Arm build scripts.

The build scripts use the
[xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box),
a set of elaborate build environments based on a recent GCC (Docker containers
for GNU/Linux and Windows or a custom folder for MacOS).

There are two types of builds:

- **local/native builds**, which use the tools available on the
  host machine; generally the binaries do not run on a different system
  distribution/version; intended mostly for development purposes;
- **distribution builds**, which create the archives distributed as
  binaries; expected to run on most modern systems.

This page documents the distribution builds.

For native builds, see the `build-native.sh` script.

## Repository URLs

- `https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git` - the URL of the
  [xPack GNU Arm Embedded GCC](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack)
- `https://github.com/xpack-dev-tools/build-helper` - the URL of the
  xPack build helper, used as the `scripts/helper` submodule

The build scripts use Arm archives; occasionally, to avoid bugs, original
repositories are used:

- `git://sourceware.org/git/binutils-gdb.git`

## Branches

- `xpack` - the updated content, used during builds
- `xpack-develop` - the updated content, used during development
- `master` - empty, not used.

## Prerequisites

The prerequisites are common to all binary builds. Please follow the
instructions in the separate
[Prerequisites for building binaries](https://xpack.github.io/xbb/prerequisites/)
page and return when ready.

Note: Building the Arm binaries requires an Arm machine.

## Download the build scripts repo

The build scripts are available in the `scripts` folder of the
[`xpack-dev-tools/arm-none-eabi-gcc-xpack`](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack)
Git repo.

To download them, the following shortcut is available:

```console
$ curl --fail -L https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/raw/xpack/scripts/git-clone.sh | bash
```

This small script issues the following two commands:

```console
$ rm -rf ~/Downloads/arm-none-eabi-gcc-xpack.git; \
  git clone --recurse-submodules https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git \
  ~/Downloads/arm-none-eabi-gcc-xpack.git
```

> Note: the repository uses submodules; for a successful build it is
> mandatory to recurse the submodules.

For development purposes, there is a shortcut to clone the `xpack-develop`
branch:

```console
$ curl --fail -L https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/raw/xpack/scripts/git-clone-develop.sh | bash
```

which is a shortcut for:

```console
$ rm -rf ~/Downloads/arm-none-eabi-gcc-xpack.git; \
  git clone --recurse-submodules --branch xpack-develop https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git \
  ~/Downloads/arm-none-eabi-gcc-xpack.git
```

## The `Work` folder

The script creates a temporary build `Work/arm-none-eabi-gcc-${version}`
folder in the user home. Although not recommended, if for any reasons
you need to change the location of the `Work` folder,
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## Spaces in folder names

Due to the limitations of `make`, builds started in folders with
spaces in names are known to fail.

If on your system the work folder is in such a location, redefine it in a
folder without spaces and set the `WORK_FOLDER_PATH` variable before invoking
the script.

## Customizations

There are many other settings that can be redefined via
environment variables. If necessary,
place them in a file and pass it via `--env-file`. This file is
either passed to Docker or sourced to shell. The Docker syntax
**is not** identical to shell, so some files may
not be accepted by bash.

## Versioning

The version string is an extension to semver, the format looks like `10.2.1-1.1`.
It includes the three digits with the original GCC version, a fourth
digit with the Arm release, a fifth digit with the xPack release number.

When publishing on the **npmjs.com** server, a sixth digit is appended.

## Changes

Compared to the original Arm distribution, there should be no
functional changes.

The actual changes for each version are documented in the corresponding
release pages:

- https://xpack.github.io/arm-none-eabi-gcc/releases/

## How to build local/native binaries

### README-DEVELOP.md

The details on how to prepare the development environment for native build
are in the
[`README-DEVELOP.md`](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-DEVELOP.md) file.

## How to build distributions

## Build

Although it is perfectly possible to build all binaries in a single step
on a macOS system, due to Docker specifics, it is faster to build the
GNU/Linux and Windows binaries on a GNU/Linux system and the macOS binary
separately.

### Build the Intel GNU/Linux and Windows binaries

The current platform for Intel GNU/Linux and Windows production builds is a
Debian 10, running on an Intel NUC8i7BEH mini PC with 32 GB of RAM
and 512 GB of fast M.2 SSD. The machine name is `xbbi`.

```console
$ ssh xbbi
```

Before starting a multi-platform build, check if Docker is started:

```console
$ docker info
```

Eventually run the test image:

```console
$ docker run hello-world
```

Before running a build for the first time, it is recommended to preload the
docker images, since they are pretty large.

```console
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                              IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      i386-12.04-xbb-v3.2              fadc6405b606        2 days ago          4.55GB
ilegeul/ubuntu      amd64-12.04-xbb-v3.2             3aba264620ea        2 days ago          4.98GB
hello-world         latest                           bf756fb1ae65        5 months ago        13.3kB
```

It is also recommended to Remove unused Docker space. This is mostly useful
after failed builds, during development, when dangling images may be left
by Docker.

To check the content of a Docker image:

```console
$ docker run --interactive --tty ilegeul/ubuntu:amd64-12.04-xbb-v3.2
```

To remove unused files:

```console
$ docker system prune --force
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S arm
```

Run the development builds on the development machine (`wks`):

```console
$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh --develop --without-pdf --disable-tests --disable-multilib --linux64 --linux32 --win64 --win32
```

When ready, run the build on the production machine (`xbbi`):

```console
$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh --all
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r arm`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 5 hours later, the output of the build script is a set of 4 files and
their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/arm-none-eabi-gcc-*/deploy
total 682464
-rw-rw-r-- 1 ilg ilg 172441920 Oct 23 00:45 xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-x32.tar.gz
-rw-rw-r-- 1 ilg ilg       117 Oct 23 00:45 xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-x32.tar.gz.sha
-rw-rw-r-- 1 ilg ilg 169389142 Oct 22 22:17 xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-x64.tar.gz
-rw-rw-r-- 1 ilg ilg       117 Oct 22 22:17 xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-x64.tar.gz.sha
-rw-rw-r-- 1 ilg ilg 172415284 Oct 23 01:35 xpack-arm-none-eabi-gcc-10.2.1-1.1-win32-x32.zip
-rw-rw-r-- 1 ilg ilg       114 Oct 23 01:35 xpack-arm-none-eabi-gcc-10.2.1-1.1-win32-x32.zip.sha
-rw-rw-r-- 1 ilg ilg 184570818 Oct 22 23:04 xpack-arm-none-eabi-gcc-10.2.1-1.1-win32-x64.zip
-rw-rw-r-- 1 ilg ilg       114 Oct 22 23:04 xpack-arm-none-eabi-gcc-10.2.1-1.1-win32-x64.zip.sha
```

#### Build the Arm GNU/Linux binaries

The supported Arm architectures are:

- `armhf` for 32-bit devices
- `arm64` for 64-bit devices

The current platform for Arm GNU/Linux production builds is a
Debian 9, running on an ROCK Pi 4 SBC with 4 GB of RAM
and 256 GB of fast M.2 SSD. The machine name is `xbba`.

```console
$ ssh xbba
```

Before starting a multi-platform build, check if Docker is started:

```console
$ docker info
```

Before running a build for the first time, it is recommended to preload the
docker images, since they are pretty large.

```console
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                                IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      arm32v7-16.04-xbb-v3.2             b501ae18580a        27 hours ago        3.23GB
ilegeul/ubuntu      arm64v8-16.04-xbb-v3.2             db95609ffb69        37 hours ago        3.45GB
hello-world         latest                             a29f45ccde2a        5 months ago        9.14kB
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S arm
```

Run the development builds on the development machine (`wks`):

```console
$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh --develop --without-pdf --disable-tests --disable-multilib --arm32 --arm64
```

When ready, run the build on the production machine (`xbba`):

```console
$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh --all
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r arm`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 13-14 hours later, the output of the build script is a set of 2
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/arm-none-eabi-gcc-*/deploy
total 325316
-rw-rw-r-- 1 ilg ilg 168517506 Oct 23 01:08 xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm64.tar.gz
-rw-rw-r-- 1 ilg ilg       119 Oct 23 01:08 xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm64.tar.gz.sha
-rw-rw-r-- 1 ilg ilg 164591258 Oct 23 08:19 xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm.tar.gz
-rw-rw-r-- 1 ilg ilg       117 Oct 23 08:19 xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm.tar.gz.sha
```

### Build the macOS binaries

The current platform for macOS production builds is a macOS 10.10.5
running on a MacBook Pro with 32 GB of RAM and a fast SSD. The machine
name is `xbbm`.

```console
$ ssh xbbm
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S arm
```

Run the development builds on the development machine (`wks`):

```console
$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ caffeinate bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh --develop --without-pdf --disable-tests --disable-multilib --osx
```

When ready, run the build on the production machine (`xbbm`):

```console
$ sudo rm -rf ~/Work/arm-none-eabi-gcc-*
$ caffeinate bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh --osx
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r arm`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

In about 4 hours, the output of the build script is a compressed archive
and its SHA signature, created in the `deploy` folder:

```console
$ ls -l ~/Work/arm-none-eabi-gcc-*/deploy
total 321872
-rw-r--r--  1 ilg  staff  164794316 Oct 23 00:27 xpack-arm-none-eabi-gcc-10.2.1-1.1-darwin-x64.tar.gz
-rw-r--r--  1 ilg  staff        118 Oct 23 00:27 xpack-arm-none-eabi-gcc-10.2.1-1.1-darwin-x64.tar.gz.sha
```

## Subsequent runs

### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```
--linux32 --linux64
--arm32 --arm64
--win32 --win64
```

Please note that, due to the specifics of the GCC build process, the
Windows build requires the corresponding GNU/Linux build, so `--win32`
should be run after or together with `--linux32` and `--win64` after
or together with `--linux64`.

### clean

To remove most build files, use:

```console
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh clean
```

To also remove the repository and the output files, use:

```console
$ bash ~/Downloads/arm-none-eabi-gcc-xpack.git/scripts/build.sh cleanall
```

For production builds it is recommended to completely remove the build folder.

### --develop

For performance reasons, the actual build folders are internal to each
Docker run, and are not persistent. This gives the best speed, but has
the disadvantage that interrupted builds cannot be resumed.

For development builds, it is possible to define the build folders in the
host file system, and resume an interrupted build.

### --debug

For development builds, it is also possible to create everything
with `-g -O0` and be able to run debug sessions.

### --disable-multilib

For development builds, to save time, it is recommended to build the
toolchain without multilib.

### --jobs

By default, the build steps use all available cores. If, for any reason,
parallel builds fail, it is possible to reduce the load.

### Interrupted builds

The Docker scripts run with root privileges. This is generally not a
problem, since at the end of the script the output files are reassigned
to the actual user.

However, for an interrupted build, this step is skipped, and files in
the install folder will remain owned by root. Thus, before removing the
build folder, it might be necessary to run a recursive `chown`.

## Testing

A simple test is performed by the script at the end, by launching the
executables to check if all shared/dynamic libraries are correctly used.

For a true test you need to unpack the archive in a temporary location
(like `~/Downloads`) and then run the
program from there. For example on macOS the output should
look like:

```console
$ /Users/ilg/Downloads/xPacks/arm-none-eabi-gcc/10.2.1-1.1/bin/arm-none-eabi-gcc --version
arm-none-eabi-gcc (xPack GNU Arm Embedded GCC, 64-bit) 10.2.1 20170904 (release) [ARM/embedded-7-branch revision 255204]
```

## Travis tests

A multi-platform validation test for all binary archives can be performed
using Travis CI.

For details please see `tests/scripts/README.md`.

## Installed folders

After install, the package should create a structure like this (only the
first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/\@xpack-dev-tools/arm-none-eabi-gcc/10.2.1-1.1/.content/
/Users/ilg/Library/xPacks/\@xpack-dev-tools/arm-none-eabi-gcc/10.2.1-1.1/.content/
├── README.md
├── arm-none-eabi
│   ├── bin
│   ├── include
│   ├── lib
│   └── share
├── bin
│   ├── arm-none-eabi-addr2line
│   ├── arm-none-eabi-ar
│   ├── arm-none-eabi-as
│   ├── arm-none-eabi-c++
│   ├── arm-none-eabi-c++filt
│   ├── arm-none-eabi-cpp
│   ├── arm-none-eabi-elfedit
│   ├── arm-none-eabi-g++
│   ├── arm-none-eabi-gcc
│   ├── arm-none-eabi-gcc-10.2.1
│   ├── arm-none-eabi-gcc-ar
│   ├── arm-none-eabi-gcc-nm
│   ├── arm-none-eabi-gcc-ranlib
│   ├── arm-none-eabi-gcov
│   ├── arm-none-eabi-gcov-dump
│   ├── arm-none-eabi-gcov-tool
│   ├── arm-none-eabi-gdb
│   ├── arm-none-eabi-gdb-add-index
│   ├── arm-none-eabi-gdb-add-index-py3
│   ├── arm-none-eabi-gdb-py3
│   ├── arm-none-eabi-gprof
│   ├── arm-none-eabi-ld
│   ├── arm-none-eabi-ld.bfd
│   ├── arm-none-eabi-nm
│   ├── arm-none-eabi-objcopy
│   ├── arm-none-eabi-objdump
│   ├── arm-none-eabi-ranlib
│   ├── arm-none-eabi-readelf
│   ├── arm-none-eabi-size
│   ├── arm-none-eabi-strings
│   ├── arm-none-eabi-strip
│   ├── libcrypt.2.dylib
│   ├── libexpat.1.dylib
│   ├── libgcc_s.1.dylib
│   ├── libgmp.10.dylib
│   ├── libiconv.2.dylib
│   ├── libintl.8.dylib
│   ├── liblzma.5.dylib
│   ├── libmpfr.4.dylib
│   ├── libncurses.6.dylib
│   ├── libpython3.7m.dylib
│   ├── libstdc++.6.dylib
│   ├── libz.1.2.8.dylib
│   └── libz.1.dylib -> libz.1.2.8.dylib
├── distro-info
│   ├── CHANGELOG.md
│   ├── arm-readme.txt
│   ├── arm-release.txt
│   ├── patches
│   └── scripts
├── include
│   └── gdb
├── lib
│   ├── bfd-plugins
│   ├── gcc
│   ├── libcc1.0.so
│   └── libcc1.so -> libcc1.0.so
├── libexec
│   └── gcc
└── share
    ├── doc
    └── gcc-arm-none-eabi

19 directories, 50 files
```

No other files are installed in any system folders or other locations.

## Uninstall

The binaries are distributed as portable archives; thus they do not
need to run a setup and do not require an uninstall.

## Files cache

The XBB build scripts use a local cache such that files are downloaded only
during the first run, later runs being able to use the cached files.

However, occasionally some servers may not be available, and the builds
may fail.

The workaround is to manually download the files from an alternate
location (like
https://github.com/xpack-dev-tools/files-cache/tree/master/libs),
place them in the XBB cache (`Work/cache`) and restart the build.

## More build details

The build process is split into several scripts. The build starts on the
host, with `build.sh`, which runs `container-build.sh` several times,
once for each target, in one of the two docker containers. Both scripts
include several other helper scripts. The entire process is quite complex,
and an attempt to explain its functionality in a few words would not
be realistic. Thus, the authoritative source of details remains the source
code.
