#
# Please, don't change this file directly!!!
#
# To make changes to this configfile and still be update-safe, please
# just copy this file as 'myconfig.sh' in the same directory.
#
# You only have to set the config values you want to set, everything
# else will be filled up by default values.
#
# To see settings of a running essentials session, just call 'es_info'.
#
#
# Available Config Keys for essential:
#   debug       true|false          - enable/disable debug
#   log         true|false          - enable/disable logging
#   logdir      <path_to_logdir>    - only used if logfile not absolute (ex. '/tmp')
#   logfile     <path_to_logfile>   - path to logfile (ex. '/tmp/.log/out.log')
#   user        <username>          - name of active user (ex. 'simon')
#   home        <path_to_home>      - path to users home dir (ex. '/home/simon')
#   colors      true|false          - enable/disable coloring
#   unicode     true|false          - enable/disable usage of unicode icons
#
#   browser         <command>       - command to be used as browser
#   mailer          <command>       - command to be used as mailer
#   pager           <command>       - command to be used as pager
#   terminal        <command>       - command for default terminal
#   editor          <command>       - command for default editor
#   open            <command>       - command to open file with selected app by mimetype
#
#   git_name        <gituser>           - git user name (ex. 'Simon Schiele')
#   git_email       <mail_of_gituser>   - git user email (ex. 'simon.codingmonkey@googlemail.com')
#   luks_keysize    <keysize>           - keysize for luks creation
#   luks_cipher     <cipher>            - cipher for luks creation
#
#

CONFIG[git_name]='Simon Schiele'
CONFIG[git_email]='simon.codingmonkey@googlemail.com'

CONFIG[luks_keysize]='512'
CONFIG[luks_cipher]='aes-xts-plain64:sha256'

#CONFIG[debug]='true'
#CONFIG[log]='true'
#CONFIG[logfile]='/home/simon/.log/essentials.log'
#CONFIG[user]='sschiele'

#CONFIG[browser]='google-chrome'
#CONFIG[mailer]='icedove'
#CONFIG[pager]='less'
#CONFIG[terminal]='terminator'
#CONFIG[editor]='vim.nox'
#CONFIG[open]='gnome-open'

