#!/bin/bash

function es_out() {
    if [[ -z "${@}" ]] ; then
        local msgtype=""
    elif [[ -z "${2}" ]] ; then
        local msgtype="[LOG] "
    else
        local msgtype="[${2^^}] "
    fi

    echo "${msgtype}${1}"
}

function es_log() {
    if ( ${ESSENTIALS_LOG} ) ; then
        echo "$( date '+%Y-%m-%d %H:%M:%S' ) $(es_out ${@})" >> ${ESSENTIALS_LOGFILE}
    fi
}

function es_debug() {
    es_log "${@}"
    if ( ${ESSENTIALS_DEBUG} ) ; then
        es_out "${@}" >&2
    fi
}

function es_debug_enable() {
    export ESSENTIALS_DEBUG=true
    . ${ESSENTIALS_DIR}/essentials.sh
    clear
    es_info
}

function es_center() {
    if es_called_by_pipe ; then
        while read data ; do
            local length=$( echo ${data} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m )
            seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
                echo -n " "
            done
            echo -e "$data"
        done
    else
        echo "$@" | while read data ; do
            local length=$( echo ${data} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m )
            seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
                echo -n " "
            done
            echo -e "$data"
        done
    fi
}

function es_center_aligned() {
    if es_called_by_pipe ; then
        while read data ; do
            if [ -z "$length" ] ; then
                local length=$( echo ${data} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m )
            fi
            seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
                echo -n " "
            done
            echo -e "$data"
        done
    else
        echo "$@" | while read data ; do
            if [ -z "$length" ] ; then
                local length=$( echo ${data} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m )
            fi
            seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
                echo -n " "
            done
            echo -e "$data"
        done
    fi
}

function es_header() {
    echo -e "\n$( es_center_aligned "${@}" )\n"
}

function es_vr(){
    echo -e "\n\n\n\n\n"
}

function es_hr() {
    local i
    for i in $( seq ${COLUMNS:-80} ); do
        echo -n "${1:-#}"
    done
    echo
}

function es_banner() {
    if [ $( find /usr/share/figlet/ /usr/local/figlet/ /usr/local/share/figlet/ /usr/share/toilet/ /usr/local/toilet/ /usr/local/share/toilet/ -iname "future\.*" 2>/dev/null | wc -l ) -gt 0 ] ; then
        local font="-f future"
    fi

    if es_depends "toilet" "bin" ; then
        toilet -F border ${font} "essentials" --gay | es_center_aligned
        toilet ${font} -w 120 "simons bash workflow" --gay | es_center_aligned
    elif es_depends "figlet" "bin" ; then
        figlet ${font} "essentials" | es_center_aligned
        figlet ${font} -w 120 "simons bash workflow" | es_center_aligned
    else
        echo "ESSENTIALS" | es_center_aligned
        echo "simons bash workflow" | es_center_aligned
    fi
}

