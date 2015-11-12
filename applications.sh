#!/bin/bash

# default applications
export PAGER=${CONFIG['pager']:-less}
export BROWSER=${CONFIG['browser']:-chromium}
export MAILER=${CONFIG['mailer']:-icedove}
export OPEN=${CONFIG['open']:-gnome-open}

# default editors
for vis in gvim gedit ; do
    ( which $vis >/dev/null ) && VISUAL="$vis"
    [ -n "$VISUAL" ] && break
done
export VISUAL

for editor in vim.nox vim vi nano joe mcedit emacs ; do
    ( which $editor >/dev/null ) && EDITOR="$editor"
    [ -n "$EDITOR" ] && break
done
export EDITOR

if ( echo "$EDITOR" | grep -q vim ) ; then 
    alias vim.blank="${EDITOR} -N -u NONE -U NONE"
    alias vim.none=vim.blank
    alias vim.bigfile=vim.blank
fi

# default terminal
TERMINAL=${CONFIG['terminal']:-$( which terminator )}
TERMINAL=${TERMINAL:-$( which gnome-terminal )}
TERMINAL=${TERMINAL:-$( which rxvt-unicode )}
TERMINAL=${TERMINAL:-$( which xfce-terminal )}
TERMINAL=${TERMINAL:-$( which xterm )}
export TERMINAL

if [ -z "${DISPLAY}" ] ; then
    if ( pidof Xorg >/dev/null || pidof X >/dev/null ) ; then
        DISPLAY=:$( ps ax | grep -i -e Xorg -e "/usr/bin/X" | grep -o " :[0-9]* " | head -n 1 | grep -o "[0-9]*" )
        DISPLAY=${DISPLAY:-:0}
        export DISPLAY
    fi
fi

# application overwrites
alias cp='cp -i -r'
alias mv='mv -i'
alias rm='rm -i'
alias sudo='sudo '  # sudo fix
alias less='less'
alias mkdir='mkdir -p'
alias screen='screen -U'
alias dmesg='dmesg -T --color=auto'
alias wget='wget -c'
alias tmux='TERM=screen-256color-bce tmux'

# application colors
alias ls='LC_COLLATE=C ls --color=auto --group-directories-first -p'
alias grep='grep --color=auto'
export GREP_COLOR='7;34'

export LESS_TERMCAP_mb=$'\e[01;31m'
export LESS_TERMCAP_md=$'\e[01;37m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;43;37m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;32m'

( which colordiff >/dev/null ) && alias diff='colordiff'
( which pacman >/dev/null ) && alias pacman='pacman --color=auto'

# dircolors
if [ -x /usr/bin/dircolors ] ; then
    eval "`dircolors -b`"
fi

# dircolors (solarized)
if [ -r ~/.lib/dircolors-solarized/dircolors.256dark ] ; then
    eval "`dircolors ~/.lib/dircolors-solarized/dircolors.256dark`"
fi

