######################
# 00100-ax-setup START
######################

function setup_ax_init {
    entry "Initial preparations..."
    entry_up

    set +h
    entry "Disabled bash command hasing"

    umask 022
    entry "Set umask to [note:022]"

    env_set "AX_ROOT" "/tmp/ax"
    env_set "LC_ALL" "POSIX"
    env_set "AX_TGT" "$(uname -m)-ax-linux-gnu"
    env_set "AX_TOOLS" "/tmp/ax/tools"
    env_set "PATH" "$(fmt_esc ${AX_TOOLS}/bin:$PATH)"
    env_set "CONFIG_SITE" "${AX_ROOT}/usr/share/config.site"

    create_dir "$AX_ROOT"
    create_dir "$AX_TOOLS"

    entry_down
    entry "Completed initial preparations."
}

function setup_ax_fhs {
    entry "Creating Filesystem Hierarchy Standard (FHS)..."
    entry_up

    create_dir "${AX_ROOT}/bin"
    create_dir "${AX_ROOT}/boot"
    create_dir "${AX_ROOT}/dev"
    create_dir "${AX_ROOT}/etc"
    create_dir "${AX_ROOT}/etc/opt"
    create_dir "${AX_ROOT}/home"
    create_dir "${AX_ROOT}/lib"
    create_dir "${AX_ROOT}/lib64"
    create_dir "${AX_ROOT}/media"
    create_dir "${AX_ROOT}/mnt"
    create_dir "${AX_ROOT}/opt"
    create_dir "${AX_ROOT}/root"
    create_dir "${AX_ROOT}/run"
    create_dir "${AX_ROOT}/sbin"
    create_dir "${AX_ROOT}/srv"
    create_dir "${AX_ROOT}/tmp"
    create_dir "${AX_ROOT}/usr"
    create_dir "${AX_ROOT}/usr/bin"
    create_dir "${AX_ROOT}/usr/include"
    create_dir "${AX_ROOT}/usr/lib"
    create_dir "${AX_ROOT}/usr/libexec"
    create_dir "${AX_ROOT}/usr/local"
    create_dir "${AX_ROOT}/usr/local/bin"
    create_dir "${AX_ROOT}/usr/local/etc"
    create_dir "${AX_ROOT}/usr/local/games"
    create_dir "${AX_ROOT}/usr/local/include"
    create_dir "${AX_ROOT}/usr/local/lib"
    create_dir "${AX_ROOT}/usr/local/man"
    create_dir "${AX_ROOT}/usr/local/sbin"
    create_dir "${AX_ROOT}/usr/local/share"
    create_dir "${AX_ROOT}/usr/local/src"
    create_dir "${AX_ROOT}/usr/sbin"
    create_dir "${AX_ROOT}/usr/share"
    create_dir "${AX_ROOT}/usr/src"
    create_dir "${AX_ROOT}/var"
    create_dir "${AX_ROOT}/var/lib"
    create_dir "${AX_ROOT}/var/lock"
    create_dir "${AX_ROOT}/var/log"
    create_dir "${AX_ROOT}/var/opt"
    create_dir "${AX_ROOT}/var/run"
    create_dir "${AX_ROOT}/var/spool"
    create_dir "${AX_ROOT}/var/tmp'"

    entry_down
    entry "Completed FHS creation."
}

function setup_ax_binutils_step_1 {
    binutils_url="https://sourceware.org/pub/binutils/releases/binutils-2.44.tar.xz"
    binutils_archive=$(basename "${binutils_url}")
    change_dir "${AX_TOOLS}"
    fetch_url "${binutils_url}" "${binutils_archive}"
    unpack_archive "${binutils_archive}"
}

function setup_ax {
    entry "Starting [note:AX system] setup..."
    entry_up

    setup_ax_init
    setup_ax_fhs
    setup_ax_binutils_step_1

    entry_down
    entry "Completed [note:AX system] setup."
}

####################
# 00100-ax-setup END
####################
