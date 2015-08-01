#!/bin/bash

# default output
function es_msg() {
    echo "${2}> $1"
}

function es_warning() {
    es_msg "$1" "WARNING"
}

function es_error() {
    es_msg "$1" "ERROR"
}

# debug output (will be printed only if debug is enabled)
function es_debug() {
    ${ESSENTIALS_DEBUG} && es_msg "$1" "DEBUG"
}

# reload essentials libs
function es_reload() {
    reset
    . ${ESSENTIALS_DIR}/essentials.sh
}

# toggle debug
function es_debug_toggle() {
    ( $ESSENTIALS_DEBUG ) && export ESSENTIALS_DEBUG=false || export ESSENTIALS_DEBUG=true
    es_reload
    es_info
}

function es_info() {
    es_banner
    es_msg "$( color white_bold )ENVIRONMENT:$( color )"
    es_msg " USER: ${ESSENTIALS_USER}"
    es_msg " HOME: ${ESSENTIALS_HOME}/"
    es_msg " DIR CACHE: ${ESSENTIALS_DIR_CACHE}/"
    es_msg " DIR LOG: ${ESSENTIALS_DIR_LOG}/"
    es_msg " SUDO: ${ESSENTIALS_IS_SUDO} (unlocked: ${ESSENTIALS_IS_SUDO_UNLOCKED})"
    es_msg " ROOT: ${ESSENTIALS_IS_ROOT}"
    es_msg " SSH: ${ESSENTIALS_IS_SSH}"
    es_msg " MOSH: ${ESSENTIALS_IS_MOSH}"
    es_msg " TMUX: ${ESSENTIALS_IS_TMUX}"
    es_msg " SCREEN: ${ESSENTIALS_IS_SCREEN}"
    es_msg
    es_msg "$( color white_bold )SSH AGENT:$( color )"
    es_msg " AGENT RUNNING: ${ESSENTIALS_HAS_SSHAGENT} (pid ${SSH_AGENT_PID:-UNKNOWN})"
    es_msg
    es_msg "$( color white_bold )EXTERNALS:$( color )"
    es_msg " BASH VERSION: ${BASH_VERSION}"
    es_msg " GIT VERSION: ${ESSENTIALS_VERSION_GIT}"
    es_msg " VIM VERSION: ${ESSENTIALS_VERSION_VIM}"
    es_msg " HOME REPO: ${ESSENTIALS_VERSION_HOME} (commit $( es_repo_version ${ESSENTIALS_HOME} | sed 's| |, |'))"
    es_msg
    es_msg "$( color white_bold )ESSENTIALS:$( color )"
    es_msg " VERSION: ${ESSENTIALS_VERSION} (commit $( es_repo_version ${ESSENTIALS_DIR} | sed 's| |, |'))"
    es_msg " DIR ESSENTIALS: ${ESSENTIALS_DIR}/"
    es_msg " DEBUG: ${ESSENTIALS_DEBUG}"
    es_msg " LOG: ${ESSENTIALS_LOG} (-> ${ESSENTIALS_LOGFILE})"
    es_msg " FUNCTIONS: $( grep "^[ ]*function[^)]\+)" ${ESSENTIALS_DIR}/*sh | wc -l )"
    es_msg " ALIASES: $( grep "^[ ]*alias [^ ]\+=" ${ESSENTIALS_DIR}/*sh | wc -l )"
    es_msg
    es_msg "$( color white_bold )APPLICATIONS:$( color )"
    es_msg " EDITOR: ${EDITOR}"
    es_msg " PAGER: ${PAGER}"
    es_msg " BROWSER: ${BROWSER}"
    es_msg " TERMINAL: ${TERMINAL}"
    es_msg
}

function es_check_version() {
    local required_version=$( echo "$1" | sed 's|[^0-9\.]*||g' )
    local compare_version=$( echo "$2" | sed 's|[^0-9\.]*||g' )
    local higher_version=$( echo -e "${required_version}\n${compare_version}" | sort -V | head -n1 )
    [[ "$required_version" = "${higher_version}" ]]
}

function es_depends() {
    local depends_name="$1"
    local depends_type="${2:-bin}"
    local available=false

    case "$depends_type" in
        bin|which|executable)
            which $depends_name >/dev/null && available=true
            ;;

        dpkg|deb|debian)
            es_depends dpkg || exit_error 'please install dpkg if you want to check depends via dpkg'
            dpkg -l | grep -iq "^ii\ \ ${depends_name}\ " && available=true
            ;;

        pip)
            es_depends pip || exit_error 'please install (python-)pip, to check depends via pip'
            local pip_version=$( pip --version | awk {'print $2'} )

            if ( es_check_version 1.3 $pip_version ) ; then
                local pip_output=$( pip show $depends_name 2>/dev/null | xargs | awk {'print $3"=="$5'} | sed '/^==$/d' )
            else
                local pip_output=$( pip freeze 2>/dev/null | grep "^${depends_name}=" )
            fi

            [[ -n "$pip_output" ]] && available=true
            ;;

        *)
            es_depends $depends_name bin && available=true
            ;;
    esac

    return $( $available )
}

function es_depends_essentials() {
    if ( [ -z "$PS1" ] || [ -z "$BASH_VERSION" ] ) ; then
        es_error "shell is not bash"
        return 1
    fi

    return 0
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

function es_center() {
    local data line
    
    if es_called_by_pipe ; then
        while read line ; do
            data="${data}${line}\n"
        done
        data=$( echo "${data}" | sed 's|\\n$||g' )
    else
        data="${@}"
    fi

    echo -e "${data}" | while read line ; do
        local length=$( echo ${line} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m )
        seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
            echo -n " "
        done
        echo -e "$line"
    done
}

function es_center_aligned() {
    local data line
    
    if es_called_by_pipe ; then
        while read line ; do
            data="${data}${line}\n"
        done
        data=$( echo "${data}" | sed 's|\\n$||g' )
    else
        data="${@}"
    fi

    echo -e "${data}" | while read line ; do
        if [ -z "$length" ] ; then
            local length=$( echo ${line} | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -m )
        fi
        seq 1 $((( ${COLUMNS} - ${length}) / 2 )) | while read i ; do
            echo -n " "
        done
        echo -e "$line"
    done
}

function es_header() {
    echo -e "\n$( es_center_aligned "${@}" )\n"
}

function es_repo_version() {
    local repo="${@:-${ESSENTIALS_DIR}}"
    
    es_debug "updating repo ${repo}"
    cd "${repo}"
    if [ -e ".git" ] ; then
        git log --pretty=format:'%h %cr' -1
    elif [ -e ".hg" ] ; then
        cd $OLDPWD
        es_error "mercurial verion not implemented"
        return 1
    elif [ -e ".svn" ] ; then
        cd $OLDPWD
        cd $OLDPWD
        es_error "SVN version not implemented"
        return 1
    elif [ -d "CVS" ] ; then
        cd $OLDPWD
        es_error "CVS versoin not implemented"
        return 1
    else
        cd $OLDPWD
        es_error "couldn't find repo type for: $repo"
        return 1
    fi
    local status=$?
    cd $OLDPWD
    
    return $status
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
    [[ "$( realpath ${0} )" != "$( realpath ${BASH_SOURCE[0]} )" ]]
}

function es_called_by_exec() {
    [[ "$( realpath ${0} )" == "$( realpath ${BASH_SOURCE[0]} )" ]]
}

