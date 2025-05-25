############################
# 00020-format section START
############################

# format escape
function fmt_esc {
    res=''
    while IFS= read -n 1 ch ; do
        if [[ -z "${ch}" ]] ; then
            res="${res}"$'\n'
        elif [[ "${ch}" == '[' ]] ; then
            res="${res}\["
        elif [[ "${ch}" == ']' ]] ; then
            res="${res}\]"
        else
            res="${res}${ch}"
        fi
    done <<< $1
    echo "${res}"
}

# formatting rules
fmt_rules=(
    "dir:${fg_bright_yellow}"
    "err:${fg_bright_red}"
    "note:${fg_bright_yellow}"
    "path:${fg_bright_green}"
    "url:${fg_bright_green}"
    "val:${fg_bright_magenta}"
    "var:${fg_bright_cyan}"
)

# build sed formatting commands
fmt_sed_cmds=''
for rule in "${fmt_rules[@]}"
do
    IFS=':' read -r tag code <<< "${rule}"
    fmt_sed_cmds="${fmt_sed_cmds} -e s/${tag}/${code}/"
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
    local line_buf=''

    local append
    function append {
        while IFS= read -r -n 1 ch ; do
            if [[ "${col_cnt}" == 0 ]] ; then
                line_buf="${spaces}${line_buf}"
                col_cnt="${indent}"
            fi
            if [[ -n "${ch}" ]] ; then
                line_buf="${line_buf}${ch}"
                col_cnt=$((col_cnt + 1))
                if [[ "${col_cnt}" == "${max_cols}" ]] ; then
                    echo -n "${line_buf}"
                    line_buf=''
                    col_cnt=0
                fi
            fi
        done <<< "$1"
    }

    while IFS= read -r -n 1 ch ; do
        case "${state}" in
            0)  if [[ -z "${ch}" ]] ; then
                    echo -n "${line_buf}"
                    line_buf=''
                    col_cnt=0
                elif [[ "${ch}" == '\' ]] ; then
                    state=1
                elif [[ "${ch}" == '[' ]] ; then
                    state=2
                else
                    append "${ch}"
                fi ;;
            1)  if [[ "${ch}" == '[' ]] ; then
                    append '['
                elif [[ "${ch}" == ']' ]] ; then
                    append ']'
                else
                    append "\\${ch}"
                fi
                state=0 ;;
            2) if [[ "${ch}" == ':' ]] ; then
                   line_buf="${line_buf}$(fmt ${tag})"
                   tag=''
                   state=3
               elif [[ "${ch}" == ']' ]] ; then
                   append "[${tag}]"
                   tag=''
                   state=0
               else
                   tag="${tag}${ch}"
               fi ;;
            3) if [[ -z "${ch}" ]] ; then
                    echo -n "${line_buf}"
                    line_buf=''
                    col_cnt=0
               elif [[ "${ch}" == '\' ]] ; then
                   state=4
               elif [[ "${ch}" == ']' ]] ; then
                   line_buf="${line_buf}${term_reset}"
                   state=0
               else
                   append "${ch}"
               fi ;;
            *) if [[ "${ch}" == '[' ]] ; then
                   append "["
               elif [[ "${ch}" == ']' ]] ; then
                   append "]"
               else
                   append "\\${ch}"
               fi
               state=3 ;;
        esac
    done <<< $1
    if [[ col_cnt > 0 ]] ; then
        echo "${line_buf}"
    fi
    sync
}

##########################
# 00020-format section END
##########################
