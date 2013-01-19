# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dialup/fcpci/fcpci-0.1-r1.ebuild,v 1.1 2008/01/30 01:36:37 sbriesen Exp $

EAPI="4"

inherit eutils rpm linux-mod

DESCRIPTION="AVM kernel 2.6 modules for Fritz!Card PCI"
HOMEPAGE="http://blog.uid0.hu/2011/11/25/fritzcard-fcpci-driver-with-3-x-kernel/"
SRC_URI="http://trabant.uid0.hu/fritz_a1/fcpci-suse93-3.11-07.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="!net-dialup/fritzcapi"
RDEPEND="${DEPEND} net-dialup/capi4k-utils"

S="${WORKDIR}/fritz"

pkg_setup() {
	linux-mod_pkg_setup

	BUILD_TARGETS="all"
	BUILD_PARAMS="KDIR=${KV_DIR} LIBDIR=${S}/src"
	MODULE_NAMES="${PN}(net:${S}/src)"
}

src_unpack() {
	local BIT="" PAT="01234"
	if use amd64; then
		BIT="64bit-" PAT="1234"
	fi

	unpack ${A}
	cd "${S}"
	convert_to_m src/Makefile

	for i in lib/*-lib.o; do
		einfo "Localize symbols in ${i##*/} ..."
		objcopy -L memcmp -L memcpy -L memmove -L memset -L strcat \
			-L strcmp -L strcpy -L strlen -L strncmp -L strncpy "${i}"
	done
}

src_configure() {
    epatch "${FILESDIR}/fritz-3.0.8.diff.patch"
}

src_install() {
	linux-mod_src_install
	dodoc CAPI*.txt
	dohtml *.html
}
