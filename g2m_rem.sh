# Created by Brian A Carter and Kyle Halversen
#
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
      mv "$path" ~/.Trash/"$dst"
    fi
  done
}
#
## Make sure GoToMeeting and GoToMeeting Recording Manager are quit
AppNames=("\"GoToMeeting\"" "\"GoToMeeting Recording Manager\"")
for x in "${AppNames[@]}"
do
	osascript -e "quit app ${x}"
done
#
## Delete GoToMeeting Plists
Plists=("com.citrixonline.GoToMeeting" "com.citrixonline.G2MUpdate" "com.citrixonline.mac.WebDeploymentApp")
for x in "${Plists[@]}"
do
	defaults delete "$x" >/dev/null 2>&1 || echo
	defaults -currentHost delete "$x" >/dev/null 2>&1 || echo
done
#
## Delete GoToMeeting apps from Desktop, system Applications, and user Applications.
mdfind -name GoToMeeting | grep -v Removal | grep -v ShareFile | grep .app | xargs -I {} trash {} >/dev/null 2>&1 || echo
trash /Applications/GoToMeeting* >/dev/null 2>&1 || echo
trash ~/Applications/GoToMeeting* >/dev/null 2>&1 || echo
trash ~/Desktop/GoToMeeting* >/dev/null 2>&1 || echo
trash ~/Library/Application\ Support/CitrixOnline/GoToMeeting* >/dev/null 2>&1 || echo
#
## Delete Launcher
trash ~/Library/Application\ Support/CitrixOnline/CitrixOnlineLauncher.app >/dev/null 2>&1 || echo
