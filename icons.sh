
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

export ICON

function show.icons() {
    ( 
        for key in "${!ICON[@]}" ; do
            echo -e " ${ICON[$key]} : ${key}"
        done
    ) | column -c ${COLUMNS:-80}
}

