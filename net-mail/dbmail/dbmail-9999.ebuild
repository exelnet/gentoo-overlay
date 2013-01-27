EAPI="4"                                                                                                                                                                           
                                                                                                                                                                                   
inherit eutils git-2                                            
                                                                                                                                                                                   
DESCRIPTION="A mail storage and retrieval daemon that uses MySQL or PostgreSQL as its data store"                                                                                  
HOMEPAGE="http://www.dbmail.org/"                                                                                                                                                  
LICENSE="GPL-2"                                                                                                                                                                    
                                                                                                                                                                                   
SLOT="0"                                                                                                                                                                           
KEYWORDS="~amd64 ~x86"                                                                                                                                                             
IUSE="ldap sieve postgres mysql sqlite3"                                                                                                                                                              
                                                                                                                                                                                   
EGIT_REPO_URI="git://git.dbmail.eu/paul/dbmail"                                                                                                                                  
EGIT_COMMIT="${DBMAIL_GIT_REVISION}"                                                                                                                                               
EGIT_BRANCH="${DBMAIL_GIT_BRANCH}"
                                                                                                                                                                                   
DEPEND="  
	>=dev-libs/glib-2.16
	=dev-libs/gmime-2.4*
	app-crypt/mhash
	dev-libs/openssl
	dev-libs/libevent
	dev-libs/libzdb	

	sqlite3?    ( >=dev-db/sqlite-3.0  )
	mysql?	    ( >=dev-db/mysql-5.0 )
	postgres?   ( >=dev-db/postgresql-server-8.3 )

	!mysql?     ( !postgres? ( !sqlite3? ( >=dev-db/sqlite-3.0 ) ) ) 

	ldap?       ( >=net-nds/openldap-2.3.33 )
	sieve?      ( >=mail-filter/libsieve-2.2.1 )
"	                                                                                                                                               
                                                                                                                                                                                   
RDEPEND="${DEPEND}" 

src_configure() {
	econf \
		$(use_with ldap) \
		$(use_with sieve) \
		${myconf} \
		|| die "econf failed"
}

pkg_preinst() {
	enewgroup dbmail
	enewuser dbmail -1 -1 /var/lib/dbmail dbmail
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS BUGS ChangeLog README* INSTALL NEWS THANKS UPGRADING

	docinto sql/mysql
	dodoc sql/mysql/*
	docinto sql/postgresql
	dodoc sql/postgresql/*
	docinto sql/sqlite
	dodoc sql/sqlite/*
	docinto test-scripts
	dodoc test-scripts/*
	docinto contrib/sql2sql
	dodoc contrib/sql2sql/*
	docinto contrib/mailbox2dbmail
	dodoc contrib/mailbox2dbmail/README
	docinto contrib

	sed -i -e "s:nobody:dbmail:" dbmail.conf
	sed -i -e "s:nogroup:dbmail:" dbmail.conf
	sed -i -e "s:#library_directory:library_directory:" dbmail.conf

	insinto /etc/dbmail
	newins dbmail.conf dbmail.conf.dist

	# change config path to our default and use the conf.d and init.d files from the contrib dir
	sed -i -e "s:/etc/dbmail.conf:/etc/dbmail/dbmail.conf:" contrib/startup-scripts/gentoo/init.d-dbmail
	sed -i -e "s:PID_DIR=/var/run:PID_DIR=/var/run/dbmail:" contrib/startup-scripts/gentoo/init.d-dbmail
	sed -i -e "s:exit 0:return 1:" contrib/startup-scripts/gentoo/init.d-dbmail
	newconfd contrib/startup-scripts/gentoo/conf.d-dbmail dbmail
	newinitd contrib/startup-scripts/gentoo/init.d-dbmail dbmail

	dobin contrib/mailbox2dbmail/mailbox2dbmail
	doman contrib/mailbox2dbmail/mailbox2dbmail.1

	# ldap schema
	if use ldap; then
	   insinto /etc/openldap/schema
	   doins "${S}/dbmail.schema"
	fi

	keepdir /var/lib/dbmail
	fperms 750 /var/lib/dbmail

	mkdir /var/run/dbmail
	chown -R dbmail:dbmail /var/run/dbmail
}

pkg_postinst() {
	elog "Please read the INSTALL file in /usr/share/doc/${PF}/"
	elog "for remaining instructions on setting up dbmail users and "
	elog "for finishing configuration to connect to your MTA and "
	elog "to connect to your db."
	echo
	elog "DBMail requires either SQLite, PostgreSQL or MySQL."
	elog "If none of the use-flags are specified SQLite is"
	elog "used as default. To use another database please"
	elog "specify the appropriate use-flag and re-emerge dbmail."
	echo
	elog "Database schemes can be found in /usr/share/doc/${PF}/"
	elog "You will also want to follow the installation instructions"
	elog "on setting up the maintenance program to delete old messages."
	elog "Don't forget to edit /etc/dbmail/dbmail.conf as well."
	echo
	elog "For regular maintenance, add this to crontab:"
	elog "0 3 * * * /usr/bin/dbmail-util -cpdy >/dev/null 2>&1"
	echo
	elog "Please make sure to run etc-update."
	elog "If you get an error message about plugins not found"
	elog "please add the library_directory configuration switch to"
	elog "dbmail.conf and set it to the correct path"
	elog "(usually /usr/lib/dbmail or /usr/lib64/dbmail on amd64)"
	elog "A sample can be found in dbmail.conf.dist after etc-update."
	echo
	elog "We are now using the init script from upstream."
	elog "Please edit /etc/conf.d/dbmail to set which services to start"
	elog "and delete /etc/init.d/dbmail-* when you are done. (don't"
	elog "forget to rc-update del dbmail-* first)"
}

