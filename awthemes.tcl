#!/usr/bin/tclsh
#
# awdark and awlight themes
#
# Copyright 2018 Brad Lanam Walnut Creek, CA
# Copyright 2019 Brad Lanam Pleasant Hill, CA
#
# zlib/libpng license
#
# Helper routines:
#
#   ::ttk::theme::${theme}::setMenuColors .menuwidget
#     Sets the menu colors and also changes any checkbutton and
#     radiobutton types to use thematic images.
#     Side effect: The menu will have -hidemargin set to true.
#
#   ::ttk::theme::${theme}::setTextColors .textwidget ?-dark?
#     Sets the text widget colors.  If -dark is specified, the
#     background will be set to the darker color (like TEntry).
#
#   ::ttk::theme::${theme}::setListboxColors .listboxwidget
#     Sets the listbox widget colors.
#
#   ::themeutils::setThemeColors {awdark|awlight} colorname color ...
#     Allows modification of any of the colors used by awdark and awlight.
#     The graphical colors will be changed to match.
#     e.g.
#
#       package require awthemes
#       package require colorutils
#       ::themeutils::setThemeColors awdark \
#           graphics.color #007000
#       package require awdark
#     will change the graphical color to a green.
#
#     To change the user scaling:
#       awthemes uses the [tk scaling] factor multiplied by
#         the user scaling factor to determine the graphics scaling factor.
#
#       package require awthemes
#       ::themeutils::setThemeColors awdark \
#             scale.factor 1.5
#       package require awdark
#
#   ::ttk::theme::${theme}::scaledStyle \
#           name-prefix defaultfont listingfont
#     Creates a set of scaled widgets with a new style name
#     Arguments:
#         prefix for the name of the new style
#         the standard font name (default font size)
#         the font name to scale to
#
#   ::ttk::theme::${theme}::setBackground color
#     requires the colorutils package
#
#   ::ttk::theme::${theme}::getColor theme colorname
#
#   ::ttk::theme::${theme}::setHighlight color
#     requires the colorutils package
#     ** This does not work with the scalable graphics. **
#     ** May be removed at a later date **
#
# Mac OS X notes for prior to 8.6.9:
#   To style the scrollbars, use:
#        ttk::scrollbar .sb -style Vertical.TScrollbar
#     or ttk::scrollbar .sb -style Horizontal.TScrollbar
#   This will turn off the aqua styling and use the theme styling.
#   Also note that the styling for the scrollbar cannot be configured
#     afterwards, it must be configured when the scrollbar is created.
#
# 7.7 (2020-1-17)
#   - fix crash when tksvg not present.
#   - improve awdark border colors.
# 7.6 (2019-12-7)
#   - better grip design
# 7.5 (2019-12-4)
#   - reworked all .svg files.
#   - cleaned up notebook colors.
#   - fixed scaling issue with scaled style scaling.
#   - fixed combobox scaling.
#   - fixed scrollbar arrows.
#   - scaled combobox listbox scrollbar.
#   - added hasImage routine
# 7.4 (2019-12-3)
#   - added getColor routine for use by checkButtonToggle
#   - Fix menu highlight color
# 7.3 (2019-12-2)
#   - fix spinbox scaled styling
# 7.2 (2019-12-2)
#   - setBackground will not do anything if the background color is unchanged.
#   - fixed a bug with graphical buttons.
#   - make setbackground more robust.
# 7.1 (2019-12-1)
#   - fix border/padding scaling, needed for rounded buttons/tabs.
# 7.0 (2019-11-30)
#   - clean up .svg files to use alpha channel for disabled colors.
#   - calculate some disabled colors.
#   - fix doc.
#   - split out theme specific code into separate files.
#   - Fix scaledStyle set of treeview indicator.
#   - make the tab topbar a generalized option.
#   - merge themeutils package
#   - clean up notebook tabs.
#   - winxpblue: notebook tab graphics.
#   - winxpblue: disabled images.
#   - black: disabled cb/rb images.
#   - black: add labelframe color.
# 6.0 (2019-11-23)
#   - fix !focus colors
#   - slider border color
#   - various styling fixes and improvements
#   - separate scrollbar color
#   - optional scrollbar grip
#   - button images are now supported
#   - added winxpblue scalable theme
#   - fixed missing awdark and awlight labelframe
# 5.1 (2019-11-20)
#   - add more colors to support differing spinbox and scroll arrow colors.
#   - awlight, awdark, black theme cleanup
#   - rename menubutton arrow .svg files.
#   - menubutton styling fixes
# 5.0 (2019-11-19)
#   - rewrite so that the procedures are no longer duplicated.
#   - rewrite set of arrow height/width and combobox arrow height.
#   - Add scaledStyle procedure to add a scaled style to the theme.
#   - Added a user configurable scaling factor.
# 4.2.1
#   - rewrite pkgIndex.tcl
# 4.2
#   - fix scaling of images.
#   - adjust sizing for menu checkbutton and radiobutton.
#   - add support for flexmenu.
# 4.1
#   - breaking change: renamed tab.* color names to base.tab.*
#   - fix bugs in setBackground and setHighlight caused by the color
#       renaming.
#   - fix where the hover color for check and radio buttons is set.
# 4.0
#   - add support for other clam based themes.
#   - breaking change: the .svg files are now loaded from the filesystem
#       in order to support multiple themes.
#   - breaking change: All of the various colors and derived colors have
#       been renamed.
#   - awdark/awlight: Fixed empty treeview indicator.
#   - added scalable 'black' theme.
# 3.1
#   - allow user configuration of colors
# 3.0
#   - tksvg support
# 2.6
#   - Fix mac colors
# 2.5
#   - Added missing TFrame style setup.
# 2.4
#   - Some cleanup for text field background.
# 2.3
#   - Added padding for Menu.TCheckbutton and Menu.TRadiobutton styles
# 2.2
#   - Added support for flexmenu.
#   - Fixed listbox frame.
# 2.1
#   - Added Menu.TCheckbutton and Menu.TRadiobutton styles
#     to support menu creation.
# 2.0
#   - Add setBackground(), setHighlight() routines.
#     If wanted, these require the colorutils package.
#   - Removed the 'option add' statements and use a bind
#     to set the combobox's listbox colors.
#   - Merge awdark and awlight themes into a single package.
#   - More color cleanup.
#   - Make notebook top bar use dynamic colors.
# 1.4
#   - change button anchor to default to center to follow majority of themes
# 1.3
#   - clean up images a little.
# 1.2
#   - fix button press color
# 1.1
#   - per request. remove leading :: for the package name.
# 1.0
#   - more fixes for mac os x.
# 0.9
#   - changes to make it work on mac os x
# 0.8
#   - set disabled field background color for entry, spinbox, combobox.
#   - set disabled border color
# 0.7
#   - add option to text helper routine to set the darker background color.
#   - fix listbox helper routine
# 0.6
#   - fixed hover color over notebook tabs
# 0.5
#   - menubutton styling
#   - added hover images for radio/check buttons
# 0.4
#   - paned window styling
#   - clean up disabled widget color issues.
# 0.3
#   - set disabled arrowcolors
#   - fix namespace
#   - fix disabled check/radio button colors
#   - set color of scale grip and scrollbar grip to dark highlight.
# 0.2
#   - reduced height of widgets
#   - labelframe styling
#   - treeview styling
#   - remove extra outline color on notebook tabs
#   - fix non-selected color of notebook tabs
#   - added setMenuColors helper routine
#   - cleaned up the radiobutton image
#   - resized checkbutton and radiobutton images.
# 0.1
#   - initial coding
#

package provide awthemes 7.7

package require Tk
# set ::notksvg to true for testing purposes
if { ! [info exists ::notksvg] || ! $::notksvg } {
  catch { package require tksvg }
}

try {
  set iscript [info script]
  if { [file type $iscript] eq "link" } { set iscript [file link $iscript] }
  set ap [file normalize [file dirname $iscript]]
  if { $ap ni $::auto_path } {
    lappend ::auto_path $ap
  }
  set ap [file normalize [file join [file dirname $iscript] .. code]]
  if { $ap ni $::auto_path } {
    lappend ::auto_path $ap
  }
  unset ap
  unset iscript
  package require colorutils
} on error {err res} {
  puts stderr "ERROR: colorutils package is required"
}

namespace eval ::ttk::awthemes {
  proc init { theme {imagedir {}} } {

    namespace eval ::ttk::theme::${theme} {
      variable vars
      variable colors
      variable images
      variable imgdata
      variable imgtype
    }

    # set up some aliases for the theme
    interp alias {} ::ttk::theme::${theme}::scaledStyle {} ::ttk::awthemes::scaledStyle
    interp alias {} ::ttk::theme::${theme}::setBackground {} ::ttk::awthemes::setBackground
    interp alias {} ::ttk::theme::${theme}::setHighlight {} ::ttk::awthemes::setHighlight
    interp alias {} ::ttk::theme::${theme}::setListboxColors {} ::ttk::awthemes::setListboxColors
    interp alias {} ::ttk::theme::${theme}::setMenuColors {} ::ttk::awthemes::setMenuColors
    interp alias {} ::ttk::theme::${theme}::setTextColors {} ::ttk::awthemes::setTextColors
    interp alias {} ::ttk::theme::${theme}::hasImage {} ::ttk::awthemes::hasImage
    interp alias {} ::ttk::theme::${theme}::getColor {} ::ttk::awthemes::getColor

    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::${theme} $var $var
    }

    set tkscale [tk scaling]
    if { $tkscale eq "Inf" || $tkscale eq "" } {
      tk scaling -displayof . 1.3333
      set tkscale 1.3333
    }
    set calcdpi [expr {round($tkscale*72.0)}]
    set vars(scale.factor) [expr {$calcdpi/100.0}]
    set colors(scale.factor) 1.0
    set vars(theme.name) $theme

    set iscript [info script]
    if { [file type $iscript] eq "link" } { set iscript [file link $iscript] }
    set d [file dirname $iscript]
    set vars(image.dir.generic) [file join $d i generic]
    if { $imagedir eq {} } {
      set imagedir $theme
    }
    set vars(image.dir) [file join $d i $imagedir]
    set vars(cache.menu) [dict create]
    set vars(cache.text) [dict create]
    set vars(cache.listbox) [dict create]
    set vars(cache.popdown) false
    set vars(nb.img.width) 20
    set vars(nb.img.height) 3
    set vars(registered.combobox) [dict create]
    set vars(have.tksvg) false
    if { ! [catch {package present tksvg}] } {
      set vars(have.tksvg) true
    }

    # order is important
    set vars(fallback.images) {
      arrow-bg-down-d       arrow-bg-down-n
      arrow-bg-left-d       arrow-bg-left-n
      arrow-bg-right-d      arrow-bg-right-n
      arrow-bg-up-d         arrow-bg-up-n
      mb-arrow-down-n       arrow-bg-down-n
      mb-arrow-down-d       mb-arrow-down-n
      mb-arrow-down-a       mb-arrow-down-n
      combo-arrow-down-n    mb-arrow-down-n
      combo-arrow-down-d    combo-arrow-down-n
      spin-arrow-bg-down-d  arrow-bg-down-d
      spin-arrow-bg-down-n  arrow-bg-down-n
      spin-arrow-bg-up-d    arrow-bg-up-d
      spin-arrow-bg-up-n    arrow-bg-up-n
      cb-sa                 cb-sn
      cb-sd                 cb-sn
      cb-sn-small           cb-sn
      cb-ua                 cb-un
      cb-ud                 cb-un
      cb-un-small           cb-un
      rb-sa                 rb-sn
      rb-sd                 rb-sn
      rb-sn-small           rb-sn
      rb-ua                 rb-un
      rb-ud                 rb-un
      rb-un-small           rb-un
      menu-cb-sn-pad        cb-sn-small
      menu-cb-un-pad        cb-un-small
      menu-rb-sn-pad        rb-sn-small
      menu-rb-un-pad        rb-un-small
      scale-ha              scale-hn
      scale-hd              scale-hn
      scale-hp              scale-ha
      scale-va              scale-vn
      scale-vd              scale-vn
      scale-vp              scale-va
      slider-hd             slider-hn
      slider-vd             slider-vn
      button-d              button-n
      button-a              button-n
      button-p              button-n
      sb-slider-ha          sb-slider-hn
      sb-slider-hd          slider-hd
      sb-slider-hn          slider-hn
      sb-slider-hp          sb-slider-ha
      sb-slider-va          sb-slider-vn
      sb-slider-vd          slider-vd
      sb-slider-vn          slider-vn
      sb-slider-vp          sb-slider-va
      notebook-tab-a        notebook-tab-i
    }

    _setThemeBaseColors $theme

    # set up the curr.* named colors

    foreach {k} [array names colors] {
      if { [regexp {^user\.} $k] } { continue }
      set colors(curr.$k) $colors($k)
    }

    # override colors with any user.* colors
    # these are set by the ::themeutils package
    # process the base colors first, then the derived colors

    foreach {k} $::themeutils::vars(names.colors.base) {
      if { [info exists colors(user.$k)] } {
        set colors(curr.$k) $colors(user.$k)
      }
    }

    _setDerivedColors $theme

    # now override any derived colors with user-specified colors
    foreach {k} $::themeutils::vars(names.colors.derived) {
      if { [info exists colors(user.$k)] } {
        set colors(curr.$k) $colors(user.$k)
      }
    }

