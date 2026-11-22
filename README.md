# Install

```sh
curl -sL dot.de9uch1.jp | sh
```

## Optional CLI tools with mise

On Linux (including WSL), install the static musl build of mise.

```sh
curl -fsSL https://mise.run | MISE_INSTALL_MUSL=1 sh
```

On macOS, use the [standard installer](https://mise.jdx.dev/installing-mise.html).

```sh
curl -fsSL https://mise.run | sh
```

Run `make link` from this checkout, then install the configured tools. The
linked `~/.config/mise` directory provides the global `config.toml`.

```sh
"$HOME/.local/bin/mise" install
```

Run `mise upgrade` to update these tools. The global list applies across
directories. Projects can select their own versions.

Bash and Fish add mise's shims to `PATH`. The default directory is
`~/.local/share/mise/shims`. The shell configurations also respect
`XDG_DATA_HOME` and `MISE_DATA_DIR`.
