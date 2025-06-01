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
    env_set "AX_PKGS" "/tmp/ax/pkgs"
    env_set "AX_CEM" "/tmp/ax/pkgs/cemetery"
    env_set "PATH" "$(fmt_esc ${AX_TOOLS}/bin:$PATH)"
    env_set "CONFIG_SITE" "${AX_ROOT}/usr/share/config.site"
    env_set "MAKEFLAGS" "j 4"

    entry_down
    entry "Completed initial preparations."
}

function setup_ax_dirs {
    entry "Creating AX directories..."
    entry_up

    create_dir "${AX_ROOT}"
    create_dir "${AX_TOOLS}"
    create_dir "${AX_PKGS}"
    create_dir "${AX_CEM}"

    create_dir "${AX_ROOT}/lib"
    create_dir "${AX_ROOT}/lib64"
    create_dir "${AX_ROOT}/usr"
    create_dir "${AX_ROOT}/usr/include"

    entry_down
    entry "Completed AX directories creation."
}

function setup_ax_binutils_pass_1 {
    entry "Installing [note:binutils (Pass 1)]..."
    entry_up

    local binutils_url="https://sourceware.org/pub/binutils/releases/binutils-2.44.tar.xz"
    local binutils_archive=$(basename "${binutils_url}")

    change_dir "${AX_TOOLS}"
    fetch_url "${binutils_url}" "${binutils_archive}"
    unpack_archive "${binutils_archive}"
    change_dir $(archive_name "${binutils_archive}")
    prepare_build
    configure_build ".." \
        "--prefix=${AX_TOOLS}" \
        "--with-sysroot=${AX_ROOT}" \
        "--target=${AX_TGT}" \
        "--disable-nls" \
        "--enable-gprofng=no" \
        "--disable-werror" \
        "--enable-new-dtags" \
        "--enable-default-hash-style=gnu"
    compile_build
    install_build

    entry_down
    entry "Successfully installed [note:binutils (Pass 1)]..."
}

