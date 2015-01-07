
# fix old-style ~/.system.conf
#if [ -r ~/.system.conf ] && ( grep -v "^system_" ~/.system.conf | grep -q "^[A-Za-z]" ) ; then
#    echo -ne "$( color yellow )DEBUG:$( color ) Fixing old-style ~/.system.conf\t"
#    ( sed -e 's|^hostname=|system_hostname=|g' \
#          -e 's|^domain=|system_domain=|g' \
#          -e 's|^systemtype=|system_type=|g' \
#          -e 's|^username=|system_username=|g' \
#          -e '/^#\|^system\_/! s|^|#|g' \
#          -i ~/.system.conf ) && color.echo "green" "DONE" || color.echo "red" "FAILED"
#fi

# loading ~/.system.conf
#[ -r ~/.system.conf ] && . ~/.system.conf

#if [ -r ~/.lib/git-flow-completion/git-flow-completion.bash ] ; then
#    . ~/.lib/git-flow-completion/git-flow-completion.bash
#fi

#if [ "$( whereami )" = "work" ] ; then
    #GIT_COMMITTER_EMAIL='simon.schiele@ypsilon.net'
    #GIT_AUTHOR_EMAIL='simon.schiele@ypsilon.net'
#else
    #GIT_COMMITTER_EMAIL='simon.codingmonkey@googlemail.com'
    #GIT_AUTHOR_EMAIL='simon.codingmonkey@googlemail.com'
#fi
#GIT_COMMITTER_NAME='Simon Schiele'
#GIT_AUTHOR_NAME='Simon Schiele'

#[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


#[ "$( head -n1 ${HOME}/.cache/homeenv/mode 2>/dev/null )" == "debug" ] && export BASH_DEBUG=true
#( ${BASH_DEBUG:-false} ) && export PROMPT_COMMAND="source ~/.bashrc ; $PROMPT_COMMAND"

    #PS1homeenv="$( head -n1 ${HOME}/.cache/homeenv/mode 2>/dev/null )"
    #[ $PS1homeenv == 'default' ] && unset PS1homeenv
    #PS1homeenv="${PS1homeenv:+$( color.ps1 red )${PS1homeenv}$( color.ps1 none )}"
    #PS1homeenv=${PS1homeenv:+ (${PS1homeenv})}

function es_called() {
    if [ -n "${BASH_SOURCE[2]}" ] ; then
        echo "CALLED: SOURCED"
        for (( i=1 ; i < ${#BASH_SOURCE[@]} ; i++ )) ; do
            echo "src: ${BASH_SOURCE[$i]}"
        done 
    elif [ "$( realpath ${0} )" == "$( realpath ${BASH_SOURCE[0]} )" ] ; then
        echo "CALLED: EXEC DIRECTLY" 
        echo "realpath 0: $( realpath ${0} )"
        echo "realpath SOURCE: $( realpath ${BASH_SOURCE[0]} )" 
    else
        echo "CALLED: UNKNOWN"
        #SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
        #echo "scriptpath: $SCRIPTPATH"
        echo "pwd: $( pwd )"     
        echo "\${0}: ${0}"
        echo "src0: ${BASH_SOURCE[0]}"
        echo "src1: ${BASH_SOURCE[1]}"
        echo "src2: ${BASH_SOURCE[2]}"
        echo "src3: ${BASH_SOURCE[3]}"
    fi
    
    echo "Params: ${#@}"
    if [ ${#@} -gt 0 ] ; then
        echo "@: ${@}"
        for i in "${@}" ; do
            local j=${j:-0}
            echo "\${${j}}: ${i}"
            j=$(( $j + 1 ))
        done
    fi
}

# }}}

# {{{ Coloring

export TERM='xterm-256color'
export CLICOLOR=1

# color fixing trap
trap 'echo -ne "\e[0m"' DEBUG

# Color support detection + color count (warning! crap!)
if [ -x /usr/bin/tput ] && ( tput setaf 1 >&/dev/null ) ; then
    color_support=true
else
    color_support=false
fi

if ( $color_support ) && [[ "$TERM" =~ "xterm" ]] ; then
    if [[ -n "$XTERM_VERSION" ]]; then
        # xterm
        COLORCOUNT='256'
    else
        if [[ $COLORTERM =~ "gnome-terminal" ]] ; then
            # gnome-terminal
            COLORCOUNT='256'
        else
            # xterm compatible
            COLORCOUNT='256'
        fi
    fi
elif [[ "$TERM" =~ "linux" ]] ; then
    # tty
    COLORCOUNT='8'
elif [[ "$TERM" =~ "rxvt" ]] ; then
    # rxvt
    COLORCOUNT=`tput colors`
elif [[ "$TERM" =~ "screen*" ]] ; then
    # screen or tmux
    COLORCOUNT='8'
else
    # unknown
    COLORCOUNT='8'
fi

export COLORCOUNT=${COLORCOUNT:-8}

# dircolors
if [ -x /usr/bin/dircolors ] ; then
    eval "`dircolors -b`"
fi

# dircolors (solarized)
if [ -r ~/.lib/dircolors-solarized/dircolors.256dark ] ; then
    eval "`dircolors ~/.lib/dircolors-solarized/dircolors.256dark`"
fi

# grep/less/diff/... coloring
alias ls='ls --color=auto'
#export GREP_OPTIONS='--color=auto'
alias grep="grep --color=auto"
export GREP_COLOR='7;34'                # green-bold
export LESS_TERMCAP_mb=$'\e[01;31m'     # red-bold
export LESS_TERMCAP_md=$'\e[01;37m'     # white-bold
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;43;37m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;32m'
( which colordiff >/dev/null ) && alias diff='colordiff'
( which pacman >/dev/null ) && alias pacman='pacman --color=auto'

# }}}


