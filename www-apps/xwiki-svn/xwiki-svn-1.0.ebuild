# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# based on jetty ebuild

inherit subversion eutils java-pkg-2 java-ant-2

DESCRIPTION="XWiki is a second generation wiki (a.k.a an application wiki),ideally suited for developing collaborative web applications. svn 1.0 brunch"
HOMEPAGE="http://www.xwiki.org/"

ESVN_REPO_URI="svn://svn.forge.objectweb.org/svnroot/xwiki/xwiki/branches/XWIKI_1_0/"
ESVN_PROJECT="xwiki"

LICENSE="LGPL-2.1"
SLOT="${PV}"
KEYWORDS="~x86 ~amd64"
JAVA_PKG_IUSE="source"
IUSE="war exowar standalone tomcat"
# war - simple build war in /usr/share/xwiki-svn-1.0/lib/xwiki.war
# exowar - build exo portlet integration war in /usr/share/xwiki-svn-1.0/lib/xwiki-exo.war
# standalone - build standalone distribution (embedded hsqldb and jetty) and install it in
#  /usr/share/xwiki-svn-1.0/standalone . run by /etc/init.d/xwiki start
# tomcat - deploy to tomcat. simply symlink war file :)

#TODO IUSE="war standalone exo tomcat hsqldb mysql postgresql"
# hsqldb,mysql,postgresql - use selected database

#TODO http://slonopotamus.org/j2ee_on_gentoo integration

COMMON_DEP=""
# runtime scope dependencies
RDEPEND=">=virtual/jre-1.5
		tomcat? ( =www-servers/tomcat-6* )
		hsqldb? ( dev-db/hsqldb )
		pgsql? ( dev-java/jdbc-postgresql )
		mysql? ( dev-java/jdbc-mysql )
		${COMMON_DEP}"
# compile scope dependencies
DEPEND=">=virtual/jdk-1.5
		${COMMON_DEP}"

DESTDIR="/usr/share/${P}"
JETTY_HOME="${DESTDIR}/standalone"
XWIKI_NAME="xwiki"

pkg_setup() {
	if use standalone; then
		enewgroup ${XWIKI_NAME}
		enewuser ${XWIKI_NAME} -1 /bin/sh ${JETTY_HOME} xwiki
	fi
}

src_unpack() {
	subversion_src_unpack
}

src_compile() {
	local deftarget="release"
	use exowar && (eant exorelease || die)
	use standalone && deftarget="standalone"
	eant $deftarget
}

src_install() {
	java-pkg_newjar release/xwiki.jar xwiki.jar
	(use war || use tomcat) && java-pkg_newjar release/xwiki-${PV}-*.war xwiki.war
	use exowar && java-pkg_newjar release/xwiki-exo-${PV}-*.war xwiki-exo.war
	use standalone && install_standalone
	use source && java-pkg_dosrc core/src/main/java
	if use tomcat; then
		dosym ${DESTDIR}/lib/xwiki.war /var/lib/tomcat-6/webapps/xwiki.war
	fi
}

install_standalone() {
	OPTS_1="-m 750 -o ${XWIKI_NAME} -g ${XWIKI_NAME}"
	einfo "Installing standalone files"

	newconfd ${FILESDIR}/${PV}/${PN}.conf ${XWIKI_NAME}
	newinitd ${FILESDIR}/${PV}/${PN}.init ${XWIKI_NAME}
	
	diropts ${OPTS_1}
	dodir ${JETTY_HOME}
	cp -R release/xwikionjetty/* "${D}/${JETTY_HOME}" || die
	keepdir ${JETTY_HOME}/logs

	einfo "Fixing permissions..."
	chown -R ${XWIKI_NAME}:${XWIKI_NAME} "${D}/${JETTY_HOME}" || die
	chmod -R o-rwx "${D}/${JETTY_HOME}"  || die
}

pkg_postinst() {
	if use standalone; then
		einfo
		einfo " NOTICE!"
		einfo " User and group '${XWIKI_NAME}' have been added."
	fi
	einfo
	einfo " FILE LOCATIONS:"
	if use war || use exowar || use tomcat; then
		einfo
		einfo " WARS:"
		(use war || use tomcat) && einfo " $xwiki.war: ${DESTDIR}/lib/xwiki.war"
		use exowar && einfo " xwiki-exo.war: ${DESTDIR}/lib/xwiki-exo.war"
		! use tomcat && einfo "  how to install war: http://www.xwiki.org/xwiki/bin/view/AdminGuide/Installation#HInstallingtheXWikiWARmanually"
	fi

	if use standalone; then
		einfo
		einfo " XWiki Standalone:"
		einfo " 1. XWiki standalone directory: ${JETTY_HOME} "
		einfo "     Contains application data, configuration files."
		einfo " 2. Runtime settings: /etc/conf.d/${XWIKI_NAME}"
		einfo "     Contains JAVA_HOME,JAVA_OPTIONS,JETTY_PORT setting"
		einfo " 3. Logs are located at:"
		einfo "     /var/log/${XWIKI_NAME}.log"
		einfo
		einfo " STARTING AND STOPPING XWiki standalone:"
		einfo "   /etc/init.d/${XWIKI_NAME} start"
		einfo "   /etc/init.d/${XWIKI_NAME} stop"
		einfo " "
		einfo " NETWORK CONFIGURATION:"
		einfo " By default, Jetty runs on port 8080.  You can change this"
		einfo " value by setting JETTY_PORT in /etc/conf.d/${XWIKI_NAME} ."
		einfo " "
		einfo " To test XWiki standalone while it's running, point your web browser to:"
		einfo " http://localhost:8080/xwiki/"
	fi
	einfo
	einfo " LOGIN:"
	einfo " You can log in to xwiki using the default 'Admin' user (first letter is capitalized)."
	einfo " The default password is 'admin' (lowercase)."

	if use war || use exowar || use tomcat; then 
		einfo
		einfo " If you are not using standalone version you need to manualy setup database:"
		einfo "  http://www.xwiki.org/xwiki/bin/view/AdminGuide/Installation#HInstallingtheXWikiWARmanually"
		einfo " and download default set of XWiki pages (.xar) in"
		einfo "  http://www.xwiki.org/xwiki/bin/view/Main/Download"
		einfo " and load it in xwiki instance:"
		einfo "  http://www.xwiki.org/xwiki/bin/view/AdminGuide/Installation#HInstallingtheDefaultWikiXAR"
	fi
	einfo
	einfo " For more information about XWiki installation refer to http://www.xwiki.org/xwiki/bin/view/AdminGuide/Installation"
	einfo
	einfo " BUGS:"
	einfo " Please email any bugs at <amelentev at gmail dot com>"
	einfo
}

#pkg_config() {
#TODO: configurate database
#}

