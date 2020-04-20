#!/usr/bin/tclsh
#
#

package provide awlight 7.4

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
        style.checkbutton     roundedrect-check
        style.radiobutton     circle-circle-hlbg
        style.treeview        triangle-solid
        arrow.height          16
        bg.bg.disabled      #cacaca
        bg.bg               #e8e8e7
        bg.dark             #cacaca
        bg.darker           #8b8391
        bg.darkest          #000000
        fg.fg               #000000
        focus.color            #1a497c
        bg.lighter          #f0f0f0
        bg.lightest         #ffffff
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
        selectbg.bg   #1a497c
        selectfg.fg   #ffffff
        highlight.darkhighlight   #1a497c
        menubutton.padding    {5 2}
        menubutton.relief     none
        menubutton.width      {}
        notebook.tab.focusthickness  5
        notebook.tab.padding   {1 0 1 0}
        selectbg.bg        #1a497c
        selectfg.fg        #ffffff
    }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(bg.arrow.disabled) $colors(bg.darker)
    set colors(bg.button.bg) $colors(bg.dark)
    set colors(bg.entry.box) $colors(bg.dark)
    set colors(entrybg.bg) $colors(bg.lightest)
    set colors(entrybg.bg.disabled) $colors(bg.bg.disabled)
    set colors(bg.tab.active) $colors(bg.dark)
    set colors(bg.tab.disabled) $colors(bg.dark)
    set colors(bg.tab.inactive) $colors(bg.dark)
    set colors(bg.tab.selected) $colors(bg.dark)
    set colors(bg.tab.border) $colors(bg.bg)
    set colors(graphics.color.tab.hover) $colors(graphics.color)
    set colors(graphics.color.tab.inactive) $colors(bg.darker)
    set colors(tab.use.topbar) true
    set colors(entryfg.fg) $colors(bg.darkest)
    set colors(selectbg.bg.inactive) $colors(bg.darkest)
    #
    set colors(bg.entry.fg) $colors(entryfg.fg)
    #
    set colors(trough.color) $colors(entrybg.bg)
    set colors(scale.trough) $colors(entrybg.bg)
    #
    set colors(graphics.color.cb) #000000
    set colors(graphics.color.spin.bg) $colors(bg.bg)
    set colors(graphics.color.spin.arrow) #000000
  }

  proc init { } {
    ::ttk::awthemes::init awlight awthemes
  }

  init
}


