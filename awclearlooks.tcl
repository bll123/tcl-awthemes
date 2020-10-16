#!/usr/bin/tclsh
#
#   clearlooks:
#     - changed blue focus, selection and progressbar colors to a color
#       matching the overall theme
#     -
#

package provide clearlooks 1.0

set ap [file normalize [file dirname [info script]]]
if { $ap ni $::auto_path } {
  lappend ::auto_path $ap
}
set ap [file normalize [file join [file dirname [info script]] .. code]]
if { $ap ni $::auto_path } {
  lappend ::auto_path $ap
}
unset ap
package require awthemes

namespace eval ::ttk::theme::clearlooks {

  proc setBaseColors { } {
    variable colors

      array set colors {
          style.arrow           solid-bg
          style.button          roundedrect-gradient
          style.checkbutton     square-check-gradient
          style.combobox        rounded
          style.entry           roundedrect
          style.menubutton      solid
          style.notebook        -
          style.progressbar     rect-diag
          style.radiobutton     circle-circle
          style.scale           rect-narrow
          style.scrollbar       rect-bord
          style.scrollbar-grip  none
          style.treeview        open
          bg.bg                 #efebe7
          fg.fg                 #000000
          graphics.color        #c9ac9a
      }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(bg.light) #f5f3f0
    set colors(bg.lightest) #ffffff
    set colors(bg.dark) #e7ddd8
    set colors(bg.darker) #c9c1bc
    set colors(bg.darkest) #9c9284

    set colors(accent.color) #000000
    set colors(bg.border) $colors(bg.darkest)
    set colors(bg.button) $colors(bg.dark)
    set colors(bg.button.active) $colors(bg.bg)
    set colors(bg.button.pressed) $colors(bg.darker)
    set colors(bg.tab.active) $colors(bg.darker)
    set colors(bg.tab.inactive) $colors(bg.darker)
    set colors(button.anchor) {}
    set colors(button.padding) {8 2}
    set colors(checkbutton.scale) 0.8
    set colors(combobox.entry.image.border) {4 4}
    set colors(combobox.entry.image.padding) {3 1}
    set colors(entry.active) $colors(bg.darkest)
    set colors(entrybg.bg) $colors(bg.lightest)
    set colors(entry.image.padding) {3 1}
    set colors(entry.padding) {0 1}
    set colors(focus.color) #c9ac9a
    set colors(graphics.color.arrow) #000000
    set colors(graphics.color.pbar) $colors(focus.color)
    set colors(graphics.color.pbar.border) $colors(bg.border)
    set colors(graphics.color.scrollbar.arrow) #000000
    set colors(graphics.color.sizegrip) $colors(bg.darkest)
    set colors(graphics.color.spin.bg) $colors(bg.dark)
    set colors(menubutton.padding) {0 2}
    set colors(menubutton.use.button.image) true
    set colors(notebook.tab.focusthickness) 2
    set colors(notebook.tab.padding) {3 2}
    set colors(parent.theme) clam
    set colors(scrollbar.active) $colors(bg.light)
    set colors(scrollbar.color) $colors(graphics.color.spin.bg)
    set colors(scrollbar.has.arrows) true
    set colors(selectbg.bg) $colors(focus.color)
    set colors(selectfg.fg) #000000
    set colors(trough.color) #d7cbbe
    set colors(toolbutton.image.padding) {4 0}
    set colors(toolbutton.use.button.image) true
  }

  proc init { } {
    ::ttk::awthemes::init clearlooks
  }

  init
}
