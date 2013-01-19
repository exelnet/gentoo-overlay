# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils git

DESCRIPTION="Cut Rubies with ease!"
HOMEPAGE="http://beginrescueend.com/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/wayneeseguin/rvm.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup "${PN}"
	for user in $(grep -xF -f <(cat /etc/passwd | cut -d: -f1) <(find /home -mindepth 1 -maxdepth 1 -type d | cut -d '/' -f 3)); do
		usermod -a -G "${PN}" "$user"
	done
	rm -f "/etc/rvmrc"
}

src_install() {
	addpredict "/etc/rvmrc"
	addwrite "/etc/profile.d/rvm.sh"
	$WORKDIR/$P/scripts/install --prefix "${D}/usr/local/" || die
	insinto /etc/
	doins "${FILESDIR}"/rvmrc
}

