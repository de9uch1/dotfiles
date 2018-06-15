#!/bin/sh

if [ `which git` ] ; then
    if [ `ssh -T git@github.com` ] ; then
        git clone git@github.com:dlambda/dotfiles.git ~/.dotfiles
    else
        git clone https://github.com/dlambda/dotfiles.git ~/.dotfiles
    fi
elif [ `which wget` ] ; then
    mkdir /tmp/dotfiles
    cd /tmp/dotfiles
    wget https://github.com/dlambda/dotfiles/archive/master.zip
    unzip master.zip
    mv dotfiles-master ~/.dotfiles
    rm -r /tmp/dotfiles
fi

cd ~/.dotfiles
if [ $(uname) = "Linux" ] ; then
    make link
elif [ $(uname) = "FreeBSD" ] ; then
    gmake link
fi
