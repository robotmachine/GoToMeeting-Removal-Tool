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
# Delete GoToMeeting Plists
defaults delete com.citrixonline.GoToMeeting >/dev/null 2>&1 || echo
defaults -currentHost delete com.citrixonline.GoToMeeting >/dev/null 2>&1 || echo
defaults delete com.citrixonline.G2MUpdate >/dev/null 2>&1 || echo
defaults -currentHost delete com.citrixonline.G2MUpdate >/dev/null 2>&1 || echo
##
## Delete Launcher Plist
defaults -currentHost delete com.citrixonline.mac.WebDeploymentApp >/dev/null 2>&1 || echo
defaults delete com.citrixonline.mac.WebDeploymentApp >/dev/null 2>&1 || echo
##
## Delete GoToMeeting apps from Desktop, system Applications, and user Applications.
trash ~/Desktop/GoToMeeting* >/dev/null 2>&1 || echo
trash /Applications/GoToMeeting* >/dev/null 2>&1 || echo
trash ~/Applications/GoToMeeting* >/dev/null 2>&1 || echo
trash ~/Library/Application\ Support/CitrixOnline/GoToMeeting* >/dev/null 2>&1 || echo
##
## Delete Launcher
trash ~/Library/Application\ Support/CitrixOnline/CitrixOnlineLauncher >/dev/null 2>&1 || echo
