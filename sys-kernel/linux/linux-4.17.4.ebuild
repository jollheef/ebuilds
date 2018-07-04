# Copyright 1999-2018 Gentoo Foundation
# Author: Mikhail Klementev <jollheef@riseup.net>
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="Linux kernel"
HOMEPAGE="https://kernel.org/"
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${PV}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cryptsetup suid +initramfs +grub"

DEPEND="sys-devel/make
        sys-devel/binutils
        dev-lang/perl
        sys-devel/bc
        grub? ( sys-boot/grub )
        initramfs? ( sys-kernel/genkernel )"

RDEPEND="${DEPEND}"

ARCH=x86

src_prepare() {
	default

	echo 'config LOCAL_CONFIG' >> Kconfig
	echo -e '\tbool "Local configuration"' >> Kconfig
	echo -e '\tdefault y' >> Kconfig

	if use cryptsetup; then
		echo -e '\tselect DM_CRYPT' >> Kconfig
		echo -e '\tselect CRYPTO_USER_API_SKCIPHER' >> Kconfig
		cat /proc/cpuinfo | grep aes >/dev/null && {
			echo -e '\tselect CRYPTO_AES_NI_INTEL' >> Kconfig
		}
	fi

	if use suid; then
		echo -e '\tselect USER_NS' >> Kconfig
	fi

	# make.conf:
	# # qemu
	# KCONFIG="$KCONFIG KVM KVM_INTEL"
	# # ethernet
	# KCONFIG="$KCONFIG ALX"
	# # wireless card
	# KCONFIG="$KCONFIG ATH_CARDS ATH9K CFG80211_WEXT"
	# # openvpn
	# KCONFIG="$KCONFIG TUN"
	# # audio
	# ...
	for i in $KCONFIG; do
		echo -e "\tselect $i" >> Kconfig
	done

        # /etc/linux/Kconfig
        # config INTEL_NUC_7I7DN
        #         bool "Intel NUC 7i7DN"
        #         default y
        #
        #         select BLABLABLA
        #         ...
        if [ -e /etc/linux/Kconfig ]; then
                echo 'source "/etc/linux/Kconfig"' >> Kconfig
        fi

	make defconfig 2>&1 | grep warning && die "Broken config"
}

src_install() {
	mkdir -p ./boot
	make install INSTALL_PATH=./boot
	insinto /boot
	ls ./boot | while read file; do
	        doins ./boot/${file}
	done
}

pkg_postinst() {
        if use initramfs; then
                if use cryptsetup; then
                        GENKERNEL_ARGS=--luks
                fi
                genkernel ${GENKERNEL_ARGS} initramfs --kerneldir=${S}
        fi

        if use grub; then
                grub-mkconfig -o /boot/grub/grub.cfg
        fi
}
