#!/bin/sh

set -eu

repo_url=ssh://git@github.com/de9uch1/dotfiles.git
dotfiles=$HOME/.dotfiles

if [ "$#" -gt 0 ]; then
    git clone -- "$repo_url" "$1"
    checkout=$(CDPATH= cd -- "$1" && pwd -P)
    ln -s "$checkout" "$dotfiles"
fi

mise_bin=$HOME/.local/bin/mise
if command -v mise >/dev/null 2>&1; then
    mise_bin=$(command -v mise)
elif [ ! -x "$mise_bin" ]; then
    if [ "$(uname -s)" = "Linux" ]; then
        export MISE_INSTALL_MUSL=1
    fi
    curl -fsSL https://mise.run | sh
fi

exec "$mise_bin" -C "$HOME" bootstrap --from "$repo_url" \
    --from-dir "$dotfiles" --config-dir .config/mise
