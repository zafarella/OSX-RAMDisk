OS X RAM Disk
================

This app will create a [RAM disk](http://en.wikipedia.org/wiki/RAM_drive) with specified size to 
store apps cache in RAM, which is known as SSD optimization - reducing disk IO or making browsing the web and
programming using IntelliJ more enjoyable.

Supported apps (you can add yours):

* IntelliJ Idea 14
* Google Chrome
* Google Canary
* Safari
* iTunes
* todo: Android studio 
* your_app_goes_here

The IntelliJ Idea is really fast after this. Be warned that for large projects you will need to have larger RAM Disk. I don't have exact numbers, sorry.

If you observing performance degradation - revise how much memory you are using and may be adding more can help.
By default script will create 4Gb RAM disk. If you need to change the size - edit createRAMDiskandMoveCaches.sh

Compatibility
============
Works on
* MAC OS X 10.10.2 Yosemite

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
./startupRAMDiskandCacheMover.sh
```

Installation
============
```
git clone git@github.com:zafarella/OSX-RAMDisk.git
cd OSX-RAMDisk
make install
```

Manual Installation
------------------
```
cp OSXRamDisk.plist ~/Library/LaunchAgents
cp createRAMDiskandMoveCaches.sh /usr/local/bin
# note - it will close Chrome, safari idea
/usr/local/bin/createRAMDiskandMoveCaches.sh
```

Uninstall
============
Run `make uninstall`
or manually do following

Close the chrome, idea or any other application you configured to use ram disk.
```
   rm /usr/local/bin/ChromeRamDisk.sh
   launchctl unload -w ~/Library/LaunchAgents/OSXRamDisk.plist 
   rm ~/Library/LaunchAgents/OSXRamDisk.plist
```

TODO
===========
Add support for persisting files in HDD (rsync) and restoring on system startup - will save a lot of time



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/zafarella/osx-ramdisk/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

