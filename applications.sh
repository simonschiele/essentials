
# SETTINGS
export LUKS_KEYSIZE='512'
export LUKS_CIPHER='aes-xts-plain64:sha256'

export BROWSER='google-chrome'
export MAILER='icedove'
export TERMINAL='terminator'
export OPEN='gnome-open'

# default overwrites
alias cp='cp -i -r'
alias less='less'
alias mkdir='mkdir -p'
alias mv='mv -i'
alias rm='rm -i'
alias screen='screen -U'
alias dmesg='dmesg -T --color=auto'
alias wget='wget -c'
alias tmux='TERM=screen-256color-bce tmux'

# {{{ Editor / Vim

EDITOR=$( which vim.nox )
EDITOR=${EDITOR:-$( which vim )}
if [ -n "${EDITOR}" ] ; then
    alias vim.blank="${EDITOR} -N -u NONE -U NONE"
    alias vim.none=vim.blank
    alias vim.bigfile=vim.blank
fi
EDITOR=${EDITOR:-$( which vi )}
EDITOR=${EDITOR:-$( which nano )}
EDITOR=${EDITOR:-$( which joe )}
EDITOR=${EDITOR:-$( which mcedit )}
EDITOR=${EDITOR:-$( which emacs )}
export EDITOR

# check if powerline patched font for vim is available
POWERLINE_FONT=$( [ $( find ~/.fonts/ -iname "*pragmata*powerline*ttf" 2>/dev/null | wc -l ) -eq 0 ] ; echo ${BOOLEAN[$?]} )
export POWERLINE_FONT

# }}}

# {{{ PAGER

PAGER=less
export PAGER

# }}}

# shorties
alias p='ps aux | grep -i'

