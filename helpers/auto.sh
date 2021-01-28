#!/bin/bash
# Attempt to guess settings for a package binary install.
# Author: Zachary Loeber

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
    local vendorapp="${1?"Usage: get_github_urls_by_platform vendor/app"}"
    OS="${OS:-"linux"}"
    ARCH="${ARCH:-"amd64"}"
    curl -s "https://api.github.com/repos/${vendorapp}/releases/latest" | \
     ${INSTALL_PATH}/jq -r --arg OS ${OS} --arg ARCH ${ARCH} \
     '.assets[] | .browser_download_url'
}

function get_github_project_description {
    # Description: Scrape github project for its description
    local vendorapp="${1?"Usage: $0 vendor/app"}"
    curl -s "https://api.github.com/repos/${vendorapp}" | ${INSTALL_PATH}/jq -r '.description'
}

function get_github_project_license {
    # Description: Scrape github project for its license
    local vendorapp="${1?"Usage: $0 vendor/app"}"
    curl -s "https://api.github.com/repos/${vendorapp}" | ${INSTALL_PATH}/jq -r '.license.spdx_id'
}

function get_github_version_by_tag {
    # Attempt to get the latest version of a release by release tag
    local vendorapp="${1?"Usage: $0 vendor/app"}"
    curl -s "https://api.github.com/repos/${vendorapp}/releases/latest" | \
        grep -oP '"tag_name": "\K(.*)(?=")' | \
        grep -o '[[:digit:]].[[:digit:]].[[:digit:]]'
}

ROOT_PATH=${ROOT_PATH:-$(pwd)}
INSTALL_PATH=${INSTALL_PATH:-"${HOME}/.local/bin"}
VENDOR_REPO=${1:-""}
PACKAGE_EXE=${PACKAGE_EXE:-${VENDOR_REPO##*/}}
PACKAGES_PATH="${PACKAGES_PATH:-"${ROOT_PATH}/.packages"}"
OS="${OS:-"linux"}"
ARCH="${ARCH:-"amd64"}"
VENDORPATH=${PACKAGES_PATH}/vendor
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -o allexport
source "${SCRIPT_PATH}/ignored.env"
set +o allexport

#IGNORED_EXT='(.tar.gz.asc|.txt|.tar.xz|.asc|.MD|.hsm|\+ent.hsm|.rpm|.deb|.sha256|.src.tar.gz|.sig|SHA256SUM|.log)'
# if_os () { [[ $OSTYPE == *$1* ]]; }
# if_arch () { [[ `uname -m` == *$1* ]]; }

# if_os darwin && os_filter=(darwin|Darwin)
# if_os linux && os_filter=(linux|Linux)
# if_arch x86_64 && arch_filter=(amd64|Amd64|AMD64|x86-64|x86_64|x64)
# if_arch 386 && arch_filter=(386|i386|i686)
# if_arch arm && arch_filter=(arm64|arm)

if [ -d "${VENDORPATH}/${PACKAGE_EXE}" ]; then
    echo  "${VENDORPATH}/${PACKAGE_EXE} already exists, installing.."
    make --no-print-directory -C ${ROOT_PATH} install ${PACKAGE_EXE}
    exit 0
else
    echo  "${VENDORPATH}/${PACKAGE_EXE} is new, continuing.."
fi

#latesturl=(`get_github_urls_by_platform "${VENDOR_REPO}" | grep -v -E "${IGNORED_EXT}" | grep ${PACKAGE_EXE}`)
latesturl=(`get_github_urls_by_platform "${VENDOR_REPO}" | grep -v -E "${IGNORED_EXT}" | grep -E "(${PACKAGE_EXE}|${VENDOR_REPO})"`)
applist=()
cnt=${#latesturl[@]}
for ((i=0;i<cnt;i++)); do
    applist+=("${latesturl[i]}")
    applist+=("")
done

export URL=${applist[0]}
if [ $? -ne 0 ] || [ -z $URL ]; then
    echo "Download url not acquired."
    exit 1
fi

## Try to extract the latest version
# First look for x.x.x
VERSION=`echo "${latesturl}" | grep -o -E '[0-9]+.[0-9]+.[0-9]+' | head -1`
# Then look for x.x
if [ -z $VERSION ]; then
    VERSION=`echo "${latesturl}" | grep -o -E '[0-9]+.[0-9]+' | head -1`
fi

case ${URL##*/} in
    *.tar.gz) packageType=tarball
        ;;
    *.zip) packageType=zip
        ;;
    *.gz) packageType=binary_gz
        ;;
    *.tar.bz2) packageType=tar_bz2
        ;;
    *.tar.xz) packageType=tar_xz
        ;;
    *.tar) packageType=tarball
        ;;
    *) packageType=binary
        ;;
esac;

export PACKAGE_TYPE=${packageType}
export PACKAGE_NAME=${PACKAGE_EXE}
# make --no-print-directory -f ${ROOT_PATH}/helpers/Makefile.package install

## Attempt to tokenize the DOWNLOAD_URL next
# Construct a generic url to use based on selections
PACKAGE_REPO_URL="https://github.com/${VENDOR_REPO}"
URL=${URL//${PACKAGE_REPO_URL}/\$(PACKAGE_REPO_URL)}
URL=${URL//${VERSION}/\$(PACKAGE_VERSION)}
URL=${URL//${PACKAGE_EXE}/\$(PACKAGE_NAME)}

## Some 'fuzzy' logic on how they may have named their releases...
URL=`echo $URL | sed -E 's/(Linux|Darwin|Windows|macOS)/$(OS_UPPER)/g' | \
    sed -E 's/(linux-gnu|linux|darwin|windows)/$(OS)/g' | \
    sed -E 's/(x86-64|x86_64)/$(OS_ARCH)/g' | \
    sed -E 's/(amd64|Amd64|AMD64|386|i386|x86_64)/$(ARCH)/g'`

DESC=`get_github_project_description ${VENDOR_REPO}`
LICENSE=`get_github_project_license ${VENDOR_REPO}`
REPO=${VENDOR_REPO##*/}
VENDOR=`dirname $VENDOR_REPO`

export VENDOR PACKAGE_EXE VERSION URL REPO PACKAGE_TYPE DESC LICENSE
echo "Template path for new application: ${VENDORPATH}/${PACKAGE_EXE}"
mkdir -p ${VENDORPATH}/${PACKAGE_EXE}

${INSTALL_PATH}/gomplate \
    --input-dir ${ROOT_PATH}/templates/generic \
    --output-dir ${VENDORPATH}/${PACKAGE_EXE}

if [ -d ${VENDORPATH}/${PACKAGE_EXE} ]; then
  echo "Package Path: ${VENDORPATH}/${PACKAGE_EXE}"
  echo "VENDOR: ${VENDOR}"
  echo "REPO: ${REPO}"
  echo "DESC: ${DESC}"
  echo "LICENSE: ${LICENSE}"
  echo "PACKAGE_EXE: ${PACKAGE_EXE}"
  echo "VERSION: ${VERSION}"
  echo "URL: ${URL}"
  echo "PACKAGE_TYPE: ${PACKAGE_TYPE}"
  echo ""
  echo "This package has been saved for future installation."
  echo "Please consider submitting this package to cloudposse/packages via a PR as well."
fi

make --no-print-directory -C ${ROOT_PATH} install ${PACKAGE_EXE}
