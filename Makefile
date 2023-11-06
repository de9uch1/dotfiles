SHELL	= /bin/sh
LANG	= C

XDG_CONFIG := .config
CANDIDATES	:= $(wildcard .??* $(XDG_CONFIG)/* bin/* $(XDG_CONFIG)/systemd/user/* $(XDG_CONFIG)/pueue/*)
EXCLUDE := .git .gitignore $(XDG_CONFIG) $(XDG_CONFIG)/systemd $(XDG_CONFIG)/pueue
DOTFILES := $(filter-out $(EXCLUDE), $(CANDIDATES))

ifdef WSLENV
	WINHOME := $(shell wslpath `/mnt/c/WINDOWS/system32/cmd.exe /c echo %USERPROFILE% 2>/dev/null`)
endif

all:

list:
	@$(foreach f,$(DOTFILES),/bin/ls -d $(f);)

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
ifdef WSLENV
	cp -L $(HOME)/$(XDG_CONFIG)/wezterm/wezterm.lua $(WINHOME)/.wezterm.lua
endif

pyenv:
	@$(HOME)/bin/install-pyenv

tools:
	@$(HOME)/bin/install-tools

clean:
	$(foreach f,$(DOTFILES),/bin/rm -f $(HOME)/$(f);)
