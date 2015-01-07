#!/bin/bash

# find essentials_dir
export ESSENTIALS_DIR="${ESSENTIALS_DIR:-$( dirname $( realpath ${BASH_SOURCE[0]}))}"

# include the essential libs
tmpname="resources.sh prompt.sh functions.sh applications.sh"
for script in $tmpname ; do
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
for bin in $tmpname ; do
    es_depends "${bin}" "bin" || es_return 1 "missing depends for essentials: ${bin}"
done

# check optional depends
tmpname="toilet toilet-fonts git vim-nox colordiff wdiff fping"
for pkg in $tmpname ; do
    es_depends "${pkg}" "debian" || es_out "optional depends $pkg missing" "warning"
done

# settings
export ESSENTIALS_USER="${ESSENTIALS_USER:-${SUDO_USER:-${USER}}}"
export ESSENTIALS_HOME="${ESSENTIALS_HOME:-$( getent passwd ${ESSENTIALS_USER} | cut -d':' -f6 )}"
export ESSENTIALS_DIR_PKGLISTS="${ESSENTIALS_HOME}/.packages"
export ESSENTIALS_DIR_FONTS="${ESSENTIALS_HOME}/.fonts"
export ESSENTIALS_DIR_WALLPAPERS="${ESSENTIALS_HOME}/.backgrounds"
export ESSENTIALS_DIR_LOG="${ESSENTIALS_HOME}/.log"
export ESSENTIALS_DIR_CACHE="${ESSENTIALS_HOME}/.cache"
export ESSENTIALS_LOGFILE="${ESSENTIALS_DIR_LOG}/essentials.log"
export ESSENTIALS_CACHEFILE="${ESSENTIALS_DIR_CACHE}/essentials.cache"
export ESSENTIALS_DEBUG="${ESSENTIALS_DEBUG:-true}"
export ESSENTIALS_LOG="${ESSENTIALS_LOG:-true}"
export ESSENTIALS_COLORS="${ESSENTIALS_COLORS:-true}"
export ESSENTIALS_UNICODE="${ESSENTIALS_UNICODE:-true}"
export ESSENTIALS_VERSION=$( es_repo_version_date )
export ESSENTIALS_VERSION_VIM=$( vim --version | grep -o "[0-9.]\+" | head -n 1 )
export ESSENTIALS_VERSION_GIT=$( git --version | sed 's/git version //' )
export ESSENTIALS_IS_SUDO=$( pstree -s "$$" | grep -qi 'sudo' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_ROOT=$( [ $( id -u ) -eq 0 ] && ! ${ESSENTIALS_IS_SUDO} ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_UID0=$( ${ESSENTIALS_IS_SUDO} || ${ESSENTIALS_IS_ROOT} ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_SSH=$( pstree -s "$$" | grep -qi 'ssh' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_MOSH=$( pstree -s "$$" | grep -qi 'mosh' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_TMUX=$( pstree -s "$$" | grep -qi 'tmux' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_SCREEN=$( pstree -s "$$" | grep -qi 'screen' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_HAS_SSHAGENT=$( [ -n "$( ps hp ${SSH_AGENT_PID} 2>/dev/null )" ] ; echo ${BOOLEAN[$?]} ) 

# in debug mode -> print banner + settings overview 
${ESSENTIALS_DEBUG} && es

# cleanup
unset tmpname script pkg

