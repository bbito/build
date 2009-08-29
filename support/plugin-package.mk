# Makefile for PreWare plugin packaging
#
# Copyright (C) 2009 by Rod Whitby <rod@whitby.id.au>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

.PHONY: package clobber

ifndef NAME
PREWARE_SANITY += $(error "Please define NAME in your Makefile")
endif

package: ipkgs/${APP_ID}_${VERSION}_armv7.ipk ipkgs/${APP_ID}_${VERSION}_i686.ipk

ipkgs/${APP_ID}_${VERSION}_%.ipk: build/.built
	rm -f ipkgs/${APP_ID}_*_$*.ipk
	rm -f build/$*/CONTROL/control
	${MAKE} build/$*/CONTROL/control
	rm -f build/$*/CONTROL/postinst
	${MAKE} build/$*/CONTROL/postinst
	rm -f build/$*/CONTROL/prerm
	${MAKE} build/$*/CONTROL/prerm
	mkdir -p ipkgs
	( cd build ; \
	  TAR_OPTIONS=--wildcards \
	  ../../../toolchain/ipkg-utils/ipkg-build -o 0 -g 0 $* )
	mv build/${APP_ID}_${VERSION}_$*.ipk $@

build/%/CONTROL/postinst:
	true

build/%/CONTROL/prerm:
	true

build/%/CONTROL/control:
	rm -f $@
	mkdir -p build/$*/CONTROL
	echo "Package: ${APP_ID}" > $@
ifdef VERSION
	echo -n "Version: " >> $@
	echo "${VERSION}" >> $@
endif
	echo "Architecture: $*" >> $@
ifdef MAINTAINER
	echo -n "Maintainer: " >> $@
	echo "${MAINTAINER}" >> $@
endif
ifdef DESCRIPTION
	echo -n "Description: " >> $@
	echo "${DESCRIPTION}" >> $@
endif
ifdef SECTION
	echo -n "Section: " >> $@
	echo "${SECTION}" >> $@
endif
ifdef PRIORITY
	echo "${PRIORITY}" >> $@
else
	echo "Priority: optional" >> $@
endif
ifdef DEPENDS
	echo "Depends: ${DEPENDS}" >> $@
endif
ifdef CONFLICTS
	echo "Conficts: ${CONFLICTS}" >> $@
endif
	echo -n "Source: " >> $@
ifdef SRC_IPKG
	echo -n "{ \"Source\":\"${SRC_IPKG}\"">> $@
endif
ifdef SRC_TGZ
	echo -n "{ \"Source\":\"${SRC_TGZ}\"" >> $@
endif
ifdef SRC_ZIP
	echo -n "{ \"Source\":\"${SRC_ZIP}\"" >> $@
endif
ifdef SRC_GIT
	echo -n "{ \"Source\":\"${SRC_GIT}\"" >> $@
endif
	echo -n ", \"Last-Updated\":\""`date +%s`"\", \"LastUpdated\":\""`date +%s`"\", \"Feed\":\"WebOS Internals\"" >> $@
ifdef TYPE
	echo -n ", \"Type\":\"${TYPE}\"" >> $@
else
	echo -n ", \"Type\":\"Plugin\"" >> $@
endif
	echo ", \"Category\":\"${SECTION}\" }" >> $@
	touch $@

clobber::
	$(call PREWARE_SANITY)
	rm -rf ipkgs

