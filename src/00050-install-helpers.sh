####################################
# 00050-intall-helpers section START
####################################

# run shell command
shell_cmd_out=''
shell_cmd_err=''

function shell_cmd {
    local out_file=$(mktemp)
    local err_file=$(mktemp)
    local cmd=("$@")
    "${cmd[@]}" 1> "${out_file}" 2> "${err_file}"
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
        cmd=(mkdir "${1}")
        shell_cmd "${cmd[@]}"
    fi
}

# change directory
function change_dir {
    entry "Changing directory to [path:'${1}']."
    cmd=(cd "${1}")
    shell_cmd "${cmd[@]}"
}

# move file
function move_file {
    entry "Moving fild [path:'${1}'] to [path:'${2}']."
    cmd=(mv "${1}" "${2}")
    shell_cmd "${cmd[@]}"
}

# fetch file
function fetch_url {
    local msg="Fetching file [path:'${1}']..."
    if [[ -f "${2}" ]] ; then
        msg="${msg} ([note:skipped])"
        entry "$msg"
    else
        entry "$msg"
        cmd=(curl "${1}" -o "${2}")
        shell_cmd "${cmd[@]}"
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
        cmd=(rm -rvf "${dir_name}")
        shell_cmd "${cmd[@]}"
        entry "Completed removal of directory [path:'${dir_name}']."
    fi
    entry "Extracting archive [path:'${1}']"
    cmd=(tar -x"${tar_flags}"f "${1}")
    shell_cmd "${cmd[@]}"
    entry "Succesfully extracted archive [path:'${1}']"
}

# apply patch
function apply_patch {
    entry "Applying patch [path:${1}]."
    cmd=(patch -Np1 -i "${1}")
    shell_cmd "${cmd[@]}"
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
    cmd=(${path}/configure $@)
    shell_cmd "${cmd[@]}"
    entry "Successfully configured build."
}

# compile build
function compile_build {
    entry "Compiling build..."
    cmd=(make)
    shell_cmd "${cmd[@]}"
    entry "Successfully compiled build."
}

# compile build
function install_build {
    entry "Installing build..."
    if [[ "$#" == 0 ]] ; then
        cmd=(make install)
        shell_cmd "${cmd[@]}"
    else
        cmd=(make DESTDIR="${1}" install)
        shell_cmd "${cmd[@]}"
    fi
    entry "Successfully installed build."
}

##################################
# 00050-intall-helpers section END
##################################
