#!/bin/sh
#
#

if [ ! -f /usr/bin/inkscape ]; then
  echo "No inkscape installed"
  exit 1
fi

pinkscape () {
  tr=$1
  pfx=$2
  tf=$3

  # the images were created and sized on a 100 dpi display,
  # so adjust for inkscape's 96 dpi default.
  nr=$(($tr*96/100))
  nf=`echo $tf | sed -e 's/\.svg$/.png/' -e "s,^,$pfx,"`
  if [ \( ! -f $nf \) \
      -o \( $tf -nt $nf \) \
      -o \( mkimages.sh -nt $nf \) ]; then
    echo $nf
    mkdir -p `dirname $nf`
    inkscape -e $nf -d $nr -y 0 $tf > /dev/null
  fi
}

# 72 is good for menu selections
for r in 72; do
  for f in i/awdark/*-small.svg i/awlight/*-small.svg; do
    pinkscape $r $r/ $f
  done
done
for r in 96; do
  for f in i/awdark/*.svg i/awlight/*.svg; do
    case $f in
      "*-small.svg")
        continue
        ;;
    esac
    pinkscape $r $r/ $f
  done
done
