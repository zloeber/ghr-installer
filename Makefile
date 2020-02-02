SHELL:=/bin/bash
ROOT_PATH:=$(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
.DEFAULT_GOAL:=help

export PACKAGES_VERSION ?= master
export PACKAGES_PATH ?= $(ROOT_PATH)/.packages
export INSTALL_PATH ?= $(HOME)/.local/bin
export VENDOR_PATH ?= $(PACKAGES_PATH)/vendor

## Output related vars
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

help: ## This help
	@grep --no-filename -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

reset: ## Remove pacakge app dir (but not INSTALL_PATH)
	rm -rf $(PACKAGES_PATH)

init: ## Initialize package app dir
	@if [ ! -d $(PACKAGES_PATH) ]; then \
	  echo "Installing packages $(PACKAGES_VERSION)..."; \
	  rm -rf $(PACKAGES_PATH); \
 	  git clone --depth=1 -b $(PACKAGES_VERSION) https://github.com/cloudposse/packages.git $(PACKAGES_PATH); \
 	  rm -rf $(PACKAGES_PATH)/.git; \
 	fi
	@mkdir -p $(INSTALL_PATH)

deps: install/gomplate ## Install some dependencies

install/%: init ## Install a package
	@echo "$(BOLD)APP$(RESET): $(subst install/,,$@)"
	@if [ -d $(VENDOR_PATH)/$(subst install/,,$@) ]; then \
	  make -C $(VENDOR_PATH)/$(subst install/,,$@) install; \
	else \
	  echo "$(subst install/,,$@) not available"; \
	  exit 1; \
	fi

remove/%: ## Remove a package
	@if [ -f $(INSTALL_PATH)/$(subst remove/,,$@) ]; then \
	  rm -f $(INSTALL_PATH)/$(subst remove/,,$@); \
	  echo "Deleted $(subst remove/,,$@)"; \
	else \
	  echo "$(subst remove/,,$@) not installed"; \
	fi

new: deps ## Add a new package
	helpers/new-package.sh

install: ## Walkthrough a package install
	helpers/install-package.sh

show: ## Shows some settings
	@echo "$(BOLD)ROOT_PATH$(RESET): $(ROOT_PATH)"
	@echo "$(BOLD)INSTALL_PATH$(RESET): $(INSTALL_PATH)"
	@echo "$(BOLD)PACKAGES_PATH$(RESET): $(PACKAGES_PATH)"