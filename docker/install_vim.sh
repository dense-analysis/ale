#!/bin/sh

set -e
set -x

bail() {
  echo "$@" >&2
  exit 1
}

init_vars() {
  FLAVOR=
  TAG=
  NAME=
  PYTHON2=
  PYTHON3=
  RUBY=0
  LUA=0
  CONFIGURE_OPTIONS=
  PREBUILD_SCRIPT=
}

# "apk add --virtual" does not add to existing virtual package anymore since
# Alpine 3.9 (https://bugs.alpinelinux.org/issues/9651).
APK_BUILD_DEPS=
apk_add_build_dep() {
  for dep; do
    if ! apk info -e "$dep"; then
      apk add "$dep"
      APK_BUILD_DEPS="$APK_BUILD_DEPS $dep"
    fi
  done
}

prepare_build() {
  [ -z $TAG ] && bail "-tag is required"

  # Parse TAG into repo and tag.
  IFS=: read -r -- repo tag <<EOF
$TAG
EOF
  if [ -z "$tag" ]; then
    tag="$repo"
    repo=
  elif [ "$repo" = vim ]; then
    repo="vim/vim"
  elif [ "$repo" = neovim ]; then
    repo="neovim/neovim"
    [ -z "$FLAVOR" ] && FLAVOR=neovim
  elif [ "${repo#*/}" = "$repo" ]; then
    bail "Unrecognized repo ($repo) from tag: $TAG"
  elif [ "${repo#*/neovim}" != "$repo" ]; then
    FLAVOR=neovim
  fi
  if [ -z "$FLAVOR" ]; then
    FLAVOR=vim
  fi
  if [ -z "$repo" ]; then
    if [ "$FLAVOR" = vim ]; then
      repo="vim/vim"
    else
      repo="neovim/neovim"
    fi
  fi
  [ -z $NAME ] && NAME="${FLAVOR}-${tag}"

  if [ "$FLAVOR" = vim ]; then
    VIM_NAME="${repo}/${tag}_py${PYTHON2}${PYTHON3}_rb${RUBY}_lua${LUA}"
  else
    VIM_NAME="${repo}/${tag}"
  fi
  INSTALL_PREFIX="/vim-build/$VIM_NAME"

  if [ "$FLAVOR" = vim ]; then
    VIM_CONFIG_ARGS="--prefix=$INSTALL_PREFIX --enable-multibyte --without-x --enable-gui=no --with-compiledby=vim-testbed --with-tlib=ncurses"
  fi
  set +x
  echo "TAG:$TAG"
  echo "repo:$repo"
  echo "tag:$tag"
  echo "FLAVOR:$FLAVOR"
  echo "NAME:$NAME"
  set -x

  apk_add_build_dep gcc libc-dev make

  if [ -n "$PYTHON2" ]; then
    apk_add_build_dep python2-dev
    if [ "$FLAVOR" = vim ]; then
      VIM_CONFIG_ARGS="$VIM_CONFIG_ARGS --enable-pythoninterp=dynamic"
    else
      apk add python2
      apk_add_build_dep g++  # for building greenlet
      python2 -m ensurepip
      pip2 install pynvim
    fi
  fi

  if [ -n "$PYTHON3" ]; then
    apk_add_build_dep python3-dev
    if [ "$FLAVOR" = vim ]; then
      VIM_CONFIG_ARGS="$VIM_CONFIG_ARGS --enable-python3interp=dynamic"
    else
      apk add python3
      apk add py3-pynvim
    fi
  fi

  if [ $RUBY -eq 1 ]; then
    apk_add_build_dep ruby-dev
    apk add ruby
    if [ "$FLAVOR" = vim ]; then
      VIM_CONFIG_ARGS="$VIM_CONFIG_ARGS --enable-rubyinterp"
    else
      apk_add_build_dep ruby-rdoc ruby-irb
      gem install neovim
    fi
  fi

  if [ $LUA -eq 1 ]; then
    if [ "$FLAVOR" = vim ]; then
      VIM_CONFIG_ARGS="$VIM_CONFIG_ARGS --enable-luainterp"
      apk_add_build_dep lua5.3-dev
      apk add lua5.3-libs
      # Install symlinks to make Vim's configure pick it up.
      (cd /usr/bin && ln -s lua5.3 lua)
      (cd /usr/lib && ln -s lua5.3/liblua.so liblua5.3.so)
    else
      echo 'NOTE: -lua is automatically used with Neovim 0.2.1+, and not supported before.'
    fi
  fi

  if [ "$FLAVOR" = vim ] && [ -n "$CONFIGURE_OPTIONS" ]; then
    VIM_CONFIG_ARGS="$VIM_CONFIG_ARGS $CONFIGURE_OPTIONS"
  fi

  cd /vim

  if [ -d "$INSTALL_PREFIX" ]; then
    echo "WARNING: $INSTALL_PREFIX exists already.  Overwriting."
  fi

  BUILD_DIR="${FLAVOR}-${repo}-${tag}"
  if [ ! -d "$BUILD_DIR" ]; then
    apk_add_build_dep git
    git clone -b "$tag" "https://github.com/$repo" "$BUILD_DIR"
    cd "$BUILD_DIR"
  else
    cd "$BUILD_DIR"
  fi

  if [ "$FLAVOR" = vim ]; then
    apk_add_build_dep ncurses-dev
    apk add ncurses
  elif [ "$FLAVOR" = neovim ]; then
    # Some of them will be installed already, but it is a good reference for
    # what is required.
    # luajit is required with Neomvim 0.2.1+ (previously only during build).
    apk add gettext \
      libuv \
      libtermkey \
      libvterm \
      luajit \
      msgpack-c \
      unibilium
    apk_add_build_dep \
      autoconf \
      automake \
      ca-certificates \
      cmake \
      g++ \
      gettext-dev \
      gperf \
      libtool \
      libuv-dev \
      libtermkey-dev \
      libvterm-dev \
      lua5.1-lpeg \
      lua5.1-mpack \
      luajit-dev \
      m4 \
      make \
      msgpack-c-dev \
      perl \
      unzip \
      unibilium-dev \
      xz
  else
    bail "Unexpected FLAVOR: $FLAVOR (use vim or neovim)."
  fi
}

