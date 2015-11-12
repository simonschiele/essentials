#!/bin/bash

# es_warning will be overwritten from utils.sh after load
function es_warning() {
   echo "WARNING> $1" >&2
}

function es_load_libraries() {
    local include
    local status=0
    local libs="${1:-utils.sh colors.sh icons.sh functions.sh prompt.sh applications.sh keybinds.sh ssh.sh}"
    
    for include in $libs ; do
        if [ -r ${ESSENTIALS_DIR}/${include} ] ; then
            . ${ESSENTIALS_DIR}/${include}
        else
            es_warning "include ${include} not found"
            status=1
        fi
    done
    
    return $status
}

# helper
export BOOLEAN=(true false)
export EXTENSIONS_VIDEO='avi,mkv,mp4,mpg,mpeg,wmv,wmvlv,webm,3g,mov,flv'
export EXTENSIONS_IMAGES='png,jpg,jpeg,gif,bmp,tiff,ico,lzw,raw,ppm,pgm,pbm,psd,img,xcf,psp,svg,ai'
export EXTENSIONS_AUDIO='flac,mp1,mp2,mp3,ogg,wav,aac,ac3,dts,m4a,mid,midi,mka,mod,oma,wma'
export EXTENSIONS_DOCUMENTS='asc,rtf,txt,abw,zabw,bzabw,chm,pdf,doc,docx,docm,odm,odt,ods,ots,sdw,stw,wpd,wps,pxl,sxc,xlsx,xlsm,odg,odp,pps,ppsx,ppt,pptm,pptx,sda,sdd,sxd,dot,dotm,dotx,mobi,prc,epub,pdb,prc,tpz,azw,azw1,azw3,azw4,kf8,lit,fb2'
export EXTENSIONS_ARCHIVES='7z,s7z,ace,arj,bz,bz2,bzip,bzip2,gz,gzip,lha,lzh,rar,r0,r00,tar,taz,tbz,tbz2,tgz,zip,rpm,deb'

# find essentials_dir
export ESSENTIALS_DIR="${ESSENTIALS_DIR:-$( dirname $( readlink -f ${BASH_SOURCE[0]}))}"

# find (real) user/home
export ESSENTIALS_USER="${ESSENTIALS_USER:-${CONFIG['user']:-${SUDO_USER:-${USER}}}}"
export ESSENTIALS_HOME="${ESSENTIALS_HOME:-${CONFIG['home']:-$( getent passwd ${ESSENTIALS_USER} | cut -d':' -f6 )}}"
export ESSENTIALS_USER="${ESSENTIALS_USER:-${SUDO_USER:-${USER}}}"
export ESSENTIALS_HOME="${ESSENTIALS_HOME:-$( getent passwd ${ESSENTIALS_USER} | cut -d':' -f6 )}"

# loading essential libs
es_load_libraries || es_warning "problems including one or more libraries"

# adding essentials bin/ to path
[ -d ${ESSENTIALS_DIR}/bin ] && PATH="${ESSENTIALS_DIR}/bin:${PATH}"

# essential settings
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
export ESSENTIALS_IS_SUDO_UNLOCKED=$( sudo -n echo -n 2>/dev/null ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_ROOT=$( [ $( id -u ) -eq 0 ] && ! ${ESSENTIALS_IS_SUDO} ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_UID0=$( ${ESSENTIALS_IS_SUDO} || ${ESSENTIALS_IS_ROOT} ; echo ${BOOLEAN[$?]} )  # rename
export ESSENTIALS_IS_SSH=$( pstree -s "$$" | grep -qi 'ssh' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_MOSH=$( pstree -s "$$" | grep -qi 'mosh' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_TMUX=$( pstree -s "$$" | grep -qi 'tmux' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_IS_SCREEN=$( pstree -s "$$" | grep -qi 'screen' ; echo ${BOOLEAN[$?]} )
export ESSENTIALS_HAS_SSHAGENT=$( [ -n "$( ps hp ${SSH_AGENT_PID} 2>/dev/null )" ] ; echo ${BOOLEAN[$?]} )