    # only need to do this for the requested theme
    _setImageData $theme
    _createTheme $theme
  }

  proc _setThemeBaseColors { theme } {
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::${theme} $var $var
    }

    ::ttk::theme::${theme}::setBaseColors
  }

  proc _setDerivedColors { theme } {
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::${theme} $var $var
    }

    foreach {prefix} {{} curr.} {
      # common defaults
      set colors(${prefix}parent.theme) clam
      set colors(${prefix}base.fg.disabled) \
          [::colorutils::disabledColor $colors(base.fg) $colors(base.bg) 0.65]
      set colors(${prefix}base.arrow) $colors(base.darkest)
      set colors(${prefix}base.arrow.disabled) \
          [::colorutils::disabledColor $colors(base.arrow) $colors(base.bg)]
      set colors(${prefix}base.border) $colors(base.dark)
      set colors(${prefix}base.border.dark) $colors(base.darker)
      set colors(${prefix}base.border.disabled) \
          [::colorutils::disabledColor $colors(base.border) $colors(base.bg) 0.8]
      set colors(${prefix}base.button.active) $colors(base.lighter)
      set colors(${prefix}base.button.bg) $colors(base.bg)
      set colors(${prefix}base.button.border) $colors(base.bg)
      set colors(${prefix}base.button.pressed) $colors(base.dark)
      set colors(${prefix}base.entry.bg) $colors(base.darker)
      set colors(${prefix}base.entry.bg.disabled) \
          [::colorutils::disabledColor $colors(base.entry.bg) $colors(base.bg)]
      set colors(${prefix}base.entry.box) $colors(base.lighter)
      set colors(${prefix}base.hover) $colors(base.bg)
      set colors(${prefix}base.active) $colors(base.bg)
      set colors(${prefix}base.labelframe) $colors(base.darkest)
      set colors(${prefix}focusthickness.radiobutton) $colors(focusthickness.checkbutton)
      set colors(${prefix}padding.combobox) $colors(padding.entry)
      set colors(${prefix}padding.radiobutton) $colors(padding.checkbutton)
      set colors(${prefix}padding.spinbox) $colors(padding.entry)
      set colors(${prefix}tab.use.topbar) false
      set colors(${prefix}base.tab.bg.active) $colors(base.lighter)
      set colors(${prefix}base.tab.bg.disabled) $colors(base.bg)
      set colors(${prefix}base.tab.bg.inactive) $colors(base.bg)
      set colors(${prefix}base.tab.bg.selected) $colors(base.bg)
      set colors(${prefix}base.tab.border) $colors(base.darkest)
      set colors(${prefix}base.tab.box) $colors(base.lighter)
      set colors(${prefix}tab.image.border) {2 2 2 1}
      set colors(${prefix}text.bg) $colors(base.bg)
      set colors(${prefix}text.fg) $colors(base.fg)
      set colors(${prefix}text.select.bg.inactive) $colors(base.lighter)
      set colors(${prefix}graphics.color.cb) $colors(graphics.color.arrow)
      set colors(${prefix}progressbar.color) $colors(graphics.color)
      set colors(${prefix}graphics.color.spin.border) $colors(base.darker)
      set colors(${prefix}graphics.color.spin.bg) $colors(graphics.color)
      set colors(${prefix}graphics.color.spin.arrow) $colors(graphics.color.arrow)
      #
      set colors(${prefix}base.tab.highlight) $colors(graphics.color)
      set colors(${prefix}base.tab.highlight.inactive) $colors(base.tab.bg.inactive)
      set colors(${prefix}base.tab.highlight.selected) $colors(graphics.color)
      set colors(${prefix}base.tab.highlight.disabled) $colors(base.tab.bg.disabled)
      set colors(${prefix}graphics.color.scrollbar.border) $colors(graphics.border)
      set colors(${prefix}graphics.color.scrollbar) $colors(graphics.color)
      #
      set colors(${prefix}base.slider.border) $colors(base.border)
      set colors(${prefix}base.entry.fg) $colors(text.fg)
      set colors(${prefix}base.trough) $colors(base.entry.bg)
      #
      set colors(${prefix}tree.select.bg) $colors(text.select.bg)
      set colors(${prefix}tree.select.fg) $colors(text.select.fg)

      ::ttk::theme::${theme}::setDerivedColors $prefix
    }
  }

  proc _readFile { fn } {
    set fh [open $fn]
    set fs [file size $fn]
    set data [read $fh $fs]
    close $fh
    return $data
  }

  proc _copyDerivedImageData { theme } {
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$theme $var $var
    }
    namespace upvar ::ttk::theme::$theme imgtype imgtype

    # copy some derived image files
    # if a theme has an arrow image, it should be used for all possible
    # arrow images rather than using the generics.
    dict for {n fb} $vars(fallback.images) {
      set tn $n
      while { ! [info exists imgdata($tn)] &&
          [dict exists $vars(fallback.images) $tn] } {
        set tn [dict get $vars(fallback.images) $tn]
      }
      if { $tn ne $n &&
          [info exists imgdata($tn)] } {
        set imgdata($n) $imgdata($tn)
        set imgtype($n) $imgtype($tn)
      }
    }
  }

  proc _setImageData { theme } {
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$theme $var $var
    }
    namespace upvar ::ttk::theme::$theme imgtype imgtype

    if { $vars(have.tksvg) } {
      # load theme specific .svg files
      if { [file exists $vars(image.dir)] } {
        foreach {fn} [glob -directory $vars(image.dir) *.svg] {
          if { [string match *-base* $fn] } { continue }
          set origi [file rootname [file tail $fn]]
          set imgtype($origi) svg
          set imgdata($origi) [_readFile $fn]
        }
      }
      _copyDerivedImageData $theme
      # load generic .svg files
      if { [file exists $vars(image.dir.generic)] } {
        foreach {fn} [glob -directory $vars(image.dir.generic) *.svg] {
          if { [string match *-base* $fn] } { continue }
          set origi [file rootname [file tail $fn]]
          if { ! [info exists imgtype($origi)] } {
            set imgtype($origi) svg
            set imgdata($origi) [_readFile $fn]
          }
        }
      }
      _copyDerivedImageData $theme

      # convert all the svg colors to theme specific colors

      # the scrollbar in some themes has a different color
      foreach {n} {slider-h-grip slider-v-grip
          sb-slider-ha sb-slider-hn sb-slider-hp
          sb-slider-va sb-slider-vn sb-slider-vp
          } {
        foreach {oc nc} [list \
            _GC_ \
            $colors(curr.graphics.color.scrollbar) \
            _BORD_ \
            $colors(curr.graphics.color.scrollbar.border) \
            ] {
          set c [regsub -all :$oc $imgdata($n) :$nc imgdata($n)]
        }
      }

      # the progressbar may be colored differently.
      foreach {n} {slider-hn slider-vn} {
        foreach {oc nc} [list \
            _GC_ \
            $colors(curr.progressbar.color) \
            _BORD_ \
            $colors(curr.graphics.border) \
            ] {
          set c [regsub -all :$oc $imgdata($n) :$nc imgdata($n)]
        }
      }

      # handle spin and combo arrows separately, as they may
      # have different bg/arrow colors.
      foreach {n} {spin-arrow-bg-down-d spin-arrow-bg-down-n
          spin-arrow-bg-up-d spin-arrow-bg-up-n
          combo-arrow-down-d combo-arrow-down-n
          mb-arrow-down-a mb-arrow-down-d mb-arrow-down-n
          tree-arrow-down-n tree-arrow-right-n } {
        foreach {oc nc} [list \
            _GC_ \
            $colors(curr.graphics.color.spin.bg) \
            _BORD_ \
            $colors(curr.graphics.color.spin.border) \
            _GCARR_ \
            $colors(curr.graphics.color.spin.arrow) \
            ] {
          set c [regsub -all :$oc $imgdata($n) :$nc imgdata($n)]
        }
      }

      foreach {n} [array names imgdata] {
        foreach {oc nc} [list \
            _ARROWH_ \
            $colors(height.arrow) \
            _CBOXH_ \
            $colors(height.combobox) \
            ] {
          set c [regsub -all "=\"$oc\"" $imgdata($n) "=\"$nc\"" imgdata($n)]
        }
        foreach {oc nc} [list \
            _BG_ \
            $colors(curr.base.bg) \
             _FG_ \
            $colors(curr.base.fg) \
            _DARK_ \
            $colors(curr.base.dark) \
            _GC_ \
            $colors(curr.graphics.color) \
            _GCGRAD_ \
            $colors(curr.graphics.color) \
            _GCARR_ \
            $colors(curr.graphics.color.arrow) \
            _GCCB_ \
            $colors(curr.graphics.color.cb) \
            _EBG_ \
            $colors(curr.base.entry.bg) \
            _BORD_ \
            $colors(curr.graphics.border) \
            _BORDGRAD_ \
            $colors(curr.graphics.border) \
            _BORDDARK_ \
            $colors(curr.base.border.dark) \
            _BORDD_ \
            $colors(curr.base.border.disabled) \
            _GRIP_ \
            $colors(curr.graphics.grip) \
            _GRIPGRAD_ \
            $colors(curr.graphics.grip) \
            _SZGRIP_ \
            $colors(curr.graphics.sizegrip) \
            ] {
          set c [regsub -all :$oc $imgdata($n) :$nc imgdata($n)]
        }
      }
    }

