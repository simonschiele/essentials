#!/bin/bash

function es_prompt_status() {
    local status_type=${1:-git}
    local color=${2:-false}
    es_prompt_status ${status_type} ${color}
}

function es_prompt_status_git() {
    local color=${1:-false}

    if ( $color ) && [ -z "${COLORS['red']}" ] ; then
        if [ -r ~/.essentials/colors.sh ] ; then
            . ~/.essentials/colors.sh
        else
            echo "error: couldn't include colors.sh from resources"
            exit 1
        fi
    fi

    if $( LANG=C git rev-parse --is-inside-work-tree 2>/dev/null ) ; then

        #local gitStatus="LANG=C git diff --quiet --ignore-submodules HEAD"
        local gitStatus="$( LANG=C git status 2>/dev/null )"
        local gitBranch="$( LANG=C git symbolic-ref -q --short HEAD )"

        if [ "${gitBranch}" = 'master' ] ; then
            gitBranch=""
        fi

        if [[ ! ${gitStatus} =~ "working directory clean" ]] ; then
            local state="$( color.ps1 red )⚡"
        fi

        if [[ "${gitStatus}" =~ "ahead of" ]] ; then
            local ahead="$( color.ps1 yellow )↑"
        fi

        if test -n "${ahead}" || test -n "${state}" ; then
            echo "(${gitBranch}${ahead}${state}$( color.ps1 none ))"
        else
            echo "(${gitBranch}$( color.ps1 green )♥$( color.ps1 none ))"
        fi
    fi
}

function es_prompt() {
    local lastret=$?
    local PS1prompt=" > "
    local PS1error=$( [ ${lastret} -gt 0 ] && echo "${lastret}" )
    local PS1user="${ESSENTIALS_USER}"
    local PS1host="\h"
    local PS1path="\w"
    local PS1git=
    local PS1chroot=
    local PS1schroot=${SCHROOT_CHROOT_NAME:+(schroot:$SCHROOT_CHROOT_NAME)}
    local PS1virtualenv=${VIRTUAL_ENV:+(virtualenv:$VIRTUAL_ENV)}
    PS1chroot=${PS1chroot:+(chroot) }

    if ( ${ESSENTIALS_COLORS} ) ; then
        PS1error=${PS1error:+$( color.ps1 red )${PS1error}$( color.ps1 )}
        PS1path=${PS1path:+$( color.ps1 white_background )${PS1path}$( color.ps1 )}
        PS1path=${PS1path:+$( color.ps1 black )${PS1path}}
        PS1chroot=${PS1chroot:+($( color.ps1 red )chroot$( color.ps1 ))}

        if ${ESSENTIALS_IS_UID0} ; then
            PS1user=${PS1user:+$( color.ps1 red )${PS1user}$( color.ps1 )}
        fi

        if ${ESSENTIALS_IS_SSH} ; then
            PS1host=${PS1host:+$( color.ps1 red )${PS1host}$( color.ps1 )}
        fi
    fi

    if [ -e ${ESSENTIALS_DIR}/prompt.sh ] && [ -n "$( which timeout )" ] ; then
        PS1git=$( LANG=C timeout 0.5 ${ESSENTIALS_DIR}/prompt.sh git ${ESSENTIALS_COLORS} )
        local gitret=$?
        [ $gitret -eq 124 ] && PS1git="($( color.ps1 red )git slow$( color.ps1 ))"
    fi

    PS1error=${PS1error:+[${PS1error}] }
    PS1git=${PS1git:+ ${PS1git}}

    PS1="${PS1error}${PS1chroot}${PS1user}@${PS1host} ${PS1path}${PS1git}${PS1schroot}${PS1virtualenv}${PS1prompt}"
}

if [[ "${0}" != '-bash' ]] && [[ "$( readlink -f ${0} )" == "$( readlink -f ${BASH_SOURCE[0]} )" ]] ; then
    es_prompt_status ${1:-git} ${ESSENTIALS_COLORS:-${2:-false}}
else
    export PROMPT_COMMAND="es_prompt${PROMPT_COMMAND:+ ; ${PROMPT_COMMAND}}"
fi

