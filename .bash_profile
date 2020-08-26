#!/bin/bash
# -*- mode:shell-script; sh-indentation:4; coding:utf-8 -*-

# enviroment variables
# [[ $TERM != dumb ]] && export PS1="\[\033[01;36m\][\[\033[01;33m\]\u@\h\[\033[01;36m\]]-[\[\033[01;33m\]\$?\[\033[01;36m\]]-[\[\033[01;33m\]\w\[\033[01;36m\]]>\[\033[00m\] "
export HISTSIZE=10000000
export HISTCONTROL=ignoredups
[[ $- = *i* ]] && stty stop undef

[[ -f $HOME/.config/profile ]] && source $HOME/.config/profile

# load $HOME/.bashrc
if [[ -f $HOME/.bashrc ]] ; then
    source $HOME/.bashrc
fi
