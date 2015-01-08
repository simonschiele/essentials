#!/bin/bash

# {{{ Colors

declare -A COLOR

COLOR[none]="\e[0m"
COLOR[off]="\e[0m"
COLOR[false]="\e[0m"
COLOR[normal]="\e[0m"

# Basic Colors
COLOR[black]="\e[0;30m"
COLOR[red]="\e[0;31m"
COLOR[green]="\e[0;32m"
COLOR[yellow]="\e[0;33m"
COLOR[blue]="\e[0;34m"
COLOR[purple]="\e[0;35m"
COLOR[cyan]="\e[0;36m"
COLOR[white]="\e[0;37m"

# Bold Colors
COLOR[black_bold]="\e[1;30m"
COLOR[red_bold]="\e[1;31m"
COLOR[green_bold]="\e[1;32m"
COLOR[yellow_bold]="\e[1;33m"
COLOR[blue_bold]="\e[1;34m"
COLOR[purple_bold]="\e[1;35m"
COLOR[cyan_bold]="\e[1;36m"
COLOR[white_bold]="\e[1;37m"

# Underline 
COLOR[black_under]="\e[4;30m"
COLOR[red_under]="\e[4;31m"
COLOR[green_under]="\e[4;32m"
COLOR[yellow_under]="\e[4;33m"
COLOR[blue_under]="\e[4;34m"
COLOR[purple_under]="\e[4;35m"
COLOR[cyan_under]="\e[4;36m"
COLOR[white_under]="\e[4;37m"

# Background Colors
COLOR[black_background]="\e[40m"
COLOR[red_background]="\e[41m"
COLOR[green_background]="\e[42m"
COLOR[yellow_background]="\e[43m"
COLOR[blue_background]="\e[44m"
COLOR[purple_background]="\e[45m"
COLOR[cyan_background]="\e[46m"
COLOR[white_background]="\e[47m"
COLOR[gray_background]="\e[100m"

alias show.colors="( for key in \"\${!COLOR[@]}\" ; do echo -e \" \${COLOR[\$key]} == COLORTEST \${key} == \${COLOR[none]}\" ; done ) | column -c \${COLUMNS:-120}"

function color.existing() {
    [ ${COLOR[${1:-none}]+isset} ] && return 0 || return 1
}

function color() {
    ( color.existing ${1:-none} ) && echo -ne "${COLOR[${1:-none}]}"
}

function color.ps1() {
    ( color.existing ${1:-none} ) && echo -ne "\[${COLOR[${1:-none}]}\]"
}

function color.echo() {
    ( color.existing ${1:-black} ) && echo -e "${COLOR[${1:-black}]}${2}${COLOR[none]}"
}

function color.echon() {
    ( color.existing ${1:-black} ) && echo -ne "${COLOR[${1:-black}]}${2}${COLOR[none]}"
}

# }}}

# {{{ Icons

declare -A ICON

ICON[trademark]='\u2122'
ICON[copyright]='\u00A9'
ICON[registered]='\u00AE'
ICON[asterism]='\u2042'
ICON[voltage]='\u26A1'
ICON[whitecircle]='\u25CB'
ICON[blackcircle]='\u25CF'
ICON[largecircle]='\u25EF'
ICON[percent]='\u0025'
ICON[permille]='\u2030'
ICON[pilcrow]='\u00B6'
ICON[peace]='\u262E'
ICON[yinyang]='\u262F'
ICON[russia]='\u262D'
ICON[turkey]='\u262A'
ICON[skull]='\u2620'
ICON[heavyheart]='\u2764'
ICON[whiteheart]='\u2661'
ICON[blackheart]='\u2665'
ICON[whitesmiley]='\u263A'
ICON[blacksmiley]='\u263B'
ICON[female]='\u2640'
ICON[male]='\u2642'
ICON[airplane]='\u2708'
ICON[radioactive]='\u2622'
ICON[ohm]='\u2126'
ICON[pi]='\u220F'
ICON[cross]='\u2717'
ICON[fail]='\u2717'
ICON[error]='\u2717'
ICON[check]='\u2714'
ICON[ok]='\u2714'
ICON[success]='\u2714'
ICON[warning]='⚠'

