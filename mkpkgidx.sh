#!/bin/bash

> pkgIndex.tcl
for f in awthemes.tcl colorutils.tcl awarc.tcl awdark.tcl awlight.tcl \
    awblack.tcl awbreeze.tcl awwinxpblue.tcl; do
  sf=$(echo $f | sed 's/\.tcl$//')
  pp=$(grep 'package provide [a-z]* [0-9]' $f |
    sed -e 's/provide/ifneeded/')
  cat << _HERE_ >> pkgIndex.tcl
$pp \\
    [list source [file join \$dir $f]]
_HERE_
done

