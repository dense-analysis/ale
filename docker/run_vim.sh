#!/bin/sh

if [ "$VIM_TESTBED_DEBUG" = 1 ]; then
  set -x
fi

BIN=$1
shift

if [ "$BIN" = "sh" ] || [ -z "$BIN" ]; then
  exec /bin/sh
fi
if ! [ -x "/vim-build/bin/$BIN" ]; then
  exec "$BIN" "$@"
fi

# Set default vimrc to a visible file
ARGS="-u /home/vimtest/vimrc -i NONE"

# Run as the vimtest user (when no USER is specified in the Dockerfile, i.e.
# when running as root).
# This is not really for security.  It is for running Vim as a user that's
# unable to write to your volume.
if [ "$(id -u)" = 0 ]; then
  # So we can pass the arguments to Vim as it was passed to this script
  while [ $# -gt 0 ]; do
    ARGS="$ARGS \"$1\""
    shift
  done
  exec su -l vimtest -c "cd /testplugin && /vim-build/bin/$BIN $ARGS"
fi

cd /testplugin || exit

# shellcheck disable=SC2086
exec "/vim-build/bin/$BIN" "$@"
