#! /bin/sh

if id www-data >/dev/null 2>&1; then
    echo "Make /opt/graphite/storage/ writable for www-data"
    chown -R www-data:www-data /opt/graphite/storage/
fi