build() {
  if [ -n "$PREBUILD_SCRIPT" ]; then
    eval "$PREBUILD_SCRIPT"
  fi

  if [ "$FLAVOR" = vim ]; then
    # Apply build fix from v7.1.148.
    # NOTE: this silently does nothing with 7.1.148+, but can be skipped with
    # Vim 8+ (and needs to be for 8.0.0082, where src/configure.in was renamed
    # to src/configure.ac).
    MAJOR="$(sed -n '/^MAJOR = / s~MAJOR = ~~p' Makefile)"
    if [ "$MAJOR" -lt 8 ]; then
      sed -i 's~sys/time.h termio.h~sys/time.h sys/types.h termio.h~' src/configure.in src/auto/configure
    fi

    # Apply Vim patch v8.0.1635 to fix build with Python.
    if grep -q _POSIX_THREADS src/if_python3.c; then
      sed -i '/#ifdef _POSIX_THREADS/,+2 d' src/if_python3.c
    fi

    if [ -n "$PYTHON3" ]; then
      # Vim patch 8.1.2201 (cannot build with dynamically linked Python 3.8).
      if ! grep -q "# if PY_VERSION_HEX >= 0x030800f0" src/if_python3.c; then
        apk_add_build_dep curl patch
        curl https://github.com/vim/vim/commit/13a1f3fb0.patch \
          | patch -p1
      fi
      # Vim patch 8.2.0354 (Python 3.9 does not define _Py_DEC_REFTOTAL).
      if grep -q "^    _Py_DEC_REFTOTAL;$" src/if_python3.c; then
        apk_add_build_dep curl patch
        curl https://github.com/vim/vim/commit/a65bb5351.patch \
          | patch -p1
      fi
      # Vim patch 8.2.1225: linker errors when building with dynamic Python 3.9.
      if ! grep -q "^#  define PyType_GetFlags py3_PyType_GetFlags" src/if_python3.c; then
        # NOTE: --fuzz=3 needed with Vim v7.4.052 (likely due to e.g. missingv8.1.0735).
        apk_add_build_dep curl patch
        curl https://github.com/vim/vim/commit/ee1b93169.patch \
          | patch -p1 --fuzz=3
      fi
    fi

    echo "Configuring with: $VIM_CONFIG_ARGS"
    # shellcheck disable=SC2086
    ./configure $VIM_CONFIG_ARGS || bail "Could not configure"
    make CFLAGS="-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2" -j4 || bail "Make failed"
    make install || bail "Install failed"

  elif [ "$FLAVOR" = neovim ]; then
    CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX"
    DEPS_CMAKE_FLAGS="$DEPS_CMAKE_FLAGS -DUSE_BUNDLED_TS_PARSERS=ON"
    DEPS_CMAKE_FLAGS="$DEPS_CMAKE_FLAGS -DUSE_BUNDLED_TS=ON"

    # Use bundled libvterm.  Neovim 0.4.x requires 0.1, which is not yet in
    # Alpine Linux.  Using the bundled version also makes it easier for older
    # Neovim versions when Alpine updates it.
    DEPS_CMAKE_FLAGS="$DEPS_CMAKE_FLAGS -DUSE_BUNDLED_LIBVTERM=ON"

    # Install luv, for Neovim 0.4.0+, shipped with Alpine 3.10+.
    # Only add it when required, since it was broken with nvim-0.2.0
    # (at least, maybe only when using the bundled one), where it is optional
    # (only for tests).
    if grep -iq 'find.*libluv' CMakeLists.txt; then
      apk add libluv
      apk_add_build_dep libluv-dev
    fi

    # NOTE: ENABLE_JEMALLOC has been removed in v0.3.4-168-gc2343180d
    # (https://github.com/neovim/neovim/commit/c2343180d).
    if grep -q 'ENABLE_JEMALLOC' CMakeLists.txt; then
      CMAKE_EXTRA_FLAGS="$CMAKE_EXTRA_FLAGS -DENABLE_JEMALLOC=OFF"
    fi

    # Use bundled unibilium with older releases that use data directly, and not
    # through unibi_var_from_num like it is required now.
    if ! grep -qF 'unibi_var_from_num' src/nvim/tui/tui.c; then
      DEPS_CMAKE_FLAGS="$DEPS_CMAKE_FLAGS -DUSE_BUNDLED_UNIBILIUM=ON"
    fi

    if grep -qF 'UTF8PROC' CMakeLists.txt; then
      apk add utf8proc
      apk_add_build_dep utf8proc-dev
    fi

    # gcc10 fixes (due to -fno-common),
    # required to fix builds with v0.3.0+, until v0.4.4/v0.5.0.
    # Ref: https://github.com/neovim/neovim/commit/c036e24f3.patch
    if grep -q '\} ListLenSpecials;$' src/nvim/eval/typval.h; then
      apk_add_build_dep curl patch
      curl https://github.com/neovim/neovim/commit/ebcde1de4.patch | patch -p1
    fi
    if grep -q '\} ExprParserFlags;$' src/nvim/viml/parser/expressions.h; then
      apk_add_build_dep curl patch
      curl https://github.com/neovim/neovim/commit/b87b4a614.patch | patch -p1
    fi
    if grep -q '\} RemapValues;$' src/nvim/getchar.h; then
      apk_add_build_dep curl patch
      curl https://github.com/neovim/neovim/commit/986db1adb.patch | patch -p1
    fi
    if grep -q "^MultiQueue \*ch_before_blocking_events;" src/nvim/msgpack_rpc/channel.h; then
      apk_add_build_dep curl patch
      curl https://github.com/neovim/neovim/commit/517bf1560.patch | patch -p1
    fi
    if grep -q '^EXTERN PMap(uint64_t) \*channels;$' src/nvim/channel.h; then
      apk_add_build_dep curl patch
      curl https://github.com/neovim/neovim/commit/823b2104c.patch | patch -p1
    fi

    # NOTE: uses "make cmake" to avoid linking twice when changing versiondef.h
    make cmake CMAKE_BUILD_TYPE=RelWithDebInfo \
      CMAKE_EXTRA_FLAGS="$CMAKE_EXTRA_FLAGS" \
      DEPS_CMAKE_FLAGS="$DEPS_CMAKE_FLAGS" \
        || bail "make cmake failed"

    make install || bail "Install failed"
  fi

  # Clean, but don't delete the source in case you want make a different build
  # with the same version.
  make distclean

  if [ "$FLAVOR" = vim ]; then
    VIM_BIN="$INSTALL_PREFIX/bin/vim"
  else
    VIM_BIN="$INSTALL_PREFIX/bin/nvim"
  fi
  if ! [ -e "$VIM_BIN" ]; then
    bail "Binary $VIM_BIN was not created."
  fi
  link_target="/vim-build/bin/$NAME"
  if [ -e "$link_target" ]; then
    echo "WARNING: link target for $NAME exists already.  Overwriting."
  fi
  ln -sfn "$VIM_BIN" "$link_target"
  "$link_target" --version
}