# if using tksvg, this block may be removed to make the code smaller.
#BEGIN-PNG-DATA
    if { $vars(theme.name) eq "awdark" } {
      if { ! [info exists imgdata(cb-sa)] } {
        # cb-sa
        set imgdata(cb-sa) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAB2klEQVQ4jYWSy2sTURSHv3tnmojTNJ2J
           1KWaqnXj+wUKQgmtgv+CoLgSilIX0kh0ERAfWKFRfJGFRSpUiKKoK0EEQfFdqjufaZJS6aSlLjIV
           MnNdiCPBZuYs77nfd3/ncAUgTdM8LqTsQ6nFgCK4BEL8EnCjWq2e0E3TTMfi5kCya01MaloI+6c8
           16X4+dNhpdQizTCM0a51G5ZoIbCu6+zpSdGb6mZlZ5LS1I+WqUp5te4pZYTBlmmSzQyQXLEcgPzw
           CFJKNE0Telhcy2xn8HSWpR0dADx7/oL7Dx/5fRkERyMRspm0D3+fKJG7ch2l/u05UHBw/z4/ds2Z
           5+yFIRxnvuGOL4hGIuzauYPtWzcDsG3LJvbu7gFAKcVg7hKlcuW/R/wdnEwfY+P6tczN/eRoMUN/
           3yGEEACMFu7y8vXbBVP6gmikBYB4vI3c+TPEWlsBGBv/yK3bhaZj+iN8LU74h3/hWs1h6PK1hqU1
           FbxaIGJ++CbTtt0UbhC8H/9AZXLSb7x5N8bjJ08DYQBdCOF4nhcHuHg1T2+qm5nZWe7cexAYXSmF
           67qIRCJxqs1K9C/rXGVIGfgtGuDyty9O1Z4eEYDeblnnBBzQNd1DhAvq9bompCzM2PaR3/NDnfex
           Az+KAAAAAElFTkSuQmCC
        }
      }
      if { ! [info exists imgdata(cb-sd)] } {
        # cb-sd
        set imgdata(cb-sd) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABsUlEQVQ4jY2S204TURSGv7F7NmWAbVrk
           gkjwUAFjI9cl4J0hNhpfwMQbfQVNfAZ9BhMvfAvjIRCEYExDEIWEQ22T0gg17XQOnWZme9EwkQBt
           1+X61/evQ5aRzWalGwSvwXhigEkfoaEN+r0l5QvhBu03whx4lkwmrX7gk/B977kbBBg3pqaPhkfU
           aC9ACMGd29dJpxQN2+F7YZum3TgWaBK9YKWGeHA/h1JDACytFE6khOgFjwxbPMovYA0OAPBrp8j2
           zu9Yv9QNltIkvzgXw3+O/vJ1bfNUTVeD+dzdeGzPb/Hh0zphGJ5vIKXJzPQk1ybHAZjKTJC5OQGA
           1pqPn7/hOP6ZJvEN8os5xq6kcD2fet1mLjcbF62t/6ByeHzulP+tYABgDSZ5/PAe0ux4HxxU2Nza
           u3DN2KBWa8RJKTsP6Xktllc3LoRPGRTLh2fEldUNfL/Vn0GpVKVhO7Gwu1dmv1jpCgMIDCLoXPrL
           UoFbmas0HY+tn/s9YSBKpEfT46HWs6YwTcfxKJWrVKs1oijqSnq+5xKFb0VKqZe1uh012+2nBsh+
           2moI0LxLX1av/gGvIJ2+zm/8QQAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(cb-sn)] } {
        # cb-sn
        set imgdata(cb-sn) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAB00lEQVQ4jYWSzUtUYRTGf+edrzvleLs6
           AzGuzf6CKMhqVW0iIiJoEbUONILACWtAbBE55ghFjQ1SDEUQRLSKWvRhafYXpINlIEoD3hpnrtfN
           fVuINyVn7lme8/6e85yHVwBlmmZGlLqE1jsATfMSDWtKZNy27X4xTfNaNGb0me3JhIgEsOultUfV
           th3XXR0Ty7IW2nen00FwJBLh1MkT7Ons5FelwoOxIpXFheWw1npnEJxKpbibz7G3qwuA28N5RAQl
           SsJBdpPJJI+LBTo60gC8fvOW0pOn60MB1Qw2jBj3Rod9eLY8R3bgJlr/y7mpwJXeHt92ve5wtS+D
           4zhb3vgChhHj+LGjHDnUDcDh7oOcPXMaAM/zyPTfYO77j/+W+Bnkc0Mc2L+PZdvm3PmLDGSvsxFu
           oTjOuw8ft3XpCxhGFIA2y+JZ6RGmaQIw9eUr9wsPG57pn/Btpuw3N+BarU52YBDP84IF3m9jcejO
           CItLSw3hLQJT09PMz//0BxOfJnnx8lVTGCAUj8d74y2JFq1hZrZMSCkmPk+SGxnFdd0mqKZWrbpi
           WdZgNGZcTlhtgV96M7zy5/fqmuOUBAi3tu66JYoLItI4rc241iEl8ty27Z6/RA+bmP+MCq8AAAAA
           SUVORK5CYII=
        }
      }
      if { ! [info exists imgdata(cb-ua)] } {
        # cb-ua
        set imgdata(cb-ua) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAw0lEQVQ4je3MsU4CURCF4XNmNoSs2eDs
           dpY0Wthp4uvYG22BhBfgKWwtfA8SO2s1xgQ6lvZisvcOBQkFBez2/P33E4CY2YQiT3DPATiOR5D/
           BF7rup5mZjYuBjYaXt8UonrC7kox4u/769nd+6yqanl7/3ClLfF+khI+P+ZrSe4XXTEAiAhUldJZ
           Ho7Og/MAgJAMKaXO0N0RY4TmeW6bTbgbWNkj2Rovfn9CCOGNALLLspwReMw0S2jxaJpGKfK+Xq1e
           tqAEP9PwDWwUAAAAAElFTkSuQmCC
        }
      }
      if { ! [info exists imgdata(cb-ud)] } {
        # cb-ud
        set imgdata(cb-ud) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAArUlEQVQ4je3OvQqCYBjF8XNeTbBEImiI
           JgPtttoa24WmuoDWJrsuh9oLovyON32bGiqwbPa//87zEIA28bylqjgHqj5I1KYUAHGhUNt9GK7o
           uNO1pmsL0+xa9fK1PM+S8l5u6LjusWfZQ367/PGIQppEJwHQaIoBgCQIGqKxfKsdaAeeA/IvqRQU
           IAXAXVFkaVNf3PIUYKAPbMs/X2PGMpoJoPMLrgBJMDiMR/4DiN82UH/SIRYAAAAASUVORK5CYII=
        }
      }
      if { ! [info exists imgdata(cb-un)] } {
        # cb-un
        set imgdata(cb-un) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAuElEQVQ4je2TvQ7BYBiFz3krpYRPwyC9
           DTdkl5gRN+AaDFaD22oMEp+fRCvlew0GkYi2sYlnf57pHAIQY8yEIkOo1gEoPkMFLkIurbUzGmOm
           frU2Np1uk2SO+0DV4WjtOU2TBcMwjDu9KCoqPyOK7Sbeiao2ysoAQBJCoZQ2XyrAdwH8A78SIJmo
           5v3nHQrnHLwgCMJblvX9WuAXn7TidNgn7npdEUCl1WrPKRiQdIV0VU/ItbV2dAeqdT3jjotV3gAA
           AABJRU5ErkJggg==
        }
      }

      if { ! [info exists imgdata(cb-sn-small)] } {
        # cb-sn-small
        set imgdata(cb-sn-small) {
           iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABT0lEQVQokXWRzUqCURCGn3NUjqmL9COk
           RSWmQWQGrYooupqgZRC0LaT/ougGgihpWVEiEt5BUNYiNSgolWgRiflT6mmVEH7N6mXmmZeXGeFy
           uQZtSh1JYTFAS8xLa938QOsZ4TaMK6PLOyqkOetwOOjr7SGXL/CUzWSklBbPf/DE+BiJi1OiB/v4
           fT6k1ea0ohH/wbvbGyil2Nje4TqVQkgwtR4IBlpwLJ7gMHrcmll/RWhoiNpXlefnF9aWIyilSGey
           LEWW/5hZAaanJtnb2SJ1e8d9OkOg30+xWGRufoFKtdq+UC6XAQgPhwgPhwBYjKzyksu1xZUAN7d3
           VCqVVjMWT3CZTJpeTiLQtVqNk7NzAPL5Aivrm6YwTRBuj+fa8HaPdHTYCQaCPD49Uip9trFaa97f
           Xh+E0+kOK7s8slhsnaBNf4IUuvld/2w06rM/bvF1KxpyPTUAAAAASUVORK5CYII=
        }
      }
      if { ! [info exists imgdata(cb-un-small)] } {
        # cb-un-small
        set imgdata(cb-un-small) {
           iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAi0lEQVQokd2RsQ3CMBRE75+JgmQXBAtl
           BhoKhkJisIzDAmwADUqBKGL7qKBAQabm1e9dcxZC2DZtO9BcBETMI6mMkA7WxXiKm35v/Oa+C9yu
           lzNJt67JAGBm4KLxhGBV+xURqE9/8B+BQT/bBWDJaZTqjSTkPD3M+27XLjk416wAzX9CU5nSPed0
           fALSuy0PFYJR0AAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(rb-sn-small)] } {
        # rb-sn-small
        set imgdata(rb-sn-small) {
           iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABbElEQVQokXWSsW4TURBFz7wH73nt9QJK
           YgslMU4KoM0HEEoKOgT5FGip+RMi8QEpCR8AJVBAZBykWDZC3niXt7BvKLJRbAlufTRz594RrtRy
           zr0QMc+MNV2AWMdcNR5WVfUK+AUgDXzHeX+03usPO93MLw1hkc/DdHL2tQrhETASIHHef9gcDO9a
           30a3HqDJGgBSzjDjY/6EktPRyacqhD3rWq2XG/3bj30ns/H+AXpjB1wGLkM7PfTmLvbnZ9x1m4Uy
           iBF40k5TF7f30WR9yeWFY0020K2HtNOuE8NTY61NgcbGMnwlbd8CwFjbMQr6T2pFzSAFE+t6ASDF
           j//AihQzAGKsF0bhTXGeVzJ+ixQTVhcqUk6R8TGLfB40xsPLWN9vDob3rvmEuL2Pti5ipZhiT9/x
           O5R8H518rELYu7xy4Lw/Wuv1d9KV4pTzPA+zydmXprhvy7F459xzEXNgrMkAYh3nqvF18xoVwF8b
           KZBY5e2lGwAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(rb-un-small)] } {
        # rb-un-small
        set imgdata(rb-un-small) {
           iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABG0lEQVQokY2SsU4CURBF787M7oPAroVB
           Y0iQSmu+whg7o36Kttb+iSQ2dn6FlhoLCQmaYDRhYcG3++Zhg3ELCNz6zJ3JvRPgXxURuWKWc2KK
           AcCrH6u6rnPuBsAPAAQLeD8y5mG7sdOuJ1umZIJJOrJfn8O33NojAP0AQDUy5qnZah9IGGKZXFFg
           0O+95NZ2WKLourG7d1KpVnkpDYCYEYZhMpvOAmKi01ocR6vgP9XiJGKhM2Lm+jq4tKlGc2C+6QDm
           AHnVbFPee81Ivb/Lxmm+Dp6kI6vOdf9ifWy22oerYi2KAu/93nNubYcBOFW9n2aTYxaJjalI+ehx
           mtrhx+B1Udx3UDIyInLJLBfElACAV5+qutvFa+QA8AsEQHDkbXq4nAAAAABJRU5ErkJggg==
        }
      }

      if { ! [info exists imgdata(menu-cb-sn-pad)] } {
        # cb-sn-pad
        set imgdata(menu-cb-sn-pad) {
           iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMCAYAAABSgIzaAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABZUlEQVQokXXRv0rDUBTH8e9NrmgxYGuQ
           4NBuOkj9W3wA8TV8CgcHURQRFPw/CoKLICIipdTBBxBFrK2LU6tmsAqpVmiMxabXQVoH0zMdLr8P
           9xyOMAxjoK29/UATuglKI7BEva5857tanapUKvcAImKaGbPHGhVasDGMTmLRKLZt81jIZ95LpQSA
           pml6pBWanJjgPJ1if28Xy7L4neq3JArRCq2tLiOlZH5xiXzhAbS/bOBXg/F4Ex0eHZNMpf9lZKMZ
           Gozjui7Fl1dWlheRUpLN5Vjb3A5cQzbG2lpf5fomw/NzkVg0iuM4TM/MUqvVWkPP+wRgPDEGCVBK
           MbewhOM4gai5423ujq+vavPx5DTJxeVVS9SEnueRSp8B8GTbbGzvBKfrqEYrIt3dWdPqHQ6FOujv
           6yNfKOC6n/+MUorSazH3/vY2AiDC4fCIpusHut7WBSrwpiCU739/1H1/qlwuZwF+AHh0hdcmxafz
           AAAAAElFTkSuQmCC
        }
      }
      if { ! [info exists imgdata(menu-cb-un-pad)] } {
        # cb-un-pad
        set imgdata(menu-cb-un-pad) {
           iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMCAYAAABSgIzaAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAnklEQVQoke2RzQqCYBBF78yXuBFCPqJ3
           aBe+Tgsfzudx2yv0Zxm4EXVuCzMhMqF1ZzVzuQcGRqIo2gRhmKk4D1DxETFjd2nqeldV1R4AJPY+
           96v1VnTCeUIzFOdjfiuKBABU1cVzEgCIKvqrehSEzFpjW8bxR/7iOwa+RLO2JPmtDgAgCbO2HPYF
           zdLr6ZA5FywBTvxU2HXNnWbpkDwA1ec6OAmodXwAAAAASUVORK5CYII=
        }
      }
      if { ! [info exists imgdata(menu-rb-sn-pad)] } {
        # rb-sn-pad
        set imgdata(menu-rb-sn-pad) {
           iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMCAYAAABSgIzaAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABlUlEQVQokXWRsW/TQBjFf+dL7mI3dkox
           qQitqoqhC0NZu3SElQHYWJhYWNn5C9hZETsrDEgVEgMSIxJIKKraplACauva+JLYH4ObxEXqWz7p
           3vvdu9OnmKtljHmmPO+h1noBoCiKTODNKM+fA1ktizqfPWPtu7i7fHMhjGw9kKVn4+GPw75z7i7Q
           r4NNY+3n3urarWYroFzZRoKrlZX/Qe/tMHEpg93+V+fcbeAvgLbWPl2Ku/f9sNMsNh4gi+tgIjAh
           BF2ks07j+BvNRiNyLveKyeQ9gCfwqB1FfnljC/G7tddXEj+mWNkmaLeNgnvTc09rHSqlEP/a/8xc
           /pUq7OlwBorM7r6EutA/C3mllCciAunPS2CBbAhAWZTJvLGQl8nJcaoHH1Hp4UVYBJUdofd3OEtO
           c5Hy9dRSgDbGfLq+urZpWr4qelvQXq6sbIg++MA4zxjs7X4ZVesYTUGA2Bj7dimON9qdxUApdV4o
           pMlp/vvX0feRc3eAg3rjVLpp7RMPHntaR4AqC0mgfOWcewGM6z//B5ZqmsLd48LOAAAAAElFTkSu
           QmCC
        }
      }
      if { ! [info exists imgdata(menu-rb-un-pad)] } {
        # rb-un-pad
        set imgdata(menu-rb-un-pad) {
           iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMCAYAAABSgIzaAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABR0lEQVQokY2RvU7DMBRGP9uxUwhpJH4q
           UanqwMoAD4FgZUBsLEwsrOw8ATsrYmNgZuABkBiROlUVUlWQELRpmtrxjRlo2gwFehbb0nd8fa8Z
           ZlQ8z7sQnncshAgAgIhGlOf31phLAKNSFmyy1pXvP6xt1LZWqpFfDiTDOPt467W11gcA2mVRKt9/
           rjea21IpzMNai26n3dJa7wJIAUBIKc9X12tHy0Eg51oAOOfwpKqm45TnRI8AwBnnJ2EULf0mFQRh
           qATnh9PLhBAhY+wvp1RZhNO9cws5E2Zpnru87xa0c8rjqWgNXQ++PpP/pHjQHxPZ2+LMAAil1NNm
           o7mjfH9us5kx6L52XszPdxgAEAAcEd2lSbLHGYtUpSKLYTnnMBz0x++9bstovQ/gq1yxQHApzyTn
           p1yIKgCWk4uJshtr7RWArPyKb8UjfFtWcf+KAAAAAElFTkSuQmCC
        }
      }

      if { ! [info exists imgdata(rb-sa)] } {
        # rb-sa
        set imgdata(rb-sa) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAACcUlEQVQ4jYWSzW+UVRSHn3ve9947M/2g
           9Gu0mpSgGARbSBd+sJDEvYmJ7Pkv/Bt0wRICiRt3bgzBLQvjxg2BqAuQ2k6HEUvp1JaZTjtz33nv
           PS6QhlCQszqL3/NbPOfA4Vlwzn3nvd+0zvWcc7vWuR3v/XXg0xfD5rndOueu5dZ+Of/OibHp2bqx
           zgEQY2R7q01zZblTDAa3QggXgM7zBbn1/qfZ+htL753+oGaMoEApNTCCTXugCkCrsVK01hoPixCW
           gI4B8N5fnpqpXzy5eGYEDDu19+n5twABQFGq5RbTvd8wGmmtrYYHjdVfhiF8lgHHc2uvnP3w4zGM
           8Hj8HHtujiSeZHKSyVFjKeQI+/5NxkKLiYmJvL2xPhXL8laWO/fVsePvnp+YnJRu9QQ9/zZqssNq
           DUTjKLMRRopH+ErVb7fbdclFvpicmckBdv38y+GDEsPATqNkHJ2aJqX4icSUZqvVGmoy0v/B/40i
           DLNRRASRzAgHfvW1MIAaPcgqimQij/r7exhNiJavLRBN2NgjxogmTZJS+uGfzcdDgPFBA9HhK2Gj
           iWqxiSGxvdVGxPwsRVF8+1dzrR/LkvFBk8pwC6PxMEzCxS5T+7+jqqwt3++EEL7OgG5m7ejukydL
           9bk5N1qsY4iUUsOQyLREUsFYaDHTu40h0Vi+3+/sbN+MMV569srivP/xyNHJ86fOnB3NshyAZHJA
           EC2eSlNl9Y97/Y31hytFCB8B/Wd30xjj92VZjv/dbC4aYzLrnNg8Q0gM+n02N9b17q93drvdzo0i
           hM+BwatczTvnvvGVyp/Wuo61tusrlQfe+6vAwovhfwHxTg80BiJS7QAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(rb-sd)] } {
        # rb-sd
        set imgdata(rb-sd) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAACQElEQVQ4jYWTQUtUURiGn++ce+ZeZ8bU
           tIUl6UQyCxdtKkIoXLVpYcsg2gT9g/oDLSMIcteiH9CqVQvbCO4KWwSSaKRBJQY6Os7kOTP33q+F
           Do5l+a4OfO/7cPh4P+EPjVarFcn0gQi3VXUYQETWVXlNZF6sLS2tdful620vjI8/VeR+HMdFG7nI
           yP44VyVL22kI4ZegL7+srDwEskPA1FQ09m191jl7JU56yiIdrkEFRHMAVJXg9xrtdvZ+bWT4JnNz
           qQWoFAozhcjdSnqKZTEGX67Q7L+EL10glMYIxfNgDC7dIYpcQfP8TN/2zvD21uYbqVSrVXLelXt7
           TyFCfeAyqRsAY48uRzNca4ve2gLkOY1Go47hqj09OPi4EMeT1kbiyxdpJWf/DgOIQW0CgGvXQHB5
           llqDMu2cMwC+eA49Ltz5hFhCcQSAyDmDMm1y6BcxqIlR+Xe4G6Imxoghh35zOBBET8wjuu/tyAAN
           VUUyj3AyQVBMHlBVBJpGlNksbasALvyE/0IU5zdgv1iKMmskZyb4UAco7nzCtndBj4GoYtu7FOtL
           AATv65Lz3NZqmz/6hoauoToWRTaK976jtge1DlQRzTDaohA2KNc+IOQE732q2dvVz8vPIoC9JL6L
           9wvAaBwnSWnnI9QNmS0BYLMmHNQ5BO9baevrXpLc29/JgSYmJsrNdvrKwGScJH3WRnRuQlXJspTg
           fV1V54sFd2dxcbFxBNBRZXz8BsgjVK8jB8VQzRCZR3iyurw83+3/DbK6ACz9O82sAAAAAElFTkSu
           QmCC
        }
      }
      if { ! [info exists imgdata(rb-sn)] } {
        # rb-sn
        set imgdata(rb-sn) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAACT0lEQVQ4jYWSzWtUZxTGf+e8572TzEdM
           MolGAxVq0UWx0ICICAruhYL+Lf4NuuiiG7HQTXfdFNFVQVC7dtFFoV0otGJEnMlkMnNnesd775zX
           RYyIH/XA+eBwnoeHhwMfxukY489m1jOziZnlZjY0y24DF94/lnfmGGP8UUSvrK6vd5rtjoQQAHB3
           iumU4aA/qsryUV3XV4HRuwRmZg/aS4e21o5sNEUEREhZByQgr0aQHIDhYFCOdne2q6raAkYGEGL8
           odXufLu+cbQJgm+ex1dPIrKvICVHJtuEp/dZ6XYzETaHO/3bdV1fCsCXFuzmsS+Od0SV+ckrpJWv
           wBYhZG+yAQtrpOUT6OBvFhYaNsnzLik9CmZ2baXbvbjYbKlvnCGtngKNH1orArZAaiyje0+IFhvT
           6eSIiup3zXbHAHzt64+D35Ioqb0Jaiy2WuB+TpP74ZhFUEPkf8AHoYHUWEFEEBFRIJF409LnCfZt
           fVtVVV+UVQk+R7z6LFS8RmZD3B1ScnX3X//L8wpAen/AvPw02h3G/0KaU0ynoPq71nX9095wt3B3
           tP8nkj+DjylJc2TWJzx7CMBgpzeqy/J6AMZq1i6LYqu9tJTp8DGkChrLkGpkXkJdoIO/CP/8BmnO
           oN8rZtPpPXf//uCV1czuLjZbFw8f22yr6v42ZCAB6mJfRErs9ntFPtp7UlXVWaAIBwLd/RdPaWm8
           O/gmQQgWNCjgNXVVMcnH6eXz7fzVrLhTVdVlYPYpq46b2Y0syx6b2cjMxjHLnoYYbwGn3z9+DdZ0
           +7udtE82AAAAAElFTkSuQmCC
        }
      }
      if { ! [info exists imgdata(rb-ua)] } {
        # rb-ua
        set imgdata(rb-ua) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAB0klEQVQ4jZWSu24TQRSG/zm7c2bXEZAY
           XxAFgQQiJGKQQgVIUNBAgYQEJc/BM0CdBiSadDQI8QIBKgokLk0gxtgmFwh2cFg7sJ7NzA5FhGQF
           G2W/6kjnfL/+4gD/UmHmBaVUSzJvM3NPMm8ppZ4CuLz3WAzMkpkf+lLempw+daBQKgvJDACw1qKz
           2UazVo2Sfv+11vo2gGgwwJdKPS+Vj8zNnJnNCUFDiu2yUq8lK436WqL1HIDIAwCl1HyhWL52unJu
           TAgxUgaAQxN5DwK5Xq97KbV2gQBMQYg7M7OVsf+aAxw7Ma3CMDzv+/5Vz2e+e3zq5JXxfH507yGo
           IFSddrtMPtHNfLHoZ5EBYOJwAWlqL5BN01IY5rL6ICIQeYIAOJdZ38XBgTyib/HvX5llay1c6lJK
           0/TJj9b3nawBnc02iMRLSpLk0WqzEVtj9i0759CoLkda63sEYA1CzC+9f7u934B6dTlOEr0I4JUH
           ANaYF8bsXIx+bh0tlEpMNPwlnHP4/PFDvLG+Wku0vg7AeH931trHxpiD683mWSGEJ5nJlxJCCPTj
           GK2Nr27p3Ztetxs9S7S+AaA/quEkM99XQfBJSo6klF0VBF+UUg8AVPYe/wF4NLEd4MjCaAAAAABJ
           RU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(rb-ud)] } {
        # rb-ud
        set imgdata(rb-ud) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABsUlEQVQ4jZWTMWsUURSFz7nzdmZYzWpS
           pFBQdotgo2C20iptCkGif8HGWv+DnYhYCP4AGxErO402FiksbIQMIy7LWq1x183OvHlv3rXQjUtA
           4pzqwj3f4cDlEsfU6126rBLugdhWoC2ABlUvwl1Vffhlf//9sp+Lod/vt8bT2VOB3orTdMWYFsnf
           awVQewdblhNV3WPtb+d5PvkbsLVluqPRW2PizTRN28dbLauqbGWtHUrtN/M8nwgAdIejR8aYqyfB
           ABDHSZzEyflgWi8BgBc2NnpG8fHU6ZUOyJP4I80PZ1Pnwo5IwJ04SdtNYACIk6QTRXpfSN6MTGQa
           0QBMZADFNVHqOilNeYAESAoU2pw+SoEQ/KaheYYCgIYgqvrCeeeaBtTeAZR3YhCeucoW0GYtbFlO
           gtYPJMuyoQgfF0Ux+2/YlkWAvvmaZR8iADgYj3fPrK5er4M/12rF8b9ABWCLsvC+yvx8vj2dTn20
           2P34Pn5+dm2tU1l7hcKIf25LEhoCvHdazg9/htq/UuduDAaDElj6xoW63e5FFXOX5A6g6yAJ6AEh
           r1HzSZ5//rTs/wUo28NldkL2cAAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(rb-un)] } {
        # rb-un
        set imgdata(rb-un) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABqUlEQVQ4jZWTu24TURCGv3PmHEd4bUMc
           mzhQINEHiVBBAQUVBRISlDwHzwAlogGJho4GRbwAl4oijwANkrnZ8WXXS9bZPRcKhGQFJcr+1Ugz
           36cpZuD/bFtrX4nISERyEVmIyMyYxi5w8+iwWqmttfYFqPvdfr+dtDtKRAAIIXCQ50wn49RX1Z5z
           7gGQrgqMMeZ9q3N2p7c5aCqlOC7T/f1yPhkPvfc7QKoBxNqnSbtztT/YOhEG6PZ6jfVe/6IxZhdA
           A5dV5GF/sJWcSK5kfaO3JqZxDbgtxphH57obt84kiT6tAMAYs1Ysi02NUveSdsfUgQGarRbR++s6
           hnDeNmxdHqUUSimlgUiszQMQAa21/lFWZW04hAAxBu29f/M7y6q6goM8R4l81CGEl/PZtAgh1BJM
           xr9SV5aPNTCM8Gz0/Vt+enhUBO/fAZ8EIIbwIXh/47AoLjRb7cZx1xhjZDoeFdl89sU5dwdw8q8X
           QnjtvO9k08mVGKOIMfrvMylcVbHI0vhzOFyUh8u3zrm7wPK4DS8ZY55Yaz+LSCoimVj7Vax9Dmwf
           Hf4Dx8Kr4mNF2+sAAAAASUVORK5CYII=
        }
      }
    }

    if { $vars(theme.name) eq "awlight" } {
      if { ! [info exists imgdata(cb-sa)] } {
        # cb-sa
        set imgdata(cb-sa) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAB3klEQVQ4jYWSvW9SURiHn3O4VMtH1ARb
           DJsNCXU25oZEVAbYcCaBtJONbWwhDGricPkDKJMdbIxhEId2IDGxCUxEBwY1MdXusggJKVPD1Qsc
           B9KbYOXyjuf3Pr/36wjDMOS1xevPhXRtoZQHKRROMVYC+I0Qb07POi+0q56lZ8Hg0tPogzt+t9vt
           yJ7HaDSi9enLE/WTy5pLuLai9+fDlmVRrb7j5OQHweANdna2PQft91lNqbHXveAMdzodstksx8ff
           ATAMAyklmpRCm9dut9sllXpIu90GIJVKsbHxaCJKkE6waZpkMhkbjkQilMu7CCHsHEcDwyjabft8
           Pvb3X+H1eqdybAPTNKnVatTrdQAajQaVSmWSJCV7ey8Jh8MXitg7WFtbp9lsEggEODr6QC6XR6nJ
           l8jncyQSif92aRuY5gCAXq9HIpGk3+8DEIvFKBQKM8e0R1hdvWU/nsN+v59yeRcpZ6/KVpLJ5AWx
           WDQIhUIz4SmDWOwuKys3bSEej5NOpx1hAE0IMRgOh1c0TaNUKlGtVlleDrK5+Xjq3v+GUoqhNUIb
           j9Xr1sevuei9215d19F1fW5VpRSfW98GQohDrT/oGrTV4sHbX+sLbm08lwasP5YLIQ5Pzy5t/wXP
           QKK9o+YbTwAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(cb-sd)] } {
        # cb-sd
        set imgdata(cb-sd) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABrklEQVQ4jY2TT08TQRyGn1lW2FkLpHSt
           VMWmBDQNJiRASqgGDvopJPGi8Rto4mfALyEJdw8mSCKagHrgwK3GCPInthezi0JJp9ltdjygkzRI
           u3Obed/nnXd+yYhKpdKrlFoCFoUQl0iwtNYRsCKlfGYrpV5KKR8PDaVdIUQSHoAgOHqilMIGHiaB
           W60W375859fRb1L9KSanJ9xqtbZoCyF6usH14zrv1z5yclwHYG5+5p/UY3erenpyytqbD6hGE4Dx
           4ihjt0eNbnWCwzBi/e2mgb1shlJ5qs3TMWDr07ap7UiHhQdlLKsdMbswjNj5usePgxoAezuH7O8e
           npksi/n7c7iX5blLzAzWVzfwfwZIVzKYHmDr87YxTc1OcjV35b8tTQMdxwCohmL19TuiMAIgX7hB
           8c74hc80AelM2hyGf2FH9lG6N30h3BYwks+dE2fvzuA4fckCro3k6B9IGaEwludm4XpHGMDWWsdw
           NunyQon93QPclEtx4lZXGIhtIcSy7wdPPS/jZoc9ssNeEhDfDxpCiGVba/282WzG1WrtEdDb7V9o
           rQFC4BXw4g8dNY0KDGeioAAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(cb-sn)] } {
        # cb-sn
        set imgdata(cb-sn) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABzklEQVQ4jY2Sv4oaURTGv3PvQNwZEiMb
           xUokSlgICUwzhaCVrQ8gGBHRaklwREiCUwhTWPsAIT7AWoidXVBYbLZLiCYhqSxWQa3kYmZuCtkB
           2XXMKe93ft/5d6nVarHgo/OPRPxSQqogSPiFBAEQRPR5vb21lCeBZx+ehoLvL14nH3POfdm7cF0X
           06+/3rq3MqBwYpcXr07Du90Og8EAs9kMkUgEpVJJvV7evFFcKTWu+MOLxQL1eh3T6RQAUKvVwBgD
           JyLlVLvL5RLVahXz+RwAkM1mkc/n9yIBzA8WQsA0TQ9OJBKwLAtE5OX4GnQ6Ha9tVVXRbrehqupB
           jmcghMBwOMRoNAIAjMdj9Hq9fRJjsG0b8Xj8XhFvB41GA5PJBKFQCN1uF7ZtQ8r9lyiXy0in0w92
           6RkIIQAAq9UKxWIRm80GAGAYBiqVytExvRGSyaT3eAdrmgbLssDY8VV5SiaTuSeapoloNHoUPjAw
           DAOxWMwTUqkUcrmcLwwACiPaOo4T5Jyj2Wyi3+8jHA6jUCgc3PuhcBwXiuvKTz++/a69ePlc03Ud
           uq6frAoAP7//2RKxK2UjFi0s5Nn1l3WJc+b+D+z+dTiIXa23gXf/AJaPnECURofgAAAAAElFTkSu
           QmCC
        }
      }
      if { ! [info exists imgdata(cb-ua)] } {
        # cb-ua
        set imgdata(cb-ua) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAzUlEQVQ4je3MsWrCUBiG4e/7T47ViNAO
           ihcigkJBL0Rwl3ZtCw65keLkpHehQwYVegntoi46haBJzu/k4CIJ3Urf/XkZBIE8VeofFDOCqg+h
           4l5OCeAEcnKIdmPv0W+8N5uNt26/XbPW3rXXsixDuFy/6DfKYmhG3V5+DADGGHSeWz6Igai6qi3l
           x9dEBJ4IpbC8uQC/G+B/8FcGJOM0TQtDVUWaZBDn9DNcbCLnXCG8Cr9iknPvGO8D/GhlNt0OS9bL
           dUnOiQE5P0QPrxeAzEWdFLFAUQAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(cb-ud)] } {
        # cb-ud
        set imgdata(cb-ud) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAqElEQVQ4je3OMQ6CQBSE4ZmHkpBQGPYA
           hptZSWlPYqUHsLXCmqtwCGK0XbRYAgmRZ2NhrFhrpv/+DMuyDNJ0vSeDTFVXmDCST9XXua6vB1ZV
           dYyiaGdMEpOc4qGqsLZxfd+fhOTWB38ewJgkBpAJidAHf0cAhOItfzYH5gAAiCqGf6CqAsAgAC7W
           Nq1voGkeraoWCwB513W83e4bEVlOweM4DiQL51z+BsK+Poco4SryAAAAAElFTkSuQmCC
        }
      }
      if { ! [info exists imgdata(cb-un)] } {
        # cb-un
        set imgdata(cb-un) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAwklEQVQ4je3MMWoCYRRF4XvfG8ioGCNx
           BwoKojsKpJekjUKK2Yi4ATdh5QqUBA2x1mYsZBDyv2clWMmoXfD032GSJFJ5eB6Q2nN4EYTjXA4C
           2JMcpdn6M3qMa/2nauWj1W2UVfWsPWZm+J79vNnaY1FKr9XJjwFARNBs14sUvoi5lzTKj08nSlIu
           lqcRuG2A++C/DITMQghX4RAMYubDxfx3Z2YX4eXXKiNlHG33mwQbL0wn6auq5LrYX1BQxmkWvx8A
           z/Q/zoRhgI8AAAAASUVORK5CYII=
        }
      }

      if { ! [info exists imgdata(cb-sn-small)] } {
        # cb-sn-small
        set imgdata(cb-sn-small) {
           iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABUUlEQVQokXWRv2rCcBSFv1/wX+JQfkRx
           UEGFiCKFIAWdM7m7mSC1+C4ugoOPYOkjKAQfIFCkIKWIi6BTBocWhAREuwnF9I73fudwOFckk0mj
           XC6/FQoFmUgkBBFzPp+vh8Phe7/fP4tarfa+WCyepJRRLKfTid1uh67rdLvdT0XX9cx/sOu6NBoN
           LMvC932KxeJDTAgRGWO5XNLv9wmCgMlkgmmaKIoiYlHwer3Gtm3CMMRxHAaDwe12E6xWKzRNo1Qq
           MRwOCcOQZrPJeDz+YxYDmM/n9Ho92u021WqV7XZLNptlNpuRSqXuBZqmAeB5Hp7nATCdTsnn83dx
           FYBWq4Wqqrelbdt0Op3I5hQhxFVVVRzHAaBSqTAajSLhy+WCqNfrH67rmvF4nM1mg2EYpNPpOzgI
           AizL+hJSysdcLveayWQkEPkTIcT1eDz++L7/8gv+E2ey4F2//wAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(cb-un-small)] } {
        # cb-un-small
        set imgdata(cb-un-small) {
           iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAo0lEQVQokd3RMQqDQBCF4XlT7DZCGHbB
           RguLgE26nGHPEXK2kCt4iLQ5gVsJColaWCxrOqsFrfPX34OBgdb6XFXVsygKUUqBEoUQVu/9t23b
           G+q6fjVNcxWRlN2a55mcc282xtg9TESUZRmVZXliAMkzUjEz+CjeRv8wALAexTFG4r7vP9M07eJl
           Wch7P0JELnmeP6y1QkTJnwBYh2EYu667/wAhkDBFom/zLwAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(rb-sn-small)] } {
        # rb-sn-small
        set imgdata(rb-sn-small) {
           iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAB00lEQVQokW2RPWgTYRjH/+97rUe+elFP
           jUFeL3CUxg9E6aiFFBwMZHDRgF/oVJwUydC5bkFBwSFZdDEEg4NLQKmgg0axIBRaqk0IxnBee4nv
           Nc1dQ+D6Omhqh/zW58f/eR7+BP8ZjUajd/1+/9VwODwmSRI4567ruq+azeZ9AM4uF4c0TVvM5XJb
           7XZb2LYtbNsWnHNRLBb7uq5/l2V5HAAIgBFN0xZKpdIpdjSGB8/fY6VhwfO2oUX3Yvb6NNzuBpLJ
           ZK1arZ6WIpHI7Uwmc/nsuanRG3NFzC/UYLQ6MH9vYuWHhXdfa7h0fhInjsfHKpVKiAaDwZvpdNr/
           +MUHLNXWIYTYfSpWf7Yx9/QtEonESCAQuEBDoZAiyzKW62vwxDaG0fjFAQCqqvqo+BdJKRkqAwDI
           35kQQlDHcXiv18NJ/TAkSRrq60f2AwAsy3IlSqnw+XzTM9cu7vm81MA67+78QQhBXDuIh3dSmH/z
           ul8ul58RAJQx9qlQKExOxI+RJy8/YnHVgOcJjLMDuHdlCtaaiVQq9a1er58ZbN3HGPuSzWY3TdPc
           Ka7Vaol8Pr8Vi8WWAbBBcQOoqqq3FEWZURRFIYSg0+l0HccpGIbxCEAfAP4AsTDDpD5SGF4AAAAA
           SUVORK5CYII=
        }
      }
      if { ! [info exists imgdata(rb-un-small)] } {
        # rb-un-small
        set imgdata(rb-un-small) {
           iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABOklEQVQokY3QsWrCUBQG4D9JJTQhXimB
           isMlgWsfoFtWX6JLp07SrYNv0C1TR7O4Fcd2yRNEhIZCKVJK2lFEULnBeqM49HTSSkHqD2f7/nPg
           aPhNqVar3ViWdVmpVMqGYUBKWRRF8TgcDm8BqB2LU8/zXtvt9nI2m1Ge55TnOUkpqdvtroUQmWma
           Zxt85HneS5qmW/h3siwjIcQnAMeoVqvXrVbrotFolLAntm2jXq+X+/2+owkhnnu93rlpmvv8NkEQ
           fOiO47BDMAC4rnusExEdpAEQEelKKblarQ4qTCaTQpdSRp1OZ/EfjuN4rZR6AACdc/6UJMn3vrcO
           BgPyff8dgLVZcMI5T8Mw/BqPx1s4nU4piqKl7/tvADgAaDtXddd1rxhjTcYY0zQN8/l8oZS6H41G
           dwDWAPADBOS0dhP9s/YAAAAASUVORK5CYII=
        }
      }

      if { ! [info exists imgdata(menu-cb-sn-pad)] } {
        # cb-sn-pad
        set imgdata(menu-cb-sn-pad) {
           iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMCAYAAABSgIzaAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABUklEQVQokXWRsYrCQBCGvxUDopF4aBGE
           aGFjUl2ZwsrOR1AUwSJPovgGqS3uDSxtFOz0jiuE64QQsDpDDpJq4faaSxrjwsDO8H8z8zNC13XH
           sqy3ZrPZBEoUv9/7/f4dhuE0SZIvAGzb/giCQMVxXBhhGKr9fq8ul4uybfs961RqtVovhmEUjtlu
           tziOw2g0IkkS/rcCoAyIZ9BisUBKie/79Pt9hBC5ttDT+XzOIc/zmEwmD5py9jmdTtTrdSzLwvM8
           pJS4rstqtSq0Uc7Wms1mDAYDOp0O1+sV0zTZbDZomvYcrNVqAByPRwCEEPi+j2mahVDu0XVdKpVK
           XpzP5wyHw6cQQEkpRbVaZTweA9Dr9Vgul4VipZTKwSiK4jRNWa/X7HY7DocDuq4/QGmaEkVRnOWi
           0Wi8ttvtt263a2iaVnhTKaUKguDndrtN4zj+BPgDk/mTpWV8DuoAAAAASUVORK5CYII=
        }
      }
      if { ! [info exists imgdata(menu-cb-un-pad)] } {
        # cb-un-pad
        set imgdata(menu-cb-un-pad) {
           iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMCAYAAABSgIzaAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAAqElEQVQokeWRsQqDQAyG/xPchFjOSRDn
           69QH8vF8nZZunYPgVI8UvOmg6VBtO2jt3g8yHPxfLiEmy7J9VVWttdYCSLDMfRiGa9d1zTiOFwCA
           c+7EzCoiX4uZ1Tl3nDslRVHsiGjlozdEhGmqpwjAbFoTxphXdm2nTf5CVNWfw/oRTrz3EkLYlEII
           8N7L/DZ5nh/KsmzruqY0TRdvGmNUZr71fd+IyBkAHkinWoV3DyNgAAAAAElFTkSuQmCC
        }
      }
      if { ! [info exists imgdata(menu-rb-sn-pad)] } {
        # rb-sn-pad
        set imgdata(menu-rb-sn-pad) {
           iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMCAYAAABSgIzaAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAB1klEQVQokW2RzWvTcBjHv7/UFSVZKKXM
           vqC/NHQIOsRdVBREj+ZUD0FE6cWTl10E7VVPO8ZbwUuH1lKEFv+CiuKhCPWgU4sS66jdSLulaV4W
           JuTnQZplbF944OF5ns/zwkOwr+PZbPaxIAi3k8kkDwCmaXqu674ZDAZPAXg4QllJktar1apvmiab
           TCah1ev1PVmWewDyUYAAmMvn891ms7mUyZ3C6os2fmyMwBiDnEuhXLoBx9qBoig9XdeXAewCQCyT
           yayUy2X10uUrc6Undbzt6tjctrG14+Bb38C7Tzru3LwIWaJip9PhbNtuAwDH83xJVdUTWuM91n8Z
           YIwduKG3McLqWhuKosR5nr81i3OiKM7H43F8/z06BM2kD7dBCEEikZgPwVkxR8iR0P8cBwAIgiDs
           zNm2bfm+j3PyScQ47hBECMHi6RSCIIBlWXYITqfT57VazV1Rr+J8IY1jsf3JHCE4Ky3g0b3raLVa
           vud5r6LviFFKPzYajQuFwiJ59voDPv/cAgsCnKELeHj3Gjb/DFAsFr/2+/1lAHvRjVKU0q6maa5h
           GOHzx+Mxq1Qqu5TSLwByB06I+LF0Ov1AEIT7oiiKjDHiOI7tuu7L4XCoAfgbBf8B1trLnD3kvsEA
           AAAASUVORK5CYII=
        }
      }
      if { ! [info exists imgdata(menu-rb-un-pad)] } {
        # rb-un-pad
        set imgdata(menu-rb-un-pad) {
           iVBORw0KGgoAAAANSUhEUgAAAA4AAAAMCAYAAABSgIzaAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAKnQAACp0BJpU99gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABQklEQVQokY3RMWvCQBQH8H8ihsqdh0gH
           TYVL8kH8AG4dQrcunbp0rXM/QUahi0Oto/QTdNVFhVZId3EQISbnpaGFXKekaavYP7zhjvfjHu80
           fOfENM1bSulFvV4nABAEQSylfFoul3cAYuyJaVnWot/vJ0EQqO12m9dwOPxwHOcNgP0blW3bfpnN
           Zj9AsXzfV47j+AAqGSo1m82bbrfrttvt8r5RAIBSilarxSaTiS6EeAYAnRBy6bpu5RDK0ul0DELI
           eXbWGWNVwzCOOWiahlqtVs2hUuooypKmad6sCyHCJEn+gxCGochhFEX3g8FAHoOj0SiJ4/ixeFfi
           nE/H43F66Dvm87myLGsB4M8yTjnnU8/z5Hq9zsFms1G9Xu+dc/4K4KwItOLLjUbjmlJ6xRhjSilt
           t9sJKeXDarXyAHwW4Rfhy7qDi3SfrAAAAABJRU5ErkJggg==
        }
      }

      if { ! [info exists imgdata(rb-sa)] } {
        # rb-sa
        set imgdata(rb-sa) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAC30lEQVQ4jYWRbWiVZRjHf/fL85zznJ0t
           B7WaZ20qErZ0W1s6ZA1JalAkyNqXZl9jJAgVFluFjJAIehmRfRj0QfoUhPRCMDLBo1CCq3biuJVL
           l7nyuHVqO3PuvDz3c999Upbr5f/p+vD//a+L6y+4RW+/+u42GVcHheNR61xCCuEcziil0+VSceTg
           K8+eXu0XN4bR0VGvshSNSqWfaO3YWn33hpSIxXwAjDFcmb1K5ttzheJKcbxoVd/g4EDhZsDw8LCu
           DepONm5qaO/s6khIKbHOkctfw0SW1O3VaK0AyGamKpPfn/+15FT74OBAQQPUVt35TkPj+vt3dm9P
           mMhy5KMzfHH2J0IT4ZzA04KOLSmGntrFtrZmXwiZmsz88DGwW4wMj2zSyWCi98k9NQh45o3PyM7M
           Ua6Yv/1GScnG9es4+nIfibjH58eOLxXyi71SxP2nm1u2JJSSfDCWITszvwYGiKzl59wih4+eBKBt
           +9YaPxF7QUql9jY01muAT05PUa6Ea+CbIZHlu+kc5dBQn7oLY6Kd0lpbl6yuohJGlMK1m29VxRh+
           yS2ilERpJaQA5xwIsarT/5BwAilvOB1SSJlbXlrG04og5v1vQMxXbKivxRhDFDkrIxMdu3zptxCg
           /+FWquL+v8JaSbpamtBKcmX2KkqKU7JSjt7/cXK6GIYhfbvvY0dzA4n42ks8Lbmn8Q5e3NeNc46J
           8WyhXCq9rk6kx5Ye63k8mZ9faN+4ucnv2bGZwPeY/b1AzNMkA5/bkgF7u+/ltYFH8LRiYvxcMT+X
           //K5lw68pQH+uD53yM2LtvTxr3Y9+FBnsr+nlf6eVpZXyhjrWJeMA2Ct5ZszmeLF6ZkLkVfeB6AA
           0um06+x64ENToub81IUWnFDxIC6TyYAg5nF9eYVLFy+7Uye+vvZnfuHThWKwZ2hofwn+obk3Dx9p
           Ulrs10r2RpGtcyCUVAsWN2ZL5r3nDx3Irvb/BdytK8PnPThIAAAAAElFTkSuQmCC
        }
      }
      if { ! [info exists imgdata(rb-sd)] } {
        # rb-sd
        set imgdata(rb-sd) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAACwklEQVQ4jYWTS0hUURjH/+c7Z8Y7M7e0
           F47OSEpFZfigUuwllVTQmyArIoKolSEJFdQiLtimB2WJm4LWMYtoYVBW9LAylCErpcLAHjYpldU4
           rzv33HtalKWJ9Vsd+P6//+LjOwx/caq+scDt5vuI2GbbcXIAgBN9dBx1NZE0Lxwx6t6MzLPhRygU
           4pHewdOcqz1zi+Z486bnCn2CDgCIDcXw/m1Evnj+MmHb7FJuweSD1dXV9u8CwzDEJK+/JZCXXbao
           skznnAMALGkDSsHlEgAAKW203e+IRfoGOr4m+lcbhiEFAEzx+c/lBHPKl64o9ymlcONeO+61dcK0
           LABAhtuF5RWlWFVZhmUrK/SHdx+X4Z3TAGA/O1HfMNvn9bRv2bF+ImMMZy6G8PrNB6TT1qjdZLhd
           mFUQxIG9W+E4ClcuN0cTiWQ5aZpWW1xaqBMRmm89wuvesTIAmGkLPb19uHa7DZwTSkoLdU3TaglK
           bQrmB0gphQcdXUhbY+WRJa3tz6GUQjA/QFBqEzmOneX1efB9KA4p5bjyMFJKfB+Kw+vzwHHsLBoe
           KKWg1H/9X7k/QSLGY2bKROYEH4Sgf6g/EYIja6IOM2WCMYoTCC2Rvn5FRCieOwOcxi/hRCgpnAnG
           GCJ9/YoRtZCVNBs7w11RpRS2baxCwD8VxNkYmYgQyJmK6g0roZRCZ7graiVT53nLneuRNVVrK6Ql
           8wNBv1iysAiD36KIJ1IQnCPD7YLu82B+0SzU7N4Cl0vgabg79Xngy826o/vPCgAwMbTzVXdPmDE2
           vWTBPG3PtnWQto2BT4MAgOxpkyF+nffTcHfqZXfPW4viu4ARn6nJaNJtH4U0j7a4dEFRZm6eH0L8
           lKS0EXnfjycdz6KmmW7lcXt7jVETG1UwzOnjDZUZmnZISmcZ5+AAYNuwhaDWZCJ98vCx2taR+R+G
           cynsNneqLwAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(rb-sn)] } {
        # rb-sn
        set imgdata(rb-sn) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAACyUlEQVQ4jYWRS2icVRiGn/Od/zL5TYek
           k4umjWlGW6kmxY5oW6gKokiEAWnduVQJFJRSW0hRahAXXahBVCTgxoXgRoq46MKA4wVdKPVWi8G0
           JM04TTo2M5N2Opf/P+e4iqaG6rP6Fu/zLr5X8S/efPXtURXIUZwbs85FopRzziWidSGJ21NHXz78
           5fq8Wjump6f9RiWeFq0PDt0xuKmnf7PyfQ8AYwwr5SoL54u1Vqv9XQvvqYmJ8drfBZOTk15Xqvfz
           TH8mt+Pu4UgphXWOcrVBYiy3dkdoLQAsXCi2i/OXii283MTEeM0DSIeZtzb3de++655sZKzjw5lz
           fHW2RGIMOIXWipHhHsafGGUouzUQkS2LF/44BTyipianshKFP+x56L40Cl754Ftmiyu0Y3vDb0QU
           g72dnHzmQTpCj++/+Xm1UasfEBd4z23dNhCJKE59PcdssbJBBrDWUSxf471PfwJgePtgWof+MRGR
           JzO93R7AzJmLtGOzQV7DWMevCyu0E0N3pgtr7T6x1valOkLixNJKbi6vESeG0p91RBSiRYmIOOcA
           3D+b/gcKUOuCglKXmteb+J4mFXj/WxD4wpaeTowxWOusmMR8XF6+EgPk92SJwpuXeKLIbe/H08JK
           uYqI+kKS2L1furjUMMbw+P1DjA73kgr0BtnXwrbbunh2bATnHPO/L9biVuuknimcXh17LN+5Wr2W
           6x/oCfaPDJAKPJYqdQJP05Hy2BQFPLr7do4czOF7mvm5xUatsvrZiy+98IYHUGksn7DO3nv2zOzD
           O3fd2ZnfmyW/N8v1ZkxiHekoAMA5x/nf5htLpctzLmg/DaABCoWC27f/gY+IdbpUXN6FQwehL1FH
           SOhrmo0Wl5euuHM/zl6tX61/Um3ekj9+/FBzbZUbeP21d4aUuENa5IC1tg+llCipONxp17bvHjnx
           /C/r838BIX8q3IsYTesAAAAASUVORK5CYII=
        }
      }
      if { ! [info exists imgdata(rb-ua)] } {
        # rb-ua
        set imgdata(rb-ua) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAACAUlEQVQ4jZWT30tTYRjHv+/zHs9+qANv
           VrJl4lXJ1KWJiPQHdCHE6ia6DkEoKpQmxBjhRRfRCOti0B/QjUQQBBK2RSWxYoupZRqImlmpa2vu
           nG3ved9uUoaQeD5Xz8X38+V5Lh6Gfdy7PdFBTj7CFM5KpdzEmFJQgnMtUTaN2Mita69q82x3iMfj
           dZWCFSeune/qCTQea/Uxh0MHAAghsL66gcyH2bxRMlKG5BfC4aH8XkE0GtWaXN6XLW3+7r6BHjcR
           7V9sj2xmvjL3cWHNVLw7HB7KEwA01R+572/1neo/03ugDAAdwXY9EDzpczHrCQCwWDTWpjW40qGL
           gx7OD5ZreTY5Vchv/g4Rc+qX2ztPuO3IABDsDXh0t2OUiPNz/pZmzZYNoNl3FEJY/SSl9DY01tv1
           wTmBa5wRA5RStv1/KBAj+l4sFG2rQghYlpJkCWtyZflb1W7B+uoGOLEkVcrWo89zX4xq9fAdSimk
           U9l82TTv0M3o1TUGTLyefnfoO9KpWaNSrkyPRq7PEABs7fyI/Pq5lUxMvSmKqvivKKXE+5mMsfhp
           canKS5cAgANAIpFQfQOnHwsTnoX5pU4oxp0uJ+mOOjDGsFMsYfnrikq+ePtnezP3NGe4BsfGhk2g
           5ht3uTv+4DjX2LDGKWRZ0qsAxonnJNRzaYqHNyJXsrX5vxZq0kmvqutEAAAAAElFTkSuQmCC
        }
      }
      if { ! [info exists imgdata(rb-ud)] } {
        # rb-ud
        set imgdata(rb-ud) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAABqElEQVQ4jZWTPYsTURSG3/c6ytzATMIG
           tjCFYG9hGJJYprRbVjtbLbTW1lLsRMRC8C+IhYWdcW0s8mFha7kQYV2T+VhnxuTOayEucVHXeerz
           PIdTHOIEk8nkkqS7JK8CaAAQgDXJt865R71e793mPDfEs6SeAeZaq9UMrLU0xgAAJKEoCiwWy9g5
           NyZ5PYqi+DgwGo28IAhG1vrdra2tBkn8jTiOv6dptg+gG0VRbAAgCILH1vqX2+32P2UAaDab58Iw
           7Eh6CQAcj8cXSX7odM6Hp8mbzOefk9VqtWtI3grD8NTNJ2m1mqEx5p4BsGOt79WyAfi+D0lXjKRt
           z6vtgyRI0pBUbfsYwQCYr9fr+qoEgJWR9OLo6NuqbqAoCkjaM86551mW5VVV1QosFsu4qqqHZjAY
           7JN6cnj4NftfOY6TXNKbfr//3gBAtxvdL8ty7+DgS/bztj8jCctlnCdJ8qksyxvAxjNJMtPp9AHJ
           20EQNKy1nuedAUk455DnueI4SSW9StP05nA4LH4L/GI2m11wzt0huStpGwCNMYuqql6TfBpF0cfN
           +R+IaMQGt5KnggAAAABJRU5ErkJggg==
        }
      }
      if { ! [info exists imgdata(rb-un)] } {
        # rb-un
        set imgdata(rb-un) {
           iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
           AAAOJgAADiYBou8l/AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABSdEVY
           dENvcHlyaWdodABDQyBBdHRyaWJ1dGlvbi1TaGFyZUFsaWtlIGh0dHA6Ly9jcmVhdGl2ZWNvbW1v
           bnMub3JnL2xpY2Vuc2VzL2J5LXNhLzQuMC/DVGIFAAAB8ElEQVQ4jZWTTWsTYRSFz3tn8mHE0DQ2
           BdsaG1FBUbCCUhD3LgSp7lxLoaCotDQFCYO4cCEGqS4C/gA3Iq7caepCF4rfqMVUUjOkiaFNpm2c
           TGbe97qKBqGl86zu4jyHuzkC/3HnxuxhEaRJMJ9WzBESgpnZI03Le247O3n9yovuvOgcuVwuYNfd
           HGnaueTeoR07+3tFIKADAKSUWKk1sLhgWo7Tfu1AP59Oj1t/CwzD0HvCfc/j/fGR/QeHI0IIbMTi
           D7NtFpdMB/pIOj1uEQBEQ/G7vYnY0QOHUpvKAJBMDQZ3pwYGwvAeA4DIGtkURULvTpw6FiXaXO7m
           zcuPq7bVHCMO6hcH9+yK+JEBYHjfUFQLBaaIiM7G+2K6LxtALN4DpdQoKaUS4W0hvz6IBEgjQUTE
           zL79f0UQYqn1u+VblFJCKVYkPfmoVl12/Ras1BogEnPkufyg/LNiSym3LDMzit9Llus4t2jauGwK
           QbNfPxTWt1pQLJRs13WfTWWuviIAqNvVjNVYnfv8dn5deht/wsxY+Fa0y6VKQQWdCwCgAUA+n+fR
           k8cfwtWiZbN6BAwtGApQZ0wt28GvyjJ/eT+/1lxrPmm0tp+ZmZloAV1r7HD75r2kIJ7QiMaUUgkI
           IUhQncFPua3uX8tc+tSd/wNrt9JgtBf0OwAAAABJRU5ErkJggg==
        }
      }
    }
