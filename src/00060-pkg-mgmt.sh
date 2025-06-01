################################
# 00060-package management START
################################

function install_pkg {
    entry "Installing package [note:${1}]..."
    entry_up

    local desc_path="${AX_DESCS}/${1}"
    if ! [[ -e desc_path ]] ; then
        entry "[err:Cannot load package descriptor] [path:${desc_path}]"
    fi
    unset pkg_name
    unset pkg_ver
    unset pkg_fetch
    unset pkg_prepare
    unset pkg_install
    entry "Loading package descriptor [path:${desc_path}]."
    local cmd=(source "${desc_path}")
    shell_cmd "${cmd[@]}"
    local pkg_build_dir="/tmp/ax-build"
    create_dir "${pkg_build_dir}"
    change_dir "${pkg_build_dir}"
    entry "Fetching package."
    pkg_fetch
    entry "Preparing package."
    pkg_prepare
    entry "Installing package."
    pkg_install
    change_dir ".."
    local cmd=(rm -rf "${pkg_build_dir}")
    shell_cmd "${cmd[@]}"

    entry_down
    entry "Completed installation of package [note:${1}]..."
}

##############################
# 00060-package management END
##############################
