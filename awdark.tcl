#!/usr/bin/tclsh
#
#

package provide awdark 7.2

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

namespace eval ::ttk::theme::awdark {

  proc setBaseColors { } {
    variable colors

    array set colors {
        anchor.button         {}
        base.bg               #33393b
        base.bg.disabled      #2d3234
        base.dark             #252a2c
        base.darker           #1b1f20
        base.darkest          #000000
        base.fg               #ffffff
        base.focus            #215d9c
        base.lighter          #525c5f
        base.lightest         #ffffff
        focusthickness.checkbutton  4
        focusthickness.notebooktab  5
        graphics.border       #000000
        graphics.color        #215d9c
        graphics.color.arrow  #ffffff
        graphics.grip         #000000
        graphics.sizegrip     #215d9c
        height.arrow          16
        height.combobox       25
        highlight.active.bg   #215d9c
        highlight.active.fg   #ffffff
        highlight.darkhighlight   #1a497c
        padding.button        {5 3}
        padding.checkbutton   {5 1 1 1}
        padding.entry         {5 1}
        padding.menubutton    {5 2}
        padding.notebooktab   {1 0 1 0}
        relief.menubutton     none
        scrollbar.grip        true
        text.select.bg        #215d9c
        text.select.fg        #ffffff
        width.menubutton      {}
    }
  }

  proc setDerivedColors { prefix } {
    variable colors

    set colors(${prefix}base.border) $colors(base.darkest)
    set colors(${prefix}base.border.disabled) \
        [::colorutils::disabledColor $colors(base.dark) $colors(base.bg) 0.8]
    set colors(${prefix}base.arrow) $colors(base.lightest)
    set colors(${prefix}base.button.bg) $colors(base.dark)
    set colors(${prefix}base.entry.bg) $colors(base.darker)
    set colors(${prefix}base.entry.bg.disabled) $colors(base.bg.disabled)
    set colors(${prefix}base.entry.box) $colors(base.dark)
    set colors(${prefix}tab.use.topbar) true
    set colors(${prefix}base.tab.bg.active) $colors(base.dark)
    set colors(${prefix}base.tab.bg.disabled) $colors(base.dark)
    set colors(${prefix}base.tab.bg.inactive) $colors(base.dark)
    set colors(${prefix}base.tab.bg.selected) $colors(base.dark)
    set colors(${prefix}base.tab.border) $colors(base.bg)
    set colors(${prefix}base.tab.highlight) #8b9ca1
    set colors(${prefix}base.tab.highlight.inactive) $colors(base.darker)
    set colors(${prefix}text.fg) $colors(base.lightest)
    set colors(${prefix}text.select.bg.inactive) $colors(base.darkest)
    #
    set colors(${prefix}base.entry.fg) $colors(text.fg)
    #
    set colors(${prefix}base.trough) $colors(base.entry.bg)
  }

  proc init { } {
    ::ttk::awthemes::init awdark awthemes
  }

  init
}
