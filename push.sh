#!/bin/bash

echo -n "Development? "
read dev

if [[ $dev != "y" && $dev != "n" ]]; then
  echo "invalid response"
  exit 1
fi

if [[ $dev == "y" ]]; then
  rsync -v -e ssh aw*.zip \
      bll123@frs.sourceforge.net:/home/frs/project/tcl-awthemes/development/
else
  rsync -v -e ssh README.txt aw*.zip \
      bll123@frs.sourceforge.net:/home/frs/project/tcl-awthemes/
fi
