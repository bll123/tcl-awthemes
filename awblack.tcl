#!/usr/bin/tclsh
#
#

package provide black 7.0

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

namespace eval ::ttk::theme::black {

  proc setBaseColors { } {
    variable colors

      array set colors {
          anchor.button         w
          base.bg               #424242
          base.bg.disabled      #424242
          base.dark             #222222
          base.darker           #121212
          base.darkest          #000000
          base.fg               #ffffff
          base.focus            #000000
          base.lighter          #626262
          base.lightest         #ffffff
          focusthickness.checkbutton  1
          focusthickness.notebooktab  1
          graphics.border       #222222
          graphics.color        #424242
          graphics.color.arrow      #000000
          graphics.grip         #000000
          graphics.sizegrip     #000000
          height.arrow          16
          height.combobox       23
          highlight.active.bg   #4a6984
          highlight.active.fg   #ffffff
          highlight.darkhighlight     #424242
          padding.button        {5 1}
          padding.checkbutton   {4 1 1 1}
          padding.entry         {1 0}
          padding.menubutton    {5 1}
          padding.notebooktab   {4 2 4 2}
          relief.menubutton     raised
          scrollbar.grip        true
          text.select.bg        #4a6984
          text.select.fg        #ffffff
          width.menubutton      -8
      }
  }

  proc setDerivedColors { prefix } {
    variable colors

    set colors(${prefix}base.border) $colors(base.darkest)
    set colors(${prefix}base.border.dark) $colors(base.darkest)
    set colors(${prefix}base.button.border) $colors(base.darkest)
    set colors(${prefix}base.entry.bg) $colors(base.lightest)
    set colors(${prefix}base.hover) $colors(base.lighter)
    set colors(${prefix}base.trough) $colors(base.darker)
    set colors(${prefix}base.labelframe) $colors(base.bg)
    set colors(${prefix}padding.radiobutton) $colors(padding.checkbutton)
    set colors(${prefix}text.fg) $colors(base.darkest)
    #
    set colors(${prefix}base.entry.bg.disabled) $colors(base.entry.bg)
    set colors(${prefix}text.bg) $colors(base.entry.bg)
    #
    set colors(${prefix}base.entry.fg) $colors(text.fg)
  }

  proc init { } {
    ::ttk::awthemes::init black
  }

  init
}


