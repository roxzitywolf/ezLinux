# Maintainer: roxzitywolf <https://github.com/roxzitywolf>

pkgname=ezlinux
pkgver=1.0.0
pkgrel=1
pkgdesc="the ultimate cachyos performance + gaming setup script"
arch=('any')
url="https://github.com/roxzitywolf/ezlinux"
license=('MIT')
depends=(
    'bash'
    'git'
    'pacman'
)
optdepends=(
    'paru: AUR helper (will be auto-installed if missing)'
)
source=("${pkgname}-${pkgver}.tar.gz::https://github.com/roxzitywolf/${pkgname}/archive/v${pkgver}.tar.gz")
sha256sums=('SKIP')

package() {
    cd "${srcdir}/${pkgname}-${pkgver}"
    install -Dm755 ezlinux.sh "${pkgdir}/usr/bin/ezlinux"
    install -Dm644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md"
}
