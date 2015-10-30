# Maintainer: m1kc <m1kc@yandex.ru>
pkgname=admiral
pkgver=1.1.0
pkgrel=1
pkgdesc="Serious captain for serious people."
arch=('any')
url="https://github.com/uonline/admiral"
license=('GPL')
groups=()
depends=('nodejs' 'coffee-script')
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

pkgver() {
	cd "$pkgname"
	cat package.json | grep version | cut -d'"' -f4
}

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
	rm -rf "${pkgdir}/opt/${pkgname}/.git"
	mkdir -p "${pkgdir}/etc/systemd/system"
	cp "${srcdir}/${pkgname}/${pkgname}.service" "${pkgdir}/etc/systemd/system/${pkgname}.service"
}
