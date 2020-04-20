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
          bg.bg               #424242
          bg.bg.disabled      #424242
          bg.dark             #222222
          bg.darker           #121212
          bg.darkest          #000000
          fg.fg               #ffffff
          focus.color            #000000
          bg.lighter          #626262
          bg.lightest         #ffffff
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
          selectbg.bg   #4a6984
          selectfg.fg   #ffffff
          highlight.darkhighlight     #424242
          menubutton.padding    {5 1}
          menubutton.relief     raised
          menubutton.width      -8
          notebook.tab.focusthickness  1
          notebook.tab.padding   {4 2 4 2}
          selectbg.bg        #4a6984
          selectfg.fg        #ffffff
      }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(bg.border) $colors(bg.darkest)
    set colors(bg.border.dark) $colors(bg.darkest)
    set colors(bg.button.border) $colors(bg.darkest)
    set colors(entrybg.bg) $colors(bg.lightest)
    set colors(bg.hover) $colors(bg.lighter)
    set colors(trough.color) $colors(bg.darker)
    set colors(radiobutton.padding) $colors(checkbutton.padding)
    set colors(entryfg.fg) $colors(bg.darkest)
    #
    set colors(entrybg.bg.disabled) $colors(entrybg.bg)
    set colors(entrybg.bg) $colors(entrybg.bg)
    #
    set colors(bg.entry.fg) $colors(entryfg.fg)
  }

  proc init { } {
    ::ttk::awthemes::init black
  }

  init
}


