#!/usr/bin/tclsh
#
#

package provide awdark 7.5

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
        bg.bg               #33393b
        bg.bg.disabled      #2d3234
        bg.dark             #252a2c
        bg.darker           #1b1f20
        bg.darkest          #000000
        fg.fg               #ffffff
        focus.color            #215d9c
        bg.lighter          #525c5f
        bg.lightest         #ffffff
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
        selectbg.bg   #215d9c
        selectfg.fg   #ffffff
        highlight.darkhighlight   #1a497c
        menubutton.padding    {5 2}
        menubutton.relief     none
        menubutton.width      {}
        notebook.tab.focusthickness  5
        notebook.tab.padding   {1 0 1 0}
        selectbg.bg        #215d9c
        selectfg.fg        #ffffff
    }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(bg.arrow) $colors(bg.lightest)
    set colors(bg.border) $colors(bg.darkest)
    set colors(bg.border.disabled) \
        [::colorutils::disabledColor $colors(bg.dark) $colors(bg.bg) 0.8 2]
    set colors(bg.button.bg) $colors(bg.dark)
    set colors(bg.entry.box) $colors(bg.dark)
    set colors(entrybg.bg) $colors(bg.darker)
    set colors(entrybg.bg.disabled) $colors(bg.bg.disabled)
    set colors(bg.tab.active) $colors(bg.dark)
    set colors(bg.tab.disabled) $colors(bg.dark)
    set colors(bg.tab.inactive) $colors(bg.dark)
    set colors(bg.tab.selected) $colors(bg.dark)
    set colors(bg.tab.border) $colors(bg.bg)
    set colors(graphics.color.tab.hover) $colors(graphics.color)
    set colors(graphics.color.tab.inactive) $colors(bg.darker)
    set colors(tab.use.topbar) true
    set colors(entryfg.fg) $colors(bg.lightest)
    set colors(selectbg.bg.inactive) $colors(bg.darkest)
    #
    set colors(bg.entry.fg) $colors(entryfg.fg)
    #
    set colors(trough.color) $colors(entrybg.bg)
  }

  proc init { } {
    ::ttk::awthemes::init awdark awthemes
  }

  init
}
