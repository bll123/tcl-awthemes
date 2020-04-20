#!/usr/bin/tclsh
#
#

package provide breeze 1.2

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

namespace eval ::ttk::theme::breeze {

  proc setBaseColors { } {
    variable colors

      # original breeze base foreground is #31363b
      # I personally want as high of a contrast as is possible.
      # #3daee9 - normal graphics color
      # #93cee9 - active/pressed graphics color
      # #757778 - dark border color
      # #bbbcbe - disabled graphics color
      # #c0c2c4 - border color
      #
      # the combobox style must be set to -, otherwise the awthemes
      # default (solid-bg) is used.
      array set colors {
          style.arrow           chevron
          style.button          roundedrect-flat
          style.checkbutton     roundedrect-square
          style.combobox        -
          style.entry           roundedrect
          style.labelframe      square
          style.menubutton      chevron
          style.notebook        roundedtop-dark
          style.radiobutton     circle-circle
          style.scale           circle
          style.scrollbar-grip  none
          style.progressbar     rounded-line
          style.treeview        chevron
          arrow.height          16
          bg.bg.disabled      #e7e8ea
          bg.bg               #eff0f1
          bg.dark             #c0c2c4
          bg.darker           #757778
          bg.darkest          #000000
          fg.fg               #000000
          focus.color            #3daee9
          bg.lighter          #fcfcfc
          bg.lightest         #ffffff
          button.anchor         {}
          button.padding        {8 4}
          checkbutton.focusthickness  1
          checkbutton.padding   {4}
          combobox.height       12
          entry.padding         {2 0}
          graphics.border       #c0c2c4
          graphics.color        #3daee9
          graphics.color.arrow  #757778
          graphics.grip         #000000
          graphics.sizegrip     #3daee9
          selectbg.bg   #3daee9
          selectfg.fg   #ffffff
          highlight.darkhighlight     #eff0f1
          menubutton.padding    {8 4 4 4}
          menubutton.relief     raised
          menubutton.width      {}
          notebook.tab.focusthickness  1
          notebook.tab.padding   {12 4}
      }
  }

  proc setDerivedColors { } {
    variable colors

    set colors(bg.border) $colors(bg.dark)
    set colors(bg.button.active) $colors(bg.bg)
    set colors(bg.button.border) $colors(bg.bg)
    set colors(bg.button.pressed) $colors(bg.bg)
    set colors(bg.entry.border) $colors(bg.bg)
    set colors(entrybg.bg) $colors(bg.lighter)
    set colors(fg.fg.disabled) #bbccc3
    set colors(bg.slider.border) $colors(bg.bg)
    set colors(trough.color) $colors(bg.dark)
    set colors(button.has.focus) false
    set colors(button.relief) none
    set colors(combobox.image.border) 6
    set colors(combobox.image.padding) {8 8}
    # derive the alternate graphics color.
    set colors(graphics.color.alternate) \
        [::colorutils::disabledColor $colors(graphics.color) $colors(bg.bg) 0.5 2]
    set colors(scale.trough)  $colors(graphics.color)
    set colors(menubutton.image.padding) {7 3}
    set colors(menubutton.use.button.image) true
    set colors(parent.theme) default
    set colors(radiobutton.padding) $colors(checkbutton.padding)
    set colors(scrollbar.has.arrows) false
    set colors(slider.image.border) {4 0}
    set colors(entryfg.fg) $colors(bg.darkest)
    set colors(toolbutton.image.padding) {10 8}
    set colors(toolbutton.use.button.image) true
    #
    set colors(entrybg.bg.disabled) $colors(entrybg.bg)
    set colors(entrybg.bg) $colors(entrybg.bg)
    #
    set colors(bg.entry.fg) $colors(entryfg.fg)
  }

  proc init { } {
    ::ttk::awthemes::init breeze awbreeze
  }

  init
}
