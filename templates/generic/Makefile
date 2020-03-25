## Package - {{ .Env.PACKAGE_EXE }}
include ../../tasks/Makefile.package
include ../../tasks/Makefile.apk

OS_UPPER=$(shell uname -s)

export VENDOR = {{ .Env.VENDOR }}
export PACKAGE_NAME = {{ .Env.PACKAGE_EXE }}
export PACKAGE_REPO_NAME = {{ .Env.REPO }}
export DOWNLOAD_URL ?= {{ .Env.URL }}
export APK_BUILD_TEMPLATE ?= APKBUILD.github-binary

## Uncomment only if you need additional libraries
#export APKBUILD_DEPENDS += libc6-compat musl

install:
	$(call download_{{ .Env.PACKAGE_TYPE }})

test:
	$(PACKAGE_EXE) --version

## This may be required for apk building and varies from package to package
# Custom post-package processing (Note the double colon to append to current inherited package/prepare task)
#package/prepare::
#	mv src/{{ .Env.PACKAGE_EXE }}-$(OS).$(ARCH)/{{ .Env.PACKAGE_EXE }} src