alias show.icons="( for key in \"\${!ICON[@]}\" ; do echo -e \" \${ICON[\$key]} : \${key}\" ; done ) | column -c \${COLUMNS:-80}"

# }}}

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
    es 
}

function es_center() {
    if es_called_by_pipe ; then
        while read data ; do
            local length=$( echo ${data} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m)
            seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
                echo -n " "
            done
            echo -e "$data"
        done
    else
        echo "$@" | while read data ; do
            local length=$( echo ${data} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m)
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
                local length=$( echo ${data} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m)
            fi
            seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
                echo -n " "
            done
            echo -e "$data"
        done
    else
        echo "$@" | while read data ; do
            if [ -z "$length" ] ; then
                local length=$( echo ${data} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m)
            fi
            seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
                echo -n " "
            done
            echo -e "$data"
        done
    fi
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

function es() {
    es_out
    es_banner
    es_out
    es_out "$( color white_bold )ENVIRONMENT:$( color )"
    es_out "* USER: ${ESSENTIALS_USER}"
    es_out "* HOME: ${ESSENTIALS_HOME}/"
    es_out "* DIR CACHE: ${ESSENTIALS_DIR_CACHE}/"
    es_out "* DIR LOG: ${ESSENTIALS_DIR_LOG}/"
    es_out "* SUDO: ${ESSENTIALS_IS_SUDO}"
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

function es_exit() {
    es_debug "${2}" "error"
    exit ${1:-0}
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
    [ -n "${BASH_SOURCE[2]}" ]
}

function es_called_by_exec() {
    [ "$( realpath ${0} )" == "$( realpath ${BASH_SOURCE[0]} )" ]
}

function es_tmp_dir() {
    dir=${@:-$( pwd )}
    echo "${dir}"
}

function es_tmp_file() {
    #todo: implement
    echo ""
}

function es_grep() {
    grep -r ${@:-^} ${ESSENTIALS_HOME}/.bashrc ${ESSENTIALS_DIR}/*sh ${ESSENTIALS_HOME}/.profile
}

function es_edit() {
    ${EDITOR} ${ESSENTIALS_HOME}/.bashrc ${ESSENTIALS_DIR}/*sh ${ESSENTIALS_HOME}/.profile ${@}
}

function vr(){ echo -e "\n\n\n\n\n"; }
function hr() { for i in $( seq ${COLUMNS:-80} ); do echo -n "="; done; echo; };

function t() { true; }
function f() { false; }
function r() { return ${1}; }

export BOOLEAN=(true false)
export extensions_video='avi,mkv,mp4,mpg,mpeg,wmv,wmvlv,webm,3g,mov,flv'
export extensions_images='png,jpg,jpeg,gif,bmp,tiff,ico,lzw,raw,ppm,pgm,pbm,psd,img,xcf,psp,svg,ai'
export extensions_audio='flac,mp1,mp2,mp3,ogg,wav,aac,ac3,dts,m4a,mid,midi,mka,mod,oma,wma'
export extensions_documents='asc,rtf,txt,abw,zabw,bzabw,chm,pdf,doc,docx,docm,odm,odt,ods,ots,sdw,stw,wpd,wps,pxl,sxc,xlsx,xlsm,odg,odp,pps,ppsx,ppt,pptm,pptx,sda,sdd,sxd,dot,dotm,dotx,mobi,prc,epub,pdb,prc,tpz,azw,azw1,azw3,azw4,kf8,lit,fb2'
export extensions_archives='7z,s7z,ace,arj,bz,bz2,bzip,bzip2,gz,gzip,lha,lzh,rar,r0,r00,tar,taz,tbz,tbz2,tgz,zip,rpm,deb'

