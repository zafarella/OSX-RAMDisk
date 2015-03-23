install:
	[ ! -d /usr/local/bin/ ] && mkdir -p /usr/local/bin
	cp createRAMDiskandMoveCaches.sh /usr/local/bin/
	cp ./OSXRamDisk.plist ~/Library/LaunchAgents/
	[ -f ~/Library/LaunchAgents/OSXRamDisk.plist ] && launchctl load -w ~/Library/LaunchAgents/OSXRamDisk.plist

uninstall:
	[ -f ~/Library/LaunchAgents/OSXRamDisk.plist ] && launchctl unload -w ~/Library/LaunchAgents/OSXRamDisk.plist
	[ -f /usr/local/bin/createRAMDiskandMoveCaches.sh ] && rm -f /usr/local/bin/createRAMDiskandMoveCaches.sh
	[ -f ~/Library/LaunchAgents/OSXRamDisk.plist ] && rm -f ~/Library/LaunchAgents/OSXRamDisk.plist
	[ -h ~/Library/Caches/Google/Chrome/Default ] && bash -c "rm -f ~/Library/Caches/Google/Chrome/Default; mkdir ~/Library/Caches/Google/Chrome/Default"
	./uninstall.sh
