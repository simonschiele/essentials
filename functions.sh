#!/bin/bash

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

# {{{ worldclock()

worldclock() { 
    zones="America/Los_Angeles America/Chicago America/Denver America/New_York Iceland Europe/London"
    zones="${zones} Europe/Paris Europe/Berlin Europe/Moscow Asia/Hong_Kong Australia/Sydney"

    for tz in $zones 
    do 
        local tz_short=$( echo ${tz} | cut -f'2' -d'/' )
        echo -n -e "${tz_short}\t"
        [[ ${#tz_short} -lt 8 ]] && echo -n -e "\t"
        TZ=${tz} date
    done
    unset tz zones
}

# }}}

# {{{ debian.packages_custom_get()

debian.packages_custom_get() {
    local listtype="${1}.list"
    local pkglist="${HOME}/.packages/${listtype}"

    if ! [ -e $pkglist ] || [ -z "${@}" ]
    then
        echo "Unknown Systemtype '$pkglist'"
        return 1
    fi
    
    local lists="$listtype $(grep ^[\.] $pkglist | sed 's|^[\.]\ *||g')"
    lists=$( echo $lists | sed "s|\([A-Za-z0-9]*\.list\)|${HOME}/.packages/\1|g" )

    sed -e '/^\ *$/d' -e '/^\ *#/d' -e '/^[\.]/d' $lists | cut -d':' -f'2-' | xargs
}

# }}}

# {{{ scan.*

alias scan.wlans='/sbin/iwlist scanning 2>/dev/null | grep -e "Cell" -e "Channel:" -e "Encryption" -e "ESSID" -e "WPA" | sed "s|Cell|\nCell|g"'

function scan.hosts() { 
    local routing_interface=$( LANG=C /sbin/route -n | grep "^[0-9 :\.]\+ U .*[a-z]\+[0-9]\+" | head -n 1 )
    local routing_interface=${routing_interface##* }
    local network="$( LANG=C /sbin/ifconfig ${routing_interface} | grep -o 'inet addr[^ ]*' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.' )0/24"
    fping -q -a -g ${network} | while read ip ; do 
        echo -ne "${ip}\t"
        echo -e "$( host -W 1 ${ip} | grep -o '[^ ]*.$' | sed 's|\.$||g' )"
    done 
}

# }}} 

# {{{ convert2()

convert2() {
    ext=${1} ; shift ; for file ; do echo -n ; [ -e "$file" ] && ( echo -e "\n\n[CONVERTING] ${file} ==> ${file%.*}.${ext}" && ffmpeg -loglevel error -i "${file}" -strict experimental "${file%.*}.${ext}" && echo rm -i "${file}" ) || echo "[ERROR] File not found: ${file}" ; done
}

# }}}

# {{{ keyboard_kitt()

function keyboard_kitt() {
	# copyright 2007 - 2010 Christopher Bratusek
	setleds -L -num;
	setleds -L -caps;
	setleds -L -scroll;
	while :; do
		setleds -L +num;
		sleep 0.2;
		setleds -L -num;
		setleds -L +caps;
		sleep 0.2;
		setleds -L -caps;
		setleds -L +scroll;
		sleep 0.2;
		setleds -L -scroll;
		setleds -L +caps;
		sleep 0.2;
		setleds -L -caps;
	done
	resetleds
}

# }}}

# {{{ confirm()

function confirm.whiptail_yesno() {
    whiptail --yesno "${1:-Are you sure you want to perform 'unknown action'?}" 10 60
}

function confirm.yesno() {
    while read -p "${1:-Are you sure (Y/N)? }" -r -n 1 -s answer; do
        if [[ $answer = [YyNn] ]]; then
            [[ $answer = [Yy] ]] && ( echo ; return 0 ) 
            [[ $answer = [Nn] ]] && ( echo ; return 1 ) 
            break
        fi
    done
}

function confirm.keypress() {
    local keypress
    read -s -r -p "${1:-Press any key to continue...}" -n 1 keypress
}

# }}}

# {{{ whereami()
function whereami() {

    ips=$( /sbin/ifconfig | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | sort -u | grep -v -e "^127" -e "^255" )
    if ( grep -q -i wlan-ap[0-9] <( /sbin/iwconfig 2>&1 )) && ( grep -q -i 192\.168\.190 <( /sbin/ifconfig 2>&1 )) ; then 
        echo "work-mobile" 
    elif ( echo $ips | grep -q -e "192\.168\.[78]0" -e "195\.4\.7[01]" ) ; then
        echo "work"
    elif ( echo $ips | grep -q -e "192\.168\.5" ) ; then
        echo "home"
    else
        echo "unknown"
    fi
}

# }}}

# {{{ verify_su()

function verify_su() {
    if [ "$( id -u )" == "0" ] ; then
        return 0 
    elif ( sudo -n echo -n ) ; then
        return 0
    elif ( sudo echo -n ) ; then
        return 0
    else
        return 1
    fi
}

# }}} 

# {{{ debian.add_pubkey()

function debian.add_pubkey() {
    if ! verify_su ; then
        echo "you need root/sudo permissions to call debian_add_pubkey" 1>&2 
        return 1
    elif [ -z "${1}" ] ; then
        echo "Please call like:"
        echo " > debian_add_pubkey path/to/file.key" 
        echo "or"
        echo " > debian_add_pubkey 07DC563D1F41B907" 
    elif [ -e ${1} ] ; then
        echo "import via keyfile not implemented yet" 1>&2 
        return 1
    else
        if ( sudo gpg --keyserver pgpkeys.mit.edu --recv-key ${1} ) && ( sudo gpg -a --export ${1} | sudo apt-key add - ) ; then
            return 0
        else
            return 1
        fi
    fi
}

# }}} 

# {{{ debian.security()

function debian.security() { 
    wget -q -O- https://www.debian.org/security/dsa \
        | xml2 \
        | grep -o -e "item/title=.*$" -e "item/dc:date=.*$" -e "item/link=.*$" \
        | tac \
        | cut -f'2-' -d'=' \
        | sed -e ':a;N;$!ba;s/\n/ /g' -e 's/\(20[0-9]\{2\}-\)/\n\1/g' \
        | awk {'print $1" "$4" ("$2")"'} \
        | sed "s|^|\ \ $( echo -e ${ICON[fail]})\ \ |g" \
        | tac \
        | head -n ${1:-6}
}

# }}}

# {{{ web.google()

function web.google() {
    Q="$@";
    GOOG_URL='https://www.google.com/search?tbs=li:1&q=';
    AGENT="Mozilla/4.0";
    stream=$(curl -A "$AGENT" -skLm 10 "${GOOG_URL}${Q//\ /+}");
    echo "$stream" | grep -o "href=\"/url[^\&]*&amp;" | sed 's/href=".url.q=\([^\&]*\).*/\1/';
    unset stream AGENT GOOG_URL Q
}

# }}} 

# {{{ nzb.queue()

function nzb.queue() {
    local target=/share/.usenet/queue/
    local delete=true

    if [ ! -d ${target} ] ; then
        echo "Local target not available -> will use 'ssh enkheim.psaux.de'" >&2
        local action="scp -P2222"
        local target="simon@enkheim.psaux.de:${target}"
    else
        local action="mv -v"
        local delete=false
    fi
    
    if [[ -z "${@}" ]] ; then
        if ls ~/Downloads/*[nN][zZ][bB] 2>/dev/null >&2 ; then
            if ( ${action} ~/Downloads/*[nN][zZ][bB] ${target} ) ; then
                ( ${delete} ) && rm -ri ~/Downloads/*[nN][zZ][bB]
            fi
        else
            echo "No nzb files found in the following dirs:" >&2
            echo " ~/Downloads/" >&2
            return 1
        fi
    else
        if ( ${action} ${@} ${target} ) ; then
            if [[ "$@" != "/" ]] && [[ "$@" != "." ]] && [[ "$@" != "" ]] ; then
                ( ${delete} ) && rm -ri ${@}
            fi
        fi
    fi
}

# }}} 

# {{{ return.unicode()

function return.unicode() {
    if [ ${1} -gt 0 ] ; then
        echo -e " ${COLOR[red]}${ICON[fail]}${COLOR[none]}" 
    else
        echo -e " ${COLOR[green]}${ICON[success]}${COLOR[none]}" 
    fi
    
    return ${1}
}

# }}} 

# {{{ show.repo()

function show.repo() {
    local debug
}

# }}}

# {{{ update.repo()

function update.repo() {
    local debug dir repo
    shopt -s extglob
   
    debug=true
    dir=${1:-$( pwd )}
    dir=${dir%%+(/)}
   
    repo=false
    submodule=false
    below_repo=false
    
    if [ -d "${dir}/.git" ] && [ -e "${dir}/.git/index" ] ; then
        repo=true
    elif [ -e "${dir}/.git" ] && [ -d "$( head -n 1 "${dir}/.git" | cut -f'2' -d' ' )" ] ; then
        submodule=true
    elif ( LANG=C git rev-parse 2>/dev/null ) ; then
        below_repo=true
        return 2 
    else
        echo "error: '$( pwd )' is not inside a repository" >&2
        return 1
    fi

    return 0 
    
    if [ -d .git ] && [ -e ${diri} ] ; then
        echo ${dir}
    elif [] ; then
        echo -n
    else
        echo -n
    fi
    
    return 0
    
    local repo="${1}"
    local dir="${2}"

    if [ ! -d "${dir}" ] ; then
        echo -en "  ${ICON['whitecircle']}  Initializing ${dir} (via ${repo})"
        local out=$( LANG=C git clone --recursive "${repo}" "${dir}" 2>&1 )
        echo -en "\r  ${ICON['blackcircle']}  Initializing ${dir} (via ${repo})"
        local ret=$?
    else
        echo -en "  ${ICON['blackcircle']}  Updating ${dir}"
        cd "${dir}" 2>/dev/null && local out=$( LANG=C git pull --recurse-submodules=yes 2>&1 )
        local ret=$? ; [ $ret -eq 0 ] && cd ${OLDPWD}
    fi
    
    return.unicode $ret
    return $ret
}

# }}}

# {{{ spinner()

function spinner() {
    local pid=$1
    while [ -d /proc/$pid ] ; do
        echo -n '/^H' ; sleep 0.05
        echo -n '-^H' ; sleep 0.05
        echo -n '\^H' ; sleep 0.05
        echo -n '|^H' ; sleep 0.05
    done
    return 0
}

# }}}

# {{{ echo.centered()

function echo.centered() {
    printf "%*s\n" $(( ${#1} + ( ${COLUMNS} - ${#1} ) / 2 )) "${1}"
}

# }}}

# {{{ echo.header()

function echo.header() {
    echo -e "\n$( echo.centered "${@}" )\n"
}

# }}}

# {{{ show.stats()

function show.stats() {
    color.echon "white_bold" "Date: " ; date +'%d.%m.%Y (%A, %H:%M)'
    color.echon "white_bold" "Host: " ; hostname
    color.echon "white_bold" "Location: " ; whereami
    color.echon "white_bold" "Systemtype: " ; echo "${system_type}"
    
    echo -e "\n${COLOR[white_under]}${COLOR[white_bold]}Hardware:${COLOR[none]}"
    
    cpu=$( grep "^model\ name" /proc/cpuinfo | sed -e "s|^[^:]*:\([^:]*\)$|\1|g" -e "s/[\ ]\{2\}//g" -e "s|^\ ||g" )
    echo -e 'cpu: '$( echo -e "$cpu" | wc -l )'x '$( echo "$cpu" | head -n1 )
    
    ram=$( LANG=c free -m | grep ^Mem | awk {'print $2'} )
    echo -ne "ram: ${ram}mb (free: $( free -m | grep cache\: | awk {'print $4'} )mb, "
    #free | awk '/Mem/{printf("used: %.2f%"), $3/$2*100} /buffers\/cache/{printf(", buffers: %.2f%"), $4/($3+$4)*100} /Swap/{printf(", swap: %.2f%"), $3/$2*100}'
    
    local swap=$( LANG=c free | grep "^swap" | sed 's|^swap\:[0\ ]*||g' )
    [ -z "$swap" ] && echo -n "swap: no active swap" || echo -n "swap: ${swap}"
    echo ")" 
    
    LANG=C df -h | grep "\ /$" | awk {'print "hd: "$2" (root, free: "$4")"'}
}

# }}}

# {{{ good_morning()

function good_morning() {
    for i in ${@} ; do
        echo $i
    done

    local status=0
    local has_root=false
    
    clear
    echo.header "${COLOR[white_bold]}Good Morning, ${SUDO_USER:-${USER^}}!${COLOR[none]}"
    show.stats

    if [ $( id -u ) -eq 0 ] ; then
        has_root=true
        sudo_cmd=""
    elif ( sudo -n echo -n 2>/dev/null ) ; then
        has_root=true
        sudo_cmd="sudo"
    fi

    if ! ( ${has_root} ) ; then
        echo -e "\n${COLOR[white_under]}${COLOR[white_bold]}sudo:${COLOR[none]}"
        if ! ( sudo echo -n ) ; then
            echo -e "\n${COLOR[red]}error${COLOR[none]}: couldn't unlock sudo\n" >&2
            return 1
        else
            has_root=true
            sudo_cmd="sudo"
        fi
    fi
   
    echo -e "\n${COLOR[white_under]}${COLOR[white_bold]}Debian:${COLOR[none]}"
    echo "version: $( lsb_release -ds 2>&1 )"
    
    echo -n "updating packagelists: "
    local out=$( ${sudo_cmd} apt-get update 2>&1 )
    local ret=$?
    if [ $ret -eq 0 ] ; then
        echo -e "success ${COLOR[green]}${icon[ok]}${COLOR[none]}"
    else
        echo -e "failed ${COLOR[red]}${icon[fail]}${COLOR[none]}"
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
    
    echo.header "${COLOR[white_bold]}Have a nice day, ${SUDO_USER:-${USER^}}! (-:${COLOR[none]}"
    return $status
}

# }}}

# {{{ no.sleep()

function no.sleep() {
    pkill -f screensaver
    ( pgrep screensaver ) && echo "error: couldn't kill screensaver" && return 1
    xset -display ${DISPLAY:-:0} -dpms
}

# }}} 

# {{{ show.*()

function show.tlds() {
    [ ! -d ${HOME}/.cache/bash/ ] && mkdir -p ${HOME}/.cache/bash/
    if [ ! -e ${HOME}/.cache/bash/tlds ] ; then
        wget -q "http://data.iana.org/TLD/tlds-alpha-by-domain.txt" -O ${HOME}/.cache/bash/tlds
    fi
    grep -v -e "^\ *$" -e "^\ *#" ${HOME}/.cache/bash/tlds
}

function grep.tld() {
    local input
     
    function process() {
        local iinput
        echo "${1}" | grep -o "[^\ \"\']\+\.[A-Za-z]\+" | while read iinput ; do
            local clean_input=${iinput##*.}
            show.tlds | grep "^${clean_input}$"
        done
    }
    
    while read -t 1 -r input ; do
        [ -z "${input}" ] && break 
        process "${input}"
    done

    for input in ${@} ; do
        process "${input}"
    done
     
    unset process    
}

function show.path() {
    local path="${1}"
    local path_real=$( realpath "${path}" )
    local filetype=$( file -b "${path}" ) 
    local filetype_real=$( file -b "${path_real}" )
    local size=$( ls -s "${path_real}" | awk {'print $1'} )
    local size_human=$( ls -sh "${path_real}" | awk {'print $1'} )
    
    echo -e "name:\t\t$( color white_bold )${path}$( color none )"
    echo -e "type:\t\t${filetype}"
    
    if [ -h "${path}" ] ; then
        echo -e "real path:\t${path_real}"
        echo -e "real type:\t${filetype_real}"
    fi
    
    if [ -d "${real_path}" ] ; then
        echo 
    else
        echo -e "size:\t\t${size_human} (${size})"
        echo  
    fi
}

alias show.dir=show.path
alias show.file=show.path

function show.host() {
    local ip=$( echo "${1}" | grep.ip | head -n 1 )
    local host=${1}
    
    if [ -n "$host" ] && [ -z "$ip" ] ; then
        ip=$( host ${host} | grep "has address " | grep.ip )
    elif [ -n "$ip" ] ; then
        host=$( host ${ip} | grep "domain name pointer" | sed 's|.*pointer\ \(.*\)\.$|\1|g' )
    else
        echo "'${1}' neither ip address nor hostname"
        return 1
    fi
    
    echo "host: ${host}" 
    echo "ip: ${ip}" 
}

function show() {
    if [ -z "${1}" ] ; then
        echo "usage: show <file|dir|url|ip|int|string>"
    elif [ -e "${1}" ] ; then
        show.path "${1}"
    elif echo "${1}" | grep.ip ; then
        show.host "${1}"
    elif ( echo "${1:$((${#1}-8))}" | grep -q "\." ) && ( show.tlds | grep $( echo "${1:$((${#1}-8))}" | cut -f"2-" -d"." ) ) ; then
        show.host "${1}"
    else
        echo "input not identified"
    fi
}

# }}}

function is.systemd() { 
    sudo LANG=C lsof -a -p 1 -d txt | grep -q "^systems\ *1\ *"
    return $?
}

function git.subupd() {
    git submodule foreach git fetch origin --tags && git pull && git submodule update --init --recursive
}

function git.is_submodule() {
     (cd "$(git rev-parse --show-toplevel)/.." && git rev-parse --is-inside-work-tree) | grep -q true
}

function git.dirty_ignore() {
    local dot_git=$( git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git rev-parse --git-dir 2>/dev/null )
    
    if [ -z "$dot_git" ] ; then
        echo "Couldn't find repo" >&2
        return 1
    fi
     
    #"config" -> "ignore = dirty"
}

# {{{ laptop stuff

function save.battery_lifetime() {
    echo 15 > /sys/devices/platform/smapi/BAT0/start_charge_thresh
    echo 85 > /sys/devices/platform/smapi/BAT0/stop_charge_thresh
}

function save.battery() {
    if ! [ $( id -u ) -eq 0 ] ; then 
        echo "please use root or sudo -s" >&2
        return 1
    fi
    
    es_debug " * setting gov powersave for all $( grep ^process /proc/cpuinfo | wc -l ) cores"
    ${ESSENTIALS_DEBUG} && echo -n "[LOG]   " >&2
    seq 0 $( grep ^process /proc/cpuinfo | tail -n 1 | grep -o "[0-9]" ) | while read i ; do
        ${ESSENTIALS_DEBUG} && echo -n " ${i}" >&2
        cpufreq-set -c ${i} -g powersave
    done
    ${ESSENTIALS_DEBUG} && echo "" >&2
    
    es_debug " * turn off NMI watchdog"
    echo '0' > '/proc/sys/kernel/nmi_watchdog'
   
    es_debug " * auto suspend bluetooth"
    echo 'auto' > /sys/bus/usb/devices/1-1.4/power/control

    es_debug " * auto suspend umts modem"
    echo 'auto' > /sys/bus/usb/devices/2-1.4/power/control

    es_debug " * deactivate WOL for eth0"
    ethtool -s eth0 wol d
  
    es_debug " * enable audio codec power management"
    echo '1' > /sys/module/snd_hda_intel/parameters/power_save

    es_debug " * setting VM writeback timeout to 1500"
    echo '1500' > /proc/sys/vm/dirty_writeback_centisecs

    es_debug " * wireless power saving for wlan0"
    iw dev wlan0 set power_save on
    
    es_debug " * activating sata link power managenment on host0-host$(( $( ls /sys/class/scsi_host/host*/link_power_management_policy | wc -l ) - 1 ))"
    seq 0 $(( $( ls /sys/class/scsi_host/host*/link_power_management_policy | wc -l ) - 1 )) | while read i ; do
        echo 'min_power' > /sys/class/scsi_host/host${i}/link_power_management_policy
    done

    es_debug " * enabling power control for pci bus"
    for f in ls /sys/bus/pci/devices/*/power/control ; do echo 'auto' > "$f" ; done

    es_debug " * enabling power control for usb bus"
    for f in ls /sys/bus/usb/devices/*/power/control ; do echo 'on' > "$f" ; done
    for f in ls /sys/bus/usb/devices/*/power/control ; do echo 'auto' > "$f" ; done
}

alias show.battery='upower -d | grep -e state -e percentage -e time | sort -u | tr "\n" " " | sed "s|^[^0-9]*\([0-9]*%\)[^:]*:\ *\([^\ ]*\)[^0-9\.]*\([0-9\.]*\)[^0-9]*$|(\1, \2, \3h)|g"; echo'

# }}}

# sudo stuff
alias sudo='sudo '
alias sudo.that='eval "sudo $(fc -ln -1)"'
alias sudo.password_disable='sudo grep -iq "^${SUDO_USER:-${USER}}.*NOPASSWD.*ALL.*$" /etc/sudoers && echo "entry already in /etc/sudoers" >&2 || sudo bash -c "echo -e \"${SUDO_USER:-${USER}}\tALL = NOPASSWD:  ALL\n\" >> /etc/sudoers"'
alias sudo.password_enable='sudo grep -iq "^${SUDO_USER:-${USER}}.*NOPASSWD.*ALL.*$" /etc/sudoers && sudo sed -i "/^${SUDO_USER:-${USER}}.*NOPASSWD.*ALL.*$/d" /etc/sudoers || echo "entry not in /etc/sudoers" >&2'


# system
alias create.system_user='sudo adduser --no-create-home --disabled-login --shell /bin/false'
alias observe.pid='strace -T -f -p'

# package and system-config
alias debian.version='lsb_release -a'
alias debian.bugs='bts'
alias debian.packages_custom='debian.packages_custom_get $(grep ^system_type ~/.system.conf | cut -f"2-" -d"=" | sed "s|[\"]||g")'
alias debian.packages_by_size='dpkg-query -W --showformat="\${Installed-Size;10}\t\${Package}\n" | sort -k1,1n'
alias debian.package_configfiles='dpkg-query -f "\n${Package} \n${Conffiles}\n" -W'

# logs
alias log.dmesg='dmesg -T --color=auto'
alias log.pidgin='find ~/.purple/logs/ -type f -mtime -5 | xargs tail -n 5'
alias log.NetworkManager='sudo journalctl -u NetworkManager'

# find
alias find.dir='find . -type d'
alias find.files='find . -type f'
alias find.links='find . -type l'
alias find.links+dead='find -L -type l'
alias find.exec='find . ! -type d -executable'
alias find.last_edited='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 1000'
alias find.last_edited_10k='find . -type f -printf "%T@ %T+ %p\n" | sort -n | tail -n 10000'
alias find.repos='find . -name .git -or -name .svn -or -name .bzr -or -name .hg | while read dir ; do echo "$dir" | sed "s|\(.\+\)/\.\([a-z]\+\)$|\2: \1|g" ; done'
alias find.comma='ls -r --format=commas'

function find.tree() {
    local dir="${1}"
    shift
   
    if [ "${dir}" == "-d" ] ; then
        local dir_find="-type d "
        local dir="${1}"
    fi
    
    find "${dir:-.}" ${dir_find} -print | sed -e 's;[^/]*/;|__;g;s;__|; |;g'
}

# date/time stuff
alias date.format='date --help | sed -n "/^FORMAT/,/%Z/p"'
alias date.timestamp='date +%s'
alias date.week='date +%V'
alias date.YY-mm-dd='date "+%Y-%m-%d"'
alias date.YY-mm-dd_HH_MM='date "+%Y-%m-%d_%H-%M"'
alias date.world=worldclock
alias date.stopwatch=stopwatch
alias stopwatch='time read -n 1'

# compression
alias zip.dir='compress zip'
alias rar.dir='compress rar'
alias tar.dir='compress targz'

# mirror
alias mirror.complete='wget --random-wait -r -p -e robots=off -U mozilla'           # mirror website with everything
alias mirror.images='wget -r -l1 --no-parent -nH -nd -P/tmp -A".gif,.jpg"'     # download all images from a site

# filter
alias grep.ip='grep -o "\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}"'
alias grep.url="sed -e \"s|'|\\\"|g\" -e \"s|src|href|g\" | sed -e \"s|href|\nhref|g\" | grep -i -e \"href[ ]*=\" | sed 's/.*href[ ]*=[ ]*[\"]*\(.*\)[\"\ ].*/\1/g' | cut -f'1' -d'\"'"
alias grep.year='grep -o "[1-2][0-9]\{3\}"'
alias highlite='grep --color=yes -e ^ -e'

# random
alias random.mac='openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//"'
alias random.ip='nmap -iR 1 -sL -n | grep.ip -o'
alias random.lotto='shuf -i 1-49 -n 6 | sort -n | xargs'
random.hex() { openssl rand -hex ${1:-8} ; }
random.integer() { from=1 ; to=${1:-100} ; [[ -n "${2}" ]] && from=${1} && to=${2} ; echo "f:${from} t:${to}"; echo "$(( RANDOM % ${2:-100} + ${1:-1} ))" ; }
random.password() { openssl rand -base64 ${1:-8} ; }
# random.password+phpass() { local pass="${@:-$( random.password 12 )}" ; python -c "from passlib.hash import phpass ; print phpass.encrypt('${pass}')" }

# media 
alias mplayer.left='mplayer -xineramascreen 0'
alias mplayer.right='mplayer -xineramascreen 1'

# sound
alias alsa.silent='for mix in PCM MASTER Master ; do amixer -q sset $mix 0 2>/dev/null ; done'
alias alsa.unsilent='for mix in PCM MASTER Master ; do amixer -q sset $mix 90% 2>/dev/null ; done'
alias no.sound='alsa.silent'

# synergy
alias synergys.custom='[ -e ~/.synergy/$( hostname -s ).conf ] && synergys --daemon --restart --display ${DISPLAY:-:0} --config ~/.synergy/$( hostname -s ).conf 2> ~/.log/synergys.log >&2 || echo "no config for this host available"'
alias synergyc.custom='[ -e ~/.synergy/$( hostname -s ).conf ] && synergyc --daemon --restart --display ${DISPLAY:-:0} --name $( hostname -s ) $( ls ~/.synergy/ | grep -iv "$( hostname -s ).conf" | head -n1 | sed "s|\.conf$||g" ) 2> ~/.log/synergyc.log >&2'
alias synergy.start='kill.synergy ; synergys.custom ; synergyc.custom'
alias kill.synergy='killall -9 synergyc synergys 2>/dev/null ; true'

# show.*
alias show.ip_remote='addr=$( dig +short myip.opendns.com @resolver1.opendns.com | grep.ip ) ; echo remote:${addr:-$( wget -q -O- icanhazip.com | grep.ip )}'
alias show.ip_local='LANG=C /sbin/ifconfig | grep -o -e "^[^\ ]*" -e "^\ *inet addr:\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}" | tr "\n" " " | sed -e "s|\ *inet addr||g" -e "s|\ |\n|g"' #-e "s|:\(.*\)$|: $( color yellow )\1$( color none )|g"'
alias show.ip='show.ip_local | sed "s|:\(.*\)$|: $( color yellow )\1$( color none )|g" ; show.ip_remote | sed "s|:\(.*\)$|: $( color green )\1$( color none )|g"'
for tmpname in $( /sbin/ifconfig | grep -o "^[^ ]*" ) ; do
    alias show.${tmpname}="$( echo /sbin/ifconfig ${tmpname} )"
done

alias show.io='echo -n d | nmon -s 1'
alias show.tcp='sudo netstat -atp'
alias show.tcp_stats='sudo netstat -st'
alias show.udp='sudo netstat -aup'
alias show.udp_stats='sudo netstat -su'
alias show.window_class='xprop | grep CLASS'
alias show.resolution='LANG=C xrandr -q | grep -o "current [0-9]\{3,4\} x [0-9]\{3,4\}" | sed -e "s|current ||g" -e "s|\ ||g"'
alias show.certs='openssl s_client -connect ' 

# tools
alias speedtest='wget -O- http://cachefly.cachefly.net/200mb.test > /dev/null'
alias calculator='bc -l'
alias calc='calculator'

alias sed.strip_html='sed -e "s|<[^>]*>||g"'
alias sed.htmlencode_umlaute='sed -e "s|ü|\&uuml;|g" -e "s|Ü|\&Uuml;|g" -e "s|ä|\&auml;|g" -e "s|Ä|\&Auml;|g" -e "s|ö|\&ouml;|g" -e "s|Ö|\&Ouml;|g" -e "s|ß|\&szlig;|g"' # todo: untested
alias sed.strip_doubleslash='sed "s|[/]\+|/|g"'

alias http.response='lwp-request -ds'
alias show.keycodes='xev | grep -e keycode -e button'
alias patch.from_diff='patch -Np0 -i'
alias show.usb_sticks='for dev in $( udisks --dump | grep device-file | sed "s|^.*\:\ *\(.*\)|\1|g" ) ; do udisks --show-info ${dev} | grep -qi "removable.*1" && echo ${dev} ; done ; true'
alias btc.worldwide='wget -q -O- https://bitpay.com/api/rates | json_pp'
alias btc='echo -e "€: $( btc.worldwide | grep -C2 Euro | grep -o [0-9\.]* )" ; echo "$: $( btc.worldwide | grep -C2 USD | grep -o [0-9\.]* )"'
alias kill.chrome='echo kill -9 $( ps aux | grep -i chrome | awk {"print $2"} | xargs ) 2>/dev/null'
alias iso.grml='iso=$( ls -rt /share/Software/images/grml96*iso 2>/dev/null | tail -n1 ) ; iso=${iso:-$( find /boot -iname "grml*iso" 2>/dev/null )} ; iso=${iso:-$( find ~/ -iname "*grml*iso" 2>/dev/null | tail -n1 )} ; echo "$iso"'
alias kvm.hd='kvm -m 1024 -boot c -hda'
alias kvm.grml+hd='iso=$( iso.grml ) ; kvm -cdrom ${iso} -m 1024 -boot d -hda'
alias create.qcow='next=$( printf "%02d\n" "$(( $( ls image_[0-9]*.img 2>/dev/null | grep -o [0-9]* | sort -n | tail -n1 ) + 1 ))" ) ; qemu-img create -f qcow2 -o preallocation=metadata image_${next}.img'

# host/setup specific
if ( grep -iq work /etc/hostname ) ; then
    alias scp='scp -l 30000'
    alias windows.connect='rdesktop -kde -a 16 -g 1280x1024 -u sschiele 192.168.80.55'
    alias wakeonlan.windows='wakeonlan 00:1C:C0:8D:0C:73'
elif [ $( whereami ) = 'home' ] ; then
    alias wakeonlan.mediacenter='wakeonlan 00:01:2e:27:62:87'
    alias wakeonlan.cstation='wakeonlan 00:19:66:cf:82:04'
    alias wakeonlan.cbase='wakeonlan 00:50:8d:9c:3f:6e'
fi

if ( grep -iq 'minit' /proc/cmdline ) ; then
    alias reboot='sudo minit-shutdown -r &'
    alias halt='sudo minit-shutdown -h'
fi

if ( which recordmydesktop >/dev/null ) ; then
    alias screendump='recordmydesktop -o screendump_$( date +%s ).ogv'
else
    alias screendump='ffmpeg -f x11grab -s wxga -r 25 -i :0.0 -sameq ./screendump-$(date +%Y-%m-%d_%s).mpg'
    alias screendump2='ffmpeg -f alsa -i hw:1,1 -f x11grab -r 30 -s 800x600 -i :0.0 -acodec pcm_s16le -vcodec libx264 -preset ultrafast -threads 0 output.avi'
fi

if ( which gnome-screenshot >/dev/null ) ; then
    alias screenshot=gnome-screenshot
else
    alias screenshot='import -display :0 -window root ./screenshot-$(date +%Y-%m-%d_%s).png'
fi

alias record.screendump=screendump
alias record.screenvideo=screendump
alias record.screenshot=screenshot

# sorgenkinder
alias show.open_ports='echo -e "User:      Command:   Port:\n----------------------------" ; sudo "lsof -i 4 -P -n | grep -i listen | awk {\"print \$3, \$1, \$9\"} | sed \"s| [a-z0-9\.\*]*:| |\" | sort -k 3 -n | xargs printf \"%-10s %-10s %-10s\n\"" | uniq'
alias log.authlog="sudo grep -e \"^\$( LANG=C date -d'now -24 hours' +'%b %e' )\" -e \"^\$( LANG=C date +'%b %e' )\" /var/log/auth.log | grep.ip | sort -n | uniq -c | sort -n | grep -v \"\$( host -4 enkheim.psaux.de | grep.ip | head -n1 )\" | tac | head -n 10"
alias hooks.run="echo ; systemtype=\$( grep ^systemtype ~/.system.conf | cut -f2 -d'=' | sed -e 's|[\"\ ]||g' -e \"s|'||g\" ) ; for exe in \$( find ~/.hooks/ ! -type d -executable | xargs grep -l \"^hook_systemtype.*\${systemtype}\" | xargs grep -l '^hook_optional=false' ) ; do exec_with_sudo='' ; grep -q 'hook_sudo=.*true.*' \"\${exe}\" && exec_with_sudo='sudo ' || grep -q 'hook_sudo' \"\${exe}\" || exec_with_sudo='sudo ' ; cancel=\${cancel:-false} global_success=\${global_success:-true} \${exe} ; retval=\${?} ; echo ; if test \${retval} -eq 2 ; then echo -e \"CANCELING HOOKS\" >&2 ; break ; elif ! test \${retval} -eq 0 ; then global_success=false ; fi ; done ; \${global_success} || echo -e \"Some hooks could NOT get processed successfully!\n\" ; unset global_success systemtype retval ;"

alias find.videos="find . ! -type d $( echo ${EXTENSIONS_VIDEO}\" | sed -e "s|,|\"\ \-o\ \-iname \"*|g" -e "s|^|\ \-iname \"*|g" )"
alias find.images="find . ! -type d $( echo ${EXTENSIONS_IMAGES}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
alias find.audio="find . ! -type d $( echo ${EXTENSIONS_AUDIO}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
alias find.documents="find . ! -type d $( echo ${EXTENSIONS_DOCUMENTS}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"
alias find.archives="find . ! -type d $( echo ${EXTENSIONS_ARCHIVES}\" | sed -e 's|,|\"\ \-o\ \-iname \"*|g' -e 's|^|\ \-iname \"*|g' )"

