#!/usr/bin/tclsh
#
#

package provide awlight 7.0

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
        anchor.button         {}
        base.bg               #e8e8e7
        base.bg.disabled      #cacaca
        base.dark             #cacaca
        base.darker           #8b8391
        base.darkest          #000000
        base.fg               #000000
        base.focus            #1a497c
        base.lighter          #f0f0f0
        base.lightest         #ffffff
        focusthickness.checkbutton  4
        focusthickness.notebooktab  5
        graphics.border       #cacaca
        graphics.color        #1a497c
        graphics.color.arrow  #ffffff
        graphics.grip         #ffffff
        graphics.sizegrip     #1a497c
        height.arrow          16
        height.combobox       25
        highlight.active.bg   #1a497c
        highlight.active.fg   #ffffff
        highlight.darkhighlight   #1a497c
        padding.button        {5 3}
        padding.checkbutton   {5 1 1 1}
        padding.entry         {5 1}
        padding.menubutton    {5 2}
        padding.notebooktab   {1 0 1 0}
        relief.menubutton     none
        scrollbar.grip        true
        text.select.bg        #1a497c
        text.select.fg        #ffffff
        width.menubutton      {}
    }
  }

  proc setDerivedColors { prefix } {
    variable colors

    set colors(${prefix}base.arrow.disabled) $colors(base.darker)
#    set colors(${prefix}base.border.disabled) #c0c0bd
    set colors(${prefix}base.button.bg) $colors(base.dark)
    set colors(${prefix}base.entry.bg) $colors(base.lightest)
    set colors(${prefix}base.entry.bg.disabled) $colors(base.bg.disabled)
    set colors(${prefix}base.entry.box) $colors(base.dark)
    set colors(${prefix}base.tab.use.topbar) true
    set colors(${prefix}base.tab.bg.active) $colors(base.dark)
    set colors(${prefix}base.tab.bg.disabled) $colors(base.dark)
    set colors(${prefix}base.tab.bg.inactive) $colors(base.dark)
    set colors(${prefix}base.tab.bg.selected) $colors(base.dark)
    set colors(${prefix}base.tab.border) $colors(base.bg)
    set colors(${prefix}base.tab.box) $colors(base.bg)
    set colors(${prefix}base.tab.highlight) $colors(base.darkest)
    set colors(${prefix}base.tab.highlight.inactive) $colors(base.darker)
    set colors(${prefix}text.fg) $colors(base.darkest)
    set colors(${prefix}text.select.bg.inactive) $colors(base.darkest)
    #
    set colors(${prefix}base.entry.fg) $colors(text.fg)
    #
    set colors(${prefix}base.trough) $colors(base.entry.bg)
    #
    set colors(${prefix}graphics.color.cb) #000000
    set colors(${prefix}graphics.color.spin.bg) $colors(base.bg)
    set colors(${prefix}graphics.color.spin.arrow) #000000
  }

  proc init { } {
    ::ttk::awthemes::init awlight awthemes
  }

  init
}


