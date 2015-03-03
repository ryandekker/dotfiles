source ~/dotfiles/bin/bash_profile.bash

drush_bashrc="$HOME/dotfiles/bin/drush.bashrc"
if [ -f $drush_bashrc ] ; then
  source $drush_bashrc
fi
