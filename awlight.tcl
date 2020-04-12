#!/usr/bin/tclsh
#
#

package provide awlight 7.2

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

namespace eval ::ttk::theme::awlight {

  proc setBaseColors { } {
    variable colors

    array set colors {
        arrow.height          16
        base.bg.disabled      #cacaca
        base.bg               #e8e8e7
        base.dark             #cacaca
        base.darker           #8b8391
        base.darkest          #000000
        base.fg               #000000
        base.focus            #1a497c
        base.lighter          #f0f0f0
        base.lightest         #ffffff
        button.anchor         {}
        button.padding        {5 3}
        checkbutton.focusthickness  4
        checkbutton.padding   {5 1 1 1}
        combobox.height       25
        entry.padding         {5 1}
        graphics.border       #cacaca
        graphics.color        #1a497c
        graphics.color.arrow  #ffffff
        graphics.grip         #ffffff
        graphics.sizegrip     #1a497c
        highlight.active.bg   #1a497c
        highlight.active.fg   #ffffff
        highlight.darkhighlight   #1a497c
        menubutton.padding    {5 2}
        menubutton.relief     none
        menubutton.width      {}
        notebook.tab.focusthickness  5
        notebook.tab.padding   {1 0 1 0}
        highlight.text.select.bg        #1a497c
        highlight.text.select.fg        #ffffff
    }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(base.arrow.disabled) $colors(base.darker)
    set colors(base.button.bg) $colors(base.dark)
    set colors(base.entry.box) $colors(base.dark)
    set colors(base.entry.field.bg) $colors(base.lightest)
    set colors(base.entry.field.bg.disabled) $colors(base.bg.disabled)
    set colors(base.tab.bg.active) $colors(base.dark)
    set colors(base.tab.bg.disabled) $colors(base.dark)
    set colors(base.tab.bg.inactive) $colors(base.dark)
    set colors(base.tab.bg.selected) $colors(base.dark)
    set colors(base.tab.border) $colors(base.bg)
    set colors(highlight.tab) $colors(base.darkest)
    set colors(tab.inactive) $colors(base.darker)
    set colors(tab.use.topbar) true
    set colors(text.fg) $colors(base.darkest)
    set colors(highlight.text.select.bg.inactive) $colors(base.darkest)
    #
    set colors(base.entry.fg) $colors(text.fg)
    #
    set colors(base.trough) $colors(base.entry.field.bg)
    #
    set colors(graphics.color.cb) #000000
    set colors(graphics.color.spin.bg) $colors(base.bg)
    set colors(graphics.color.spin.arrow) #000000
  }

  proc init { } {
    ::ttk::awthemes::init awlight awthemes
  }

  init
}


