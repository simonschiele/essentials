#!/bin/bash

declare -g -A ICONS

ICONS[trademark]='\u2122'
ICONS[copyright]='\u00A9'
ICONS[registered]='\u00AE'
ICONS[asterism]='\u2042'
ICONS[voltage]='\u26A1'
ICONS[whitecircle]='\u25CB'
ICONS[blackcircle]='\u25CF'
ICONS[largecircle]='\u25EF'
ICONS[percent]='\u0025'
ICONS[permille]='\u2030'
ICONS[pilcrow]='\u00B6'
ICONS[peace]='\u262E'
ICONS[yinyang]='\u262F'
ICONS[russia]='\u262D'
ICONS[turkey]='\u262A'
ICONS[skull]='\u2620'
ICONS[heavyheart]='\u2764'
ICONS[whiteheart]='\u2661'
ICONS[blackheart]='\u2665'
ICONS[whitesmiley]='\u263A'
ICONS[blacksmiley]='\u263B'
ICONS[female]='\u2640'
ICONS[male]='\u2642'
ICONS[airplane]='\u2708'
ICONS[radioactive]='\u2622'
ICONS[ohm]='\u2126'
ICONS[pi]='\u220F'
ICONS[cross]='\u2717'
ICONS[fail]='\u2717'
ICONS[error]='\u2717'
ICONS[check]='\u2714'
ICONS[ok]='\u2714'
ICONS[success]='\u2714'
ICONS[warning]='⚠'

function show.icons() {
    (
        for key in "${!ICONS[@]}" ; do
            echo -e " ${ICONS[$key]} : ${key}"
        done
    ) | column -c ${COLUMNS:-80}
}

alias list.icons=show.icons
alias icons.show=show.icons
alias icons.list=show.icons

function icon.exists() {
    [ ${ICONS[${1:-none}]+isset} ] && return 0 || return 1
}

function icon() {
    ( icon.exists ${1:-none} ) && echo -ne "${ICONS[${1:-none}]}"
}

function icon.color() {
    local icon=${1:-fail}
    local color=${2:-red}
    local status=0

    if ( ! icon.exists $icon ) || ( ! color.exists $color ) ; then
        status=1
        icon='fail'
        color='red'
    fi

    color.echon $color $( icon $icon )
    return ${status}
}
