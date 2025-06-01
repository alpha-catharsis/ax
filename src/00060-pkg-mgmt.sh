################################
# 00060-package management START
################################

function install_pkg {
    entry "Installing package [note:${1}]..."
    entry_up

    local desc_path="${AX_DESCS}/${1}"
    if ! [[ -e "${desc_path}" ]] ; then
        entry "[err:Cannot load package descriptor] [path:${desc_path}]"
        echo "${desc_path}"
        exit 1
    fi
    unset pkg_name
    unset pkg_ver
    unset pkg_fetch
    unset pkg_prepare
    unset pkg_install
    entry "Loading package descriptor [path:${desc_path}]."
    local cmd=(source "${desc_path}")
    shell_cmd "${cmd[@]}"
    local tmp_pkg_dir=$(mktemp -d)
    change_dir "${tmp_pkg_dir}"
    entry "Fetching package."
    local cmd=(pkg_fetch)
    shell_cmd "${cmd[@]}"
    entry "Preparing package."
    cmd=(pkg_prepare)
    shell_cmd "${cmd[@]}"
    entry "Installing package."
    cmd=(pkg_install ${AX_ROOT})
    shell_cmd "${cmd[@]}"
    entry "Cleaning up."
    local cmd=(cd ..)
    shell_cmd "${cmd[@]}"
    local cmd=(rm -rf "${tmp_pkg_dir}")
    shell_cmd "${cmd[@]}"

    entry_down
    entry "Completed installation of package [note:${1}]..."
}

##############################
# 00060-package management END
##############################
