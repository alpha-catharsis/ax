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
    local val=$(fmt_esc "${2}")
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
        local cmd=(mkdir "${1}")
        shell_cmd "${cmd[@]}"
    fi
}

function create_dirs {
    entry "Creating directorys [path:'${1}']."
    local cmd=(mkdir -p "${1}")
    shell_cmd "${cmd[@]}"
}

# change directory
function change_dir {
    entry "Changing directory to [path:'${1}']."
    local cmd=(cd "${1}")
    shell_cmd "${cmd[@]}"
}

# move file
function move_file {
    entry "Moving file [path:'${1}'] to [path:'${2}']."
    local cmd=(mv "${1}" "${2}")
    shell_cmd "${cmd[@]}"
}

# create simlink
function create_simlink {
    entry "Creating symbolic link from [path:'${1}'] to [path:'${2}']."
    local cmd=(ln -s "${1}" "${2}")
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
        local cmd=(curl "${1}" -o "${2}")
        shell_cmd "${cmd[@]}"
        entry "Succesfully fetched file [path:'${1}']."
    fi
}

# unpack archive
function archive_name {
    local res=''
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
    local dir_name=$(archive_name "${1}")
    case "${1}" in
        *.tar) tar_flags='' ;;
        *.tar.gz) tar_flags='z' ;;
        *.tar.xz) tar_flags='' ;;
        *.tar.bz2) tar_flags='j' ;;
        *) entry "[err:Invalid archive extension for file '${1}']" ; exit 1 ;;
    esac
    if [[ -d "${dir_name}" ]] ; then
        entry "Archive [path:'${1}'] already extracted, removing existing directory [path:'${dir_name}']..."
        local cmd=(rm -rvf "${dir_name}")
        shell_cmd "${cmd[@]}"
        entry "Completed removal of directory [path:'${dir_name}']."
    fi
    entry "Extracting archive [path:'${1}']"
    local cmd=(tar -x"${tar_flags}"f "${1}")
    shell_cmd "${cmd[@]}"
    entry "Succesfully extracted archive [path:'${1}']"
}

# apply patch
function apply_patch {
    entry "Applying patch [path:${1}]."
    local cmd=(patch -Np1 -i "${1}")
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
    local path="${1}"
    shift
    local cmd=(${path}/configure $@)
    shell_cmd "${cmd[@]}"
    entry "Successfully configured build."
}

# compile build
function compile_build {
    entry "Compiling build..."
    local cmd=(make)
    shell_cmd "${cmd[@]}"
    entry "Successfully compiled build."
}

# compile build
function install_build {
    entry "Installing build..."
    if [[ "$#" == 0 ]] ; then
        local cmd=(make install)
        shell_cmd "${cmd[@]}"
    else
        local cmd=(make DESTDIR="${1}" install)
        shell_cmd "${cmd[@]}"
    fi
    entry "Successfully installed build."
}

# mutable path
function mutable_path {
    local path=$(realpath -s "${1}")
    [[ "${path}" == "${AX_ROOT}"/etc/* || "${path}" == "${AX_ROOT}"/var/* ]]
}

# embed package
function embed_pkg {
    local pkg_dir="${AX_INSTS}/${1}/${2}"
    local tgt_dir="${3}"
    entry "Embedding package..."
    entry_up
    entry "Finding files to embed..."
    local cmd=(pushd "${pkg_dir}")
    shell_cmd "${cmd[@]}"
    cmd=(find . -type f)
    shell_cmd "${cmd[@]}"
    local pkg_files=($shell_cmd_out)
    cmd=(popd)
    shell_cmd "${cmd[@]}"
    for pkg_file in "${pkg_files[@]}" ; do
        local tgt_file="${tgt_dir}/${pkg_file}"
        if [[ -e "${tgt_file}" ]] ; then
            if ! mutable_path "${tgt_file}" ; then
                entry "[err:conflict for file] [path:${tgt_file}]"
                exit 1
            fi
        fi
    done
    entry "Embedding files..."
    local copy_cnt=0
    local skip_cnt=0
    local link_cnt=0
    for pkg_file in "${pkg_files[@]}" ; do
        local src_file="${pkg_dir}/${pkg_file}"
        local tgt_file="${tgt_dir}/${pkg_file}"
        cmd=(mkdir -p $(dirname "${tgt_file}"))
        shell_cmd "${cmd[@]}"
        if mutable_path "${tgt_file}" ; then
            if [[ -e "${tgt_file}" ]] ; then
                skip_cnt=$((skip_cnt + 1))
            else
                local cmd=(cp "${src_file}" "${tgt_file}")
                shell_cmd "${cmd[@]}"
                copy_cnt=$((copy_cnt + 1))
            fi
        else
            local cmd=(ln -sr "${src_file}" "${tgt_file}")
            shell_cmd "${cmd[@]}"
            link_cnt=$((link_cnt + 1))
        fi
    done
    entry "Copied [note:$copy_cnt] files"
    entry "Skipped [note:$skip_cnt] files"
    entry "Created [note:$link_cnt] symbolic links"
    entry_down
    entry "Successfully embedded package."
}

# extract package
function extract_pkg {
    local pkg_dir="${AX_INSTS}/${1}/${2}"
    local cem_dir="${AX_CEM}/${1}/${2}"
    local tgt_dir="${3}"
    entry "Extracting package..."
    entry_up
    entry "Finding files to extract..."
    local cmd=(pushd "${pkg_dir}")
    shell_cmd "${cmd[@]}"
    cmd=(find . -type f)
    shell_cmd "${cmd[@]}"
    local pkg_files=($shell_cmd_out)
    cmd=(popd)
    shell_cmd "${cmd[@]}"
    for pkg_file in "${pkg_files[@]}" ; do
        local tgt_file="${tgt_dir}/${pkg_file}"
        if ! [[ -e "${tgt_file}" ]] ; then
            entry "[err:missing file] [path:${tgt_file}]"
            exit 1
        fi
        if ! [[ -L "${tgt_file}" ]] ; then
            if ! mutable_path "${tgt_file}" ; then
                entry "[err:file] [path:${tgt_file}] [err:is not a symbolic link]"
                exit 1
            fi
        fi
    done
    entry "Removing files..."
    local rm_cnt=0
    local bury_cnt=0
    local tomb_path="${cem_dir}"/$(date +"%Y-%m-%dT%H_%M_%S_%N")/
    for pkg_file in "${pkg_files[@]}" ; do
        local tgt_file="${tgt_dir}/${pkg_file}"
        if mutable_path "${tgt_file}" ; then
            local tomb_file="${tomb_path}/${pkg_file}"
            cmd=(mkdir -p $(dirname "${tomb_file}"))
            shell_cmd "${cmd[@]}"
            cmd=(cp "${tgt_file}" "${tomb_file}")
            shell_cmd "${cmd[@]}"
            bury_cnt=$((rm_cnt + 1))
        fi
        cmd=(rm "${tgt_file}")
        shell_cmd "${cmd[@]}"
        rm_cnt=$((rm_cnt + 1))
    done
    entry "Removed [note:$rm_cnt] files"
    entry "Buried [note:$bury_cnt] files"
    entry_down
    entry "Successfully extracted package."
}

##################################
# 00050-intall-helpers section END
##################################
