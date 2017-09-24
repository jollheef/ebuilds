# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Atlassian SDK"
SRC_URI="https://packages.atlassian.com/maven/repository/public/com/atlassian/amps/atlassian-plugin-sdk/${PV}/atlassian-plugin-sdk-${PV}.tar.gz"

LICENSE="EULA"
SLOT="0"
KEYWORDS="amd64"

RESTRICT="bindist"

RDEPEND="dev-java/oracle-jdk-bin"

S=${WORKDIR}

src_install() {
	mv atlassian-plugin-sdk-${PV} atlassian-plugin-sdk
	insinto /opt
	doins -r atlassian-plugin-sdk

	exeinto /opt/atlassian-plugin-sdk/bin/
	find atlassian-plugin-sdk/bin | while read file; do
	    doexe ${file}
	done

	echo 'export PATH=/opt/atlassian-plugin-sdk/bin' > 99atlassian-plugin-sdk
	doenvd 99atlassian-plugin-sdk
}