#END-PNG-DATA
  }

  proc _mkimage { n {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }
    namespace upvar ::ttk::theme::$currtheme imgtype imgtype

    if { $vars(have.tksvg) &&
        [info exists imgtype($n)] &&
        $imgtype($n) eq "svg" &&
        [info exists imgdata($n)] } {
      set sf [expr {$vars(scale.factor)*$colors(curr.scale.factor)*$scale}]
      set images($n) [image create photo -data $imgdata($n) \
          -format "svg -scale $sf"]
    }
    if { ! [info exists images($n)] &&
        [info exists imgdata($n)] } {
      set images($n) [image create photo -data $imgdata($n)]
    }
  }

  proc _createButton { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(button-n)] } {

      # adjust the borders and padding by the scale factor
      set sf [expr {$vars(scale.factor)*$colors(curr.scale.factor)*$scale}]
      set imgbord {}
      set imgpad {}
      foreach {sz} $colors(curr.button.image.border) {
        lappend imgbord [expr {round(double($sz)*$sf)}]
      }
      foreach {sz} $colors(curr.button.image.padding) {
        lappend imgpad [expr {round(double($sz)*$sf)}]
      }

      ttk::style element create ${pfx}Button.button image \
          [list $images(button-n${sfx}) \
          disabled $images(button-d${sfx}) \
          {active !pressed !disabled} $images(button-a${sfx}) \
          {pressed !disabled} $images(button-p${sfx})] \
          -sticky nsew \
          -border $imgbord \
          -padding $imgpad

      ttk::style layout ${pfx}TButton [list \
        ${pfx}Button.button -children [list \
          Button.focus -children [list \
            Button.padding -children [list \
              Button.label -expand true \
            ] \
          ] \
        ] \
      ]
    }

    ttk::style configure ${pfx}TButton \
        -width -8 \
        -borderwidth 1 \
        -relief raised
  }

  # prefix must include the trailing dot.
  proc _createCheckButton { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    ttk::style element create ${pfx}Checkbutton.indicator image \
        [list $images(cb-un${sfx}) \
        {hover selected !disabled} $images(cb-sa${sfx}) \
        {hover !selected !disabled} $images(cb-ua${sfx}) \
        {!selected disabled} $images(cb-ud${sfx}) \
        {selected disabled} $images(cb-sd${sfx}) \
        {selected !disabled} $images(cb-sn${sfx})]

    ttk::style layout ${pfx}TCheckbutton [list \
      Checkbutton.focus -side left -sticky w -children [list \
        ${pfx}Checkbutton.indicator -side left -sticky {} \
        Checkbutton.padding -sticky nswe -children { \
          Checkbutton.label -sticky nswe \
        } \
      ]
    ]

    ttk::style configure ${pfx}TCheckbutton \
        -borderwidth 1 \
        -relief none

    ttk::style element create ${pfx}Menu.Checkbutton.indicator image \
        [list $images(cb-un-small${sfx}) \
        {selected !disabled} $images(cb-sn-small${sfx})]

    ttk::style layout ${pfx}Menu.TCheckbutton [list \
      Checkbutton.padding -sticky nswe -children [list \
        ${pfx}Menu.Checkbutton.indicator -side left -sticky {} \
      ] \
    ]
    ttk::style layout ${pfx}Flexmenu.TCheckbutton [list \
      Checkbutton.padding -sticky nswe -children [list \
        ${pfx}Menu.Checkbutton.indicator -side left -sticky {} \
      ] \
    ]

    ttk::style configure ${pfx}Menu.TCheckbutton \
        -borderwidth 0 \
        -relief none \
        -focusthickness 0
    ttk::style configure ${pfx}Flexmenu.TCheckbutton \
        -borderwidth 0 \
        -relief none \
        -focusthickness 0
  }

  proc _createCombobox { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(combo-arrow-down-n)] } {
      set sf [expr {$vars(scale.factor)*$colors(curr.scale.factor)*$scale}]
      set wid [image width $images(combo-arrow-down-n${sfx})]

      ttk::style element create ${pfx}Combobox.downarrow image \
          [list $images(combo-arrow-down-n${sfx}) \
          disabled $images(combo-arrow-down-d${sfx})] \
          -sticky e -border [list $wid 0 0 0]

      if { $pfx ne {} } {
        set layout [ttk::style layout TCombobox]
        regsub {(Combobox.downarrow)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}TCombobox $layout

        dict set vars(registered.combobox) ${pfx}TCombobox $pfx
      }
    }

    ttk::style configure ${pfx}TCombobox \
        -borderwidth 1 \
        -relief none
    if { [info exists images(combo-arrow-down-n)] } {
      set wid [image width $images(combo-arrow-down-n${sfx})]
      ttk::style configure ${pfx}TCombobox \
          -arrowsize $wid
    }
  }

  proc _createEntry { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    ttk::style configure ${pfx}TEntry \
        -borderwidth 0 \
        -relief none
  }

  proc _createLabelframe { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    ttk::style configure TLabelframe \
        -borderwidth 1 \
        -relief groove
  }

  proc _createMenubutton { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(mb-arrow-down-n)] } {
      ttk::style element create ${pfx}Menubutton.indicator image \
          [list $images(mb-arrow-down-n${sfx}) \
          disabled $images(mb-arrow-down-d${sfx}) \
          {active !disabled} $images(mb-arrow-down-a${sfx}) \
          ]

      if { $pfx ne {} } {
        set layout [ttk::style layout TMenubutton]
        regsub {(Menubutton.indicator)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}TMenubutton $layout
      }
    }

    ttk::style configure ${pfx}TMenubutton \
        -borderwidth 1
  }

  proc _createNotebook { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    _createNotebookStyle $currtheme $pfx

    if { $vars(have.tksvg) && [info exists images(notebook-tab-i)] } {
      # adjust the borders and padding by the scale factor
      set sf [expr {$vars(scale.factor)*$colors(curr.scale.factor)*$scale}]
      set imgbord {}
      foreach {sz} $colors(curr.tab.image.border) {
        lappend imgbord [expr {round(double($sz)*$sf)}]
      }

      ttk::style element create ${pfx}tab image \
          [list $images(notebook-tab-i${sfx}) \
          {selected !disabled} $images(notebook-tab-a${sfx})] \
          -border $imgbord
    }

    ttk::style configure ${pfx}TNotebook \
        -borderwidth 0
    ttk::style configure ${pfx}TNotebook.Tab \
        -borderwidth 0
    ttk::style map ${pfx}TNotebook.Tab \
        -borderwidth [list disabled 0]
  }

  proc _createPanedwindow { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    ttk::style configure Sash \
        -sashthickness 10
  }

  proc _createProgressbar { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(slider-hn)] } {
      ttk::style element create ${pfx}Horizontal.Progressbar.pbar image \
          $images(slider-hn${sfx}) \
          -border 4
      ttk::style element create ${pfx}Vertical.Progressbar.pbar image \
          $images(slider-vn${sfx}) \
          -border 4

      if { $pfx ne {} } {
        set layout [ttk::style layout Horizontal.TProgressbar]
        regsub {(Horizontal.Progressbar.pbar)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}Horizontal.TProgressbar $layout
        set layout [ttk::style layout Vertical.TProgressbar]
        regsub {(Vertical.Progressbar.pbar)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}Vertical.TProgressbar $layout
      }
    }

    ttk::style configure ${pfx}TProgressbar \
        -borderwidth 1 \
        -pbarrelief none
  }

  # prefix must include the trailing dot.
  proc _createRadioButton { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    ttk::style element create ${pfx}Radiobutton.indicator image \
        [list $images(rb-un$sfx) \
        {hover selected !disabled} $images(rb-sa$sfx) \
        {hover !selected !disabled} $images(rb-ua$sfx) \
        {!selected disabled} $images(rb-ud$sfx) \
        {selected disabled} $images(rb-sd$sfx) \
        {selected !disabled} $images(rb-sn$sfx)]

    ttk::style layout ${pfx}TRadiobutton [list \
      Radiobutton.focus -side left -sticky w -children [list \
        ${pfx}Radiobutton.indicator -side left -sticky {} \
        Radiobutton.padding -sticky nswe -children { \
          Radiobutton.label -sticky nswe \
        } \
      ] \
    ]

    ttk::style configure ${pfx}TRadiobutton \
        -borderwidth 1 \
        -relief none

    ttk::style element create ${pfx}Menu.Radiobutton.indicator image \
        [list $images(rb-un-small${sfx}) \
        {selected} $images(rb-sn-small${sfx})]

    ttk::style layout ${pfx}Menu.TRadiobutton [list \
      Radiobutton.padding -sticky nswe -children [list \
        ${pfx}Menu.Radiobutton.indicator -side left -sticky {} \
      ] \
    ]
    ttk::style layout ${pfx}Flexmenu.TRadiobutton [list \
      Radiobutton.padding -sticky nswe -children [list \
        ${pfx}Menu.Radiobutton.indicator -side left -sticky {} \
      ] \
    ]

    ttk::style configure ${pfx}Menu.TRadiobutton \
        -borderwidth 0 \
        -relief none \
        -focusthickness 0
    ttk::style configure ${pfx}Flexmenu.TRadiobutton \
        -padding $colors(curr.padding.radiobutton) \
        -borderwidth 0 \
        -relief none \
        -focusthickness 0
  }

  proc _createScale { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(scale-hn)] } {
      # using a separate image for the grip for the scale slider
      # does not work, unlike the scrollbar.
      ttk::style element create ${pfx}Horizontal.Scale.slider image \
          [list $images(scale-hn${sfx}) \
          disabled $images(scale-hd${sfx}) \
          {pressed !disabled} $images(scale-hp${sfx}) \
          {active !pressed !disabled} $images(scale-ha${sfx}) \
          ] \
          -sticky {}
      ttk::style element create ${pfx}Vertical.Scale.slider image \
          [list $images(scale-vn${sfx}) \
          disabled $images(scale-vd${sfx}) \
          {pressed !disabled} $images(scale-vp${sfx}) \
          {active !pressed !disabled} $images(scale-va${sfx}) \
          ] \
          -sticky {}

      if { $pfx ne {} } {
        set layout [ttk::style layout Horizontal.TScale]
        regsub {(Horizontal.Scale.slider)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}Horizontal.TScale $layout
        set layout [ttk::style layout Vertical.TScale]
        regsub {(Vertical.Scale.slider)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}Vertical.TScale $layout
      }
    }

    ttk::style configure TScale \
        -borderwidth 1
  }

  proc _createScrollbars { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(slider-vn)] } {
      ttk::style element create ${pfx}Vertical.Scrollbar.uparrow image \
          [list $images(arrow-bg-up-n${sfx}) \
          disabled  $images(arrow-bg-up-d${sfx})]
      ttk::style element create ${pfx}Vertical.Scrollbar.downarrow image \
          [list $images(arrow-bg-down-n${sfx}) \
          disabled  $images(arrow-bg-down-d${sfx})]
      ttk::style element create ${pfx}Vertical.Scrollbar.grip image \
          [list $images(slider-v-grip${sfx})] -sticky {}
      ttk::style element create ${pfx}Vertical.Scrollbar.thumb image \
          [list $images(sb-slider-vn${sfx}) \
          disabled $images(sb-slider-vd${sfx}) \
          {pressed !disabled} $images(sb-slider-vp${sfx}) \
          {active !pressed !disabled} $images(sb-slider-va${sfx}) \
          ] \
          -border 4 -sticky ns

      set vlayout [list \
        ${pfx}Vertical.Scrollbar.uparrow -side top -sticky {} \
        ${pfx}Vertical.Scrollbar.downarrow -side bottom -sticky {} \
        Vertical.Scrollbar.trough -sticky nsew -children [list \
          ${pfx}Vertical.Scrollbar.thumb -expand 1 -unit 1 \
          _GRIP_ \
        ] \
      ]
      set grip {}
      if { $colors(curr.scrollbar.grip) } {
        set grip "-children { [list ${pfx}Vertical.Scrollbar.grip -sticky {}] }"
      }
      regsub {_GRIP_} $vlayout $grip vlayout
      ttk::style layout ${pfx}Vertical.TScrollbar $vlayout

      ttk::style element create ${pfx}Horizontal.Scrollbar.leftarrow image \
          [list $images(arrow-bg-left-n${sfx}) \
          disabled  $images(arrow-bg-left-d${sfx})]
      ttk::style element create ${pfx}Horizontal.Scrollbar.rightarrow image \
          [list $images(arrow-bg-right-n${sfx}) \
          disabled  $images(arrow-bg-right-d${sfx})]
      ttk::style element create ${pfx}Horizontal.Scrollbar.grip image \
          [list $images(slider-h-grip${sfx})] -sticky {}
      ttk::style element create ${pfx}Horizontal.Scrollbar.thumb image \
          [list $images(sb-slider-hn${sfx}) \
          disabled $images(sb-slider-hd${sfx}) \
          {pressed !disabled} $images(sb-slider-hp${sfx}) \
          {active !pressed !disabled} $images(sb-slider-ha${sfx}) \
          ] \
          -border 4 -sticky ew

      set hlayout [list \
        ${pfx}Horizontal.Scrollbar.leftarrow -side left -sticky {} \
        ${pfx}Horizontal.Scrollbar.rightarrow -side right -sticky {} \
        Horizontal.Scrollbar.trough -sticky nsew -children [list \
          ${pfx}Horizontal.Scrollbar.thumb -expand 1 -unit 1 \
            _GRIP_ \
        ] \
      ]
      set grip {}
      if { $colors(curr.scrollbar.grip) } {
        set grip "-children { [list ${pfx}Horizontal.Scrollbar.grip -sticky {}] }"
      }
      regsub {_GRIP_} $hlayout $grip hlayout
      ttk::style layout ${pfx}Horizontal.TScrollbar $hlayout
    }

    ttk::style configure TScrollbar \
        -borderwidth 0 \
        -arrowsize 14
  }

  proc _createSizegrip { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(sizegrip)] } {
      ttk::style element create ${pfx}Sizegrip.sizegrip image $images(sizegrip${sfx})

      if { $pfx ne {} } {
        set layout [ttk::style layout TSizegrip]
        regsub {(Sizegrip.sizegrip)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}TSizegrip $layout
      }
    }
  }

  proc _createSpinbox { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(spin-arrow-bg-down-n)] } {
      ttk::style element create ${pfx}Spinbox.uparrow image \
          [list $images(spin-arrow-bg-up-n${sfx}) \
          disabled  $images(spin-arrow-bg-up-d${sfx})]
      ttk::style element create ${pfx}Spinbox.downarrow image \
          [list $images(spin-arrow-bg-down-n${sfx}) \
          disabled  $images(spin-arrow-bg-down-d${sfx})]

      if { $pfx ne {} } {
        set layout [ttk::style layout TSpinbox]
        regsub {(Spinbox.uparrow)} $layout "${pfx}\\1" layout
        regsub {(Spinbox.downarrow)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}TSpinbox $layout
      }
    }

    ttk::style configure ${pfx}TSpinbox \
        -borderwidth 1 \
        -relief none \
        -arrowsize 14
  }

  # Treeview
  #   Item
  #   Cell
  proc _createTreeview { {pfx {}} {sfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { $vars(have.tksvg) && [info exists images(tree-arrow-down-n)] } {
      ttk::style element create ${pfx}Treeitem.indicator image \
          [list $images(tree-arrow-right-n${sfx}) \
          user1 $images(tree-arrow-down-n${sfx}) \
          user2 $images(tree-arrow-empty${sfx})] \
          -sticky w

      if { $pfx ne {} } {
        set layout [ttk::style layout Item]
        regsub {(Treeitem.indicator)} $layout "${pfx}\\1" layout
        ttk::style layout ${pfx}Item $layout
      }
    }
  }

  proc _createTheme { theme } {
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$theme $var $var
    }

    # the styling is set here.
    # the images are created here.
    # the colors are set in setStyledColors (called by scaledStyle)

    bind ComboboxListbox <Map> \
        [list +::ttk::awthemes::awCboxHandler %W]

    ttk::style theme create $theme -parent $colors(parent.theme) -settings {
      scaledStyle {} {} {} $theme
    }
  }

  proc _createNotebookStyle { theme {pfx {}} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { ! $colors(curr.tab.use.topbar) } {
      return
    }

    foreach {k bg} [list \
        tabindhover $colors(curr.base.tab.highlight) \
        tabindnotactive $colors(curr.base.tab.highlight.inactive) \
        tabindselected $colors(curr.base.tab.highlight.selected) \
        tabinddisabled $colors(curr.base.tab.highlight.disabled) \
        ] {
      if { ! [info exists images(${pfx}$k)] } {
        set images(${pfx}$k) [image create photo \
            -width $vars(nb.img.width) \
            -height $vars(nb.img.height)]
        set row [lrepeat $vars(nb.img.width) $bg]
        set pix [list]
        for {set i 0} {$i < $vars(nb.img.height)} {incr i} {
          lappend pix $row
        }
        $images(${pfx}$k) put $pix
      }
    }

    if { ! [info exists vars(cache.nb.tabind.${pfx})] } {
      ttk::style element create \
         ${pfx}${theme}.Notebook.indicator image \
         [list $images(${pfx}tabindnotactive) \
         {hover active !selected !disabled} $images(${pfx}tabindhover) \
         {selected !disabled} $images(${pfx}tabindselected) \
         {disabled} $images(${pfx}tabinddisabled)]
      set vars(cache.nb.tabind.${pfx}) true
    }

    ttk::style layout ${pfx}TNotebook.Tab [list \
      Notebook.tab -sticky nswe -children [list \
        ${pfx}${theme}.Notebook.indicator -side top -sticky we \
        Notebook.padding -side top -sticky nswe -children [list \
          Notebook.focus -side top -sticky nswe -children {
            Notebook.label -side top -sticky {} \
          } \
        ] \
      ] \
    ]
  }

  proc _setStyledColors { {pfx {}} {scale 1.0} } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    set theme $vars(theme.name)

    ttk::style theme settings $theme {
      # defaults
      ttk::style configure . \
          -background $colors(curr.base.bg) \
          -bordercolor $colors(curr.base.border) \
          -borderwidth 1 \
          -darkcolor $colors(curr.base.darker) \
          -fieldbackground $colors(curr.base.entry.bg) \
          -focuscolor $colors(curr.base.focus) \
          -foreground $colors(curr.base.fg) \
          -insertcolor $colors(curr.base.entry.fg) \
          -lightcolor $colors(curr.base.lighter) \
          -relief none \
          -selectbackground $colors(curr.text.select.bg) \
          -selectborderwidth 0 \
          -selectforeground $colors(curr.text.select.fg) \
          -troughcolor $colors(curr.base.entry.bg)
      ttk::style map . \
          -background [list disabled $colors(curr.base.bg)] \
          -foreground [list disabled $colors(curr.base.fg.disabled)] \
          -selectbackground [list !focus $colors(curr.text.select.bg)] \
          -selectforeground [list !focus $colors(curr.text.select.fg)] \
          -bordercolor [list disabled $colors(curr.base.border.disabled)]

      # button

      ttk::style configure ${pfx}TButton \
          -bordercolor $colors(curr.base.button.border) \
          -background $colors(curr.base.button.bg) \
          -lightcolor $colors(curr.base.lighter) \
          -darkcolor $colors(curr.base.darker) \
          -anchor $colors(curr.anchor.button) \
          -padding $colors(curr.padding.button)
      ttk::style map ${pfx}TButton \
          -background [list \
              {hover !pressed !disabled} $colors(curr.base.button.active) \
              {active !pressed} $colors(curr.base.button.active) \
              {selected !disabled} $colors(curr.base.button.bg) \
              pressed $colors(curr.base.button.pressed) \
              disabled $colors(curr.base.bg.disabled)] \
          -lightcolor [list pressed $colors(curr.base.darker)] \
          -darkcolor [list pressed $colors(curr.base.lighter)]

      # checkbutton

      ttk::style configure ${pfx}TCheckbutton \
          -padding $colors(curr.padding.checkbutton) \
          -focusthickness $colors(curr.focusthickness.checkbutton)
      ttk::style configure ${pfx}Menu.TCheckbutton \
          -padding $colors(curr.padding.checkbutton)
      ttk::style configure ${pfx}Flexmenu.TCheckbutton \
          -padding $colors(curr.padding.checkbutton)
      ttk::style map TCheckbutton \
          -background [list {hover !disabled} $colors(curr.base.hover)] \
          -indicatorcolor [list selected $colors(curr.base.lightest)] \
          -darkcolor [list disabled $colors(curr.base.bg)] \
          -lightcolor [list disabled $colors(curr.base.bg)] \

      # combobox

      ttk::style configure ${pfx}TCombobox \
          -foreground $colors(curr.base.entry.fg) \
          -bordercolor $colors(curr.base.border) \
          -lightcolor $colors(curr.base.entry.box) \
          -arrowcolor $colors(curr.base.arrow) \
          -padding $colors(curr.padding.combobox)
      ttk::style map ${pfx}TCombobox \
          -lightcolor [list active $colors(curr.graphics.color) \
              {!focus !disabled} $colors(curr.base.entry.bg) \
              {!focus disabled} $colors(curr.base.entry.bg.disabled) \
              focus $colors(curr.base.focus)] \
          -darkcolor [list active $colors(curr.graphics.color) \
              focus $colors(curr.base.focus)] \
          -arrowcolor [list disabled $colors(curr.base.arrow.disabled)] \
          -fieldbackground [list disabled $colors(curr.base.entry.bg.disabled)]
      if { $::tcl_platform(os) eq "Darwin" } {
        # mac os x has cross-platform incompatibilities
        ttk::style configure ${pfx}TCombobox \
            -background $colors(curr.base.entry.bg)
        ttk::style map ${pfx}TCombobox \
            -lightcolor [list active $colors(curr.graphics.color) \
                {!focus !disabled} $colors(curr.base.entry.bg) \
                {!focus disabled} $colors(curr.base.entry.bg.disabled) \
                focus $colors(curr.base.focus)] \
            -darkcolor [list active $colors(curr.graphics.color) \
                focus $colors(curr.base.focus)] \
            -arrowcolor [list disabled $colors(curr.base.arrow.disabled)] \
            -background [list disabled $colors(curr.base.entry.bg.disabled)]
      }

      # entry

      ttk::style configure ${pfx}TEntry \
          -foreground $colors(curr.base.entry.fg) \
          -background $colors(curr.base.dark) \
          -bordercolor $colors(curr.base.border) \
          -lightcolor $colors(curr.base.entry.box) \
          -padding $colors(curr.padding.entry)
      ttk::style map ${pfx}TEntry \
          -lightcolor [list active $colors(curr.graphics.color) \
              {!focus !disabled} $colors(curr.base.entry.bg) \
              {!focus disabled} $colors(curr.base.entry.bg.disabled) \
              focus $colors(curr.base.focus)] \
          -fieldbackground [list disabled $colors(curr.base.entry.bg.disabled)]
      if { $::tcl_platform(os) eq "Darwin" } {
        # mac os x has cross-platform incompatibilities
        ttk::style configure ${pfx}TEntry \
            -background $colors(curr.base.dark)
        ttk::style map ${pfx}TEntry \
            -lightcolor [list active $colors(curr.graphics.color) \
                focus $colors(curr.base.focus)] \
            -background [list disabled $colors(curr.base.bg.disabled)]
      }

      # frame

      ttk::style configure ${pfx}TFrame \
          -borderwidth 1 \
          -bordercolor $colors(curr.base.bg) \
          -lightcolor $colors(curr.base.lighter) \
          -darkcolor $colors(curr.base.darker)

      # label

      # labelframe

      ttk::style configure ${pfx}TLabelframe \
          -bordercolor $colors(curr.base.labelframe) \
          -lightcolor $colors(curr.base.bg) \
          -darkcolor $colors(curr.base.bg)

      # menubutton

      ttk::style configure ${pfx}TMenubutton \
          -arrowcolor $colors(curr.base.arrow) \
          -padding $colors(curr.padding.menubutton) \
          -relief $colors(curr.relief.menubutton) \
          -width $colors(curr.width.menubutton)
      ttk::style map ${pfx}TMenubutton \
          -background [list {active !disabled} $colors(curr.base.active)] \
          -foreground [list disabled $colors(curr.base.fg.disabled)] \
          -arrowcolor [list disabled $colors(curr.base.arrow.disabled)]

      # notebook

      ttk::style configure ${pfx}TNotebook \
          -bordercolor $colors(curr.base.tab.border) \
          -lightcolor $colors(curr.base.tab.box) \
          -darkcolor $colors(curr.base.darker)
      ttk::style configure ${pfx}TNotebook.Tab \
          -lightcolor $colors(curr.base.tab.box) \
          -darkcolor $colors(curr.base.bg) \
          -bordercolor $colors(curr.base.tab.border) \
          -background $colors(curr.base.tab.bg.inactive) \
          -padding $colors(curr.padding.notebooktab) \
          -focusthickness $colors(focusthickness.notebooktab)
      ttk::style map ${pfx}TNotebook.Tab \
          -bordercolor [list disabled $colors(curr.base.tab.border)] \
          -foreground [list disabled $colors(curr.base.fg.disabled)] \
          -background [list \
              {selected !disabled} $colors(curr.base.tab.bg.selected) \
              {!selected active !disabled} $colors(curr.base.tab.bg.active) \
              {!selected !active !disabled} $colors(curr.base.tab.bg.inactive) \
              disabled $colors(curr.base.tab.bg.disabled)]

      # panedwindow

      ttk::style configure ${pfx}TPanedwindow \
          -background $colors(curr.base.dark)
      ttk::style configure Sash \
          -lightcolor $colors(curr.highlight.darkhighlight) \
          -darkcolor $colors(curr.base.darkest) \
          -sashthickness \
          [expr {round(10*$vars(scale.factor)*$colors(curr.scale.factor)*$scale)}]

      # progressbar

      ttk::style configure ${pfx}TProgressbar \
          -troughcolor $colors(curr.base.trough) \
          -background $colors(curr.highlight.darkhighlight) \
          -bordercolor $colors(curr.base.slider.border) \
          -lightcolor $colors(curr.highlight.darkhighlight) \
          -darkcolor $colors(curr.highlight.darkhighlight)
      ttk::style map ${pfx}TProgressbar \
          -troughcolor [list disabled $colors(curr.base.dark)] \
          -darkcolor [list disabled $colors(curr.base.bg.disabled)] \
          -lightcolor [list disabled $colors(curr.base.bg.disabled)]

      # radiobutton

      ttk::style configure ${pfx}TRadiobutton \
          -padding $colors(curr.padding.radiobutton) \
          -focusthickness $colors(curr.focusthickness.radiobutton)
      ttk::style configure ${pfx}Menu.TRadiobutton \
          -padding $colors(curr.padding.radiobutton)
      ttk::style configure ${pfx}Flexmenu.TRadiobutton \
          -padding $colors(curr.padding.radiobutton)
      ttk::style map ${pfx}TRadiobutton \
          -background [list {hover !disabled} $colors(curr.base.active)]

      # scale

      # background is used both for the background and
      # for the grip colors

      ttk::style configure ${pfx}TScale \
          -troughcolor $colors(curr.base.trough) \
          -background $colors(curr.highlight.darkhighlight) \
          -bordercolor $colors(curr.base.slider.border) \
          -lightcolor $colors(curr.highlight.darkhighlight) \
          -darkcolor $colors(curr.highlight.darkhighlight)
      ttk::style map TScale \
          -troughcolor [list disabled $colors(curr.base.dark)] \
          -darkcolor [list disabled $colors(curr.base.bg.disabled)] \
          -lightcolor [list disabled $colors(curr.base.bg.disabled)]

      # scrollbar

      ttk::style configure ${pfx}TScrollbar \
          -background $colors(curr.graphics.color) \
          -bordercolor $colors(curr.base.slider.border) \
          -lightcolor $colors(curr.graphics.color) \
          -darkcolor $colors(curr.graphics.color) \
          -arrowcolor $colors(curr.base.lightest) \
          -troughcolor $colors(curr.base.trough)
      ttk::style map ${pfx}TScrollbar \
          -troughcolor [list disabled $colors(curr.base.dark)] \
          -arrowcolor [list disabled $colors(curr.base.arrow.disabled)] \
          -darkcolor [list disabled $colors(curr.base.bg)] \
          -lightcolor [list disabled $colors(curr.base.bg)]

      # spinbox

      ttk::style configure ${pfx}TSpinbox \
          -foreground $colors(curr.base.entry.fg) \
          -bordercolor $colors(curr.base.border) \
          -lightcolor $colors(curr.base.entry.box) \
          -arrowcolor $colors(curr.base.arrow) \
          -padding $colors(curr.padding.spinbox)
      ttk::style map ${pfx}TSpinbox \
          -lightcolor [list active $colors(curr.graphics.color) \
              {!focus !disabled} $colors(curr.base.entry.bg) \
              {!focus disabled} $colors(curr.base.entry.bg.disabled) \
              focus $colors(curr.base.focus)] \
          -darkcolor [list active $colors(curr.graphics.color) \
              focus $colors(curr.base.focus)] \
          -arrowcolor [list disabled $colors(curr.base.arrow.disabled)] \
          -fieldbackground [list disabled $colors(curr.base.entry.bg.disabled)]
      if { $::tcl_platform(os) eq "Darwin" } {
        # mac os x has cross-platform incompatibilities
        ttk::style configure ${pfx}TSpinbox \
            -background $colors(curr.base.entry.bg)
        ttk::style map ${pfx}TSpinbox \
            -lightcolor [list active $colors(curr.graphics.color) \
                {!focus !disabled} $colors(curr.base.entry.bg) \
                {!focus disabled} $colors(curr.base.entry.bg.disabled) \
                focus $colors(curr.base.focus)] \
            -darkcolor [list active $colors(curr.graphics.color) \
                focus $colors(curr.base.focus)] \
            -arrowcolor [list disabled $colors(curr.base.arrow.disabled)] \
            -background [list disabled $colors(curr.base.entry.bg.disabled)]
      }

      # treeview

      ttk::style configure ${pfx}Treeview \
          -fieldbackground $colors(curr.base.bg) \
          -lightcolor $colors(curr.base.bg) \
          -bordercolor $colors(curr.base.border)
      ttk::style map ${pfx}Treeview \
          -background [list selected $colors(curr.tree.select.bg)] \
          -foreground [list selected $colors(curr.tree.select.fg)]
    }
  }

  proc _setColors { } {
    variable currtheme
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    _setStyledColors
    dict for {w v} $vars(cache.menu) {
      if { [winfo exists $w] } {
        setMenuColors $w
      }
    }
    dict for {w t} $vars(cache.text) {
      if { [winfo exists $w] } {
        setTextColors $w $t
      }
    }
    dict for {w v} $vars(cache.listbox) {
      if { [winfo exists $w] } {
        setListboxColors $w
      }
    }

    _createNotebookStyle $currtheme {}
  }

  proc hasImage { nm } {
    variable currtheme
    set currtheme [ttk::style theme use]
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    set rc false
    if { $vars(have.tksvg) && [info exists images($nm)] } {
      set rc true
    }
    return $rc
  }

  proc getColor { theme nm } {
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$theme $var $var
    }

    set rc {}
    if { [info exists colors($nm)] } {
      set rc $colors($nm)
    }
    return $rc
  }

  proc setBackground { bcol } {
    variable currtheme
    set currtheme [ttk::style theme use]
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { ! [package present colorutils] } {
      return
    }
    if { $colors(curr.base.bg) eq $bcol } {
      return
    }

    foreach {k} [array names colors base.*] {
      set nk curr.$k
      if { $colors($k) eq $colors(base.bg) } {
        set tc $bcol
      } elseif { $k eq "base.bg" || $colors($k) eq {} } {
        set tc $colors($k)
      } else {
        set tc [::colorutils::adjustColor $colors($k) $colors(base.bg) $bcol]
        if { $tc eq {} } {
          set tc $colors($k)
        }
      }
      set colors($nk) $tc
    }
    set colors(curr.base.bg) $bcol

    foreach {k} [array names colors highlight.*] {
      set nk curr.$k
      set tc $colors($k)
      if { $colors($k) ne {} } {
        set tc [::colorutils::adjustColor $colors($k) $colors(base.bg) $bcol]
      }
      if { $tc eq {} } {
        set tc $colors($k)
      }
      set colors($nk) $tc
    }

    _setColors
  }

  proc setHighlight { hcol } {
    variable currtheme
    set currtheme [ttk::style theme use]
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { ! [package present colorutils] } {
      return
    }

    foreach {k} [array names colors highlight.*] {
      set nk curr.$k
      set tc $colors($k)
      if { $colors($k) ne {} } {
        set tc [::colorutils::adjustColor $colors($k) $colors(graphics.color) $hcol]
      }
      if { $tc eq {} } {
        set tc $colors($k)
      }
      set colors($nk) $tc
    }

    _setColors
  }

  proc setMenuColors { w } {
    variable currtheme
    set currtheme [ttk::style theme use]
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { ! [dict exists $vars(cache.menu) $w] } {
      dict set vars(cache.menu) $w 1
    }

    $w configure -background $colors(curr.base.bg)
    $w configure -foreground $colors(curr.base.fg)
    $w configure -activebackground $colors(curr.highlight.active.bg)
    $w configure -activeforeground $colors(curr.highlight.active.fg)
    $w configure -disabledforeground $colors(curr.base.fg.disabled)
    $w configure -selectcolor $colors(curr.highlight.active.bg)

    set max [$w index end]
    if { $max eq "none" } {
      return
    }

    # the standard menu does not have a -mode option
    if { [catch {$w cget -mode}] } {
      # this does not work for mac os x standard menus.
      # it is fine for user menus or pop-ups
      for {set i 0} {$i <= $max} {incr i} {
        set type [$w type $i]
        if { $type eq "checkbutton" } {
          $w entryconfigure $i \
              -image $images(menu-cb-un-pad) \
              -selectimage $images(menu-cb-sn-pad) \
              -compound left \
              -hidemargin 1
        }
        if { $type eq "radiobutton" } {
          $w entryconfigure $i \
              -image $images(menu-rb-un-pad) \
              -selectimage $images(menu-rb-sn-pad) \
              -compound left \
              -hidemargin 1
        }
      } ; # for each menu entry
    } ; # not using flexmenu? (has -mode)
  }

  proc setListboxColors { w } {
    variable currtheme
    set currtheme [ttk::style theme use]
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { ! [dict exists $vars(cache.listbox) $w] } {
      dict set vars(cache.listbox) $w 1
    }

    $w configure -background $colors(curr.text.bg)
    $w configure -foreground $colors(curr.text.fg)
    $w configure -disabledforeground $colors(curr.base.fg.disabled)
    $w configure -selectbackground $colors(curr.text.select.bg)
    $w configure -selectforeground $colors(curr.text.select.fg)
    $w configure -borderwidth 1p
    $w configure -relief solid
  }

  proc setTextColors { w {useflag {}} } {
    variable currtheme
    set currtheme [ttk::style theme use]
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { ! [dict exists $vars(cache.text) $w] } {
      dict set vars(cache.text) $w $useflag
    }

    if { $useflag eq "-entry" } {
      $w configure -background $colors(curr.base.entry.bg)
    } elseif { $useflag eq "-dark" } {
      $w configure -background $colors(curr.base.dark)
    } else {
      $w configure -background $colors(curr.base.bg)
    }
    $w configure -background $colors(curr.text.bg)
    $w configure -foreground $colors(curr.text.fg)
    $w configure -selectforeground $colors(curr.text.select.fg)
    $w configure -selectbackground $colors(curr.text.select.bg)
    $w configure -inactiveselectbackground $colors(curr.text.select.bg.inactive)
    $w configure -borderwidth 1p
  }

  proc scaledStyle { {pfx {}} {f1 {}} {f2 {}} {theme {}} } {
    variable currtheme
    set currtheme [ttk::style theme use]
    if { $theme ne {} } {
      set currtheme $theme
    }
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }
    namespace upvar ::ttk::theme::$currtheme imgtype imgtype

    set sf 1.0
    if { $f1 ne {} && $f2 ne {} } {
      set sz1 [font metrics $f1 -ascent]
      set sz2 [font metrics $f2 -ascent]
      set sf [expr {double($sz2)/double($sz1)}]
    }
    set sfx {}
    if { $pfx ne {} } {
      set sfx -$pfx
      set pfx $pfx.
    }

    foreach {n} {cb-un cb-ud cb-sn cb-sd cb-ua cb-sa
        rb-un rb-ud rb-sn rb-sd rb-ua rb-sa
        arrow-bg-up-d arrow-bg-down-d arrow-bg-right-d arrow-bg-left-d
        arrow-bg-up-n arrow-bg-down-n arrow-bg-right-n arrow-bg-left-n
        spin-arrow-bg-down-d spin-arrow-bg-down-n
        spin-arrow-bg-up-n spin-arrow-bg-up-d
        mb-arrow-down-n mb-arrow-down-d mb-arrow-down-a
        tree-arrow-right-n tree-arrow-down-n tree-arrow-empty
        combo-arrow-down-n combo-arrow-down-d
        scale-va scale-vd scale-vn scale-vp
        scale-ha scale-hd scale-hn scale-hp
        sizegrip
        slider-h-grip slider-v-grip
        slider-vn slider-vd slider-hn slider-hd
        button-n button-a button-d button-p
        sb-slider-ha sb-slider-hd sb-slider-hn sb-slider-hp
        sb-slider-va sb-slider-vd sb-slider-vn sb-slider-vp
        notebook-tab-i notebook-tab-a
        } {
      if { $sfx ne {} && [info exists imgdata($n)] } {
        set imgdata($n${sfx}) $imgdata($n)
        set imgtype($n${sfx}) $imgtype($n)
      }
      _mkimage $n${sfx} $sf
    }

    foreach {n} {menu-cb-un-pad menu-cb-sn-pad menu-rb-un-pad menu-rb-sn-pad
        cb-un-small cb-sn-small rb-un-small rb-sn-small} {
      if { $sfx ne {} && [info exists imgdata($n)] } {
        set imgdata($n${sfx}) $imgdata($n)
        set imgtype($n${sfx}) $imgtype($n)
      }
      _mkimage $n${sfx} 0.9
    }

    ttk::style theme settings $vars(theme.name) {
      if { $vars(have.tksvg) } {
        foreach {dir} {up down left right} {
          ttk::style element create ${pfx}${dir}arrow image \
              [list $images(arrow-bg-${dir}-n${sfx}) \
              disabled $images(arrow-bg-${dir}-d${sfx}) \
              pressed $images(arrow-bg-${dir}-n${sfx}) \
              active $images(arrow-bg-${dir}-n${sfx})] \
              -border 4 -sticky news
        }
      }

      _createButton $pfx $sfx $sf
      _createCheckButton $pfx $sfx $sf
      _createCombobox $pfx $sfx $sf
      _createEntry $pfx $sfx $sf
      _createLabelframe $pfx $sfx $sf
      _createMenubutton $pfx $sfx $sf
      _createNotebook $pfx $sfx $sf
      _createProgressbar $pfx $sfx $sf
      _createRadioButton $pfx $sfx $sf
      _createScale $pfx $sfx $sf
      _createScrollbars $pfx $sfx $sf
      _createSizegrip $pfx $sfx $sf
      _createSpinbox $pfx $sfx $sf
      _createTreeview $pfx $sfx $sf
    }
    _setStyledColors $pfx $sf
  }

  proc awCboxHandler { w } {
    variable currtheme
    set currtheme [ttk::style theme use]
    foreach {var} {colors images imgdata vars} {
      namespace upvar ::ttk::theme::$currtheme $var $var
    }

    if { [info exists colors(curr.base.entry.bg)] &&
        $currtheme eq $vars(theme.name) &&
        ! [dict exists $vars(cache.listbox) $w] } {
      regsub {\.popdown\.f\.l$} $w {} cbw
      set style [$cbw cget -style]
      if { [dict exists $vars(registered.combobox) $style] } {
        set pfx [dict get $vars(registered.combobox) $style]
        set sb $cbw.popdown.f.sb
        set sborient [string totitle [$sb cget -orient]]
        set sbstyle [$sb cget -style]
        if { $sbstyle eq {} } {
          set sbstyle ${sborient}.TScrollbar
        }
        $cbw.popdown.f.sb configure -style ${pfx}${sbstyle}
      }
      ::ttk::awthemes::setListboxColors $w
    }
  }
}

