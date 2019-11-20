#!/usr/bin/tclsh
#
# themeutils.tcl
#
# Copyright 2019 Brad Lanam Pleasant Hill, CA
#
# zlib/libpng license
#

package provide themeutils 2.1

# scale.factor
#   additional scaling factor (default 1.0)
#   scaling is computed based on the ttk scaling multipled by this scale factor.
# anchor.button
#   button text anchor: {} for center, e, w
# base.bg
#   background color
# base.bg.disabled
#   disabled background color
# base.dark
#   dark color
# base.darker
#   darker color
# base.darkest
#   darkest color, typically black
# base.fg.disabled
#   foreground disabled color
# base.fg
#   foreground color
# base.focus
#   focus ring color
# base.lighter
#   lighter color
# base.lightest
#   lightest color, typically white
# focusthickness.checkbutton
#   thickness of the focus ring on checkbuttons
# focusthickness.notebooktab
#   thickness of the focus ring on the notebook tab
# graphics.border
#   border color for the graphics
# graphics.color
#   color for the graphics
# graphics.color.b.disabled
#   disabled color for the graphics
# graphics.color.b
#   secondary graphics color
# graphics.color.disabled
#   disabled graphics color
# graphics.grip
#   grip color for scale and scrollbars
# graphics.sizegrip
#   sizegrip color
# height.arrow
#   height and width of the arrows
# height.combobox
#   height of the combobox arrow
# highlight.active.bg
#   background highlight color (for menus, menubuttons)
# highlight.active.fg
#   foreground highlight color (for menus, menubuttons)
# highlight.darkhighlight
#   dark highlight color (for sash, progress bar, scale)
# padding.button
#   button padding
# padding.checkbutton
#   checkbutton padding
# padding.entry
#   entry box padding
# padding.menubutton
#   menu button padding
# padding.notebooktab
#   notebook tab padding
# text.select.bg
#   selected text background
# text.select.fg
#   selected text foreground

# Derived Colors
#
# base.arrow                          base.darkest
# base.arrow.disabled                 base.lighter
# base.border
# base.border.dark
# base.border.disabled
# base.button.active                  base.lighter
# base.button.bg                      base.bg
# base.button.border                  base.bg
# base.button.pressed                 base.dark
# base.entry.bg
# base.entry.bg.disabled
# base.entry.box                      base.lighter
# base.entry.fg
# base.hover                          base.bg
# base.trough
# focusthickness.radiobutton          focusthickness.checkbutton
# padding.combobox                    padding.entry
# padding.radiobutton                 padding.checkbutton
# padding.spinbox                     padding.entry
# tab.bg                              base.bg
# tab.bg.disabled                     base.bg
# tab.border                          base.darkest
# tab.box                             base.lighter
# tab.highlight                       none
# tab.highlight.inactive              base.bg
# text.bg                             base.bg
# text.fg                             base.fg
# text.select.bg.inactive             base.lighter

namespace eval ::themeutils {
  variable vars

  proc init {} {
    variable vars

      set vars(names.colors.base) {
          anchor.button
          base.bg
          base.bg.disabled
          base.dark
          base.darker
          base.darkest
          base.fg.disabled
          base.fg
          base.focus
          base.lighter
          base.lightest
          focusthickness.checkbutton
          focusthickness.notebooktab
          graphics.border
          graphics.color
          graphics.color.b.disabled
          graphics.color.b
          graphics.color.disabled
          graphics.grip
          graphics.sizegrip
          height.arrow
          height.combobox
          highlight.active.bg
          highlight.active.fg
          highlight.darkhighlight
          padding.button
          padding.checkbutton
          padding.entry
          padding.menubutton
          padding.notebooktab
          scale.factor
          text.select.bg
          text.select.fg
          }
      set vars(names.colors.derived) {
          base.arrow
          base.arrow.disabled
          base.border
          base.border.dark
          base.border.disabled
          base.button.active
          base.button.bg
          base.button.border
          base.button.pressed
          base.entry.bg
          base.entry.bg.disabled
          base.entry.box
          base.entry.fg
          base.hover
          base.trough
          focusthickness.radiobutton
          padding.combobox
          padding.radiobutton
          padding.spinbox
          tab.bg
          tab.bg.disabled
          tab.border
          tab.box
          tab.highlight
          tab.highlight.inactive
          text.bg
          text.fg
          text.select.bg.inactive
          }
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
