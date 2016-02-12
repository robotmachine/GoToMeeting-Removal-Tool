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
# Version 1.3.0
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

## Log File Comment
logcomment() {
	echo "" >> $logFile
	echo "### $@ ###" >> $logFile
}
 
## Establish a log file
logFile=~/Library/Logs/com.citrixonline.g2mremoval.log
echo "GoToMeeting Removal Tool .:. Log started $(date)\n" > $logFile
 
## Delete GoToMeeting Plists
logcomment "Delete Plists"
Plists=("com.citrixonline.GoToMeeting" "com.citrixonline.G2MUpdate" "com.citrixonline.mac.WebDeploymentApp")
for x in "${Plists[@]}"
do
	defaults delete "$x" >> $logFile 2>&1
	defaults -currentHost delete "$x" >> $logFile 2>&1
	trash ~/Library/Preferences/"$x" >> $logFile 2>&1
done
 
## Delete GoToMeeting apps from Desktop, system Applications, and user Applications.
logcomment "Trash Using MDFind"
locations=("/Applications" "~/Applications" "~/Desktop")
mdfind -name GoToMeeting | grep -v Removal | grep -v ShareFile | grep .app | xargs -I {} trash {} >> $logFile 2>&1
trash /Applications/GoToMeeting* >> $logFile 2>&1
trash ~/Applications/GoToMeeting* >> $logFile 2>&1
trash ~/Desktop/GoToMeeting* >> $logFile 2>&1
trash ~/Library/Application\ Support/CitrixOnline/GoToMeeting* >> $logFile 2>&1
 
## Delete Launcher
trash ~/Library/Application\ Support/CitrixOnline/CitrixOnlineLauncher.app >> $logFile 2>&1