# scale.factor
#   additional scaling factor (default 1.0)
#   scaling is computed based on the ttk scaling multipled by this scale factor.
# anchor.button
#   button text anchor: {} for center, e, w
# base.bg
#   background color
# base.bg.disabled
#   disabled background color
# base.dark
#   dark color
# base.darker
#   darker color
# base.darkest
#   darkest color, typically black
# base.fg
#   foreground color
# base.focus
#   focus ring color
# base.lighter
#   lighter color
# base.lightest
#   lightest color, typically white
# button.image.border
# button.image.padding
# focusthickness.checkbutton
#   thickness of the focus ring on checkbuttons
# focusthickness.notebooktab
#   thickness of the focus ring on the notebook tab
# graphics.border
#   border color for the graphics
# graphics.color
#   color for the graphics
# graphics.grip
#   grip color for scale and scrollbars
# graphics.sizegrip
#   sizegrip color
# height.arrow
#   height and width of the arrows
# height.combobox
#   height of the combobox arrow
# highlight.active.bg
#   background highlight color (for menus, menubuttons)
# highlight.active.fg
#   foreground highlight color (for menus, menubuttons)
# highlight.darkhighlight
#   dark highlight color (for sash, progress bar, scale)
# padding.button
#   button padding
# padding.checkbutton
#   checkbutton padding
# padding.entry
#   entry box padding
# padding.menubutton
#   menu button padding
# padding.notebooktab
#   notebook tab padding
# relief.menubutton
#   menubutton relief
# scrollbar.grip
#   true / false
# text.select.bg
#   selected text background
# text.select.fg
#   selected text foreground
# width.menubutton
#   menubutton width setting