function es_info() {
    es_out
    es_banner
    es_out
    es_out "$( color white_bold )ENVIRONMENT:$( color )"
    es_out "* USER: ${ESSENTIALS_USER}"
    es_out "* HOME: ${ESSENTIALS_HOME}/"
    es_out "* DIR CACHE: ${ESSENTIALS_DIR_CACHE}/"
    es_out "* DIR LOG: ${ESSENTIALS_DIR_LOG}/"
    es_out "* SUDO: ${ESSENTIALS_IS_SUDO} (unlocked: ${ESSENTIALS_IS_SUDO_UNLOCKED})"
    es_out "* ROOT: ${ESSENTIALS_IS_ROOT}"
    es_out "* SSH: ${ESSENTIALS_IS_SSH}"
    es_out "* MOSH: ${ESSENTIALS_IS_MOSH}"
    es_out "* TMUX: ${ESSENTIALS_IS_TMUX}"
    es_out "* SCREEN: ${ESSENTIALS_IS_SCREEN}"
    es_out
    es_out "$( color white_bold )SSH AGENT:$( color )"
    es_out "* AGENT RUNNING: ${ESSENTIALS_HAS_SSHAGENT} (pid ${SSH_AGENT_PID:-UNKNOWN})"
    es_out
    es_out "$( color white_bold )EXTERNALS:$( color )"
    es_out "* BASH VERSION: ${BASH_VERSION}"
    es_out "* GIT VERSION: ${ESSENTIALS_VERSION_GIT}"
    es_out "* VIM VERSION: ${ESSENTIALS_VERSION_VIM}"
    es_out "* HOME REPO: ${ESSENTIALS_VERSION_HOME} (commit $( es_repo_version ${ESSENTIALS_HOME} | sed 's| |, |'))"
    es_out
    es_out "$( color white_bold )ESSENTIALS:$( color )"
    es_out "* VERSION: ${ESSENTIALS_VERSION} (commit $( es_repo_version ${ESSENTIALS_DIR} | sed 's| |, |'))"
    es_out "* DIR ESSENTIALS: ${ESSENTIALS_DIR}/"
    es_out "* DEBUG: ${ESSENTIALS_DEBUG}"
    es_out "* LOG: ${ESSENTIALS_LOG} (-> ${ESSENTIALS_LOGFILE})"
    es_out
    es_out "$( color white_bold )FUNCTIONS:$( color )"
    es_out "* COUNT: $( grep "^[ ]*function[^)]\+)" ${ESSENTIALS_DIR}/*sh | wc -l )"
    es_out
    es_out "$( color white_bold )ALIASES:$( color )"
    es_out "* COUNT: $( grep "^[ ]*alias [^ ]\+=" ${ESSENTIALS_DIR}/*sh | wc -l )"
    es_out
    es_out "$( color white_bold )APPLICATIONS:$( color )"
    es_out "* EDITOR: ${EDITOR}"
    es_out "* PAGER: ${PAGER}"
    es_out "* BROWSER: ${BROWSER}"
    es_out "* TERMINAL: ${TERMINAL}"
    es_out
}

function es_return() {
    es_debug "${2}" "error"
    return ${1:-0}
}

function es_return_unicode() {
    local last_ret=$?
    local ret=${@:-${last_ret:-1}}
    local status=1
    local icon='fail'
    local iconcolor='red'
    local tmpname

    local positives="0 true success ok"
    for tmpname in ${positives} ; do
        if [ "${ret}" == "${tmpname}" ] ; then
            status=0
            iconcolor='green'
            icon='success'
            break
        fi
    done

    if [ ! ${status} -eq 0 ] ; then
        if ( echo "${ret}" | grep -q "^[0-9]\+$" ) ; then
            status=${ret}
        fi
    fi

    echo -e " $( color ${iconcolor} )$( icon $icon )$( color )"
    return ${status}
}

function es_exit() {
    es_debug "${2}" "error"
    exit ${1:-0}
}

function es_confirm_yesno() {
    while read -p "${1:-Are you sure (Y/N)? }" -r -n 1 -s answer; do
        if [[ $answer = [YyNn] ]]; then
            [[ $answer = [Yy] ]] && ( echo ; return 0 )
            [[ $answer = [Nn] ]] && ( echo ; return 1 )
            break
        fi
    done
}

function es_confirm_yesno_whiptail() {
    whiptail --yesno "${1:-Are you sure you want to perform 'unknown action'?}" 10 60
}

function es_confirm_keypress() {
    local keypress
    read -s -r -p "${1:-Press any key to continue...}" -n 1 keypress
}

function es_depends() {
    local depends_name="${1}"
    local depends_type="${2:-bin}"
    local available=false

    case "${depends_type}" in
        dpkg|deb|debian)
                dpkg -l | grep -iq "^ii\ \ ${depends_name}\ " && available=true
            ;;

        bin|which|executable)
                which ${depends_name} >/dev/null && available=true
            ;;

        *)
                es_depends ${depends_name} bin && available=true
            ;;
    esac

    return $( ${available} )
}

function es_reload() {
    . ${ESSENTIALS_DIR}/essentials.sh
}

function es_depends_essentials() {
    if ( [ -z "$PS1" ] || [ -z "$BASH_VERSION" ] ) ; then
        es_debug "shell is not bash" "error"
        return 1
    fi

    return 0
}

