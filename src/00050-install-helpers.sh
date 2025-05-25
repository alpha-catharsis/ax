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
    shell_cmd_out=$(tr -d '\0' < "${out_file}")
    shell_cmd_err=$(tr -d '\0' < "${err_file}")
}

# set environment variable
function env_set {
    export "${1}"="${2}"
    val=$(fmt_esc "${2}")
    entry "Set environment variable [var:${1}] to [val:${val}]."
}

# create directory
function create_dir {
    local msg="Creating directory [path:'${1}']."
    if [[ -d "${1}" ]] ; then
        msg="${msg} ([note:skipped])"
        entry "$msg"
    else
        entry "$msg"
        shell_cmd "mkdir ${1}"
    fi
}

# change directory
function change_dir {
    entry "Changing directory to [path:'${1}']."
    shell_cmd "cd ${1}"
}

# move file
function move_file {
    entry "Moving fild [path:'${1}'] to [path:'${2}']."
    shell_cmd "mv ${1} ${2}"
}

# fetch file
function fetch_url {
    local msg="Fetching file [path:'${1}']..."
    if [[ -f "${2}" ]] ; then
        msg="${msg} ([note:skipped])"
        entry "$msg"
    else
        entry "$msg"
        shell_cmd "curl ${1} -o ${2}"
        entry "Succesfully fetched file [path:'${1}']."
    fi
}

# unpack archive
function archive_name {
    res=''
    case "${1}" in
        *.tar) res=${1/.tar/} ;;
        *.tar.gz) res=${1/.tar.gz/} ;;
        *.tar.xz) res=${1/.tar.xz/} ;;
        *.tar.bz2) res==${1/.tar.bz2/} ;;
        *) exit 1 ;;
    esac
    echo "${res}"
}

function unpack_archive {
    dir_name=$(archive_name "${1}")
    case "${1}" in
        *.tar) tar_flags='' ;;
        *.tar.gz) tar_flags='z' ;;
        *.tar.xz) tar_flags='' ;;
        *.tar.bz2) tar_flags='j' ;;
        *) entry "[err:Invalid archive extension for file '${1}']" ; exit 1 ;;
    esac
    if [[ -d "${dir_name}" ]] ; then
        entry "Archive [path:'${1}'] already extracted, removing existing directory [path:'${dir_name}']..."
        shell_cmd "rm -rvf ${dir_name}"
        entry "Completed removal of directory [path:'${dir_name}']."
    fi
    entry "Extracting archive [path:'${1}']"
    shell_cmd "tar -x${tar_flags}f ${1}"
    entry "Succesfully extracted archive [path:'${1}']"
}

# apply patch
function apply_patch {
    entry "Applying patch [path:${1}]."
    shell_cmd "patch -Np1 -i ${1}"
}

# prepare build
function prepare_build {
    create_dir "build"
    change_dir "./build"
}

# configure build
function configure_build {
    entry "Configuring build..."
    path="${1}"
    shift
    shell_cmd "${path}/configure $@"
    entry "Successfully configured build."
}

# compile build
function compile_build {
    entry "Compiling build..."
    shell_cmd "make"
    entry "Successfully compiled build."
}

# compile build
function install_build {
    entry "Installing build..."
    if [[ "$#" == 0 ]] ; then
        shell_cmd "make install"
    else
        shell_cmd "make DESTDIR=${1} install"
    fi
    entry "Successfully installed build."
}

##################################
# 00050-intall-helpers section END
##################################
