#!/usr/bin/tclsh
#
#

package provide winxpblue 7.4

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
          bg.bg.disabled      #ece9d8
          bg.bg               #ece9d8
          bg.dark             #bab5ab
          bg.darker           #9e9a91
          bg.darkest          #000000
          fg.fg               #000000
          focus.color            #c1d2ee
          bg.lighter          #f0f0ea
          bg.lightest         #ffffff
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
          selectbg.bg   #4a6984
          selectfg.fg   #ffffff
          highlight.darkhighlight     #4a6984
          menubutton.padding    {5 1}
          menubutton.relief     none
          menubutton.width      {}
          notebook.tab.focusthickness  1
          notebook.tab.padding   {4 2 4 2}
          selectbg.bg  #4a6984
          selectfg.fg  #ffffff
      }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(accent.color) #21a12a
    set colors(graphics.highlight) #e59700
    set colors(bg.active) $colors(focus.color)
    set colors(bg.button.active) $colors(focus.color)
    set colors(bg.button.border) $colors(bg.bg)
    set colors(bg.button.pressed) $colors(bg.lighter)
    set colors(entrybg.bg) $colors(bg.lightest)
    set colors(bg.hover) $colors(focus.color)
    set colors(bg.slider.border) $colors(bg.bg)
    set colors(bg.tab.inactive) $colors(bg.lighter)
    set colors(bg.tab.active) $colors(bg.bg)
    set colors(bg.tab.border) $colors(bg.bg)
    set colors(trough.color) $colors(bg.lighter)
    set colors(scale.trough) $colors(bg.lighter)
    set colors(radiobutton.padding) $colors(checkbutton.padding)
    set colors(tab.use.topbar) false
    set colors(entryfg.fg) $colors(bg.darkest)
    #
    set colors(focus.combobox) $colors(entrybg.bg)
    set colors(entrybg.bg.disabled) $colors(entrybg.bg)
    set colors(focus.entry) $colors(entrybg.bg)
    set colors(entrybg.bg) $colors(entrybg.bg)
    #
    set colors(bg.entry.fg) $colors(entryfg.fg)
    #
    set colors(tree.select.bg) $colors(bg.bg)
    set colors(tree.select.fg) $colors(fg.fg)
  }

  proc init { } {
    ::ttk::awthemes::init winxpblue
  }

  init
}