function setup_ax_gcc_pass_1 {
    entry "Installing [note:gcc (Pass 1)]..."
    entry_up

    local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz"
    local gcc_archive=$(basename "${gcc_url}")
    local gcc_dir=$(archive_name "${gcc_archive}")
    local mpfr_url="https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.2.tar.xz"
    local mpfr_archive=$(basename "${mpfr_url}")
    local mpfr_dir=$(archive_name "${mpfr_archive}")
    local gmp_url="https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
    local gmp_archive=$(basename "${gmp_url}")
    local gmp_dir=$(archive_name "${gmp_archive}")
    local mpc_url="https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
    local mpc_archive=$(basename "${mpc_url}")
    local mpc_dir=$(archive_name "${mpc_archive}")

    change_dir "${AX_TOOLS}"
    fetch_url "${gcc_url}" "${gcc_archive}"
    unpack_archive "${gcc_archive}"
    change_dir $(archive_name "${gcc_archive}")
    fetch_url "${mpfr_url}" "${mpfr_archive}"
    unpack_archive "${mpfr_archive}"
    move_file "${mpfr_dir}" "mpfr"
    fetch_url "${gmp_url}" "${gmp_archive}"
    unpack_archive "${gmp_archive}"
    move_file "${gmp_dir}" "gmp"
    fetch_url "${mpc_url}" "${mpc_archive}"
    unpack_archive "${mpc_archive}"
    move_file "${mpc_dir}" "mpc"

    entry "Setting default directory name for 64-bit libraries to [path:lib]."
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

    prepare_build
    configure_build ".." \
        "--target=${AX_TGT}" \
        "--prefix=${AX_TOOLS}" \
        "--with-glibc-version=2.41" \
        "--with-sysroot=${AX_ROOT}" \
        "--with-newlib" \
        "--without-headers" \
        "--enable-default-pie" \
        "--enable-default-ssp" \
        "--disable-nls" \
        "--disable-shared" \
        "--disable-multilib" \
        "--disable-threads" \
        "--disable-libatomic" \
        "--disable-libgomp" \
        "--disable-libquadmath" \
        "--disable-libssp" \
        "--disable-libvtv" \
        "--disable-libstdcxx" \
        "--enable-languages=c,c++"
    compile_build
    install_build

    entry "Generating [path:limits.h]."
    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname $($AX_TGT-gcc -print-libgcc-file-name)`/include/limits.h

    entry_down
    entry "Successfully installed [note:gcc (Pass 1)]..."
}

function setup_ax_linux_api_headers {
    entry "Installing [note:linux API headers]..."
    entry_up

    local linux_url="https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.14.6.tar.xz"
    local linux_archive=$(basename "${linux_url}")

    change_dir "${AX_TOOLS}"
    fetch_url "${linux_url}" "${linux_archive}"
    unpack_archive "${linux_archive}"
    change_dir $(archive_name "${linux_archive}")
    entry "Cleaning up package"
    local cmd=(make mrproper)
    shell_cmd "${cmd[@]}"
    entry "Generating headers"
    cmd=(make headers)
    shell_cmd "${cmd[@]}"
    entry "Installing headers"
    cmd=(find usr/include -type f ! -name '*.h' -delete)
    shell_cmd "${cmd[@]}"

    local install_dir="${AX_PKGS}/linux-headers/6.14.6"
    create_dirs "${install_dir}/usr"
    cmd=(cp -r usr/include "${install_dir}/usr")
    shell_cmd "${cmd[@]}"

    embed_pkg "linux-headers" "6.14.6" "${AX_ROOT}"

    entry_down
    entry "Successfully installed [note:linux API headers]..."
}

function setup_ax_glibc {
    entry "Installing [note:glibc]..."
    entry_up

    local glibc_url="https://ftp.gnu.org/gnu/glibc/glibc-2.41.tar.xz"
    local glibc_archive=$(basename "${glibc_url}")
    local patch_url="https://www.linuxfromscratch.org/patches/lfs/development/glibc-2.41-fhs-1.patch"
    local patch_file=$(basename "${patch_url}")

    change_dir "${AX_TOOLS}"
    fetch_url "${glibc_url}" "${glibc_archive}"
    unpack_archive "${glibc_archive}"
    change_dir $(archive_name "${glibc_archive}")
    fetch_url "${patch_url}" "${patch_file}"
    entry "Creating 64-bit library compatibility links"
    local cmd=(ln -sfv ../lib/ld-linux-x86-64.so.2 "${AX_ROOT}"/lib64)
    shell_cmd "${cmd[@]}"
    cmd=(ln -sfv ../lib/ld-linux-x86-64.so.2 "${AX_ROOT}"/lib64/ld-lsb-x86-64.so.3)
    shell_cmd "${cmd[@]}"
    apply_patch "${patch_file}"
    prepare_build
    entry "Enforcing the use of [path:/usr/sbin] directory"
    echo "rootsbindir=/usr/sbin" > configparms
    configure_build ".." \
      "--prefix=/usr" \
      "--host=${AX_TGT}" \
      "--build=$(../scripts/config.guess)" \
      "--with-headers=${AX_ROOT}/usr/include" \
      "--disable-nscd" \
      "libc_cv_slibdir=/usr/lib" \
      "--enable-kernel=5.4"
    compile_build

    local install_dir="${AX_PKGS}/glibc/2.41"
    create_dirs "${install_dir}"
    install_build "${install_dir}"
    entry "Fix hardcoded path to the executable loader in [note:ldd] script"
    cmd=(sed /RTLDLIST=/s@/usr@@g -i "${install_dir}"/usr/bin/ldd)
    shell_cmd "${cmd[@]}"

    embed_pkg "glibc" "2.41" "${AX_ROOT}"

    entry_down
    entry "Successfully installed [note:glibc]..."
}

function setup_ax_stdlibcpp {
    entry "Installing [note:libstdc++]..."
    entry_up

    local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz"
    local gcc_archive=$(basename "${gcc_url}")
    local gcc_dir=$(archive_name "${gcc_archive}")

    change_dir "${AX_TOOLS}"
    fetch_url "${gcc_url}" "${gcc_archive}"
    unpack_archive "${gcc_archive}"
    change_dir $(archive_name "${gcc_archive}")
    prepare_build
    configure_build "../libstdc++-v3"\
        "--host=${AX_TGT}" \
        "--build=$(../config.guess)" \
        "--prefix=/usr" \
        "--disable-multilib" \
        "--disable-nls" \
        "--disable-libstdcxx-pch" \
        "--with-gxx-include-dir=/tools/${AX_TGT}/include/c++/14.2.0"
    compile_build

    local install_dir="${AX_PKGS}/libstdc++/14.2.0"
    create_dirs "${install_dir}"
    install_build "${install_dir}"
    entry "Removing libtool archive files."
    local cmd=(rm -v "${install_dir}"/usr/lib/lib{stdc++{,exp,fs},supc++}.la)
    shell_cmd "${cmd[@]}"

    embed_pkg "libstdc++" "14.2.0" "${AX_ROOT}"

    entry_down
    entry "Successfully installed [note:libstdc++]..."
}

function setup_ax {
    entry "Starting [note:AX system] setup..."
    entry_up

    setup_ax_init
    setup_ax_dirs
    setup_ax_binutils_pass_1
    setup_ax_gcc_pass_1
    setup_ax_linux_api_headers
    setup_ax_glibc
    # setup_ax_stdlibcpp

    entry_down
    entry "Completed [note:AX system] setup."
}

####################
# 00100-ax-setup END
####################
