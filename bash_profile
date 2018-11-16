export COLOR_NC='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_YELLOW='\e[0;33m'
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
git_branch() {
  git branch 2>/dev/null | grep '^*' | colrm 1 2
}
git_status() {
 RC=`git status --porcelain 2>/dev/null | grep "?" | wc -l`
 if [[ $RC -eq 1 ]]; then 
   echo "[✚]"
   return 
 else
   exit 
 fi 
}

export PS1="\[${UC}\]\u \[${COLOR_CYAN}\]\W\[${COLOR_PURPLE}\] \$(git_branch)\[${COLOR_RED}\]\$(git_status)\[${COLOR_LIGHT_GREEN}\] $ → \[${COLOR_NC}\]"

