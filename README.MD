# GHR-Installer (githubapp)

Github Releases Installer

## Description

This project allows for arbitrary github releases to be installed a bit more quickly on a system. As such, it can serve as a generic installer for your local non-root user based binary installs of github releases.

## Features

- Generate repeatable build scripts for your own pipeline scripts (installing an app spits output to the screen with all commands run to download/install the app)
- Auto-detect and install latest versions of single binary releases from github releases.
- Whiptail based console GUI helper functions for adding new vendor package templates to cloudposse/packages

## How It Works

This started as a wrapper for cloudposse/packages to make authoring new packages for it a bit easier. Each package in this project is essentially a Makefile with some additional dressing that define how to install the app. This project automates the construction of those packages and runs them.

## Installation

Clone this repo into a folder of your choice. Run `make` to see the list of tasks. 

### Setup an Alias

If you are not wanting to have to dive into this project folder everytime you want to install some app, you can setup an alias quite easily. In this example we clone this repo into `${HOME}/.local/app/ghr-installer`

```bash
mkdir -p ${HOME}/.local/app
git clone git@github.com:zloeber/ghr-installer.git ${HOME}/.local/app/ghr-installer
alias githubapp="make --no-print-directory -C ${HOME}/.local/app/ghr-installer"
```

Once this has been sourced into your shell you can then run githubapp from anywhere.

```bash
githubapp install k3d
githubapp urls kubernetes/minikube
githubapp new
githubapp auto mumoshu/variant
```

## Usage

This is a simple makefile with some trivial amounts of bash scripting. Simply run `make` to see all available tasks. It is 

Any installed application will be dropped into `INSTALL_PATH` which we set to `${HOME}/.local/bin` by default. This aligns with where pip tends to install apps if run with the --user flag and is my personal preference. One can easily change this by exporting `INSTALL_PATH` beforehand or including `INSTALL_PATH` as a task parameter;

## Tasks

Here are some basic tasks this project can perform.

### List Available Apps

To list apps which already have been packaged: `make list`

### Existing Apps
To install an already packaged application run: `make install <appname>`.

This will also work for any packages which you have done a walkthrough or auto installation of via this script (we create a generic package and store it in .packages/vendor/<<appname>> for future installs)

### New Apps
To be prompted for more information on a new app you wish to install run: `make new`

You need 3 bits of information for installing an app from github:

- App: The target binary app which will be installed
- Vendor: The github vendor name
- Repo: The github repository which contains the source application

The vendor/repo combo are in the github url for a project (ie. https://github.com/`<vendor>`/`<repo>`). The app name is differentiated as there are instances where the repo name and app name simply are not the same (example: there are multiple applications sourced from a single repo).

> **NOTE**: At the first step, if you enter in an app that already exists in the '.packages/vendors' folder it will simply be installed again with the known package definition. You can reset the package with `make reset <app>` and the definition will be deleted from the cached packages.

If the vendor/repo has releases which are able to be downloaded the latest version will be displayed for selection. Once chosen you will then be prompted for an installation type. Generally this lines up with the file format being downloaded so pay attention to the download URL you have chosen in the prior step!

### Auto Apps

This is the same as the new app (`make new`) walkthrough but without the prompting nonsense. This generates the same packages bundle as the walkthrough. You just need to provide the vendor/repo and app (or, if the repo and app name are the same just the vendor/repo)

```bash
make auto zloeber/githubinfo

# If the extracted binary file differs from the repo name you can use PACKAGE_EXE
make auto zloeber/githubinfo PACKAGE_EXE=githubinfo
```

> **NOTE:** The backend script for this task really just finds one specific version of the release download then automatically generates a packages template that then gets used for the actual download of the binary. It is pretty effective but may also result in false positives based on the naming convention of the released package being installed.

### List Download URLs

Sometimes you just need to see the most recent download URL for a package (perhaps for some other pipeline task or script): `make list/urls vendor/app`

## Examples

```bash
# Show help
make

# Show all packages already available in cloudeposse/packages
make list

# Install k3d binary to default location of ${HOME}/.local/bin
make install k3d

# Install jx a non-default location (default = ${HOME}/.local/bin)
make install jx INSTALL_PATH=${HOME}/.jx/bin

# Then remove it
make uninstall jx

# Then remove its package definition as well
make reset jx

# Now recreate the package and reinstall it from the most recent version
make auto jenkins-x/jx

# List all the most recent release download URLs for a github project
make urls jenkins-x/jx

# Walkthrough the installation of a new package from github 
# (unless the app name already exists, then it will simply be installed)
make new

# Walthrough the addition of a new package to packages (including hashicorp sourced apps like vagrant or consul)
make walkthrough
```

## Package Cache

This wrapper will automatically add a generic .packages/vendor/app folder for a future installation of the package. This can be removed to start the helper wizard again. Optionally, you can back this up for your own future use.

Or, better yet, if the app works well and you'd like to help the community a little, you can review the generated package folder and submit a PR to the upstream cloudposse/packages repo instead! This requires a little more work but essentially involves:
1. Forking cloudposse/packages
2. Cloning your fork into another folder
3. Creating a new branch for your changes.
4. Copying your `.packages/vendor/<app>` folder into the new fork/branch
5. Testing and rectifying any possible apk build isssues
6. Updating documentation
7. Pushing your changes to your fork
8. Submitting a PR

See cloudposse/packages README.MD for more information on making a contribution.

## Limitations

Simple package installations should mostly work. Anything more complex should be authored into a proper cloudposse/packages package and a PR should be submit to add to the upstream project.

## Credits

<cloudposse/packages>[https://github.com/cloudposse/packages]
