#!/bin/sh

DOTFILES_PATH=$HOME/.dotfiles
SRC_URI_GIT_SSH="git@github.com:de9uch1/dotfiles.git"
SRC_URI_GIT_HTTP="https://github.com/de9uch1/dotfiles.git"
SRC_URI_TARBALL="https://github.com/de9uch1/dotfiles/archive/master.tar.gz"

case $(uname) in
    Linux)
        MAKE="make"
        ;;
    FreeBSD)
        MAKE="gmake"
        ;;
    *)
        
esac

get_git_repo() {
    if [ $(ssh -fT git@github.com) ]; then
        git clone $SRC_URI_GIT_SSH $DOTFILES_PATH
    else
        git clone $SRC_URI_GIT_HTTP $DOTFILES_PATH
    fi
}

get_master_archive() {
    local 
    if $(which curl >/dev/null 2>&1) ; then
        curl -L $SRC_URI_TARBALL
    elif $(which wget >/dev/null 2>&1) ; then
        wget -O - $SRC_URI_TARBALL
    fi | tar xzv
    mv dotfiles-master $DOTFILES_PATH
}

if $(which git >/dev/null 2>&1); then
    get_git_repo
else
    get_master_archive
fi

cd $DOTFILES_PATH
$MAKE link
