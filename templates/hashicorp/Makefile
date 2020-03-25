## Package - {{ .Env.APP }}
include ../../tasks/Makefile.package
include ../../tasks/Makefile.apk

OS_UPPER=$(shell uname -s)

export VENDOR ?= hashicorp
export PACKAGE_NAME ?= {{ .Env.APP }}
export DOWNLOAD_URL ?= https://releases.hashicorp.com/$(PACKAGE_NAME)/$(PACKAGE_VERSION)/$(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(OS)_$(OS_ARCH).zip
export APK_BUILD_TEMPLATE ?= APKBUILD.github-binary

install:
	$(CURL) -o - $(DOWNLOAD_URL) > $(INSTALL_PATH)/$(PACKAGE_NAME).zip
	unzip -p $(INSTALL_PATH)/$(PACKAGE_NAME).zip $(PACKAGE_NAME) > $(INSTALL_PATH)/$(PACKAGE_NAME)
	rm $(INSTALL_PATH)/$(PACKAGE_NAME).zip
	chmod +x $(INSTALL_PATH)/$(PACKAGE_NAME)

test:
	$(PACKAGE_EXE) version
