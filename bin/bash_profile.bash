# Includes
source `brew --prefix`/Library/Contributions/brew_bash_completion.sh
source `brew --prefix`/Cellar/drush/6.3.0/etc/bash_completion.d/drush
source ~/dotfiles/bin/git-completion.bash

MACHINE_NAME=$(cat /info/machine_name)

# Make sure anything added by homebrew takes precendence over OS X defaults.
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/Cellar/ruby/1.9.3-p194/bin:$PATH"
export PATH="$PATH:$HOME/.composer/vendor/bin"
alias drush="/usr/local/opt/drush/bin/drush"
alias mysql="/Applications/MAMP/Library/bin/mysql"

# Platform.sh CLI configuration
PLATFORMSH_CONF=~/.composer/vendor/platformsh/cli/platform.rc
[ -f "$PLATFORMSH_CONF" ] && . "$PLATFORMSH_CONF"


alias ll="ls -l"
alias la="ls -la"
alias ..="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."

alias ga="git add"
alias gc="git commit"
alias gcm="git commit -m"
alias gpm="git push origin master"
alias gs="git status"
alias gi="~/bin/git-info.sh"
alias cbp="cordova build; cordova prepare"

function gd
{
    if [[ `git diff |wc -l` -gt 0 ]]
    then
      git diff | /Applications/MacVim.app/Contents/MacOS/Vim -R -
    else
      echo "No changes since last commit."
    fi
}
function gclone
{
  cmd=""
  if [ -z "$2" ]
    then
      cmd="git clone git@clikgit.com:$1"
  else
    case "$1" in
      "clik" )
        cmd="git clone git@clikgit.com:$2"
        ;;

      "drupal" )
        cmd="git clone http://git.drupal.org/project/$2.git"
        ;;

      "ghcf" )
        cmd="git clone git@github.com:Clikfocus/$2.git"
        ;;
    esac
  fi

  echo "$cmd"
  $cmd
}

# git remove deleted items in working directory
function grmwd {
  git status .|grep 'deleted:'|awk '{print $3}'|xargs git rm
}

alias sc="ssh clikbox.com"
alias sr="ssh r.clkd.co"

alias tmreload="osascript -e 'tell app "TextMate" to reload bundles'"

alias ct='ctags --langmap=php:.engine.inc.module.theme.php --php-kinds=cdfi --languages=php --recurse'
alias cts='ctags --langmap=php:.engine.inc.module.theme.php --php-kinds=cdfi --languages=php --recurse -f .tags'

alias cw='compass watch .'

export DRUSH_PHP="/Applications/MAMP/bin/php/php5.5.18/bin/php"
#export DRUSH_PHP="/Applications/MAMP/bin/php5.4.26/bin/php"


# Git editor
#export GIT_EDITOR="/usr/bin/vim"
#export GIT_EDITOR="/usr/local/bin/mate -w"
export GIT_EDITOR="subl -nw"
export EDITOR="subl -n"
#export EDITOR=/usr"/local/bin/mate"
alias sub="subl -n"

export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

alias ht="cd ~/htdocs"
alias hosts="sudo $EDITOR /etc/hosts"
alias vhost="$EDITOR ~/vhost.d"
alias aliases="$EDITOR ~/.drush/aliases.drushrc.php"
alias drushrc="$EDITOR ~/.drushrc.php"
alias pc="pwd | pbcopy"

alias rma="sudo /Applications/MAMP/bin/apache2/bin/apachectl restart"

alias fdns="sudo killall -HUP mDNSResponder"

# Start, stop and restart solr easily.
function solr {
  solrpath="/Users/ryandekker/Library/LaunchAgents/com.apache.solr.plist"
  case "$1" in
    "start" )
      cmd="launchctl load -w $solrpath"
      $cmd
      ;;
    "stop" )
      launchctl unload -w $solrpath
      ;;
    "restart" )
      launchctl unload -w $solrpath
      launchctl load -w $solrpath
      ;;
    * )
      /usr/bin/java -Djetty.home=$(brew --prefix solr)/libexec/example -Djetty.logs=/var/logs/solr -Dsolr.solr.home=$(brew --prefix solr)/libexec/example/multicore -jar $(brew --prefix solr)/libexec/example/start.jar
      ;;
  esac
}

# Prints working directory based on rules.
function wd {
  # Custom path strings.
  local pwd=$(pwd)
  local wd=${pwd##/Users/}
  # This gives us what we would normally see
  wd=${wd/$(whoami)/'~'}

  # Regex to grab the last 3 directories in the path.
  local mwd=`expr "$wd" : '.*/\(.*/.*/.*\)'`

  # As long as the regex returned something, print that.
  if [ -n "$mwd" ] ; then
    echo $mwd
  else
    echo $wd
  fi
}

# Sets custom prompt.
function prompt {
  local CYAN="\[\033[0;36m\]"
  local GREEN="\[\033[0;32m\]"
  local BLUE="\[\033[0;34m\]"
  local GRAY="\[\033[0;37m\]"
  local LIGHT_BLUE="\[\033[1;34m\]"

  # Attempt to fix issue with TERM sometimes not being set...
  if [[ -z "$TERM" ]] ; then
    export TERM=xterm
  fi

  if [ "\$(type -t __git_ps1)" ] && [ "\$(type -t __drush_ps1)" ]; then
    export PS1="${CYAN}$MACHINE_NAME "${GREEN}' $(wd "(%s)")'${BLUE}' $(__git_ps1 "(%s)")'${LIGHT_BLUE}' $(__drush_ps1 "[%s]")'"${GRAY}$ \[$(tput sgr0)\]"
  fi
}
# Initialize our prompt.
prompt

# Port scanner.
scan() {
  if [[ -z $1 || -z $2 ]]; then
    echo "Usage: $0 <host> <port, ports, or port-range>"
    return
  fi

  local host=$1
  local ports=()
  case $2 in
    *-*)
      IFS=- read start end <<< "$2"
      for ((port=start; port <= end; port++)); do
        ports+=($port)
      done
      ;;
    *,*)
      IFS=, read -ra ports <<< "$2"
      ;;
    *)
      ports+=($2)
      ;;
  esac


  for port in "${ports[@]}"; do
    alarm 1 "echo >/dev/tcp/$host/$port" &&
      echo "port $port is open" ||
      echo "port $port is closed"
  done
}
alarm() {
  perl -e '
    eval {
      $SIG{ALRM} = sub { die };
      alarm shift;
      system(@ARGV);
    };
    if ($@) { exit 1 }
  ' "$@";
}

