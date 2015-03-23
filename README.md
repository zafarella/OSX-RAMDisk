OS X RAM Disk
================

This app will create a [RAM disk](http://en.wikipedia.org/wiki/RAM_drive) with specified size to 
store apps cache in RAM, which is known as SSD optimization - reducing disk IO or making browsing the web and
programming using IntelliJ more enjoyable.

Supported apps (you can add yours):

1. IntelliJ Idea 14

1. Google Chrome

1. Google Canary

1. Safari

1. iTunes

1. todo: Android studio 

1. your_app_goes_here

The IntelliJ Idea is really fast after this. Be warned that for large projects you will need to have larger RAM Disk.

If you observing performance degradation - revise how much memory you are using and may be adding more can help.
By default script will create 4Gb RAM disk. If you need to change the size - edit createRAMDiskandMoveCaches.sh

Compatibility
============
Works on
* MAC OS X 10.10.2 Yosemite

Give it a try before installing
===============================
```
git clone git@github.com:zafarella/OSX-RAMDisk.git
./createRAMDiskandMoveCaches.sh
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
   rm ~/Library/LaunchAgents/com.alanthing.ChromeRamDisk.plist
```

TODO
===========
Add support for persisting files in HDD (rsync) and restoring on system startup - will save a lot of time

