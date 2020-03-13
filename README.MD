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

## Tasks

Here are some basic tasks this project can perform.

### List Available Apps

To list apps which already have been packaged: `make list`

### Existing Apps
To install an already packaged application run: `make install <appname>`.

This will also work for any packages which you have done a walkthrough or auto installation of via this script (we create a generic package and store it in .packages/vendor/<<appname>> for future installs)

### New Apps
To be prompted for more information on a new app you wish to install run: `make new`

Generically, you need 3 bits of information for installing an app from github when using this script:

- App: The target binary app which will be installed
- Vendor: The github vendor name
- Repo: The github repository which contains the source application

The vendor/repo combo are in the github url for a project (ie. https://github.com/`<vendor>`/`<repo>`). The app name is differentiated as there are instances where the repo name and app name simply are not the same (example: there are multiple applications sourced from a single repo).

> **NOTE**: At the first step, if you enter in an app that already exists in the '.packages/vendors' folder it will simply be installed again at that point.

If the vendor/repo has releases which are able to be downloaded the latest version will be displayed for selection. Once chosen you will then be prompted for an installation type. Generally this lines up with the file format being downloaded so pay attention to the download URL you have chosen in the prior step!

### Auto Apps

This is the same as the new app (`make new`) walkthrough but without the prompting nonsense. This generates the same packages bundle as the walkthrough. You just need to provide the vendor/repo and app (or, if the repo and app name are the same just the vendor/repo)

```bash
make auto zloeber/githubinfo
```

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

## Tips

A few tips on how to use this to make your life a little easier:

### Setup an Alias
If you are not wanting to have to dive into this project everytime you want to install some app, one can setup an alias quite easily. In this case we assume you have cloned this repo into `${HOME}/.local/app/ghr-installer`

```bash
alias githubapp="make --no-print-directory -C ${HOME}/.local/app/ghr-installer"
```

Once this has been sourced into your shell you can then run githubapp from anywhere.

```bash
githubapp install k3d
githubapp urls kubernetes/minikube
githubapp new
githubapp auto mumoshu/variant
```

### Package Cache

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
