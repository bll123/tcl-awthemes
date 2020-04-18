#!/usr/bin/tclsh
#
#

package provide black 7.1

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
          style.checkbutton     square-x
          style.radiobutton     octagon-circle
          arrow.height          16
          base.bg               #424242
          base.bg.disabled      #424242
          base.dark             #222222
          base.darker           #121212
          base.darkest          #000000
          base.fg               #ffffff
          base.focus            #000000
          base.lighter          #626262
          base.lightest         #ffffff
          button.anchor         w
          button.padding        {5 1}
          checkbutton.focusthickness  1
          checkbutton.padding   {4 1 1 1}
          combobox.height       23
          entry.padding         {1 0}
          graphics.border       #222222
          graphics.color        #424242
          graphics.color.arrow      #000000
          graphics.grip         #000000
          graphics.sizegrip     #000000
          highlight.active.bg   #4a6984
          highlight.active.fg   #ffffff
          highlight.darkhighlight     #424242
          menubutton.padding    {5 1}
          menubutton.relief     raised
          menubutton.width      -8
          notebook.tab.focusthickness  1
          notebook.tab.padding   {4 2 4 2}
          highlight.text.select.bg        #4a6984
          highlight.text.select.fg        #ffffff
      }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(base.border) $colors(base.darkest)
    set colors(base.border.dark) $colors(base.darkest)
    set colors(base.button.border) $colors(base.darkest)
    set colors(base.entry.field.bg) $colors(base.lightest)
    set colors(base.hover) $colors(base.lighter)
    set colors(base.trough) $colors(base.darker)
    set colors(radiobutton.padding) $colors(checkbutton.padding)
    set colors(text.fg) $colors(base.darkest)
    #
    set colors(base.entry.field.bg.disabled) $colors(base.entry.field.bg)
    set colors(text.bg) $colors(base.entry.field.bg)
    #
    set colors(base.entry.fg) $colors(text.fg)
  }

  proc init { } {
    ::ttk::awthemes::init black
  }

  init
}


