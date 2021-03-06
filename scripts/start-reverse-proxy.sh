#!/bin/sh -eu

DYLD_LIBRARY_PATH=/usr/local/opt/apache2/lib/httpd/modules/ \
  httpd \
  -C 'LoadModule mpm_worker_module mod_mpm_worker.so' \
  -d reverse-proxy \
  -f conf/httpd.conf \
  -e info \
  -DFOREGROUND
