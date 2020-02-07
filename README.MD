# GHR Installer

Github Releases Installer

## Description

This is a wrapper for cloudposse/packages which makes authoring new packages for it a bit easier. As an additional benefit, this project allows for arbitrary github releases to be installed a bit more quickly on a system.

## Features

- Adds whiptail based console GUI helper functions for adding new vendor package templates to cloudposse/packages
- Serves as a generic installer for your local non-root user based binary installs of github releases

## Usage

This is a simple makefile with some trivial amounts of bash scripting. Simply run `make` to see all available tasks.

Any installed application will be dropped into `INSTALL_PATH` which we set to `${HOME}/.local/bin` by default. This aligns with where pip tends to install apps if run with the --user flag and is my personal preference. One can easily change this by exporting `INSTALL_PATH` beforehand or including `INSTALL_PATH` as a task parameter;

If you are using this to install an already packaged up application and you know that application name simply run `make install/<appname>` otherwise run `make install` to be prompted for more information on the app you wish to install.

Generically, you need 3 bits of information for installing an app from github when using this script:

- App: The target binary app which will be installed
- Vendor: The github vendor name
- Repo: The github repository which contains the source application

The vendor/repo combo are in the github url for a project (ie. https://github.com/`<vendor>`/`<repo>`). 

## Examples

```bash
# Show help
make

# Install k3d binary to default location of ${HOME}/.local/bin
make install k3d

# Install jx to ${HOME}/.local/jx then remove it
export INSTALL_PATH=${HOME}/.local/jx
make install jx
make remove jx

# Walkthrough the installation of a new package from github 
# (unless the app name already exists in packages, then it will simply be installed)
make helper

# Walthrough the addition of a new package to packages (including hashicorp sourced apps)
make new

# List all the most recent release download URLs for a github project
make list jenkins-x/jx

# Show all packages already available in cloudeposse/packages
make packages
```
## Tips

If you are not wanting to have to dive into this project everytime you want to run some app one can setup an alias quite easily.

```bash
alias githubapp="make -C ${HOME}/.local/app/ghr-installer"
```

Using the above alias assumes this project has been clone to ${HOME}/.local/app/ghr-installer. Once this has been sourced into your shell you can then run githubapp from anywhere to install or try to install applications from github.

```bash
githubapp install k3d
githubapp list kubernetes/minikube
githubapp packages
```

This wrapper will automatically add a generic .packages/vendor/app folder for a future installation of your package. This can be removed to start the helper wizard again or better yet, you can review it and submit a PR to the upstream cloudposse/packages repo with it instead!

## Limitations

Simple package installations should work mostly ok. Anything more complex should be authored into a proper cloudposse/packages package and a PR should be submit to add to the upstream project.

## Credits

<cloudposse/packages>[https://github.com/cloudposse/packages]