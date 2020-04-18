#!/usr/bin/tclsh
#
#

package provide winxpblue 7.3

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

namespace eval ::ttk::theme::winxpblue {

  proc setBaseColors { } {
    variable colors

      # #ccccc2 -> #bab5ab
      # #cdcac3 -> #bab5ab
      # #21a12a accent color
      # #e59700 highlight color
      array set colors {
          style.arrow           chevron
          style.button          roundedrect-accent-gradient
          style.checkbutton     square-check-gradient
          style.combobox        -
          style.menubutton      -
          style.notebook        roundedtop-light-accent
          style.radiobutton     circle-circle-gradient
          style.treeview        -
          arrow.height          16
          base.bg.disabled      #ece9d8
          base.bg               #ece9d8
          base.dark             #bab5ab
          base.darker           #9e9a91
          base.darkest          #000000
          base.fg               #000000
          base.focus            #c1d2ee
          base.lighter          #f0f0ea
          base.lightest         #ffffff
          button.anchor         w
          button.padding        {3 3}
          checkbutton.focusthickness  1
          checkbutton.padding   {8 1 1 1}
          combobox.height       23
          entry.padding         {2 0}
          graphics.border       #9e9a91
          graphics.color.arrow  #003c74
          graphics.color        #ece9d8
          graphics.grip         #9e9a91
          graphics.sizegrip     #003c74
          highlight.active.bg   #4a6984
          highlight.active.fg   #ffffff
          highlight.darkhighlight     #4a6984
          menubutton.padding    {5 1}
          menubutton.relief     none
          menubutton.width      {}
          notebook.tab.focusthickness  1
          notebook.tab.padding   {4 2 4 2}
          highlight.text.select.bg  #4a6984
          highlight.text.select.fg  #ffffff
      }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(accent.color) #21a12a
    set colors(graphics.highlight) #e59700
    set colors(base.active) $colors(base.focus)
    set colors(base.button.active) $colors(base.focus)
    set colors(base.button.border) $colors(base.bg)
    set colors(base.button.pressed) $colors(base.lighter)
    set colors(base.entry.field.bg) $colors(base.lightest)
    set colors(base.hover) $colors(base.focus)
    set colors(base.slider.border) $colors(base.bg)
    set colors(base.tab.bg.inactive) $colors(base.lighter)
    set colors(base.tab.bg.active) $colors(base.bg)
    set colors(base.tab.border) $colors(base.bg)
    set colors(base.trough) $colors(base.lighter)
    set colors(scale.trough) $colors(base.lighter)
    set colors(radiobutton.padding) $colors(checkbutton.padding)
    set colors(tab.use.topbar) false
    set colors(text.fg) $colors(base.darkest)
    #
    set colors(base.combobox.focus) $colors(base.entry.field.bg)
    set colors(base.entry.field.bg.disabled) $colors(base.entry.field.bg)
    set colors(base.entry.focus) $colors(base.entry.field.bg)
    set colors(text.bg) $colors(base.entry.field.bg)
    #
    set colors(base.entry.fg) $colors(text.fg)
    #
    set colors(tree.select.bg) $colors(base.bg)
    set colors(tree.select.fg) $colors(base.fg)
  }

  proc init { } {
    ::ttk::awthemes::init winxpblue
  }

  init
}
