OS X RAM Disk
================

Need really fast Java IDE or browser? Then keep reading.

This app will create a [RAM disk](http://en.wikipedia.org/wiki/RAM_drive) in OS-X with specified size to
store apps cache in RAM, which is known as SSD optimization - reducing disk IO or making browsing the web and
programming using IntelliJ more enjoyable.

Supported apps (you can add yours):

* [IntelliJ Idea 14] (https://www.jetbrains.com/idea/download/)
* [Google Chrome] (https://support.google.com/chrome/answer/95346?hl=en)
* [Google Canary] (https://www.google.com/chrome/browser/canary.html)
* Safari
* iTunes
* [Android studio] (http://developer.android.com/sdk/index.html)
* [WebShtorm] (https://www.jetbrains.com/webstorm/)
* [Clion] (https://www.jetbrains.com/clion/)
* your_app_goes_here

The IntelliJ Idea is really fast after this. Be warned that for large projects you will
need to have larger RAM Disk. I don't have exact numbers, sorry.

If you observing performance degradation - revise how much memory you are using and may be adding more can help.
By default script will create disk of 1/4 of your RAM .
If you need to change the size - edit startupRAMDiskandCacheMover.sh

Have something to discuss? 
[![Join the chat at https://gitter.im/zafarella/OSX-RAMDisk](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/zafarella/OSX-RAMDisk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
Compatibility
============
Works on
* MAC OS X 10.10.2 Yosemite

> Note that you have to re-run the script in order to get the ram disk back.
> Currently it doe not place it on startup.
>

Give it a try before installing
===============================
```bash
$ curl -o startupRAMDiskandCacheMover.sh https://raw.githubusercontent.com/zafarella/OSX-RAMDisk/master/Contents/MacOS/startupRAMDiskandCacheMover.sh
chmod +x startupRAMDiskandCacheMover.sh
./startupRAMDiskandCacheMover.sh
```
or
```
git clone git@github.com:zafarella/OSX-RAMDisk.git
OSX-RAMDisk/Contents/MacOS/startupRAMDiskandCacheMover.sh
```

Installation
============
Do not use it now - the startup script does not work yet - work in progress
```
git clone git@github.com:zafarella/OSX-RAMDisk.git
cd OSX-RAMDisk
make install
```

Manual Installation
------------------
```
cp OSXRamDisk.plist ~/Library/LaunchAgents
cp startupRAMDiskandCacheMover.sh /usr/local/bin
# note - it will close Chrome, safari idea
/usr/local/bin/startupRAMDiskandCacheMover.sh
```

Uninstall
============
Run `make uninstall`
or manually do following

Close the chrome, idea or any other application you configured to use ram disk.
```
   rm /usr/local/bin/startupRAMDiskandCacheMover.sh
   launchctl unload -w ~/Library/LaunchAgents/OSXRamDisk.plist
   rm ~/Library/LaunchAgents/OSXRamDisk.plist
```
