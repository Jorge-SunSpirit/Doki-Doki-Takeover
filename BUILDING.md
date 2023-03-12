# Build instructions

## Installing the required programs

You will need to install [Haxe](https://haxe.org/download/), [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/), and [Git](https://git-scm.com/downloads).

You also need to install additional libraries. Currently, these are the things that are required:

```text
haxelib install firetongue
haxelib install hxCodec
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git tentools https://github.com/TentaRJ/tentools
haxelib git systools https://github.com/haya3218/systools
```

Recompiling systools is required as it's different from the one that comes with HaxeFlixel.

```text
haxelib run lime rebuild systools [windows, mac, linux]
```

If you're on Linux, you'll need to grab a specific commit of hxCodec instead and install libvlc.

```text
sudo apt-get install libvlc-dev
sudo apt-get install libvlccore-dev
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec 15d950b103603a976e0e2d5004c8717b4eecc945
```

You should have everything ready for compiling the game; follow the guide below to continue!

## Compiling the game

**NOTE: If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling.**

To compile it on your desktop (Windows, Mac, Linux) it is a bit more involved, as you ***MUST*** be on the platform that you are compiling for.

Once the compilation finishes, Doki Doki Takeover will boot up automatically.

### Windows Compilation

For Windows, you need to install [Visual Studio Community 2022](https://visualstudio.microsoft.com/downloads/). Don't click on any of the options to install workloads. Instead, go to the individual components tab and search up the following:

- MSVC v143 - VS 2022 C++ x64/x86 build tools (Latest)
- Windows 10 SDK (10.0.19041.0)

Once that is done you can open up a command line in the project's directory and run `lime test windows -debug`.

### Linux Compilation

For Linux, you can either compile via WSL 2.0 (Windows) or on a Linux kernel.

You only need to open a terminal in the project directory and run `lime test linux -debug`.

### Mac Compilation

For Mac, install Xcode and `lime test mac -debug` *should* just work; if not, the internet surely has a guide on how to compile Haxe stuff for Mac.
