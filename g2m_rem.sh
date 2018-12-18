#   ____     _____     __  __           _   _             
#  / ___| __|_   _|__ |  \/  | ___  ___| |_(_)_ __   __ _ 
# | |  _ / _ \| |/ _ \| |\/| |/ _ \/ _ \ __| | '_ \ / _` |
# | |_| | (_) | | (_) | |  | |  __/  __/ |_| | | | | (_| |
#  \____|\___/|_|\___/|_|  |_|\___|\___|\__|_|_| |_|\__, |
#                                                   |___/ 
#  ____                                _   _____           _ 
# |  _ \ ___ _ __ ___   _____   ____ _| | |_   _|__   ___ | |
# | |_) / _ \ '_ ` _ \ / _ \ \ / / _` | |   | |/ _ \ / _ \| |
# |  _ <  __/ | | | | | (_) \ V / (_| | |   | | (_) | (_) | |
# |_| \_\___|_| |_| |_|\___/ \_/ \__,_|_|   |_|\___/ \___/|_|
#                                                            
# Version 1.5.0
# Created by Brian A Carter and Kyle Halversen
#
## Functions
# Creates a local function to move to trash instead of permanently deleting.
function trash () {
  local path
  for path in "$@"; do
    # ignore any arguments
    if [[ "$path" = -* ]]; then :
    else
      # remove trailing slash
      local mindtrailingslash=${path%/}
      # remove preceding directory path
      local dst=${mindtrailingslash##*/}
      # append the time if necessary
      while [ -e ~/.Trash/"$dst" ]; do
        dst="`expr "$dst" : '\(.*\)\.[^.]*'` `date +%H-%M-%S`.`expr "$dst" : '.*\.\([^.]*\)'`"
      done
      mv "$path" ~/.Trash/"$dst" && echo "$path moved to trash" || echo "Failed to trash $path"
    fi
  done
}
#
## Log File Comment
logcomment() {
	echo "" >> $logFile
	echo "### $@ ###" >> $logFile
}
#
## Establish a log file
logFile=~/Library/Logs/com.logmein.g2mremoval.log
echo "GoToMeeting Removal Tool .:. Log started $(date)\n" > $logFile
#
## Delete GoToMeeting Plists
logcomment "Delete Plists"
gtmPlists=(
    com.citrixonline.GoToMeeting
    com.citrixonline.G2MUpdate
    com.citrixonline.mac.WebDeploymentApp
    com.logmein.GoToMeeting
    com.logmein.gotomeeting
    com.logmein.G2MUpdate
    com.logmein.COLVideo
       )
for gtmPlist in "${gtmPlists[@]}"
do
	defaults delete "$gtmPlist" >> $logFile 2>&1
	defaults -currentHost delete "$gtmPlist" >> $logFile 2>&1
	trash ~/Library/Preferences/"$gtmPlist"*.plist >> $logFile 2>&1
	trash ~/Library/Preferences/ByHost/"$gtmPlist"*.plist >> $logFile 2>&1
done
#
## Delete GoToMeeting apps from Desktop, system Applications, and user Applications.
gtmLocations=(
    "/Applications"
    "$HOME/Applications"
    "$HOME/Desktop"
    "$HOME/Library/Application Support/CitrixOnline"
    "$HOME/Library/Application Support/LogMeInInc"
             )
for gtmLoc in "${gtmLocations[@]}"
do
	trash "$gtmLoc"/GoToMeeting* >> $logFile 2>&1
done
#
## Delete Launcher
gtoLocations=(
    "$HOME/Library/Application Support/CitrixOnline/CitrixOnlineLauncher.app"
    "$HOME/Library/Application Support/GoToOpener*"
    "$HOME/Applications/CitrixOnline/CitrixOnlineLauncher.app"
    "$HOME/Applications/CitrixOnline/LaunchLock*"
    "$HOME/Applications/Utilities/CitrixOnline"
    "$HOME/Library/com.logmein.GoToMeeting.G2MAIRUploader.plist"
    "$HOME/Library/com.logmein.GoToMeeting.G2MUpdate.plist"
             )
for gtoLoc in "${gtoLocations[@]}"; do
    trash "$gtoLoc" >> $logFile 2>&1
done
#
## Clean Cookies
gtmCookies=(
    "$HOME/Library/Cookies/com.logmein.GoToMeeting-Scheduler-for-Mac.binarycookies"
    "$HOME/Library/Cookies/com.logmein.GoToMeeting.binarycookies"
    )
for gtmCookie in "${gtmCookies[@]}"; do
    trash "$gtmCookie" >> $logFile 2>&1
done
#
## Clean Caches
gtmCache=(
    com.citrixonline.GoToMeeting
    com.citrixonline.mac.WebDeploymentApp
    com.logmein.gotomeeting
    com.logmein.GoToMeeting
         )
for gotoCache in "${gtmCache[@]}"; do
    trash "$HOME"/Library/Caches/"$gotoCache"* >> $logFile 2>&1
done
#
## Clean up Dock
#!/bin/bash

pb="/usr/libexec/PlistBuddy "
dockPlist="$HOME/Library/Preferences/com.apple.dock.plist"

for index in {0..50} ; do
    $pb $dockPlist -c "Print persistent-apps:$index:tile-data:file-label:" >/dev/null 2>&1
        if [[ "$?" == 0 ]]; then
            appName=$($pb $dockPlist -c "Print persistent-apps:$index:tile-data:file-label:")
            if [[ "$appName" == GoToMeeting* ]] ; then
                $pb $dockPlist -c "Delete persistent-apps:$index"
                osascript -e 'delay 1' -e 'tell Application "Dock"' -e 'quit' -e 'end tell' -e 'delay 1'
            fi
        fi
done
