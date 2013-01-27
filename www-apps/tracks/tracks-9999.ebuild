# Copyright 2013 Jan Marc Hoffmann
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils git-2

DESCRIPTION="Tracks is a web-based application to help you implement David Allen’s Getting Things Done™ methodology. It was built using Ruby on Rails, and comes with a built-in webserver (WEBrick), so that you can run it on your own computer if you like."
HOMEPAGE="http://getontracks.org"
LICENSE="GPL-2"

KEYWORDS="~x86 ~amd64"
IUSE="mysql sqlite3" 
SLOT="0"

EGIT_REPO_URI="https://github.com/TracksApp/tracks.git"

DEPEND=" >=dev-lang/ruby-1.9
	 >=dev-ruby/rubygems-1.8.10
	 >=app-misc/tmux-1.6
	 || ( mysql? ( >=dev-db/mysql-5 ) sqlite3? ( >=dev-db/sqlite-3 ) )"

RDEPEND=">=dev-lang/ruby-1.9"

gemDir="${WORKDIR}/gems"
# This suffix might change with different ruby versions
gemDirRubySuffix="/ruby/1.9.1"

pkg_pretend() {
    rubyVersion=$(eselect ruby show  | grep ruby | sed -e 's/^[ \t]*//')

    if [ ${rubyVersion} != "ruby19" ] ; then
	    eerror "Ruby 1.9.x is required. Set the ruby version using \"eselect ruby\"." && die
    fi
}

src_compile() {
    gem install rdoc bundle --install-dir "${gemDir}${gemDirRubySuffix}"
    bundle install --path ${gemDir}
}

pkg_preinst() {
    enewgroup tracks
    enewuser tracks -1 /bin/bash /var/lib/tracks tracks
}

src_install() {
    sed -i -e "s:config.serve_static_assets = false:config.serve_static_assets = true:" config/environments/production.rb
    sed -i -e "s:config.assets.compile = false:config.assets.compile = true:" config/environments/production.rb

    dodir /usr/lib/tracks
    cp -R "${gemDir}/" "${D}/usr/lib/tracks/" 						|| die "Install failed!"

    dodir /var/lib/tracks
    cp -R . "${D}/var/lib/tracks/" 							|| die "Install failed!"

    dodir /etc/tracks
    cp config/database.yml.tmpl "${D}/etc/tracks/database.yml"  			|| die "Install failed!"
    cp config/site.yml.tmpl "${D}/etc/tracks/site.yml"  				|| die "Install failed!"

    doinitd "${FILESDIR}/init.d/tracks" 						|| die "Install failed!"

    dodir /var/log/tracks
}

pkg_postinst() {
    ln -sf /etc/tracks/database.yml /var/lib/tracks/config/database.yml 		|| die "Install failed!"
    ln -sf /etc/tracks/site.yml /var/lib/tracks/config/site.yml 			|| die "Install failed!"

    chown -R tracks:tracks /usr/lib/tracks 						|| die "Install failed!"
    chown -R tracks:tracks /var/lib/tracks 						|| die "Install failed!"
    chown -R tracks:tracks /var/log/tracks 						|| die "Install failed!"
    
    # update bundle and let it resolve the gems in their new location
    # this should never fail.
    su tracks -c "cd; bundle install --path /usr/lib/tracks/gems &> /dev/null"

    elog "Tracks has been installed. Before starting you must"
    elog "setup the database and basic configuration file for tracks."
    elog "1. Adjust the /etc/tracks/database.yml production section to your needs."
    elog "2. Adjust the /etc/tracks/site.yml to your needs."
    elog "3. Setup the database with: bundle exec rake db:migrate RAILS_ENV=production"
    elog "4. You can start the service with: /etc/init.d/tracks start"
    elog "5. Add to the system startup with: rc-update add tracks default"
    elog "6. The service is accessible under http://<hostname>:3000"
}