# Derived Colors
#
# base.active                         base.bg
# base.arrow                          base.darkest
# base.arrow.disabled                 base.lighter
# base.border                         base.dark
# base.border.dark                    base.darker
# base.border.disabled                base.border
# base.button.active                  base.lighter
# base.button.bg                      base.bg
# base.button.border                  base.bg
# base.button.pressed                 base.dark
# base.entry.bg                       base.darker
# base.entry.bg.disabled              base.bg.disabled
# base.entry.box                      base.lighter
# base.entry.fg                       text.fg
# base.fg.disabled                    calculated: base.fg
# base.hover                          base.bg
# base.slider.border                  base.border
# base.tab.bg.active                  base.lighter
# base.tab.bg.disabled                base.bg
# base.tab.bg.inactive                base.bg
# base.tab.bg.selected                base.bg
# base.tab.border                     base.darkest
# base.tab.box                        base.lighter
# base.tab.highlight                  graphics.color
# base.tab.highlight.inactive         base.tab.bg.inactive
# base.tab.highlight.selected         graphics.color
# base.tab.highlight.disabled         base.tab.bg.disabled
# base.trough                         base.entry.bg
# focusthickness.radiobutton          focusthickness.checkbutton
# graphics.border                     base.border
# graphics.color.cb.disabled          graphics.color.arrow.disabled
# graphics.color.cb                   graphics.color.arrow
# progressbar.color                   graphics.color
# graphics.color.scrollbar.border     graphics.border
# graphics.color.scrollbar            graphics.color
# graphics.color.spin.arrow.disabled  graphics.color.arrow.disabled
# graphics.color.spin.arrow           graphics.color.arrow
# graphics.color.spin.bg              graphics.color
# graphics.color.spin.border          base.darker
# padding.combobox                    padding.entry
# padding.radiobutton                 padding.checkbutton
# padding.spinbox                     padding.entry
# text.select.bg.inactive             base.lighter
# tree.select.fg                      text.select.fg
# tree.select.bg                      text.select.bg

