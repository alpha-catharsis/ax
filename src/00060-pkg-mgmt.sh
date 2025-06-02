################################
# 00060-package management START
################################

function install_pkg {
    local pkg_ext_name="${1}"
    local pkg_ver="${2}"
    entry "Installing package [note:${pkg_ext_name}:${pkg_ver}]..."
    entry_up

    local desc_path="${AX_DESCS}/${pkg_ext_name}"
    if ! [[ -e "${desc_path}" ]] ; then
        entry "[err:Cannot load package descriptor] [path:${desc_path}]"
        exit 1
    fi

    unset pkg_name
    unset pkg_vers
    unset pkg_fetch
    unset pkg_prepare
    unset pkg_install
    source "${desc_path}"

    local supported=0
    for ver in "${pkg_vers[@]}" ; do
        if [[ "${pkg_ver}" == "${ver}" ]] ; then
            supported=1
            break
        fi
    done
    if ((supported == 0)) ; then
        entry "[err:unsupported package version] [note:${pkg_ver}]"
        exit 1
    fi

    shell_cmd "${cmd[@]}"
    local tmp_pkg_dir=$(mktemp -d)
    trap "rm -rf ${tmp_pkg_dir}" EXIT
    change_dir "${tmp_pkg_dir}"

    entry "Fetching package."
    entry_up
    pkg_fetch "${pkg_ver}"
    entry_down
    entry "Preparing package."
    entry_up
    pkg_prepare "${pkg_ver}"
    entry_down
    entry "Installing package."
    entry_up
    pkg_install "${pkg_ver}"
    entry_down
    entry "Cleaning up."
    local cmd=(cd ..)
    shell_cmd "${cmd[@]}"
    local cmd=(rm -rf "${tmp_pkg_dir}")
    shell_cmd "${cmd[@]}"

    trap - EXIT

    entry_down
    entry "Completed installation of package [note:${1}]..."
}

##############################
# 00060-package management END
##############################
