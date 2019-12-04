#!/usr/bin/tclsh
#
#

package provide winxpblue 7.1

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

      array set colors {
          anchor.button         w
          base.bg               #ece9d8
          base.bg.disabled      #ece9d8
          base.dark             #bab5ab
          base.darker           #9e9a91
          base.darkest          #000000
          base.fg               #000000
          base.focus            #c1d2ee
          base.lighter          #ffffff
          base.lightest         #ffffff
          focusthickness.checkbutton  1
          focusthickness.notebooktab  1
          graphics.border       #9e9a91
          graphics.color        #ece9d8
          graphics.color.arrow  #003c74
          graphics.grip         #9e9a91
          graphics.sizegrip     #003c74
          height.arrow          16
          height.combobox       23
          highlight.active.bg   #4a6984
          highlight.active.fg   #ffffff
          highlight.darkhighlight     #4a6984
          padding.button        {3 3}
          padding.checkbutton   {8 1 1 1}
          padding.entry         {2 0}
          padding.menubutton    {5 1}
          padding.notebooktab   {4 2 4 2}
          relief.menubutton     none
          scrollbar.grip        false
          text.select.bg        #4a6984
          text.select.fg        #ffffff
          width.menubutton      {}
      }
  }

  proc setDerivedColors { prefix } {
    variable colors

    set colors(${prefix}button.image.border) {4 9}
    set colors(${prefix}button.image.padding) {5 2}
    set colors(${prefix}base.slider.border) $colors(base.bg)
    set colors(${prefix}base.button.active) #c1d2ee
    set colors(${prefix}base.button.border) $colors(base.bg)
    set colors(${prefix}base.button.pressed) $colors(base.lighter)
    set colors(${prefix}base.entry.bg) $colors(base.lightest)
    set colors(${prefix}base.hover) #c1d2ee
    set colors(${prefix}base.active) #c1d2ee
    set colors(${prefix}base.trough) $colors(base.lightest)
    set colors(${prefix}base.labelframe) $colors(base.darker)
    set colors(${prefix}padding.radiobutton) $colors(padding.checkbutton)
    set colors(${prefix}text.fg) $colors(base.darkest)
    set colors(${prefix}tab.use.topbar) false
    set colors(${prefix}base.tab.border) $colors(base.bg)
    set colors(${prefix}base.tab.bg.active) $colors(base.tab.bg.inactive)
    set colors(${prefix}base.tab.bg.inactive) #f0f0eb
    set colors(${prefix}tab.image.border) {3 4 3 4}
    set colors(${prefix}graphics.color.scrollbar.border) #c1d2ee
    set colors(${prefix}graphics.color.scrollbar)        #c1d2ee
    #
    set colors(${prefix}base.entry.bg.disabled) $colors(base.entry.bg)
    set colors(${prefix}text.bg) $colors(base.entry.bg)
    #
    set colors(${prefix}base.entry.fg) $colors(text.fg)
    #
    set colors(${prefix}tree.select.bg) $colors(base.bg)
    set colors(${prefix}tree.select.fg) $colors(base.fg)
  }

  proc init { } {
    ::ttk::awthemes::init winxpblue
  }

  init
}


