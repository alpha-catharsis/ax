############################
# 00020-format section START
############################

# formatting rules
fmt_rules=(
    "var:${fg_yellow}"
    "dir:${fg_cyan}"
)

# build sed formatting commands
fmt_sed_cmds="-e s/\]/${term_reset}/g"
for rule in "${fmt_rules[@]}"
do
    IFS=':' read -r tag code <<< "${rule}"
    fmt_sed_cmds="${fmt_sed_cmds} -e s/\[${tag}:/${code}/g"
done

function fmt {
    sed ${fmt_sed_cmds} <<< "${1}"
}

##########################
# 00020-format section END
##########################
