#!/bin/bash

declare -g -A COLORS

COLORS[none]="\e[0m"
COLORS[off]="\e[0m"
COLORS[false]="\e[0m"
COLORS[normal]="\e[0m"

# Basic Colors
COLORS[black]="\e[0;30m"
COLORS[red]="\e[0;31m"
COLORS[green]="\e[0;32m"
COLORS[yellow]="\e[0;33m"
COLORS[blue]="\e[0;34m"
COLORS[purple]="\e[0;35m"
COLORS[cyan]="\e[0;36m"
COLORS[white]="\e[0;37m"

# Bold Colors
COLORS[black_bold]="\e[1;30m"
COLORS[red_bold]="\e[1;31m"
COLORS[green_bold]="\e[1;32m"
COLORS[yellow_bold]="\e[1;33m"
COLORS[blue_bold]="\e[1;34m"
COLORS[purple_bold]="\e[1;35m"
COLORS[cyan_bold]="\e[1;36m"
COLORS[white_bold]="\e[1;37m"

# Underline
COLORS[black_under]="\e[4;30m"
COLORS[red_under]="\e[4;31m"
COLORS[green_under]="\e[4;32m"
COLORS[yellow_under]="\e[4;33m"
COLORS[blue_under]="\e[4;34m"
COLORS[purple_under]="\e[4;35m"
COLORS[cyan_under]="\e[4;36m"
COLORS[white_under]="\e[4;37m"

# Background Colors
COLORS[black_background]="\e[40m"
COLORS[red_background]="\e[41m"
COLORS[green_background]="\e[42m"
COLORS[yellow_background]="\e[43m"
COLORS[blue_background]="\e[44m"
COLORS[purple_background]="\e[45m"
COLORS[cyan_background]="\e[46m"
COLORS[white_background]="\e[47m"
COLORS[gray_background]="\e[100m"

function show.colors() {
    (
        for key in "${!COLORS[@]}" ; do
            echo -e " ${COLORS[$key]} == COLORTEST ${key} == ${COLORS[none]}"
        done
    ) | column -c ${COLUMNS:-120}
}

alias list.colors=show.colors
alias colors.show=show.colors
alias colors.list=show.colors

function color.exists() {
    [ ${COLORS[${1:-none}]+isset} ] && return 0 || return 1
}

function color() {
    ( color.exists ${1:-none} ) && echo -ne "${COLORS[${1:-none}]}"
}

function color.ps1() {
    ( color.exists ${1:-none} ) && echo -ne "\[${COLORS[${1:-none}]}\]"
}

function color.echo() {
    ( color.exists ${1:-black} ) && echo -e "${COLORS[${1:-black}]}${2}${COLORS[none]}"
}

function color.echon() {
    ( color.exists ${1:-black} ) && echo -ne "${COLORS[${1:-black}]}${2}${COLORS[none]}"
}

