# Install

- Bootstrap dotfiles

```sh
curl -fsSL https://raw.githubusercontent.com/de9uch1/dotfiles/refs/heads/main/bootstrap.sh | sh
```

- Install tools

```sh
mise run init-rust ::: init-uv
mise run build
mise run tools
```
