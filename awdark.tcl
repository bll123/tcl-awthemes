#!/usr/bin/tclsh
#
#

package provide awdark 7.4

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
        style.checkbutton     roundedrect-check
        style.radiobutton     circle-circle-hlbg
        style.treeview        triangle-solid
        arrow.height          16
        base.bg               #33393b
        base.bg.disabled      #2d3234
        base.dark             #252a2c
        base.darker           #1b1f20
        base.darkest          #000000
        base.fg               #ffffff
        base.focus            #215d9c
        base.lighter          #525c5f
        base.lightest         #ffffff
        button.anchor         {}
        button.padding        {5 3}
        checkbutton.focusthickness  4
        checkbutton.padding   {5 1 1 1}
        combobox.height       25
        entry.padding         {5 1}
        graphics.border       #000000
        graphics.color        #215d9c
        graphics.color.arrow  #ffffff
        graphics.grip         #000000
        graphics.sizegrip     #215d9c
        highlight.active.bg   #215d9c
        highlight.active.fg   #ffffff
        highlight.darkhighlight   #1a497c
        menubutton.padding    {5 2}
        menubutton.relief     none
        menubutton.width      {}
        notebook.tab.focusthickness  5
        notebook.tab.padding   {1 0 1 0}
        highlight.text.select.bg        #215d9c
        highlight.text.select.fg        #ffffff
    }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(base.arrow) $colors(base.lightest)
    set colors(base.border) $colors(base.darkest)
    set colors(base.border.disabled) \
        [::colorutils::disabledColor $colors(base.dark) $colors(base.bg) 0.8 2]
    set colors(base.button.bg) $colors(base.dark)
    set colors(base.entry.box) $colors(base.dark)
    set colors(base.entry.field.bg) $colors(base.darker)
    set colors(base.entry.field.bg.disabled) $colors(base.bg.disabled)
    set colors(base.tab.bg.active) $colors(base.dark)
    set colors(base.tab.bg.disabled) $colors(base.dark)
    set colors(base.tab.bg.inactive) $colors(base.dark)
    set colors(base.tab.bg.selected) $colors(base.dark)
    set colors(base.tab.border) $colors(base.bg)
    set colors(highlight.tab) #8b9ca1
    set colors(tab.inactive) $colors(base.darker)
    set colors(tab.use.topbar) true
    set colors(text.fg) $colors(base.lightest)
    set colors(highlight.text.select.bg.inactive) $colors(base.darkest)
    #
    set colors(base.entry.fg) $colors(text.fg)
    #
    set colors(base.trough) $colors(base.entry.field.bg)
  }

  proc init { } {
    ::ttk::awthemes::init awdark awthemes
  }

  init
}