apk update

init_vars
clean=
while [ $# -gt 0 ]; do
  case $1 in
    -flavor)
      if [ "$2" != vim ] && [ "$2" != neovim ]; then
        bail "Invalid value for -flavor: $2: only vim or neovim are recognized."
      fi
      FLAVOR="$2"
      shift
      ;;
    -name)
      NAME="$2"
      shift
      ;;
    -tag)
      TAG="$2"
      shift
      ;;
    -py|-py2)
      PYTHON2=2
      ;;
    -py3)
      PYTHON3=3
      ;;
    -ruby)
      RUBY=1
      ;;
    -lua)
      LUA=1
      ;;
    -prepare_build)
      # Not documented, meant to ease hacking on this script, by avoiding
      # downloads over and over again.
      prepare_build
      [ -z "$clean" ] && clean=0
      ;;
    -skip_clean)
      clean=0
      ;;
    -prebuild_script)
      PREBUILD_SCRIPT="$2"
      shift
      ;;
    -build)
      # So here I am thinking that using Alpine was going to give the biggest
      # savings in image size.  Alpine starts at about 5MB.  Built this image,
      # and it's about 8MB.  Looking good.  Install two versions of vanilla
      # vim, 300MB wtf!!!  Each run of this script without cleaning up created
      # a layer with all of the build dependencies.  So now, this script
      # expects a -build flag to signal the start of a build.  This way,
      # installing all Vim versions becomes one layer.
      # Side note: tried docker-squash and it didn't seem to do anything.
      echo "=== building: NAME=$NAME, TAG=$TAG, PYTHON=${PYTHON2}${PYTHON3}, RUBY=$RUBY, LUA=$LUA, FLAVOR=$FLAVOR ==="
      prepare_build
      build
      init_vars
      [ -z "$clean" ] && clean=1
      ;;
    *)
      CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS $1"
      ;;
  esac

  shift
done

if [ "$clean" = 0 ]; then
  echo "NOTE: skipping cleanup."
else
  echo "Pruning packages and dirs.."
  if [ -n "$APK_BUILD_DEPS" ]; then
    # shellcheck disable=SC2086
    apk del $APK_BUILD_DEPS
    APK_BUILD_DEPS=
  fi
  rm -rf /vim/*
  rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /root/.cache
  find / \( -name '*.pyc' -o -name '*.pyo' \) -delete

  # Luarocks used for Neovim.
  rm -f /usr/local/bin/luarocks*
  rm -rf /usr/local/share/lua/5*/luarocks
  rm -rf /usr/local/etc/luarocks*
fi
