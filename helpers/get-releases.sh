#!/bin/bash
# Attempt to list current github releases for a package
# Author: Zachary Loeber

IGNORED_EXT='(.tar.gz.asc|.txt|.tar.xz|.asc|.MD|.hsm|+ent.hsm|rpm|deb|sha256)'

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
