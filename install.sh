#!/bin/sh

DOTFILES_PATH=$HOME/.dotfiles
SRC_URI_GIT_SSH="git@github.com:de9uch1/dotfiles.git"
SRC_URI_GIT_HTTP="https://github.com/de9uch1/dotfiles.git"
SRC_URI_TARBALL="https://github.com/de9uch1/dotfiles/archive/master.tar.gz"

MAKE=""
case $(uname) in
    Linux|Darwin)
        MAKE="make"
        ;;
    FreeBSD)
        MAKE="gmake"
        ;;
    *)
        ;;
esac
if [ -z "$MAKE" ]; then
    echo "GNUmake not found, abort."
    exit -1
fi

get_git_repo() {
    if ssh -T git@github.com; [ $? -eq 1 ]; then
        git clone $SRC_URI_GIT_SSH $DOTFILES_PATH
    else
        git clone $SRC_URI_GIT_HTTP $DOTFILES_PATH
    fi
}

get_master_archive() {
    if command -v curl >/dev/null; then
        curl -L $SRC_URI_TARBALL
    elif command -v wget >/dev/null; then
        wget -O - $SRC_URI_TARBALL
    fi | tar xzv
    mv dotfiles-master $DOTFILES_PATH
}

if command -v git >/dev/null; then
    get_git_repo
else
    get_master_archive
fi

cd $DOTFILES_PATH
$MAKE link
exec $SHELL
