
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

export COLOR

function show.colors() {
    (
        for key in "${!COLOR[@]}" ; do
            echo -e " ${COLOR[$key]} == COLORTEST ${key} == ${COLOR[none]}"
        done
    ) | column -c ${COLUMNS:-120}
}

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

