#! /bin/bash

#
# This script needs "fpm". If you dont have it,
# run "gem install fpm"
#

clean() {
    rm -rf whisper-0.9.9 carbon-0.9.9 graphite-web-0.9.9
    rm -f python*.deb
}

download() {
    [ -e graphite-web-0.9.9.tar.gz ] || wget http://launchpad.net/graphite/0.9/0.9.9/+download/graphite-web-0.9.9.tar.gz
    [ -e carbon-0.9.9.tar.gz ]       || wget http://launchpad.net/graphite/0.9/0.9.9/+download/carbon-0.9.9.tar.gz
    [ -e whisper-0.9.9.tar.gz ]      || wget http://launchpad.net/graphite/0.9/0.9.9/+download/whisper-0.9.9.tar.gz
}

extract() {
    tar -zxvf graphite-web-0.9.9.tar.gz
    tar -zxvf carbon-0.9.9.tar.gz
    tar -zxvf whisper-0.9.9.tar.gz
}

package() {
    fpm -s python -t deb txamqp
    fpm -s python -t deb -S 2.7 --depends "python" --depends "python-support" whisper-0.9.9/setup.py
    fpm -s python -t deb -S 2.7 --depends "python" --depends "python-support" \
	--depends "python-twisted" --depends "python2.7-whisper" carbon-0.9.9/setup.py
    fpm -s python -t deb -S 2.7 --depends "python" --depends "python-support" \
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
	graphite-web-0.9.9/setup.py
}

install() {
    sudo dpkg -i python*.deb
    sudo apt-get -f install
}

download
clean
extract
package
#install
