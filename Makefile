SHELL	= /bin/sh
LANG	= C

XDG_CONFIG := .config
CANDIDATES	:= $(wildcard .??* $(XDG_CONFIG)/* bin/* $(XDG_CONFIG)/systemd/user/* $(XDG_CONFIG)/pueue/*)
EXCLUDE := .git .gitignore $(XDG_CONFIG) $(XDG_CONFIG)/systemd $(XDG_CONFIG)/pueue
DOTFILES := $(filter-out $(EXCLUDE), $(CANDIDATES))

ifdef WSLENV
	WINHOME := $(shell wslpath `/mnt/c/WINDOWS/system32/cmd.exe /c echo %USERPROFILE% 2>/dev/null`)
endif
ifeq ($(shell uname),Linux)
	IS_LINUX := 1
endif

all:

list:
	@$(foreach f,$(DOTFILES),/bin/ls -d $(f);)

build:
ifdef IS_LINUX
	@cd src/mid && cargo build --release --target=x86_64-unknown-linux-musl
else
	@cd src/mid && cargo build --release
endif

link:
	@echo "These dotfiles are linked."
	@mkdir -p $(HOME)/bin
	@mkdir -p $(HOME)/$(XDG_CONFIG)
	@mkdir -p $(HOME)/$(XDG_CONFIG)/systemd/user
	@mkdir -p $(HOME)/$(XDG_CONFIG)/pueue
	@rm -rf $(HOME)/.vim
	@rm -rf $(HOME)/$(XDG_CONFIG)/fish
	@rm -rf $(HOME)/$(XDG_CONFIG)/powerline
	@rm -rf $(HOME)/$(XDG_CONFIG)/ptpython
	@rm -rf $(HOME)/$(XDG_CONFIG)/wezterm
	@$(foreach f,$(DOTFILES), ln -sfnv $(abspath $(f)) $(HOME)/$(f);)
ifdef IS_LINUX
	@ln -sfnv $(abspath src/mid/target/x86_64-unknown-linux-musl/release/mid) $(HOME)/bin/mid
else
	@ln -sfnv $(abspath src/mid/target/release/mid) $(HOME)/bin/mid
endif
ifdef WSLENV
	cp -L $(HOME)/$(XDG_CONFIG)/wezterm/wezterm.lua $(WINHOME)/.wezterm.lua
endif

pyenv:
	@$(HOME)/bin/install-pyenv

tools:
	@$(HOME)/bin/install-tools

clean:
	$(foreach f,$(DOTFILES),/bin/rm -f $(HOME)/$(f);)
