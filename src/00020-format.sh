############################
# 00020-format section START
############################

# formatting rules
fmt_rules=(
    "var:${fg_bright_cyan}"
    "val:${fg_bright_magenta}"
    "dir:${fg_bright_yellow}"
    "err:${fg_bright_red}"
)

# build sed formatting commands
fmt_sed_cmds="-e s/\]/${term_reset}/g"
for rule in "${fmt_rules[@]}"
do
    IFS=':' read -r tag code <<< "${rule}"
    fmt_sed_cmds="${fmt_sed_cmds} -e s/\[${tag}:/${code}/g"
done

# formatting function
function fmt {
    # shellcheck disable=SC2086
    sed ${fmt_sed_cmds} <<< "${1}"
}

# entry management
entry_level=0

function entry_up {
    entry_level=$((entry_level + 1))
}

function entry_down {
    entry_level=$((entry_level - 1))
}

function entry {
    local state=0
    local col_cnt=0
    local tag=''
    local max_cols=$(stty size | awk '{print $2}')
    local indent=$((entry_level * 2))
    local spaces=""
    for ((i = 0; i < indent; i++)) ; do spaces="${spaces} " ; done
    max_cols=$((max_cols - indent))
    local line_buf=''

    local append
    function append {
        while IFS= read -r -n 1 ch ; do
            if [[ "${col_cnt}" == 0 ]] ; then
                line_buf="${spaces}"
            fi
            if [[ -n "${ch}" ]] ; then
                line_buf="${line_buf}${ch}"
                col_cnt=$((col_cnt + 1))
                if [[ "${col_cnt}" == "${max_cols}" ]] ; then
                    fmt "${line_buf}"
                    line_buf=""
                    col_cnt=0
                fi
            fi
        done <<< "$1"
    }

    while IFS= read -r -n 1 ch ; do
        if [[ "${state}" == 0 ]] ; then
            if [[ "${ch}" == '[' ]] ; then
                state=1
            else
                append "${ch}"
            fi
        elif [[ "${state}" == 1 ]] ; then
            if [[ "${ch}" == '>' ]] ; then
                state=2
            else
                state=0
                append "{${ch}"
            fi
        elif [[ "${state}" == 2 ]] ; then
            if [[ "${ch}" == ':' ]] ; then
                line_buf="${line_buf}[${tag}:"
                state=3
            else
                tag="${tag}${ch}"
            fi
        elif [[ "${state}" == 3 ]] ; then
            if [[ "${ch}" == ']' ]] ; then
                line_buf="${line_buf}${ch}"
                tag=''
                state=0
            else
                append "${ch}"
            fi
        fi
    done <<< $1
    if [[ col_cnt > 0 ]] ; then
        fmt "${line_buf}"
    fi
}

##########################
# 00020-format section END
##########################
