# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils subversion

DESCRIPTION="A mail storage and retrieval daemon that uses MySQL or PostgreSQL as its data store"
HOMEPAGE="http://www.dbmail.org/"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

ESVN_REPO_URI="svn://svn.chan-capi.org/chan-capi/trunk"
ESVN_REVISION=""

RDEPEND="net-misc/asterisk"
DEPEND="${RDEPEND}"

