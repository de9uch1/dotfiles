#!/bin/bash
# -*- mode:shell-script; sh-indentation:4; coding:utf-8 -*-

function add_path() {
    while [[ $# -gt 0 ]] ; do
        if [[ ":${PATH}:" != *:"$1":* ]] ; then
            export PATH="${1}:${PATH}"
        fi
        shift
    done
}

# enviroment variables
source $HOME/.envvars

export LANG=en_US.UTF-8
[[ -d $HOME/gentoo ]] && [[ $(uname -m) = x86_64 ]] && EPREFIX=$HOME/gentoo
[[ -d $HOME/gentoo32 ]] && [[ $(uname -m) = i686 ]] && EPREFIX=$HOME/gentoo32
[[ $TERM != dumb ]] && export PS1="\[\033[01;36m\][\[\033[01;33m\]\u@\h\[\033[01;36m\]]-[\[\033[01;33m\]\$?\[\033[01;36m\]]-[\[\033[01;33m\]\w\[\033[01;36m\]]>\[\033[00m\] "
export EMACS_SERVER_FILE=$HOME/.emacs.d/tmp/server/server
export HISTSIZE=10000000
export HISTCONTROL=ignoredups
[[ $- = *i* ]] && stty stop undef
[[ -z $NOFISH ]] && export NOFISH=0
export QT_XFT="true"
export GDK_USE_XFT=1
export VDPAU_DRIVER="va_gl"
if [[ -f $EPREFIX/etc/os-release ]]; then
    source $EPREFIX/etc/os-release
    export DISTRIB_ID="${ID}"
fi

# programming languages specific PATH
export GHQ_ROOT=$HOME/src
export FZF_DEFAULT_OPTS="--height 30% --layout reverse --border --color 16"
export FILTER="fzf $FZF_DEFAULT_OPTS"

# Golang
export GOPATH=$HOME/.go
add_path $GOPATH/bin

# Ruby
if command -v ruby >/dev/null; then
    add_path $(ruby -e 'puts Gem.user_dir')/bin
fi

# Python
export PYENV_ROOT=$HOME/.pyenv
add_path $PYENV_ROOT/bin
if command -v pyenv >/dev/null; then
    eval "$(pyenv init -)"
    add_path $HOME/.poetry/bin
fi

# my scripts and own tools
add_path $HOME/bin
add_path $HOME/.local/bin
add_path $HOME/local/bin

# for experiments
add_path $HOME/src/github.com/de9uch1/mlenv/bin
add_path $HOME/src/github.com/de9uch1/MiniBatch/bin
add_path $HOME/src/github.com/de9uch1/Xplorer/bin

# load $HOME/.bashrc
if [[ -f $HOME/.bashrc ]] ; then
    source $HOME/.bashrc
fi
