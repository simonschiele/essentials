#!/bin/bash

function prompt_ps1() {
    local lastret=$?
    local PS1error=$( [ ${lastret} -gt 0 ] && echo "${lastret}" )
    local PS1user="${ESSENTIALS_USER}"
    local PS1host="\h"
    local PS1path="\w"
    local PS1chroot=
    PS1chroot=${PS1chroot:+(chroot) }

    if ( ${ESSENTIALS_COLORS} ) ; then
        PS1error=${PS1error:+$( color.ps1 red )${PS1error}$( color.ps1 )}
        PS1path=${PS1path:+$( color.ps1 white_background )${PS1path}$( color.ps1 )}
        PS1path=${PS1path:+$( color.ps1 black )${PS1path}}
        PS1chroot=${PS1chroot:+($( color.ps1 red )chroot$( color.ps1 ))}
        
        if ${ESSENTIALS_IS_SUDO} || ${ESSENTIALS_IS_ROOT} ; then
            PS1user=${PS1user:+$( color.ps1 red )${PS1user}$( color.ps1 )}
        fi
        
        if ${ESSENTIALS_IS_SSH} ; then
            PS1host=${PS1host:+$( color.ps1 red )${PS1host}$( color.ps1 )}
        fi
    fi
    
    if [ -e ${ESSENTIALS_DIR}/prompt_git.sh ] && [ -n "$( which timeout )" ] ; then
        PS1git=$( LANG=C timeout 0.5 ${ESSENTIALS_DIR}/prompt_git.sh ${ESSENTIALS_COLORS} )
        local gitret=$?
        [ $gitret -eq 124 ] && PS1git="($( color.ps1 red )git slow$( color.ps1 ))"
    else
        PS1git=
    fi

    PS1error=${PS1error:+[${PS1error}] }
    PS1git=${PS1git:+ ${PS1git}}
    PS1prompt=" > "

    PS1="${PS1error}${PS1chroot}${PS1user}@${PS1host} ${PS1path}${PS1git}${PS1prompt}"
}

export PROMPT_COMMAND="prompt_ps1${PROMPT_COMMAND:+ ; ${PROMPT_COMMAND}}"