function es_repo_version() {
    local repo="${@:-${ESSENTIALS_DIR}}"
    cd "${repo}"
    git log --pretty=format:'%h %cr' -1
    cd "${OLDPWD}"
}

function es_repo_version_date() {
    local repo="${@:-${ESSENTIALS_DIR}}"
    cd "${repo}"
    local orig_date=$( git log --pretty=format:'%ci' -1 | awk {'print $1'} )
    local from_date=$( date "--date=$orig_date -1 day" +%Y-%m-%d )
    local to_date=$( date "--date=$orig_date +1 day" +%Y-%m-%d )
    local commits=$(( $( git log --pretty=format:'%h %cr' --since=${from_date} --until=${to_date} | wc -l ) + 1 ))
    echo ${from_date//-/}~${commits}
    cd "${OLDPWD}"
}

function es_called_by_pipe() {
    [[ -p /dev/stdin ]]
}

function es_called_by_include() {
    #[ -n "${BASH_SOURCE[2]}" ]
    [ "$( realpath ${0} )" != "$( realpath ${BASH_SOURCE[0]} )" ]
}

function es_called_by_exec() {
    [ "$( realpath ${0} )" == "$( realpath ${BASH_SOURCE[0]} )" ]
}

function es_tmp_dir() {
    local dir=${@:-$( pwd )}
    #todo: implement
    echo -n
}

function es_tmp_file() {
    #todo: implement
    echo -n
}

function es_grep() {
    grep -r ${@:-^} ${ESSENTIALS_DIR}/ ${ESSENTIALS_HOME}/{.bashrc,.profile,.xsession,.gitconfig,.ssh/config,.bin*/}
}

function es_edit() {
    ${EDITOR} ${ESSENTIALS_DIR}/*.sh ${ESSENTIALS_HOME}/{.bashrc,.profile,.xsession,.gitconfig,.ssh/config,.doc/*.md} ${ESSENTIALS_DIR}/*.md ${@}
}

function es_goodmorning() {
    local status=0
    local sudo_cmd

    clear
    es_header "$( color white_bold )Good Morning, ${SUDO_USER:-${USER^}}!$( color )"
    show.stats

    if ${ESSENTIALS_IS_UID0} ; then
        # user already has uid0
        sudo_cmd=""
    elif ( sudo -n echo -n 2>/dev/null ) ; then
        # sudo already unlocked
        sudo_cmd="sudo"
    elif ( sudo echo -n ) ; then
        # user unlocked sudo
        sudo_cmd="sudo"
    else
        echo -e "\n$( color red )error$( color ): couldn't unlock sudo\n" >&2
        return 1
    fi

    echo -e "\n$( color white_under )$( color white_bold )Debian:$( color )"
    echo "version: $( lsb_release -ds 2>&1 )"

    echo -n "updating packagelists: "
    local out=$( ${sudo_cmd} apt-get update 2>&1 )
    local ret=$?
    if [ $ret -eq 0 ] ; then
        echo -e "success $( color green )$( icon ok )$( color )"
    else
        echo -e "failed $( color red )$( icon fail )$( color )"
        let status++
    fi

    echo -en "available updates: "
    yes "no" | ${sudo_cmd} apt-get dist-upgrade 2>&1 | grep --color=never "upgraded.*installed.*remove.*upgraded"

    echo -e "Latest Security Advisories: "
    debian.security

    echo -e "\n$( color white_under )$( color white_bold )Repos:$( color )"
    update.repo git@psaux.de:dot.bin-ypsilon.git ~/.bin-ypsilon/ || let status++
    update.repo git@psaux.de:dot.bin-private.git ~/.bin-private/ || let status++
    update.repo git@simon.psaux.de:dot.fonts.git ~/.fonts/ || let status++
    update.repo git@simon.psaux.de:dot.backgrounds.git ~/.backgrounds/ || let status++
    update.repo git@simon.psaux.de:home.git ~/ || let status++

    es_header "$( color white_bold )Have a nice day, ${SUDO_USER:-${USER^}}! (-:$( color )"
    return $status
}

# check if powerline patched font for vim is available
export POWERLINE_FONT=$( [ $( find ~/.fonts/ -iname "*pragmata*powerline*ttf" 2>/dev/null | wc -l ) -eq 0 ] ; echo ${BOOLEAN[$?]} )

# helper
export BOOLEAN=(true false)
export EXTENSIONS_VIDEO='avi,mkv,mp4,mpg,mpeg,wmv,wmvlv,webm,3g,mov,flv'
export EXTENSIONS_IMAGES='png,jpg,jpeg,gif,bmp,tiff,ico,lzw,raw,ppm,pgm,pbm,psd,img,xcf,psp,svg,ai'
export EXTENSIONS_AUDIO='flac,mp1,mp2,mp3,ogg,wav,aac,ac3,dts,m4a,mid,midi,mka,mod,oma,wma'
export EXTENSIONS_DOCUMENTS='asc,rtf,txt,abw,zabw,bzabw,chm,pdf,doc,docx,docm,odm,odt,ods,ots,sdw,stw,wpd,wps,pxl,sxc,xlsx,xlsm,odg,odp,pps,ppsx,ppt,pptm,pptx,sda,sdd,sxd,dot,dotm,dotx,mobi,prc,epub,pdb,prc,tpz,azw,azw1,azw3,azw4,kf8,lit,fb2'
export EXTENSIONS_ARCHIVES='7z,s7z,ace,arj,bz,bz2,bzip,bzip2,gz,gzip,lha,lzh,rar,r0,r00,tar,taz,tbz,tbz2,tgz,zip,rpm,deb'

# find essentials_dir
export ESSENTIALS_DIR="${ESSENTIALS_DIR:-$( dirname $( realpath ${BASH_SOURCE[0]}))}"

# include external essential libs
tmpname="colors.sh icons.sh prompt.sh functions.sh"
for script in ${tmpname} ; do
    if [ -r ${ESSENTIALS_DIR}/${script} ] ; then
        . ${ESSENTIALS_DIR}/${script}
    else
        echo "[ERROR] ${script} not found in ${ESSENTIALS_DIR}" >&2
        return 1
    fi
done

# check mandatory depends
es_depends_essentials || es_return 1 "missing depends for essentials"
tmpname="pstree"
for bin in ${tmpname} ; do
    es_depends "${bin}" "bin" || es_return 1 "missing depends for essentials: ${bin}"
done

# check optional depends
tmpname="toilet toilet-fonts git vim-nox colordiff wdiff fping"
for pkg in ${tmpname} ; do
    es_depends "${pkg}" "debian" || es_out "optional depends $pkg missing" "warning"
done

# load config
declare -A CONFIG

tmpname="my*config.sh custom*config.sh config.sh"
for configfile in ${tmpname} ; do
    if [ -e ${ESSENTIALS_DIR}/${configfile} ] ; then
        . ${ESSENTIALS_DIR}/${configfile}
    fi
done

# config defaults
export LUKS_KEYSIZE=${CONFIG['luks_keysize']:-512}
export LUKS_CIPHER=${CONFIG['luks_cipher']:-aes-xts-plain64:sha256}

# default applications
export PAGER=${CONFIG['pager']:-less}
export BROWSER=${CONFIG['browser']:-google-chrome}
export MAILER=${CONFIG['mailer']:-icedove}
export OPEN=${CONFIG['open']:-gnome-open}

# default editor (vim + failover)
EDITOR=${CONFIG['editor']:-$( which vim.nox )}
EDITOR=${EDITOR:-$( which vim )}
if [ -n "${EDITOR}" ] ; then
    alias vim.blank="${EDITOR} -N -u NONE -U NONE"
    alias vim.none=vim.blank
    alias vim.bigfile=vim.blank
fi
EDITOR=${EDITOR:-$( which vi )}
EDITOR=${EDITOR:-$( which nano )}
EDITOR=${EDITOR:-$( which joe )}
EDITOR=${EDITOR:-$( which mcedit )}
EDITOR=${EDITOR:-$( which emacs )}
export EDITOR

# default terminal
TERMINAL=${CONFIG['terminal']:-$( which terminator )}
TERMINAL=${TERMINAL:-$( which gnome-terminal )}
TERMINAL=${TERMINAL:-$( which rxvt-unicode )}
TERMINAL=${TERMINAL:-$( which xfce-terminal )}
TERMINAL=${TERMINAL:-$( which xterm )}
export TERMINAL

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

# shorties
function t() { true; }
function f() { false; }
function r() { return ${1:-0}; }
function p() { ps aux | grep -i ${@:-^}; }

# essential settings
export ESSENTIALS_USER="${ESSENTIALS_USER:-${CONFIG['user']:-${SUDO_USER:-${USER}}}}"
export ESSENTIALS_HOME="${ESSENTIALS_HOME:-${CONFIG['home']:-$( getent passwd ${ESSENTIALS_USER} | cut -d':' -f6 )}}"
export ESSENTIALS_USER="${ESSENTIALS_USER:-${SUDO_USER:-${USER}}}"
export ESSENTIALS_HOME="${ESSENTIALS_HOME:-$( getent passwd ${ESSENTIALS_USER} | cut -d':' -f6 )}"
export ESSENTIALS_DIR_PKGLISTS="${ESSENTIALS_HOME}/.packages"
export ESSENTIALS_DIR_FONTS="${ESSENTIALS_HOME}/.fonts"
export ESSENTIALS_DIR_WALLPAPERS="${ESSENTIALS_HOME}/.backgrounds"
export ESSENTIALS_DIR_LOG="${ESSENTIALS_HOME}/.log"
export ESSENTIALS_DIR_CACHE="${ESSENTIALS_HOME}/.cache"
export ESSENTIALS_LOGFILE="${CONFIG['logfile']:-${ESSENTIALS_DIR_LOG}/essentials.log}"
export ESSENTIALS_CACHEFILE="${ESSENTIALS_DIR_CACHE}/essentials.cache"
export ESSENTIALS_DEBUG="${ESSENTIALS_DEBUG:-${CONFIG['debug']:-false}}"
export ESSENTIALS_LOG="${ESSENTIALS_LOG:-${CONFIG['log']:-true}}"
export ESSENTIALS_COLORS="${ESSENTIALS_COLORS:-${CONFIG['colors']:-true}}"
export ESSENTIALS_UNICODE="${ESSENTIALS_UNICODE:-${CONFIG['unicode']:-true}}"
export ESSENTIALS_VERSION=$( es_repo_version_date ${ESSENTIALS_DIR} )
export ESSENTIALS_VERSION_VIM=$( vim --version | grep -o "[0-9.]\+" | head -n 1 )
export ESSENTIALS_VERSION_GIT=$( git --version | sed 's/git version //' )
export ESSENTIALS_VERSION_HOME=$( es_repo_version_date ${ESSENTIALS_HOME} )
export ESSENTIALS_IS_SUDO=$( pstree -s "$$" | grep -qi 'sudo' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_SUDO_UNLOCKED=$( sudo -n echo -n 2>/dev/null ; echo ${BOOLEAN[$?]} )  # maybe rename
export ESSENTIALS_IS_ROOT=$( [ $( id -u ) -eq 0 ] && ! ${ESSENTIALS_IS_SUDO} ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_UID0=$( ${ESSENTIALS_IS_SUDO} || ${ESSENTIALS_IS_ROOT} ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_SSH=$( pstree -s "$$" | grep -qi 'ssh' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_MOSH=$( pstree -s "$$" | grep -qi 'mosh' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_TMUX=$( pstree -s "$$" | grep -qi 'tmux' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_SCREEN=$( pstree -s "$$" | grep -qi 'screen' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_HAS_SSHAGENT=$( [ -n "$( ps hp ${SSH_AGENT_PID} 2>/dev/null )" ] ; echo ${BOOLEAN[$?]} )

# cleanup
unset CONFIG tmpname script bin pkg configfile i j

