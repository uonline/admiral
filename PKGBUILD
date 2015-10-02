# This is an example PKGBUILD file. Use this as a start to creating your own,
# and remove these comments. For more information, see 'man PKGBUILD'.
# NOTE: Please fill out the license field for your package! If it is unknown,
# then please put 'unknown'.

# Maintainer: m1kc <m1kc@yandex.ru>
pkgname=admiral
pkgver=1.0
pkgrel=1
pkgdesc="Serious captain for serious people."
arch=('i686' 'x86_64')
url="https://github.com/uonline/admiral"
license=('GPL')
groups=()
depends=()
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=('admiral::git+git://github.com/uonline/admiral.git#branch=master')
noextract=()
md5sums=('SKIP')
validpgpkeys=()

prepare() {
	cd "$pkgname"
	#patch -p1 -i "$srcdir/$pkgname-$pkgver.patch"
}

build() {
	cd "$pkgname"
	script/bootstrap
}

check() {
	cd "$pkgname"
	LINES=`script/test | wc -l`
	echo "Test output: ${LINES} lines."
}

package() {
	cd "$pkgname"
	mkdir -p "${pkgdir}/opt"
	cp -r "${srcdir}/${pkgname}" "${pkgdir}/opt/${pkgname}"
	mkdir -p "${pkgdir}/etc/systemd/system"
	cp "${srcdir}/${pkgname}/${pkgname}.service" "${pkgdir}/etc/systemd/system/${pkgname}.service"
}
