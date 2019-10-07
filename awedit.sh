#!/bin/bash

TAWTHEME=awthemes.tmp
> $TAWTHEME
cat >> $TAWTHEME << _HERE_
          #B == svgdata ==
_HERE_

theme=awthemes

for ffn in i/$theme/*.svg; do
  case $ffn in
    *-base.svg)
      continue
      ;;
  esac
  fn=$(echo $ffn | sed -e 's,^i/aw[a-z]*/,,' -e 's/\.svg$//')

  tag=$fn
  case $fn in
    *pad*)
      tag=menu-$fn
      ;;
  esac

  cat >> $TAWTHEME << _HERE_
          # $fn
          set imgtype($tag) svg
          set imgdata($tag) {
_HERE_
  cat $ffn >> $TAWTHEME
  cat >> $TAWTHEME << _HERE_
}
_HERE_

done

cat >> $TAWTHEME << _HERE_
          #E == svgdata ==
_HERE_

ed awthemes.tcl << _HERE_
/#B == svgdata ==/
.,/#E == svgdata ==/ d
-1
. r $TAWTHEME
w
q
_HERE_

rm -f $TAWTHEME