namespace eval ::themeutils {
  variable vars

  proc init {} {
    variable vars

      set vars(names.colors.base) {
          anchor.button
          base.bg
          base.bg.disabled
          base.dark
          base.darker
          base.darkest
          base.fg
          base.focus
          base.lighter
          base.lightest
          focusthickness.checkbutton
          focusthickness.notebooktab
          graphics.border
          graphics.color
          graphics.color.arrow
          graphics.grip
          graphics.sizegrip
          height.arrow
          height.combobox
          highlight.active.bg
          highlight.active.fg
          highlight.darkhighlight
          padding.button
          padding.checkbutton
          padding.entry
          padding.menubutton
          padding.notebooktab
          relief.menubutton
          scale.factor
          text.select.bg
          text.select.fg
          width.menubutton
          }
      set vars(names.colors.derived) {
          parent.theme
          base.active
          base.arrow
          base.arrow.disabled
          base.border
          base.border.dark
          base.border.disabled
          base.button.active
          base.button.bg
          base.button.border
          base.button.pressed
          base.entry.bg
          base.entry.bg.disabled
          base.entry.box
          base.entry.fg
          base.fg.disabled
          base.hover
          base.slider.border
          base.tab.bg.active
          base.tab.bg.disabled
          base.tab.bg.inactive
          base.tab.bg.selected
          base.tab.border
          base.tab.box
          base.tab.highlight
          base.tab.highlight.inactive
          base.tab.highlight.selected
          base.tab.highlight.disabled
          tab.use.topbar
          base.trough
          focusthickness.radiobutton
          graphics.color.cb
          progressbar.color
          graphics.color.spin.arrow
          graphics.color.spin.bg
          graphics.color.spin.border
          padding.combobox
          padding.radiobutton
          padding.spinbox
          tab.image.border
          text.select.bg.inactive
          tree.select.bg
          tree.select.fg
          }
  }

  proc setThemeColors { theme args } {
    variable vars

    namespace eval ::ttk::theme::$theme {}

    foreach {cn col} $args {
      set ::ttk::theme::${theme}::colors(user.$cn) $col
    }
  }

  init
}
