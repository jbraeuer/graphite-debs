#! /bin/bash

#
# This script needs "fpm". If you dont have it,
# run "gem install fpm"
#

log() {
    echo "$@"
}

clean() {
    rm -rf "$WORK"
    rm -f python*.deb
}

download() {
    mkdir -p "$DOWNLOAD"
    for prj in graphite-web carbon whisper; do
        local file="$DOWNLOAD/$prj-$VERSION.tar.gz"
        if [ ! -e "$file" ]; then
            cd "$DOWNLOAD"
            wget "http://launchpad.net/graphite/0.9/$VERSION/+download/$prj-$VERSION.tar.gz"
            cd -
        fi
    done
}

extract() {
    mkdir -p "$WORK"
    for prj in graphite-web carbon whisper; do
        tar -C "$WORK" -zxvf "$DOWNLOAD/$prj-$VERSION.tar.gz"
    done
}

package() {
    cd "$WORK"
    fakeroot fpm1.8 -s python -t deb txamqp
    fakeroot fpm1.8 -s python -t deb --python-package-name-prefix python2.7 --depends "python" --depends "python-support" "./whisper-$VERSION/setup.py"
    fakeroot fpm1.8 -s python -t deb --python-package-name-prefix python2.7 --depends "python" --depends "python-support" \
        --depends "python-twisted" --depends "python2.7-whisper" \
        --post-install "$BASE/fix-storage.sh" \
        "./carbon-$VERSION/setup.py"
    fakeroot fpm1.8 -s python -t deb --python-package-name-prefix python2.7 --depends "python" --depends "python-support" \
        --depends "python2.7-whisper" \
        --depends "python-twisted" \
        --depends "python-cairo" \
        --depends "python-django" \
        --depends "python-django-tagging" \
        --depends "python-ldap" \
        --depends "python-memcache" \
        --depends "python-pysqlite2" \
        --depends "python-sqlite" \
        --depends "libapache2-mod-python" \
        --post-install "$BASE/fix-storage.sh" \
        "./graphite-web-$VERSION/setup.py"
}

install() {
    log "********************************************************************************"
    log "Find the .deb's here: $WORK"
    log ""
    log "To install:"
    log "  sudo dpkg -i python*.deb"
    log "  sudo apt-get -f install"
}

set -e

BASE="$(readlink -f $(dirname "$0"))"
WORK="$BASE/work"
DOWNLOAD="$BASE/download"
DIST="$BASE/dist"

VERSION=0.9.10

download
clean
extract
package
install
