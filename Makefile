SHELL:=/bin/bash
ROOT_PATH:=$(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
.DEFAULT_GOAL:=help
export PACKAGES_PATH ?= $(ROOT_PATH)/.packages
export INSTALL_PATH ?= $(HOME)/.local/bin
export VENDOR_PATH ?= $(PACKAGES_PATH)/vendor

## Output related vars
ifdef TERM
BOLD := $(shell tput bold)
RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
RESET := $(shell tput sgr0)
endif

help: ## This help
	@grep --no-filename -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deinit: ## Remove pacakge app dir (but not INSTALL_PATH)
	rm -rf $(PACKAGES_PATH)

init: ## Initialize package app dir
	@mkdir -p $(INSTALL_PATH)
ifeq (,$(wildcard $(PACKAGES_PATH)))
	@echo "Installing packages to $(PACKAGES_PATH)"
	@git clone --depth=1 https://github.com/cloudposse/packages.git $(PACKAGES_PATH)
endif

update: ## Update packages definitions
	@echo "Updating packages..."
	@cd $(PACKAGES_PATH) && git pull

deps: ## Install some dependencies
ifeq (,$(wildcard $(PACKAGES_PATH)))
	@make --no-print-directory init
endif
ifeq (,$(wildcard $(INSTALL_PATH)/gomplate))
	@make --no-print-directory install gomplate
endif
ifeq (,$(wildcard $(INSTALL_PATH)/jq))
	@make --no-print-directory install jq
endif

install: init ## Install a package
	@echo "$(BOLD)APP$(RESET): $(filter-out $@,$(MAKECMDGOALS))"
	@if [ -d $(VENDOR_PATH)/$(filter-out $@,$(MAKECMDGOALS)) ]; then \
	  make --no-print-directory -C $(VENDOR_PATH)/$(filter-out $@,$(MAKECMDGOALS)) install; \
	else \
	  echo "$(filter-out $@,$(MAKECMDGOALS)) not available"; \
	  exit 1; \
	fi

uninstall: ## Remove installed package
	@if [ "$(INSTALL_PATH)/$(filter-out $@,$(MAKECMDGOALS))" != "$(INSTALL_PATH)/" ]; then \
	  rm -f $(INSTALL_PATH)/$(filter-out $@,$(MAKECMDGOALS)); \
	  echo "Deleted: $(INSTALL_PATH)/$(filter-out $@,$(MAKECMDGOALS))"; \
	else \
	  echo "$(BOLD)No app name provided!$(RESET)"; \
	fi

reset: ## Reset a package definition.
	@if [ "$(VENDOR_PATH)/$(filter-out $@,$(MAKECMDGOALS))" != "$(VENDOR_PATH)/" ]; then \
          rm -rf $(VENDOR_PATH)/$(filter-out $@,$(MAKECMDGOALS)); \
          echo "Deleted $(VENDOR_PATH)/$(filter-out $@,$(MAKECMDGOALS))"; \
        fi

new: deps ## Add a new package
	@helpers/new.sh

auto: deps ## Add a new package
	@helpers/auto.sh $(filter-out $@,$(MAKECMDGOALS))

walkthrough: deps ## Walkthrough a package install
	@helpers/walkthrough.sh

show: ## Shows some settings
	@echo "$(BOLD)ROOT_PATH$(RESET): $(ROOT_PATH)"
	@echo "$(BOLD)INSTALL_PATH$(RESET): $(INSTALL_PATH)"
	@echo "$(BOLD)PACKAGES_PATH$(RESET): $(PACKAGES_PATH)"

urls: ## Show a list of URLs for vendor/package
	@helpers/get-releases.sh $(filter-out $@,$(MAKECMDGOALS))

list: init ## List available packages
	@make --no-print-directory -C $(VENDOR_PATH) help

%: ## A parameter
	@true
