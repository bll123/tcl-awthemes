#!/usr/bin/tclsh
#
# themeutils.tcl
#
# Copyright 2019 Brad Lanam Pleasant Hill, CA
#
# zlib/libpng license
#

package provide themeutils 2.3

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
# button.image.border
# button.image.padding
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
# relief.menubutton
#   menubutton relief
# scrollbar.grip
#   true / false
# text.select.bg
#   selected text background
# text.select.fg
#   selected text foreground
# width.menubutton
#   menubutton width setting

# Derived Colors
#
# base.active                         base.bg
# base.arrow                          base.darkest
# base.arrow.disabled                 base.lighter
# base.border                         base.dark
# base.border.dark                    base.darker
# base.border.disabled                base.border
# base.button.active                  base.lighter
# base.button.bg                      base.bg
# base.button.border                  base.bg
# base.button.pressed                 base.dark
# base.entry.bg                       base.darker
# base.entry.bg.disabled              base.bg.disabled
# base.entry.box                      base.lighter
# base.entry.fg                       text.fg
# base.hover                          base.bg
# base.slider.border                  base.border
# base.tab.bg.active                  base.lighter
# base.tab.bg.disabled                base.bg
# base.tab.bg.inactive                base.bg
# base.tab.bg.selected                base.bg
# base.tab.border                     base.darkest
# base.tab.box                        base.lighter
# base.tab.highlight                  {}
# base.tab.highlight.inactive         base.bg
# base.trough                         base.entry.bg
# focusthickness.radiobutton          focusthickness.checkbutton
# graphics.border                     base.border
# graphics.color.cb.disabled          graphics.color.arrow.disabled
# graphics.color.cb                   graphics.color.arrow
# graphics.color.scrollbar.border     graphics.border
# graphics.color.scrollbar            graphics.color
# graphics.color.spin.arrow.disabled  graphics.color.arrow.disabled
# graphics.color.spin.arrow           graphics.color.arrow
# graphics.color.spin.bg.disabled     graphics.color.disabled
# graphics.color.spin.bg              graphics.color
# graphics.color.spin.border          base.darker
# padding.combobox                    padding.entry
# padding.radiobutton                 padding.checkbutton
# padding.spinbox                     padding.entry
# text.select.bg.inactive             base.lighter
# tree.select.fg                      text.select.fg
# tree.select.bg                      text.select.bg

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
          base.fg
          base.fg.disabled
          base.focus
          base.lighter
          base.lightest
          focusthickness.checkbutton
          focusthickness.notebooktab
          graphics.border
          graphics.color
          graphics.color.arrow
          graphics.color.arrow.disabled
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
          relief.menubutton
          scale.factor
          text.select.bg
          text.select.fg
          width.menubutton
          }
      set vars(names.colors.derived) {
          base.active
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
          base.slider.border
          base.tab.bg.active
          base.tab.bg.disabled
          base.tab.bg.inactive
          base.tab.bg.selected
          base.tab.border
          base.tab.box
          base.tab.highlight
          base.tab.highlight.inactive
          base.trough
          focusthickness.radiobutton
          graphics.color.cb
          graphics.color.cb.disabled
          graphics.color.spin.arrow
          graphics.color.spin.arrow.disabled
          graphics.color.spin.bg
          graphics.color.spin.bg.disabled
          graphics.color.spin.border
          padding.combobox
          padding.radiobutton
          padding.spinbox
          text.select.bg.inactive
          tree.select.bg
          tree.select.fg
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
