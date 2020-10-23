#!/bin/bash

> pkgIndex.tcl
for f in awthemes.tcl ; do
  sf=$(echo $f | sed 's/\.tcl$//')
  pp=$(grep 'set ::themeutils::awversion [0-9]' $f |
    sed -e 's/.* /package ifneeded /')
  cat << _HERE_ >> pkgIndex.tcl
$pp \\
    [list source [file join \$dir $f]]
_HERE_
done

for f in colorutils.tcl awarc.tcl awdark.tcl awlight.tcl \
    awblack.tcl awbreeze.tcl awwinxpblue.tcl awclearlooks.tcl \
    awtemplate.tcl; do
  sf=$(echo $f | sed 's/\.tcl$//')
  pp=$(grep 'package provide [a-z]* [0-9]' $f |
    sed -e 's/provide/ifneeded/;s/^ *//')
  cat << _HERE_ >> pkgIndex.tcl
$pp \\
    [list source [file join \$dir $f]]
_HERE_
done

