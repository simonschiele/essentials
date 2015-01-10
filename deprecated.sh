
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

# old stuff
#alias route_via_wlan="for i in \`seq 1 10\` ; do route del default 2>/dev/null ; done ; route add default eth0 ; route add default wlan0 ; route add default gw \"\$( /sbin/ifconfig wlan0 | grep.ip | head -n 1 | cut -f'1-3' -d'.' ).1\""
#alias 2audio="convert2 mp3"
#alias youtube-mp3="clive -f best --exec=\"echo >&2; echo '[CONVERTING] %f ==> MP3' >&2 ; ffmpeg -loglevel error -i %f -strict experimental %f.mp3 && rm -f %f\""
#alias youtube="clive -f best --exec=\"( echo %f | grep -qi -e 'webm$' -e 'webm.$' ) && ( echo >&2 ; echo '[CONVERTING] %f ==> MP4' >&2 ; ffmpeg -loglevel error -i %f -strict experimental %f.mp4 && rm -f %f )\""
#alias image2pdf='convert -adjoin -page A4 *.jpeg multipage.pdf'				# convert images to a multi-page pdf
#nrg2iso() { dd bs=1k if="$1" of="$2" skip=300 }

#wget -q -O- http://www.di.fm/ | grep -o 'data-tunein-url="[^"]*"' | cut -f'2' -d'"'  

# random.password+phpass() { local pass="${@:-$( random.password 12 )}" ; python -c "from passlib.hash import phpass ; print phpass.encrypt('${pass}')" }


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

# sorgenkinder
alias show.open_ports='echo -e "User:      Command:   Port:\n----------------------------" ; sudo "lsof -i 4 -P -n | grep -i listen | awk {\"print \$3, \$1, \$9\"} | sed \"s| [a-z0-9\.\*]*:| |\" | sort -k 3 -n | xargs printf \"%-10s %-10s %-10s\n\"" | uniq'
alias log.authlog="sudo grep -e \"^\$( LANG=C date -d'now -24 hours' +'%b %e' )\" -e \"^\$( LANG=C date +'%b %e' )\" /var/log/auth.log | grep.ip | sort -n | uniq -c | sort -n | grep -v \"\$( host -4 enkheim.psaux.de | grep.ip | head -n1 )\" | tac | head -n 10"
alias hooks.run="echo ; systemtype=\$( grep ^systemtype ~/.system.conf | cut -f2 -d'=' | sed -e 's|[\"\ ]||g' -e \"s|'||g\" ) ; for exe in \$( find ~/.hooks/ ! -type d -executable | xargs grep -l \"^hook_systemtype.*\${systemtype}\" | xargs grep -l '^hook_optional=false' ) ; do exec_with_sudo='' ; grep -q 'hook_sudo=.*true.*' \"\${exe}\" && exec_with_sudo='sudo ' || grep -q 'hook_sudo' \"\${exe}\" || exec_with_sudo='sudo ' ; cancel=\${cancel:-false} global_success=\${global_success:-true} \${exe} ; retval=\${?} ; echo ; if test \${retval} -eq 2 ; then echo -e \"CANCELING HOOKS\" >&2 ; break ; elif ! test \${retval} -eq 0 ; then global_success=false ; fi ; done ; \${global_success} || echo -e \"Some hooks could NOT get processed successfully!\n\" ; unset global_success systemtype retval ;"

# compression
alias zip.dir='compress zip'
alias rar.dir='compress rar'
alias tar.dir='compress targz'

# mirror
# {{{ compress()

compress() {
    local OLDOPTIND=$OPTIND 
    local HELP=false
    local DATE=false
    local VERBOSE=''
    local ERROR='' 
    
    while getopts ":hdv" opt ; do
        case $opt in
            h)
                HELP=true
                ;;
            d)
                DATE=true
                ;;
            v)
                VERBOSE=true
                ;;
            \?)
                ERROR="Unknown Flag: -$OPTARG"
                ;;
        esac
    done
    shift $((OPTIND-1))
    OPTIND=$OLDOPTIND
   
    ! ${HELP} && [ -z "${ERROR}" ] && ([ -z "${1}" ] || [ -z "${2}" ]) && \
        ERROR="Please give at least a type of archive and what to compress"

    $HELP || [ -n "${ERROR}" ] && \
        echo "${FUNCNAME} [-h] [-d] <rar|zip|file.tar.gz> <dir/> [<data.txt|data2/>]"
    
    [ -n "$ERROR" ] && echo ${ERROR} && return 1
    $HELP && return 0

        ( [ -n "${ERROR}" ] && return 1 || return 0 )
   
    local target="${1}"
    local content="${2}"
    shift
    
    local archivetype="${target##*.}" 
    local change_dir=false
    
    if [ "$( basename ${content} )" == "." ]
    then
        content=$( basename "$( pwd )" | sed 's|\ |\\ |g' )
        change_dir=true
    else
        content="$@"
    fi

    [ $change_dir ] && cd ..

    local status=true
    case "${archivetype,,}" in
        rar)
            archivetype="rar"
            local cmd="rar a -ol -r -ow -idc $( ! [ ${VERBOSE} ] && echo '-inul' ) --"
            ;;
        zip)
            archivetype="zip"
            local cmd="zip -r -y $( ! [ ${VERBOSE} ] && echo '-q' )"
            ;;
        bzip2|bz2)
            archivetype="tar.bz2"
            local cmd="tar cjf${VERBOSE:+v}"
            ;;
        tar|gz|targz|tgz)
            archivetype="tar.gz"
            local cmd="tar czf${VERBOSE:+v}"
            ;;
        *)
            echo "Archivformat '${archivetype}' is not supported" && status=false
            ;;
    esac
    
    if [ "${archivetype}" == "${target}" ] || ! ( echo "$target" | grep -q "\." )
    then
        [ -n "${2}" ] && echo "Autonaming is only supported if you compress only one file or directory" && return 1
        local cleancontent=$( basename ${content} | sed -e 's|^\.|dot.|g' )
        target="${cleancontent%.*}.${archivetype}"
    fi
    
    $status && $cmd $target $content
    
    [ $change_dir ] && cd "${OLDPWD}"

    return $( $status )
}

# }}}

# {{{ convert2()

convert2() {
    ext=${1} ; shift ; for file ; do echo -n ; [ -e "$file" ] && ( echo -e "\n\n[CONVERTING] ${file} ==> ${file%.*}.${ext}" && ffmpeg -loglevel error -i "${file}" -strict experimental "${file%.*}.${ext}" && echo rm -i "${file}" ) || echo "[ERROR] File not found: ${file}" ; done
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


