#!/usr/bin/tclsh
#
# themeutils.tcl
#
# Copyright 2019 Brad Lanam Pleasant Hill, CA
#
# zlib/libpng license
#

package provide themeutils 1.0

namespace eval ::themeutils {
  variable vars

  proc init {} {
    variable vars

      set vars(names.colors.base) {
          base.disabledfg
          base.disabledbg
          base.disabledborder
          base.frame
          base.dark
          base.darker
          base.darkest
          base.bpress
          base.lighter
          base.lightest
          highlight.selectbg
          highlight.selectdisabledbg
          highlight.darkhighlight
          highlight.selectfg
          }
      set vars(names.colors.derived) {
          base.arrow
          base.arrow.disabled
          base.border
          base.border.light
          text.text
          base.tabborder
          base.tabinactive
          base.tabhighlight
          base.entrybg
          }
# derived colors:
# base.arrow
#     awdark:   base.lightest         awlight:  base.darkest
# base.arrow.disabled
#     awdark:   base.lighter          awlight:  base.darker
# base.border
#     awdark:   base.darkest          awlight:  base.dark
# base.border.light
#     awdark:   base.darkest          awlight:  base.dark
# text.text
#     awdark:   base.lightest         awlight:  base.darkest
# base.tabborder
#     awdark:   base.darkest          awlight:  base.frame
# base.tabinactive
#     awdark:   base.frame            awlight:  base.darker
# base.tabhighlight
#     awdark:   #8b9ca1               awlight:  base.darkest
# base.entrybg
#     awdark:   base.darker           awlight:  base.lightest
  }

  proc setThemeColors { theme args } {
    variable vars

    namespace eval ::ttk::theme::$theme {}

    foreach {cn col} $args {
      set ::ttk::theme::${theme}::colors(user.$cn) $col
    }
  }

  init
}
