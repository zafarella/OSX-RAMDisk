#!/usr/bin/env bash -x

# Copyright Zafar Khaydarov
#
# This is about to create a RAM disk in OS X and move the apps caches into it
# to increase performance of those apps. Performance gain is very significant,
# particularly for browsers and especially for IDEs like IntelliJ Idea.
#
# Drawbacks and risks are that if RAM disk becomes full - performance will degrade
# significantly - huge amount of paging will happen.
#
# USE AT YOUR OWN RISK. PLEASE NOTE IT WILL NOT CHECK FOR CORRUPTED FILES
# IF YOUR RAM IS BROKEN - DO NOT USE IT.
#

# The RAM amount you want to allocate for RAM disk. One of
# 1024 2048 3072 4096 5120 6144 7168 8192
# By default will use 1/4 of your RAM

ramfs_size_mb=$(sysctl hw.memsize | awk '{print $2;}')
ramfs_size_mb=$((${ramfs_size_mb} / 1024 / 1024 / 4))

mount_point=/Volumes/ramdisk
ramfs_size_sectors=$((${ramfs_size_mb}*1024*1024/512))
ramdisk_device=`hdid -nomount ram://${ramfs_size_sectors}`
USERRAMDISK="$mount_point/${USER}"

#
# Checks for the user response.
#
user_response()
{
    echo -ne $@ "[Y/n]  "
    read -r response

    case ${response} in
        [yY][eE][sS]|[yY]|"")
            true
            ;;
        [nN][oO]|[nN])
            false
            ;;
        *)
            user_response $@
            ;;
    esac
}

#
# Closes passed as arg app by name
#
close_app()
{
    osascript -e "quit app \"${1}\""
}

#
# Creates RAM Disk.
#
mk_ram_disk()
{
    # unmount if exists the RAM disk and mounts if doesn't
    umount -f ${mount_point}
    newfs_hfs -v 'ramdisk' ${ramdisk_device}
    mkdir -p ${mount_point}
    mount -o noatime -t hfs ${ramdisk_device} ${mount_point}

    echo "created RAM disk."
    # Hide RAM disk - we don't really need it to be annoiyng in finder.
    # comment out should you need it.
    hide_ramdisk
    echo "RAM disk hidden"
}

# adds rsync to be executed each 5 min for current user
add_rsync_to_cron()
{
    #todo fixme
    crontab -l | { cat; echo "5 * * * * rsync"; } | crontab -
}

# Open an application
open_app()
{
    osascript -e "tell app \"${1}\" to activate"
}

# Hide RamDisk directory
hide_ramdisk()
{
    /usr/bin/chflags hidden ${mount_point}
}

# Checks that we have
# all required utils before proceeding
check_requirements()
{
    hash rsync 2>/dev/null || { echo >&2 "No rsync has been found.  Aborting. If you use brew install using: 'brew install rsync'"; exit 1; }
    hash newfs_hfs 2>/dev/null || { echo >&2 "No newfs_hfs has been found.  Aborting."; exit 1; }
}

#
# Check existence of the string in a file.
#
check_string_in_file()
{
    if  grep "${1}" "${2}" == 0; then
        return 0;
    else
        return 1;
    fi
}

#
# Check for the flag
#
check_for_flag()
{
    if [ -e ${1} ] ; then
        return 0;
    else
        return 1;
    fi
}

#
# Creates flag indicating the apps cache has been moved.
#
make_flag()
{
    echo "" > /Applications/OSX-RAMDisk.app/${1}
}

# ------------------------------------------------------
# Applications, which needs the cache to be moved to RAM
# Add yours at the end.
# -------------------------------------------------------

#
# Google Chrome Cache
#
. apps/google-chrome

#
# Chrome Canary Cache
#
. apps/chrome-canary

#
# Safari Cache
#
. /apps/safari

#
# iTunes Cache
#
. /apps/itunes

#
# Intellij Idea
#
. /apps/intellij-14

#
# Intellij Idea Community Edition
#
. /apps/intellij-idea-ce

#
# Android Studio
#
. /apps/android-studio

#
# Clion
#
. /apps/clion

#
# AppCode
#
. /apps/appcode


# -----------------------------------------------------------------------------------
# The entry point
# -----------------------------------------------------------------------------------
main() {
    check_requirements
    # and create our RAM disk
    mk_ram_disk
    # move the caches
    move_chrome_cache
    move_safari_cache
    move_idea_cache
    move_ideace_cache
    move_itunes_cache
    move_android_studio_cache
    move_clion_cache
    move_appcode_cache
    echo "All good - I have done my job. Your apps should fly."
}

main "$@"
# -----------------------------------------------------------------------------------
