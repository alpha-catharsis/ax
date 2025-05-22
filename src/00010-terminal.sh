##############################
# 00010-terminal section START
##############################

# basic terminal codes
term_csi=$'\033['

# terminal reset
term_reset="${term_csi}0m"

# terminal foreground colors
fg_black="${term_csi}30m"
fg_red="${term_csi}31m"
fg_green="${term_csi}32m"
fg_yellow="${term_csi}33m"
fg_blue="${term_csi}34m"
fg_magenta="${term_csi}35m"
fg_cyan="${term_csi}36m"
fg_white="${term_csi}37m"

# terminal background colors
bg_black="${term_csi}40m"
bg_red="${term_csi}41m"
bg_green="${term_csi}42m"
bg_yellow="${term_csi}43m"
bg_blue="${term_csi}44m"
bg_magenta="${term_csi}45m"
bg_cyan="${term_csi}46m"
bg_white="${term_csi}47m"

# terminal bright foreground colors
fg_bright_black="${term_csi}90m"
fg_bright_red="${term_csi}91m"
fg_bright_green="${term_csi}92m"
fg_bright_yellow="${term_csi}93m"
fg_bright_blue="${term_csi}94m"
fg_bright_magenta="${term_csi}95m"
fg_bright_cyan="${term_csi}96m"
fg_bright_white="${term_csi}97m"

# terminal bright background colors
fg_bright_black="${term_csi}100m"
fg_bright_red="${term_csi}101m"
fg_bright_green="${term_csi}102m"
fg_bright_yellow="${term_csi}1030m"
fg_bright_blue="${term_csi}104m"
fg_bright_magenta="${term_csi}105m"
fg_bright_cyan="${term_csi}106m"
fg_bright_white="${term_csi}107m"

# terminal text style
bold="${term_csi}1m"
dim="${term_csi}2m"
italic="${term_csi}3m"
underline="${term_csi}4m"
blinking="${term_csi}5m"
strikethrough="${term_csi}29m"

############################
# 00010-terminal section END
############################
