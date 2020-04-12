#!/usr/bin/tclsh
#
#

package provide breeze 1.0

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
      array set colors {
          arrow.height          16
          base.bg.disabled      #e7e8ea
          base.bg               #eff0f1
          base.dark             #c0c2c4
          base.darker           #757778
          base.darkest          #000000
          base.fg               #000000
          base.focus            #3daee9
          base.lighter          #fcfcfc
          base.lightest         #ffffff
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
          highlight.active.bg   #3daee9
          highlight.active.fg   #ffffff
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

    set colors(base.border) $colors(base.dark)
    set colors(base.button.active) $colors(base.bg)
    set colors(base.button.border) $colors(base.bg)
    set colors(base.button.pressed) $colors(base.bg)
    set colors(base.entry.border) $colors(base.bg)
    set colors(base.entry.field.bg) $colors(base.lighter)
    set colors(base.fg.disabled) #bbccc3
    set colors(base.slider.border) $colors(base.bg)
    set colors(base.trough) $colors(base.dark)
    set colors(button.has.focus) false
    set colors(button.image.border) {6}
    set colors(button.image.padding) {6 4}
    set colors(button.relief) none
    set colors(combobox.image.border) 6
    set colors(combobox.image.padding) {8 8}
    set colors(entry.image.border) 6
    set colors(entry.image.padding) {5 8}
    # derive the alternate graphics color.
    set colors(graphics.color.alternate) \
        [::colorutils::disabledColor $colors(graphics.color) $colors(base.bg) 0.5 2]
    set colors(scale.trough)  $colors(graphics.color)
    set colors(menubutton.image.padding) {7 3}
    set colors(menubutton.use.button.image) true
    set colors(parent.theme) default
    set colors(radiobutton.padding) $colors(checkbutton.padding)
    set colors(scrollbar.has.arrows) false
    set colors(scrollbar.has.grip) false
    set colors(slider.image.border) {4 0}
    set colors(tab.image.border) {4}
    set colors(tab.image.padding) {3 2}
    set colors(text.fg) $colors(base.darkest)
    set colors(toolbutton.image.padding) {10 8}
    set colors(toolbutton.use.button.image) true
    set colors(trough.image.border) {5 0}
    #
    set colors(base.entry.field.bg.disabled) $colors(base.entry.field.bg)
    set colors(text.bg) $colors(base.entry.field.bg)
    #
    set colors(base.entry.fg) $colors(text.fg)
  }

  proc init { } {
    ::ttk::awthemes::init breeze awbreeze
  }

  init
}
