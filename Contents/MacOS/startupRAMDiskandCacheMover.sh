#!/usr/bin/env bash -x

#
# Copyright Zafar Khaydarov
#
# This script creates a RAM disk in macOS and moves the apps caches into it,
# increasing the performance of those apps. Performance gain is very significant
# for browsers, and especially for IDEs like IntelliJ Idea.
#
# There are risks. If the RAM disk becomes full, performance will degrade
# significantly and a huge amount of paging will happen.
#
# USE AT YOUR OWN RISK. PLEASE NOTE IT WILL NOT CHECK FOR CORRUPTED FILES.
# IF YOUR RAM IS BROKEN - DO NOT USE IT.
#

# The amount of RAM you want to allocate for the RAM disk. Sizes are:
# 1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192.
# By default the script will use 1/4 of your RAM.

ramfs_size_mb=$(sysctl hw.memsize | awk '{print $2;}')
ramfs_size_mb=$((${ramfs_size_mb} / 1024 / 1024 / 4))

mount_point=/Users/${USER}/ramdisk
ramfs_size_sectors=$((${ramfs_size_mb}*1024*1024/512))
ramdisk_device=`hdid -nomount ram://${ramfs_size_sectors}`
USERRAMDISK="$mount_point"

MSG_MOVE_CACHE=". Do you want me to move its cache?"
MSG_PROMPT_FOUND="I found "

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
# Closes passed as arg app by name.
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
    # Create the RAM disk and mounts it.
    umount -f ${mount_point}
    newfs_hfs -v 'ramdisk' ${ramdisk_device}
    mkdir -p ${mount_point}
    mount -o noatime -t hfs ${ramdisk_device} ${mount_point}

    echo "created RAM disk."
    # Hide the RAM disk - it'll be annoying sitting in finder.
    # Comment this out should you need it.
    hide_ramdisk
    echo "RAM disk hidden"
}

# Adds rsync to be executed every 5 min. for the current user.
add_rsync_to_cron()
{
    #TODO - Fix me.
    crontab -l | { cat; echo "5 * * * * rsync"; } | crontab -
}

# Open an application.
open_app()
{
    osascript -e "tell app \"${1}\" to activate"
}

# Hide ramdisk directory.
hide_ramdisk()
{
    /usr/bin/chflags hidden ${mount_point}
}

# Checks that we have
# all required utils before proceeding.
check_requirements()
{
    hash rsync 2>/dev/null || { echo >&2 "No rsync has been found.  Aborting. If you use brew install using: 'brew install rsync'"; exit 1; }
    hash newfs_hfs 2>/dev/null || { echo >&2 "No newfs_hfs has been found.  Aborting."; exit 1; }
}

#
# Check for existence of the string in a file.
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
# Check for flag indicating the app's cache has been moved.
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
# Creates flag indicating the app's cache has been moved.
#
make_flag()
{
    echo "" > /Applications/OSX-RAMDisk.app/${1}
}

# ------------------------------------------------------
# Applications whos cache is to be moved to RAM.
# Add yours at the end.
# -------------------------------------------------------

