#!/bin/bash

> pkgIndex.tcl
for f in awthemes.tcl ; do
  sf=$(echo $f | sed 's/\.tcl$//')
  pp=$(grep 'set ::themeutils::awversion [0-9]' $f |
    sed -e "s/.* /package ifneeded $sf /")
  cat << _HERE_ >> pkgIndex.tcl
$pp \\
    [list source [file join \$dir $f]]
_HERE_
done

for f in colorutils.tcl ; do
  sf=$(echo $f | sed 's/\.tcl$//')
  pp=$(grep 'package provide [a-z$\{\}]* [0-9$]' $f |
    sed -e 's/provide/ifneeded/' -e 's/^ *//')
  cat << _HERE_ >> pkgIndex.tcl
$pp \\
    [list source [file join \$dir $f]]
_HERE_
done

for f in \
    awarc.tcl awblack.tcl awbreeze.tcl \
    awclearlooks.tcl awdark.tcl awlight.tcl \
    awtemplate.tcl awwinxpblue.tcl \
    ; do
  sf=$(echo $f | sed 's/\.tcl$//')
  th=$(grep 'set theme [a-z]*' $f | sed 's/ *set theme //')
  ver=$(grep 'set version [0-9.]*' $f | sed 's/ *set version //')
  cat << _HERE_ >> pkgIndex.tcl
package ifneeded $th $ver \\
    [list source [file join \$dir $f]]
package ifneeded ttk::theme::$th $ver \\
    [list source [file join \$dir $f]]
_HERE_
done
