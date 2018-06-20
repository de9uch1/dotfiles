#!/bin/sh

DOTFILES_PATH="${HOME}/.dotfiles"

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
        git clone git@github.com:dlambda/dotfiles.git $DOTFILES_PATH
    else
        git clone https://github.com/dlambda/dotfiles.git $DOTFILES_PATH
    fi
}

get_master_archive() {
    local SRC_URI="https://github.com/dlambda/dotfiles/archive/master.tar.gz"
    if [ $(which curl) ]; then
        curl -L $SRC_URI
    elif [ $(which wget) ]; then
        wget -O - $SRC_URI 
    fi | tar xzv
    mv dotfiles-master $DOTFILES_PATH
}

if [ $(which git) ]; then
    get_git_repo
else
    get_master_archive
fi

cd $DOTFILES_PATH
$MAKE link