#
# Google Chrome Cache
#
move_chrome_cache()
{
    if [ -d "/Users/${USER}/Library/Caches/Google/Chrome" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'Chrome'${MSG_MOVE_CACHE} ; then
            close_app "Google Chrome"
            /bin/mkdir -p /tmp/Google/Chrome
            /bin/mv ~/Library/Caches/Google/Chrome/* /tmp/Google/Chrome/
            /bin/mkdir -pv ${USERRAMDISK}/Google/Chrome/Default
            /bin/mv /tmp/Google/Chrome/ ${USERRAMDISK}/Google/Chrome
            /bin/ln -v -s -f ${USERRAMDISK}/Google/Chrome/Default ~/Library/Caches/Google/Chrome/Default
            /bin/rm -rf /tmp/Google/Chrome
            # Create a flag for next run that we moved the cache.
            echo "";
        fi
    else
        echo "No Google Chrome folder has been found. Skipping."
    fi
}

#
# Chrome Canary Cache
#
move_chrome_chanary_cache()
{
    if [ -d "/Users/${USER}/Library/Caches/Google/Chrome Canary" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'Chrome Canary'${MSG_MOVE_CACHE} ; then
            close_app "Chrome Canary"
            /bin/rm -rf ~/Library/Caches/Google/Chrome\ Canary/*
            /bin/mkdir -p ${USERRAMDISK}/Google/Chrome\ Canary/Default
            /bin/ln -s ${USERRAMDISK}/Google/Chrome\ Canary/Default ~/Library/Caches/Google/Chrome\ Canary/Default
        fi
    fi
}

#
# Safari Cache
#
move_safari_cache()
{
    if [ -d "/Users/${USER}/Library/Caches/com.apple.Safari" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'Safari'${MSG_MOVE_CACHE}; then
            close_app "Safari"
            /bin/rm -rf ~/Library/Caches/com.apple.Safari
            /bin/mkdir -p ${USERRAMDISK}/Apple/Safari
            /bin/ln -s ${USERRAMDISK}/Apple/Safari ~/Library/Caches/com.apple.Safari
            echo "Moved Safari cache."
        fi
    fi
}

#
# iTunes Cache
#
move_itunes_cache()
{
    if [ -d "/Users/${USER}/Library/Caches/com.apple.iTunes" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'iTunes'${MSG_MOVE_CACHE} ; then
            close_app "iTunes"
            /bin/rm -rf /Users/${USER}/Library/Caches/com.apple.iTunes
            /bin/mkdir -pv ${USERRAMDISK}/Apple/iTunes
            /bin/ln -v -s ${USERRAMDISK}/Apple/iTunes ~/Library/Caches/com.apple.iTunes
            echo "Moved iTunes cache."
        fi
    fi
}

#
# Intellij Idea
#
# FIXME - what if the version is not 14?
move_idea_cache()
{
    if [ -d "/Applications/IntelliJ IDEA 14.app" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'IntelliJ IDEA 14'${MSG_MOVE_CACHE} ; then
            close_app "IntelliJ Idea 14"
            # Make a backup of config, we will need it when uninstalling.
            cp -f /Applications/IntelliJ\ IDEA\ 14.app/Contents/bin/idea.properties /Applications/IntelliJ\ IDEA\ 14.app/Contents/bin/idea.properties.back
            # Idea will create those dirs.
            echo "idea.system.path=${USERRAMDISK}/Idea" >> /Applications/IntelliJ\ IDEA\ 14.app/Contents/bin/idea.properties
            echo "idea.log.path=${USERRAMDISK}/Idea/logs" >> /Applications/IntelliJ\ IDEA\ 14.app/Contents/bin/idea.properties
            echo "Moved IntelliJ cache."
        fi
    fi


    if [ -d "/Applications/IntelliJ IDEA 15.app" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'IntelliJ IDEA 15'${MSG_MOVE_CACHE} ; then
            close_app "IntelliJ Idea 15"
            # Make a backup of config, we will need it when uninstalling.
            cp -f /Applications/IntelliJ\ IDEA\ 15.app/Contents/bin/idea.properties /Applications/IntelliJ\ IDEA\ 15.app/Contents/bin/idea.properties.back
            # Idea will create those dirs.
            echo "idea.system.path=${USERRAMDISK}/Idea" >> /Applications/IntelliJ\ IDEA\ 15.app/Contents/bin/idea.properties
            echo "idea.log.path=${USERRAMDISK}/Idea/logs" >> /Applications/IntelliJ\ IDEA\ 15.app/Contents/bin/idea.properties
            echo "Moved IntelliJ 15 cache."
        fi
    fi
}

#
# IntelliJ Idea Community Edition
#
move_ideace_cache()
{
    # TODO - Add support for other versions.
    if [ -d "/Applications/IntelliJ IDEA 14 CE.app" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'IntelliJ IDEA CE 14'${MSG_MOVE_CACHE} ; then
            close_app "IntelliJ Idea 14 CE"
            # make a backup of config, we will need it when uninstalling
            cp -f /Applications/IntelliJ\ IDEA\ 14\ CE.app/Contents/bin/idea.properties /Applications/IntelliJ\ IDEA\ 14\ CE.app/Contents/bin/idea.properties.back
            # Idea will create those dirs
            echo "idea.system.path=${USERRAMDISK}/Idea" >> /Applications/IntelliJ\ IDEA\ 14\ CE.app/Contents/bin/idea.properties
            echo "idea.log.path=${USERRAMDISK}/Idea/logs" >> /Applications/IntelliJ\ IDEA\ 14\ CE.app/Contents/bin/idea.properties
            echo "Moved IntelliJ cache."
        fi
    fi

    if [ -d "/Applications/IntelliJ IDEA 15 CE.app" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'IntelliJ IDEA CE 15'${MSG_MOVE_CACHE} ; then
            close_app "IntelliJ Idea 14 CE"
            # Make a backup of config, we will need it when uninstalling.
            cp -f /Applications/IntelliJ\ IDEA\ 15\ CE.app/Contents/bin/idea.properties /Applications/IntelliJ\ IDEA\ 15\ CE.app/Contents/bin/idea.properties.back
            # Idea will create those dirs.
            echo "idea.system.path=${USERRAMDISK}/Idea" >> /Applications/IntelliJ\ IDEA\ 15\ CE.app/Contents/bin/idea.properties
            echo "idea.log.path=${USERRAMDISK}/Idea/logs" >> /Applications/IntelliJ\ IDEA\ 15\ CE.app/Contents/bin/idea.properties
            echo "Moved IntelliJ cache."
        fi
    fi
}

#
# Creates IntelliJ intermediate output folder
# to be used by Java/Scala projects.
#
create_intermediate_folder_for_intellij_projects()
{
    [ -d /Volumes/ramdisk/${USER}/compileroutput ] || mkdir -p /Volumes/ramdisk/${USER}/compileroutput
}

#
# Android Studio
#
move_android_studio_cache()
{
    if [ -d "/Applications/Android Studio.app" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'Android Studio'${MSG_MOVE_CACHE} ; then
            echo "moving Android Studio cache";
            close_app "Android Studio"
            # Make a backup of config - will need it when uninstalling.
            cp -f /Applications/Android\ Studio.app/Contents/bin/idea.properties /Applications/Android\ Studio.app/Contents/bin/idea.properties.back
            # Idea will create those dirs.
            echo "idea.system.path=${USERRAMDISK}/AndroidStudio" >> /Applications/Android\ Studio.app/Contents/bin/idea.properties
            echo "idea.log.path=${USERRAMDISK}/AndroidStudio/logs" >> /Applications/Android\ Studio.app/Contents/bin/idea.properties
            echo "Moved Android cache."
        fi
    fi
}

#
# CLion
#
move_clion_cache()
{
    if [ -d "/Applications/Clion.app" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'Clion'${MSG_MOVE_CACHE} ; then
            echo "moving Clion cache";
            close_app "Clion"
            # Make a backup of config - will need it when uninstalling.
            cp -f /Applications/Clion.app/Contents/bin/idea.properties /Applications/Clion.app/Contents/bin/idea.properties.back
            # Idea will create those dirs.
            echo "idea.system.path=${USERRAMDISK}/Clion" >> /Applications/Clion.app/Contents/bin/idea.properties
            echo "idea.log.path=${USERRAMDISK}/Clion/logs" >> /Applications/Clion.app/Contents/bin/idea.properties
            echo "Moved Clion cache."
        fi
    fi
}

#
# AppCode - iOS
#
move_appcode_cache()
{
    if [ -d "/Applications/AppCode.app" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'AppCode'${MSG_MOVE_CACHE} ; then
            echo "moving AppCode cache";
            close_app "AppCode"
            # make a backup of config - will need it when uninstalling
            cp -f /Applications/AppCode.app/Contents/bin/idea.properties /Applications/AppCode.app/Contents/bin/idea.properties.back
            # Need to create those dirs
            echo "idea.system.path=${USERRAMDISK}/AppCode" >> /Applications/AppCode.app/Contents/bin/idea.properties
            echo "idea.log.path=${USERRAMDISK}/AppCode/logs" >> /Applications/AppCode.app/Contents/bin/idea.properties
            mkdir -p ${USERRAMDISK}/AppCode/logs
            echo "Moved AppCode cache."
        fi
    fi
}

#
# Xcode - iOS
#
move_xcode_cache()
{
    if [ -d "/Applications/Xcode.app" ]; then
        if user_response ${MSG_PROMT_FOUND} 'Xcode'${MSG_MOVE_CACHE} ; then
            echo "moving XCode cache..";
            echo "deleting ~/Library/Developer/Xcode/DerivedData"

            /bin/rm -rvf ~/Library/Developer/Xcode/DerivedData
            /bin/mkdir -pv ${USERRAMDISK}/Apple/Xcode
            /bin/ln -v -s ${USERRAMDISK}/Apple/Xcode /Users/${USER}/Library/Developer/Xcode/DerivedData
            echo "Moved Xcode cache."
        fi
    fi
}

#
# PhpStorm
#
move_phpstorm_cache()
{
    if [ -d "/Applications/PhpStorm.app" ]; then
        if user_response ${MSG_PROMPT_FOUND} 'PhpStorm'${MSG_MOVE_CACHE} ; then
            echo "moving PHPStorm cache";
            close_app "PhpStorm"
            # make a backup of config - will need it when uninstalling
            cp -f /Applications/PhpStorm.app/Contents/bin/idea.properties /Applications/PhpStorm.app/Contents/bin/idea.properties.back
            # Idea will create those dirs
            echo "idea.system.path=${USERRAMDISK}/PhpStorm" >> /Applications/PhpStorm.app/Contents/bin/idea.properties
            echo "idea.log.path=${USERRAMDISK}/PhpStorm/logs" >> /Applications/PhpStorm.app/Contents/bin/idea.properties
            echo "Moved PhpStorm cache."
        fi
    fi
}

# -----------------------------------------------------------------------------------
# The entry point.
# -----------------------------------------------------------------------------------
main() {
    check_requirements
    # Create the RAM disk.
    mk_ram_disk
    # Move the caches.
    move_chrome_cache
    move_safari_cache
    move_idea_cache
    move_ideace_cache
    # Create intermediate folder for IntelliJ projects output.
    create_intermediate_folder_for_intellij_projects
    move_itunes_cache
    move_android_studio_cache
    move_clion_cache
    move_appcode_cache
    move_xcode_cache
    move_phpstorm_cache
    echo "echo use \"${mount_point}/compileroutput\" for intelliJ project output directory."
    echo "All good - I have done my job. Your apps should fly."
}

main "$@"
# -----------------------------------------------------------------------------------
