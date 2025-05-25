####################################
# 00050-intall-helpers section START
####################################

# run shell command
shell_cmd_out=''
shell_cmd_err=''

function shell_cmd {
    local out_file=$(mktemp)
    local err_file=$(mktemp)
    $@ 1>"${out_file}" 2>"${err_file}"
    if [[ "$?" -ne 0 ]] ; then
        errors="$(cat ${err_file})"
        esc_errors=$(fmt_esc "${errors}")
        entry "[err:Error]: [note:${esc_errors}]"
        exit 1
    fi
    shell_cmd_out=$(cat "${out_file}")
    shell_cmd_err=$(cat "${err_file}")
}

# set environment variable
function env_set {
    export "${1}"="${2}"
    entry "set environment variable [var:${1}] to [val:$(fmt_esc ${2})]"
}

# create directory
function create_dir {
    local msg="Creating directory [path:'${1}']"
    if [[ -d "${1}" ]] ; then
        msg="${msg} ([note:skipped])"
        entry "$msg"
    else
        entry "$msg"
        shell_cmd "mkdir ${1}"
    fi
}

##################################
# 00050-intall-helpers section END
##################################
