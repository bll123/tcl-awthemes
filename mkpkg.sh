#!/bin/bash

find . -name '*~' -print0 | xargs -0 rm -f
find . -name '*.orig' -print0 | xargs -0 rm -f
nm=awthemes
ver=$(egrep 'set ::themeutils::awversion' ${nm}.tcl | sed 's/.* //')
echo "VERSION: $ver"
test -f ${nm}-${ver}.zip && rm -f ${nm}-${ver}.zip
tdir=awthemes-${ver}

mkdir ${tdir}
cp -r \
    LICENSE aw*.tcl colorutils.tcl \
    demoscaled.tcl demoscaledb.tcl demottk.tcl \
    pkgIndex.tcl README.txt i \
    ${tdir}
zip -rq ${nm}-${ver}.zip ${tdir}
rm -rf ${tdir}
