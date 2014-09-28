#ls aliases
alias l='ls -altr --color=tty'
alias ll='ls -l -h --color=tty'
alias lt='ls -altr -h --color=tty'

#ask before overwritting a file
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

#vim aliases
alias vw='vim `which\!`'
alias g='gvim'
alias xvim='urxvt -e vim'

#add color on grep commands
alias grep='grep --color'
alias rgrep='rgrep --color'
alias zgrep='zgrep --color'

#disk usage
alias du='du --max-depth=1 -h'
alias dus='du -hs * | sort -h'
alias df='df -h'

# "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#CVS aliases
alias cvst="cvs -n update -d 2> /dev/null | grep --color -E '(^|^M|^C.*|^A|^R)'"
alias cvsup="cvs update -d 2> /dev/null   | grep -v '^?' | grep --color -E '(^|^U|^C.*)'"
alias cvsadddirs="find . -type d \! -name CVS -exec cvs add '{}' \;"
alias cvsadddirs-n="find . -type d \! -name CVS"
alias cvsaddfiles="find . \( -type d -name CVS -prune \) -o \( -type f -exec cvs add '{}' \; \)"
alias cvsaddfiles-n="find . \( -type d -name CVS -prune \) -o \( -type f \)"

if [ -f ~/.alias.local.sh ]; then
    . ~/.alias.local.sh
fi

