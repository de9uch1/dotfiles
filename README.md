# Install

- Bootstrap dotfiles

```sh
curl -fsSL https://raw.githubusercontent.com/de9uch1/dotfiles/refs/heads/main/bootstrap.sh | sh
```

- Install tools

```sh
mise run --skip-tools init
mise run --skip-tools build
mise run --skip-tools tools
```
