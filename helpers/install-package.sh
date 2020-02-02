#!/bin/bash
# Attempt to guess settings for a package binary install.
# Author: Zachary Loeber

eval `resize`
HEIGHT=15
WIDTH=80
INSTALL_PATH=${INSTALL_PATH:-"${HOME}/.local/bin"}
PACKAGES_PATH=".packages"
IGNORED_EXT='(.tar.gz.asc|.txt|.tar.xz|.asc|.MD|.hsm|+ent.hsm|rpm|deb|sha256)'
ROOT_PATH=${ROOT_PATH:-$(pwd)}
OS="${OS:-"linux"}"
ARCH="${ARCH:-"amd64"}"
VENDORPATH=${PACKAGES_PATH}/vendor

# Scrapes the Hashicorp release endpoint for valid versions
# Usage: get_hashicorp_version <app>
function get_hashicorp_version () {
	local vendorapp="${1?"Usage: $0 app"}"
	# Scrape HTML from release page for binary versions, which are 
	# given as ${binary}_<version>. We just use sed to extract.
	curl -s "https://releases.hashicorp.com/${vendorapp}/" | grep -v -E "${IGNORED_EXT}" | sed -n "s|.*${vendorapp}_\([0-9\.]*\).*|\1|p" | sed -n 2p
}

# Scrapes the Hashicorp release endpoint for valid apps
# Usage: get_hashicorp_apps <app>
function get_hashicorp_apps () {
	# Scrape HTML from release page for binary app names
    # There MUST be a better way to do this one... :)
    curl -s "https://releases.hashicorp.com/" | grep -o '<a .*href=\"/\(.*\)/">' | cut -d/ -f2 | grep -v -E "${HASHICORP_IGNORED}"
}

function get_github_urls_by_platform {
    # Description: Scrape github releases for most recent release of a project based on:
    # vendor, repo, os, and arch
    local vendorapp="${1?"Usage: $0 vendor/app"}"
    OS="${OS:-"linux"}"
    ARCH="${ARCH:-"amd64"}"
	curl -s "https://api.github.com/repos/${vendorapp}/releases/latest" | \
        jq -r --arg OS ${OS} --arg ARCH ${ARCH} \
        '.assets[] | .browser_download_url'
}

function get_github_version_by_tag {
    # Attempt to get the latest version of a release by release tag
    local vendorapp="${1?"Usage: $0 vendor/app"}"
    curl -s "https://api.github.com/repos/${vendorapp}/releases/latest" | \
        grep -oP '"tag_name": "\K(.*)(?=")' | \
        grep -o '[[:digit:]].[[:digit:]].[[:digit:]]'
}

export PACKAGE_EXE=$(whiptail --inputbox "App Name" 8 78 --title "Application Info" 3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    exit 0
fi

if [ -d "${VENDORPATH}/${PACKAGE_EXE}" ]; then
    echo  "${VENDORPATH}/${PACKAGE_EXE} already exists, installing.."
    make -C ${ROOT_PATH} install/${PACKAGE_EXE}
    exit 0
else
    echo  "${VENDORPATH}/${PACKAGE_EXE} is new, continuing.."
fi

export VENDOR=$(whiptail --inputbox "Github Vendor Name" 8 78 "" --title "Application Info" 3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    exit 0
fi

REPO=$(whiptail --inputbox "Github Repo Name" 8 78 "" --title "Application Info" 3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    exit 0
fi

latesturl=(`get_github_urls_by_platform "${VENDOR}/${REPO}" | grep -v -E "${IGNORED_EXT}"`)
applist=()
cnt=${#latesturl[@]}
for ((i=0;i<cnt;i++)); do
    applist+=("${latesturl[i]}")
    applist+=("")
done

export DOWNLOAD_URL=$(whiptail --title "App URLs" --menu "Choose URL" 16 120 10 "${applist[@]}" 3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    exit 0
fi

OPTIONS=(tarball ".tar.gz"
         binary "straight binary"
         zip ".zip"
         binary_gz ".gz"
         tar_bz2 "tar.bz2"
         tar_xz "tar.xz")

packageType=$(whiptail \
    --clear \
    --title "Install Type" \
    --menu "Install Type" \
    $LINES $COLUMNS $(( $LINES - 8 )) \
    "${OPTIONS[@]}" \
    3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    exit 0
fi

export PACKAGE_TYPE=${packageType}
export PACKAGE_NAME=${PACKAGE_EXE}
make -f ${ROOT_PATH}/helpers/Makefile.package install