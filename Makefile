NAME=ninja-build
VERSION=1.7.2
EPOCH=1
ITERATION=1
PREFIX=/usr/local
LICENSE=Apache-2.0
VENDOR="Ninja Build Team"
MAINTAINER="Ryan Parman"
DESCRIPTION="Ninja is a small build system with a focus on speed."
URL=https://ninja-build.org
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)

#-------------------------------------------------------------------------------

all: info clean install-deps compile install-tmp package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "EPOCH:       $(EPOCH)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* ninja*

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:

	yum -y install \
		clang \
		clang-analyzer \
		gcc-c++ \
		git \
		python-devel \
	;

#-------------------------------------------------------------------------------

.PHONY: compile
compile:
	git clone -q -b v$(VERSION) https://github.com/ninja-build/ninja.git
	cd ninja && \
		./configure.py --bootstrap --verbose --platform=linux --host=linux
	;

#-------------------------------------------------------------------------------

.PHONY: install-tmp
install-tmp:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);
	cd ninja && \
		cp ./ninja /tmp/installdir-$(NAME)-$(VERSION)/bin/ninja;

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-f \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--epoch $(EPOCH) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG.txt \
		--rpm-dist el$(RHEL) \
		--rpm-auto-add-directories \
		usr/local/bin \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/