alias permissions.normalize="find . -type f \! -perm -a+x -exec chmod 640 {} \; -o -type f -perm -a+x -exec chmod 750 {} \; -o -type d -exec chmod 750 {} \; ; chown \${SUDO_USER:-\$USER}: . -R"
alias permissions.normalize_system="chown \${SUDO_USER:-\$USER}: ~/ -R ; find /home/* /root -maxdepth 0 -type d -exec chmod 700 {} \;"
alias permissions.normalize_web="chown \${SUDO_USER:-\$USER}:www-data . -R ; find . -type f \! -perm -a+x -exec chmod 640 {} \; -o -type f -perm -a+x -exec chmod 750 {} \; -o -type d \( -iname 'log*' -o -iname 'cache' -o -iname 'templates_c' \) -exec chown www-data:\${SUDO_USER:-\$USER} {} -R \; -exec chmod 770 {} \; -o -type d -exec chmod 750 {} \;"

alias show.init_five_activated='find /etc/rc[1-5].d/ ! -type d -executable -exec basename {} \; | sed 's/^[SK][0-9][0-9]//g' | sort -u | xargs'
alias rm.dead_links='find . -type l -exec test ! -e {} \; -delete'

alias sed.remove_special_chars='sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"'

# old stuff
#alias route_via_wlan="for i in \`seq 1 10\` ; do route del default 2>/dev/null ; done ; route add default eth0 ; route add default wlan0 ; route add default gw \"\$( /sbin/ifconfig wlan0 | grep.ip | head -n 1 | cut -f'1-3' -d'.' ).1\""
#alias 2audio="convert2 mp3"
#alias youtube-mp3="clive -f best --exec=\"echo >&2; echo '[CONVERTING] %f ==> MP3' >&2 ; ffmpeg -loglevel error -i %f -strict experimental %f.mp3 && rm -f %f\""
#alias youtube="clive -f best --exec=\"( echo %f | grep -qi -e 'webm$' -e 'webm.$' ) && ( echo >&2 ; echo '[CONVERTING] %f ==> MP4' >&2 ; ffmpeg -loglevel error -i %f -strict experimental %f.mp4 && rm -f %f )\""
#alias image2pdf='convert -adjoin -page A4 *.jpeg multipage.pdf'				# convert images to a multi-page pdf
#nrg2iso() { dd bs=1k if="$1" of="$2" skip=300 }

#wget -q -O- http://www.di.fm/ | grep -o 'data-tunein-url="[^"]*"' | cut -f'2' -d'"'  

function wget.stdout() {
    wget -O- -q ${@} || wget -O- -S ${@}
}

unset tmpname

