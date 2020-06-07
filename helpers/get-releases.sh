#!/bin/bash
# Attempt to list current github releases for a package
# Author: Zachary Loeber

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -o allexport
source "${SCRIPT_PATH}/ignored.env"
set +o allexport


GH_RELEASE=${1:?"Usage: $0 vendor/repo"}

function get_github_urls_by_platform {
    # Description: Scrape github releases for most recent release of a project
    local vendorapp="${1?"Usage: $0 vendor/app"}"
    OS="${OS:-"linux"}"
    ARCH="${ARCH:-"amd64"}"
	curl -s "https://api.github.com/repos/${vendorapp}/releases/latest" | \
        jq -r '.assets[] | .browser_download_url'
}

get_github_urls_by_platform "${GH_RELEASE}" | grep -v -E "${IGNORED_EXT}"
