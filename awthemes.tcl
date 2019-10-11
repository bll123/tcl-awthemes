#!/usr/bin/tclsh
#
# awdark/awlight.tcl
#
# Copyright 2018 Brad Lanam Walnut Creek, CA
# Copyright 2019 Brad Lanam Pleasant Hill, CA
#
# zlib/libpng license
#
# Helper routines:
#
#   ::ttk::theme::awdark::setMenuColors .menuwidget
#     Sets the menu colors and also changes any checkbutton and
#     radiobutton types to use thematic images.
#     Side effect: The menu will have -hidemargin set to true.
#
#   ::ttk::theme::awdark::setTextColors .textwidget ?-dark?
#     Sets the text widget colors.  If -dark is specified, the
#     background will be set to the darker color (like TEntry).
#
#   ::ttk::theme::awdark::setListboxColors .listboxwidget
#     Sets the listbox widget colors.
#
#   ::ttk::theme::awdark::setBackground color
#     requires the colorutils package
#
#   ::ttk::theme::awdark::setHighlight color
#     requires the colorutils package
#     This does not work with the scalable graphics.
#
#   ::themeutils::setThemeColors awdark colorname color ...
#     Allows modification of any of the colors used by awdark and awlight.
#     The graphical colors will be changed to match.
#     e.g.
#       package require colorutils
#       package require themeutils
#       ::themeutils::setThemeColors awdark \
#           highlight.selectbg #007000 highlight.selectdisabledbg #222222
#       package require awdark
#     will change the selection and graphical colors to a green, and the
#     the disabled selection color to a dark grey.
#
# Mac OS X notes for prior to 8.6.9:
#   To style the scrollbars, use:
#        ttk::scrollbar .sb -style Vertical.TScrollbar
#     or ttk::scrollbar .sb -style Horizontal.TScrollbar
#   This will turn off the aqua styling and use the theme styling.
#   Also note that the styling for the scrollbar cannot be configured
#     afterwards, it must be configured when the scrollbar is created.
#
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

package require Tk
catch { package require tksvg }

try {
  set ap [file normalize [file dirname [info script]]]
  if { $ap ni $::auto_path } {
    lappend ::auto_path $ap
  }
  unset ap
  package require colorutils
  package require themeutils
} on error {err res} {
  puts stderr "ERROR: colorutlis and themeutils packages are required"
}

proc awinit { } {
  global awthemename

  foreach awthemename {awdark awlight} {
    package provide $awthemename 3.1

    namespace eval ::ttk::theme::$awthemename {
      variable colors
      variable images
      variable imgdata
      variable vars

      proc init { } {
        variable colors
        variable vars

        set tkscale [tk scaling]
        if { $tkscale eq "Inf" || $tkscale eq "" } {
          tk scaling -displayof . 1.3333
          set tkscale 1.3333
        }
        set calcdpi [expr {round($tkscale*72.0)}]
        set vars(scale.factor) [expr {$calcdpi/100.0}]
        set vars(theme.name) $::awthemename
        set vars(cache.menu) [dict create]
        set vars(cache.text) [dict create]
        set vars(cache.listbox) [dict create]
        set vars(cache.popdown) false
        set vars(nb.img.width) 20
        set vars(nb.img.height) 3
        set vars(have.tksvg) false
        if { ! [catch {package present tksvg}] } {
          set vars(have.tksvg) true
        }

        _setThemeBaseColors

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

        # sets both the base colors and the curr.* colors
        _setDerivedColors

        # now override any derived colors with user-specified colors
        foreach {k} $::themeutils::vars(names.colors.derived) {
          if { [info exists colors(user.$k)] } {
            set colors(curr.$k) $colors(user.$k)
          }
        }

        _setImageData
        _createTheme
        _setStyledColors
      }

      proc _setThemeBaseColors { } {
        variable vars
        variable colors

        if { $vars(theme.name) eq "awdark" } {
          array set colors {
              base.disabledfg       #919282
              base.disabledbg       #2d3234
              base.disabledborder   #202425
              base.frame            #33393b
              base.dark             #252a2c
              base.darker           #1b1f20
              base.darkest          #000000
              base.bpress           #424a4d
              base.lighter          #525c5f
              base.lightest         #ffffff
              highlight.selectbg    #215d9c
              highlight.selectdisabledbg  #224162
              highlight.darkhighlight     #1a497c
              highlight.selectfg    #ffffff
              }
        }
        if { $vars(theme.name) eq "awlight" } {
          array set colors {
              base.frame      #e8e8e7
              base.disabledfg #8e8e8f
              base.disabledbg #cacaca
              base.disabledborder #c0c0bd
              base.dark       #cacaca
              base.darker     #8b8391
              base.darkest    #000000
              base.bpress     #e8e8e7
              base.lighter    #f0f0f0
              base.lightest   #ffffff
              highlight.selectbg   #1a497c
              highlight.selectdisabledbg   #f0f0f0
              highlight.darkhighlight #1a497c
              highlight.selectfg   #ffffff
              }
        }
      }

      proc _setDerivedColors { } {
        variable vars
        variable colors

        foreach {prefix} {{} curr.} {
          if { $vars(theme.name) eq "awdark" } {
            set colors(${prefix}base.arrow) $colors(base.lightest)
            set colors(${prefix}base.arrow.disabled) $colors(base.lighter)
            set colors(${prefix}base.border) $colors(base.darkest)
            set colors(${prefix}base.border.light) $colors(base.darkest)
            set colors(${prefix}text.text) $colors(base.lightest)
            set colors(${prefix}base.tabborder) $colors(base.darkest)
            set colors(${prefix}base.tabinactive) $colors(base.frame)
            set colors(${prefix}base.tabhighlight) #8b9ca1
            set colors(${prefix}base.entrybg) $colors(base.darker)
          }
          if { $vars(theme.name) eq "awlight" } {
            set colors(${prefix}base.arrow) $colors(base.darkest)
            set colors(${prefix}base.arrow.disabled) $colors(base.darker)
            set colors(${prefix}base.border) $colors(base.dark)
            set colors(${prefix}base.border.light) $colors(base.dark)
            set colors(${prefix}text.text) $colors(base.darkest)
            set colors(${prefix}base.tabborder) $colors(base.frame)
            set colors(${prefix}base.tabinactive) $colors(base.darker)
            set colors(${prefix}base.tabhighlight) $colors(base.darkest)
            set colors(${prefix}base.entrybg) $colors(base.lightest)
          }
        }
      }

      proc _setImageData { } {
        variable vars
        variable imgdata
        variable imgtype
        variable colors

        if { $vars(have.tksvg) } {
          #B == svgdata ==
          # arrow-bg-down-d
          set imgtype(arrow-bg-down-d) svg
          set imgdata(arrow-bg-down-d) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 3.81 3.81"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-down-d.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.28307"
     inkscape:cx="7.978663"
     inkscape:cy="8.0161236"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px"
     showguides="false"
     scale-x="0.8"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.45547)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#202425;stroke-width:0.07803822;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect819"
       width="3.7281528"
       height="3.7438293"
       x="-131.66174"
       y="128.48471" />
    <g
       aria-label="⏷"
       transform="matrix(1.1362206,0,0,1.1516568,19.020195,-19.405805)"
       style="font-style:normal;font-weight:normal;font-size:2.90202522px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#919282;fill-opacity:1;stroke:none;stroke-width:0.07255063"
       id="text817">
      <path
         d="m -129.98195,129.04927 q 0.0557,0 0.0557,0.0433 0,0.006 -0.006,0.0186 l -1.00294,1.88825 q -0.0186,0.0371 -0.0371,0.0371 -0.0186,0 -0.0371,-0.0371 l -1.00294,-1.88206 q 0,-0.0124 0,-0.0248 0,-0.0433 0.0619,-0.0433 z"
         style="font-size:6.19098759px;fill:#919282;fill-opacity:1;stroke-width:0.07255063"
         id="path4706"
         inkscape:connector-curvature="0" />
    </g>
  </g>
</svg>
}
          # arrow-bg-down-n
          set imgtype(arrow-bg-down-n) svg
          set imgdata(arrow-bg-down-n) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 3.81 3.81"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-down-n.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.28307"
     inkscape:cx="7.978663"
     inkscape:cy="8.0161236"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px"
     showguides="false"
     scale-x="0.8"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.45547)">
    <rect
       style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.07803822;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect819"
       width="3.7281528"
       height="3.7438293"
       x="-131.66174"
       y="128.48471" />
    <g
       aria-label="⏷"
       transform="matrix(1.1362206,0,0,1.1516568,19.020195,-19.405805)"
       style="font-style:normal;font-weight:normal;font-size:2.90202522px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:0.07255063"
       id="text817">
      <path
         d="m -129.98195,129.04927 q 0.0557,0 0.0557,0.0433 0,0.006 -0.006,0.0186 l -1.00294,1.88825 q -0.0186,0.0371 -0.0371,0.0371 -0.0186,0 -0.0371,-0.0371 l -1.00294,-1.88206 q 0,-0.0124 0,-0.0248 0,-0.0433 0.0619,-0.0433 z"
         style="font-size:6.19098759px;fill:#ffffff;fill-opacity:1;stroke-width:0.07255063"
         id="path4706"
         inkscape:connector-curvature="0" />
    </g>
  </g>
</svg>
}
          # arrow-bg-left-d
          set imgtype(arrow-bg-left-d) svg
          set imgdata(arrow-bg-left-d) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 4.2333333 4.2333333"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-left-d.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.25"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.34964)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#202423;stroke-width:0.08632814;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect819"
       width="4.1308079"
       height="4.1348972"
       x="-131.63921"
       y="128.39941" />
    <g
       aria-label="⏷"
       transform="matrix(0,1.1182676,-1.1691104,0,19.060577,-18.835003)"
       style="font-style:normal;font-weight:normal;font-size:3.28602195px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#919282;fill-opacity:1;stroke:none;stroke-width:0.08215055"
       id="text817">
      <path
         d="m 134.63134,126.01448 q 0.0631,0 0.0631,0.0491 0,0.007 -0.007,0.021 l -1.13565,2.1381 q -0.021,0.0421 -0.0421,0.0421 -0.021,0 -0.0421,-0.0421 L 132.332,126.0916 q 0,-0.014 0,-0.028 0,-0.0491 0.0701,-0.0491 z"
         style="font-size:7.01018047px;fill:#919282;fill-opacity:1;stroke-width:0.08215055"
         id="path815"
         inkscape:connector-curvature="0" />
    </g>
  </g>
</svg>
}
          # arrow-bg-left-n
          set imgtype(arrow-bg-left-n) svg
          set imgdata(arrow-bg-left-n) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 4.2333333 4.2333333"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-left.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.25"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.34964)">
    <g
       id="g4690"
       transform="matrix(1.144747,0,0,1.1420675,19.060577,-18.835003)">
      <rect
         y="128.91919"
         x="-131.64462"
         height="3.6205368"
         width="3.6084898"
         id="rect819"
         style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.07550083;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <g
         id="text817"
         style="font-style:normal;font-weight:normal;font-size:3.28602195px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:0.08215055"
         transform="matrix(0,0.97916072,-1.0212828,0,0,0)"
         aria-label="⏷">
        <path
           inkscape:connector-curvature="0"
           id="path815"
           style="font-size:7.01018047px;fill:#ffffff;fill-opacity:1;stroke-width:0.08215055"
           d="m 134.63134,126.01448 q 0.0631,0 0.0631,0.0491 0,0.007 -0.007,0.021 l -1.13565,2.1381 q -0.021,0.0421 -0.0421,0.0421 -0.021,0 -0.0421,-0.0421 L 132.332,126.0916 q 0,-0.014 0,-0.028 0,-0.0491 0.0701,-0.0491 z" />
      </g>
    </g>
  </g>
</svg>
}
          # arrow-bg-right-d
          set imgtype(arrow-bg-right-d) svg
          set imgdata(arrow-bg-right-d) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 4.2333333 4.2333333"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-right-d.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.25"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.34964)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#202425;stroke-width:0.08690879;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect819"
       width="4.1476083"
       height="4.1737323"
       x="-131.66147"
       y="128.37518" />
    <g
       aria-label="⏷"
       transform="matrix(0,1.1213995,1.1661998,0,18.655533,-19.294116)"
       style="font-style:normal;font-weight:normal;font-size:3.307621px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#919282;fill-opacity:1;stroke:none;stroke-width:0.08269052"
       id="text817">
      <path
         inkscape:connector-curvature="0"
         d="m 134.6679,-128.24434 q 0.0635,0 0.0635,0.0494 0,0.007 -0.007,0.0212 l -1.14312,2.15216 q -0.0212,0.0423 -0.0423,0.0423 -0.0212,0 -0.0423,-0.0423 l -1.14312,-2.1451 q 0,-0.0141 0,-0.0282 0,-0.0494 0.0706,-0.0494 z"
         style="font-size:7.0562582px;fill:#919282;fill-opacity:1;stroke-width:0.08269052"
         id="path815" />
    </g>
  </g>
</svg>
}
          # arrow-bg-right-n
          set imgtype(arrow-bg-right-n) svg
          set imgdata(arrow-bg-right-n) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 4.2333333 4.2333333"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-right.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.25"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.34964)">
    <g
       id="g4700"
       transform="matrix(1.1416473,0,0,1.1455166,18.655533,-19.294116)">
      <rect
         y="128.91066"
         x="-131.66676"
         height="3.6435373"
         width="3.6330032"
         id="rect819"
         style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.0759971;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <g
         id="text817"
         style="font-style:normal;font-weight:normal;font-size:3.307621px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:0.08269052"
         transform="matrix(0,0.97894657,1.0215062,0,0,0)"
         aria-label="⏷">
        <path
           id="path815"
           style="font-size:7.0562582px;fill:#ffffff;fill-opacity:1;stroke-width:0.08269052"
           d="m 134.6679,-128.24434 q 0.0635,0 0.0635,0.0494 0,0.007 -0.007,0.0212 l -1.14312,2.15216 q -0.0212,0.0423 -0.0423,0.0423 -0.0212,0 -0.0423,-0.0423 l -1.14312,-2.1451 q 0,-0.0141 0,-0.0282 0,-0.0494 0.0706,-0.0494 z"
           inkscape:connector-curvature="0" />
      </g>
    </g>
  </g>
</svg>
}
          # arrow-bg-up-d
          set imgtype(arrow-bg-up-d) svg
          set imgdata(arrow-bg-up-d) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 3.3866666 3.3866666"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-up-d.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.25"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px"
     scale-x="0.8"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.56132)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#202425;stroke-width:0.06932501;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect819"
       width="3.3318834"
       height="3.3058643"
       x="-131.6716"
       y="128.60089" />
    <g
       aria-label="⏷"
       transform="matrix(1.1691651,0,0,-1.1169925,18.701881,-19.425222)"
       style="font-style:normal;font-weight:normal;font-size:2.81951427px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#919282;fill-opacity:1;stroke:none;stroke-width:0.07048785"
       id="text817">
      <path
         d="m -126.22887,-134.96964 q 0.0541,0 0.0541,0.0421 0,0.006 -0.006,0.018 l -0.97443,1.83456 q -0.018,0.0361 -0.0361,0.0361 -0.018,0 -0.0361,-0.0361 l -0.97442,-1.82855 q 0,-0.012 0,-0.0241 0,-0.0421 0.0602,-0.0421 z"
         style="font-size:6.01496363px;fill:#919282;fill-opacity:1;stroke-width:0.07048785"
         id="path4712"
         inkscape:connector-curvature="0" />
    </g>
  </g>
</svg>
}
          # arrow-bg-up-n
          set imgtype(arrow-bg-up-n) svg
          set imgdata(arrow-bg-up-n) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 3.3866666 3.3866666"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-up.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.25"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px"
     scale-x="0.8"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.56132)">
    <g
       id="g4710"
       transform="matrix(1.1433941,0,0,1.1421684,18.885889,-18.75792)">
      <rect
         y="129.01671"
         x="-131.67593"
         height="2.8943756"
         width="2.9140289"
         id="rect819"
         style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.06066342;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <g
         id="text817"
         style="font-style:normal;font-weight:normal;font-size:2.81951427px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:0.07048785"
         transform="matrix(1.022539,0,0,-0.97795782,-0.16093137,-0.58424134)"
         aria-label="⏷">
        <path
           inkscape:connector-curvature="0"
           id="path4712"
           style="font-size:6.01496363px;fill:#ffffff;fill-opacity:1;stroke-width:0.07048785"
           d="m -126.22887,-134.96964 q 0.0541,0 0.0541,0.0421 0,0.006 -0.006,0.018 l -0.97443,1.83456 q -0.018,0.0361 -0.0361,0.0361 -0.018,0 -0.0361,-0.0361 l -0.97442,-1.82855 q 0,-0.012 0,-0.0241 0,-0.0421 0.0602,-0.0421 z" />
      </g>
    </g>
  </g>
</svg>
}
          # arrow-down-d
          set imgtype(arrow-down-d) svg
          set imgdata(arrow-down-d) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 3.81 3.81"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="tree-arrow-down-d.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="14.75"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1031"
     inkscape:window-height="414"
     inkscape:window-x="78"
     inkscape:window-y="194"
     inkscape:window-maximized="0"
     units="px"
     showguides="false"
     scale-x="0.8"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.45547)">
    <g
       aria-label="⏷"
       transform="matrix(1.1362206,0,0,1.1516568,19.020195,-19.405805)"
       style="font-style:normal;font-weight:normal;font-size:2.90202522px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#9192b2;fill-opacity:1;stroke:none;stroke-width:0.07255063"
       id="text817">
      <path
         d="m -129.98195,129.04927 q 0.0557,0 0.0557,0.0433 0,0.006 -0.006,0.0186 l -1.00294,1.88825 q -0.0186,0.0371 -0.0371,0.0371 -0.0186,0 -0.0371,-0.0371 l -1.00294,-1.88206 q 0,-0.0124 0,-0.0248 0,-0.0433 0.0619,-0.0433 z"
         style="font-size:6.19098759px;fill:#919282;fill-opacity:1;stroke-width:0.07255063"
         id="path4706"
         inkscape:connector-curvature="0" />
    </g>
  </g>
</svg>
}
          # arrow-down-n
          set imgtype(arrow-down-n) svg
          set imgdata(arrow-down-n) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 3.81 3.81"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="arrow-down-n.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="14.75"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1031"
     inkscape:window-height="414"
     inkscape:window-x="41"
     inkscape:window-y="157"
     inkscape:window-maximized="0"
     units="px"
     showguides="false"
     scale-x="0.8"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.45547)">
    <g
       aria-label="⏷"
       transform="matrix(1.1362206,0,0,1.1516568,19.020195,-19.405805)"
       style="font-style:normal;font-weight:normal;font-size:2.90202522px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:0.07255063"
       id="text817">
      <path
         d="m -129.98195,129.04927 q 0.0557,0 0.0557,0.0433 0,0.006 -0.006,0.0186 l -1.00294,1.88825 q -0.0186,0.0371 -0.0371,0.0371 -0.0186,0 -0.0371,-0.0371 l -1.00294,-1.88206 q 0,-0.0124 0,-0.0248 0,-0.0433 0.0619,-0.0433 z"
         style="font-size:6.19098759px;fill:#ffffff;fill-opacity:1;stroke-width:0.07255063"
         id="path4706"
         inkscape:connector-curvature="0" />
    </g>
  </g>
</svg>
}
          # arrow-right-n
          set imgtype(arrow-right-n) svg
          set imgdata(arrow-right-n) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="16"
   viewBox="0 0 4.2333333 4.2333333"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="tree-arrow-right-n.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="33.125"
     inkscape:cx="8"
     inkscape:cy="8"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1325"
     inkscape:window-height="740"
     inkscape:window-x="41"
     inkscape:window-y="0"
     inkscape:window-maximized="1"
     units="px"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-128.34964)">
    <g
       aria-label="⏷"
       transform="matrix(0,1.1213995,1.1661998,0,18.655533,-19.294116)"
       style="font-style:normal;font-weight:normal;font-size:3.307621px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:0.08269052"
       id="text817">
      <path
         inkscape:connector-curvature="0"
         d="m 134.6679,-128.24434 q 0.0635,0 0.0635,0.0494 0,0.007 -0.007,0.0212 l -1.14312,2.15216 q -0.0212,0.0423 -0.0423,0.0423 -0.0212,0 -0.0423,-0.0423 l -1.14312,-2.1451 q 0,-0.0141 0,-0.0282 0,-0.0494 0.0706,-0.0494 z"
         style="font-size:7.0562582px;fill:#ffffff;fill-opacity:1;stroke-width:0.08269052"
         id="path815" />
    </g>
  </g>
</svg>
}
          # cb-sa
          set imgtype(cb-sa) svg
          set imgdata(cb-sa) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   viewBox="0 0 64 64"
   sodipodi:docname="cb-sa.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.101885"
     inkscape:cx="8.576129"
     inkscape:cy="8.4973642"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#424a4d;fill-opacity:1;stroke:#0e0e0e;stroke-width:3.49840903;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.577419"
       height="60.621414"
       x="1.8717725"
       y="1.8241789"
       ry="10.698651" />
    <g
       aria-label="✔"
       transform="scale(0.96762071,1.0334628)"
       style="font-style:normal;font-weight:normal;font-size:80.48880005px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:2.01222014"
       id="text9056">
      <path
         d="m 17.358988,28.775613 q 1.532746,0 2.31877,2.515275 1.572046,4.716141 2.240166,4.716141 0.510916,0 1.061132,-0.786024 11.043629,-16.231384 20.436609,-23.109089 3.969419,-2.9082867 7.742331,-2.9082867 4.991249,0 6.013079,0.3144094 0.432313,0.1179035 0.432313,0.9825293 0,0.707421 -0.903927,1.768553 -25.270653,29.004265 -30.104697,37.729125 -1.650649,2.986889 -7.624428,2.986889 -1.965058,0 -4.126623,-1.021831 Q 13.939786,51.49169 11.69962,45.950225 8.8699352,38.954616 8.8699352,33.688259 q 0,-1.925757 2.7510818,-3.183395 3.772913,-1.729251 5.659369,-1.729251 z"
         style="fill:#ffffff;fill-opacity:1;stroke-width:2.01222014"
         id="path5786" />
    </g>
  </g>
</svg>
}
          # cb-sd
          set imgtype(cb-sd) svg
          set imgdata(cb-sd) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   viewBox="0 0 64 64"
   sodipodi:docname="cb-sd.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.039439"
     inkscape:cx="8.5356594"
     inkscape:cy="8.5383146"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#2d3234;fill-opacity:1;stroke:#202425;stroke-width:3.50260115;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.726891"
       height="60.617222"
       x="1.645276"
       y="1.6727111"
       ry="10.69791" />
    <g
       aria-label="✔"
       transform="scale(0.9676207,1.0334628)"
       style="font-style:normal;font-weight:normal;font-size:80.48880005px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#919282;fill-opacity:1;stroke:none;stroke-width:2.01222014"
       id="text9056">
      <path
         d="m 17.202149,28.627019 q 1.532746,0 2.318769,2.515275 1.572047,4.716141 2.240167,4.716141 0.510915,0 1.061132,-0.786024 11.043629,-16.231384 20.436609,-23.109089 3.969419,-2.9082866 7.742331,-2.9082866 4.991249,0 6.013079,0.3144094 0.432313,0.1179035 0.432313,0.9825292 0,0.707421 -0.903927,1.768553 -25.270653,29.004265 -30.104697,37.729125 -1.65065,2.986889 -7.624428,2.986889 -1.965058,0 -4.126623,-1.021831 -0.903927,-0.471614 -3.144093,-6.013079 -2.8296848,-6.995608 -2.8296848,-12.261965 0,-1.925758 2.7510818,-3.183395 3.772913,-1.729252 5.659369,-1.729252 z"
         style="fill:#919282;fill-opacity:1;stroke-width:2.01222014"
         id="path5783" />
    </g>
  </g>
</svg>
}
          # cb-sn-pad
          set imgtype(menu-cb-sn-pad) svg
          set imgdata(menu-cb-sn-pad) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="20"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   viewBox="0 0 74.999996 64"
   sodipodi:docname="cb-sn-pad.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="22.3"
     inkscape:cx="10"
     inkscape:cy="8.5333338"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/4.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.49840903;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.577419"
       height="60.621414"
       x="1.8717725"
       y="1.8241789"
       ry="10.698651" />
    <g
       aria-label="✔"
       transform="scale(0.96762071,1.0334628)"
       style="font-style:normal;font-weight:normal;font-size:80.48880005px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:2.01222014"
       id="text9056">
      <path
         d="m 17.358988,28.775613 q 1.532746,0 2.31877,2.515275 1.572046,4.716141 2.240166,4.716141 0.510916,0 1.061132,-0.786024 11.043629,-16.231384 20.436609,-23.109089 3.969419,-2.9082867 7.742331,-2.9082867 4.991249,0 6.013079,0.3144094 0.432313,0.1179035 0.432313,0.9825293 0,0.707421 -0.903927,1.768553 -25.270653,29.004265 -30.104697,37.729125 -1.650649,2.986889 -7.624428,2.986889 -1.965058,0 -4.126623,-1.021831 Q 13.939786,51.49169 11.69962,45.950225 8.8699352,38.954616 8.8699352,33.688259 q 0,-1.925757 2.7510818,-3.183395 3.772913,-1.729251 5.659369,-1.729251 z"
         style="fill:#ffffff;fill-opacity:1;stroke-width:2.01222014"
         id="path5780" />
    </g>
  </g>
</svg>
}
          # cb-sn-small
          set imgtype(cb-sn-small) svg
          set imgdata(cb-sn-small) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   viewBox="0 0 63.749997 64"
   sodipodi:docname="cb-sn-small.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="22.3"
     inkscape:cx="10"
     inkscape:cy="8.5333338"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/4.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.49840903;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.577419"
       height="60.621414"
       x="1.8717725"
       y="1.8241789"
       ry="10.698651" />
    <g
       aria-label="✔"
       transform="scale(0.96762071,1.0334628)"
       style="font-style:normal;font-weight:normal;font-size:80.48880005px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:2.01222014"
       id="text9056">
      <path
         d="m 17.358988,28.775613 q 1.532746,0 2.31877,2.515275 1.572046,4.716141 2.240166,4.716141 0.510916,0 1.061132,-0.786024 11.043629,-16.231384 20.436609,-23.109089 3.969419,-2.9082867 7.742331,-2.9082867 4.991249,0 6.013079,0.3144094 0.432313,0.1179035 0.432313,0.9825293 0,0.707421 -0.903927,1.768553 -25.270653,29.004265 -30.104697,37.729125 -1.650649,2.986889 -7.624428,2.986889 -1.965058,0 -4.126623,-1.021831 Q 13.939786,51.49169 11.69962,45.950225 8.8699352,38.954616 8.8699352,33.688259 q 0,-1.925757 2.7510818,-3.183395 3.772913,-1.729251 5.659369,-1.729251 z"
         style="fill:#ffffff;fill-opacity:1;stroke-width:2.01222014"
         id="path5777" />
    </g>
  </g>
</svg>
}
          # cb-sn
          set imgtype(cb-sn) svg
          set imgdata(cb-sn) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   viewBox="0 0 64 64"
   sodipodi:docname="cb-sn.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="25.984836"
     inkscape:cx="8.576129"
     inkscape:cy="8.4973642"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.49840903;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.577419"
       height="60.621414"
       x="1.8717725"
       y="1.8241789"
       ry="10.698651" />
    <g
       aria-label="✔"
       transform="scale(0.96762071,1.0334628)"
       style="font-style:normal;font-weight:normal;font-size:80.48880005px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:2.01222014"
       id="text9056">
      <path
         d="m 17.358988,28.775613 q 1.532746,0 2.31877,2.515275 1.572046,4.716141 2.240166,4.716141 0.510916,0 1.061132,-0.786024 11.043629,-16.231384 20.436609,-23.109089 3.969419,-2.9082867 7.742331,-2.9082867 4.991249,0 6.013079,0.3144094 0.432313,0.1179035 0.432313,0.9825293 0,0.707421 -0.903927,1.768553 -25.270653,29.004265 -30.104697,37.729125 -1.650649,2.986889 -7.624428,2.986889 -1.965058,0 -4.126623,-1.021831 Q 13.939786,51.49169 11.69962,45.950225 8.8699352,38.954616 8.8699352,33.688259 q 0,-1.925757 2.7510818,-3.183395 3.772913,-1.729251 5.659369,-1.729251 z"
         style="fill:#ffffff;fill-opacity:1;stroke-width:2.01222014"
         id="path5774" />
    </g>
  </g>
</svg>
}
          # cb-ua
          set imgtype(cb-ua) svg
          set imgdata(cb-ua) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 64 64"
   sodipodi:docname="cb-ua.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.101885"
     inkscape:cx="8.576129"
     inkscape:cy="8.4973642"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#424a4d;fill-opacity:1;stroke:#000000;stroke-width:3.49840903;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.577419"
       height="60.621414"
       x="1.8717725"
       y="1.8241789"
       ry="10.698651" />
  </g>
</svg>
}
          # cb-ud
          set imgtype(cb-ud) svg
          set imgdata(cb-ud) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 64 64"
   sodipodi:docname="cb-ud.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.101883"
     inkscape:cx="8.535154"
     inkscape:cy="8.5090836"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#2d3234;fill-opacity:1;stroke:#202425;stroke-width:3.49421477;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.581619"
       height="60.471951"
       x="1.7160162"
       y="1.8549629"
       ry="10.672273" />
  </g>
</svg>
}
          # cb-un-pad
          set imgtype(menu-cb-un-pad) svg
          set imgdata(menu-cb-un-pad) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="20"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 74.999996 64"
   sodipodi:docname="cb-un-pad.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="22.3"
     inkscape:cx="10"
     inkscape:cy="8.5333338"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/4.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.49840903;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.577419"
       height="60.621414"
       x="1.8717725"
       y="1.8241789"
       ry="10.698651" />
  </g>
</svg>
}
          # cb-un-small
          set imgtype(cb-un-small) svg
          set imgdata(cb-un-small) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 63.749997 64"
   sodipodi:docname="cb-un-small.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.235294"
     inkscape:cx="8.5"
     inkscape:cy="8.5333338"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/4.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.49840903;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.577419"
       height="60.621414"
       x="1.8717725"
       y="1.8241789"
       ry="10.698651" />
  </g>
</svg>
}
          # cb-un
          set imgtype(cb-un) svg
          set imgdata(cb-un) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 64 64"
   sodipodi:docname="cb-un.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.218934"
     inkscape:cx="8.5379886"
     inkscape:cy="8.4885959"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="221"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <rect
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.49840903;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect9014"
       width="60.577419"
       height="60.621414"
       x="1.8717725"
       y="1.8241789"
       ry="10.698651" />
  </g>
</svg>
}
          # combo-arrow-down-d
          set imgtype(combo-arrow-down-d) svg
          set imgdata(combo-arrow-down-d) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="27"
   viewBox="0 0 4.2333333 7.14375"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="combo-arrow-down-d.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="8.7407407"
     inkscape:cx="8"
     inkscape:cy="13.5"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1029"
     inkscape:window-height="414"
     inkscape:window-x="153"
     inkscape:window-y="69"
     inkscape:window-maximized="0"
     units="px"
     showguides="false"
     scale-x="0.8"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-125.7038)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#000000;stroke-width:0.11329506;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect819"
       width="4.1873693"
       height="7.025476"
       x="-131.68114"
       y="125.755" />
    <g
       aria-label="⏷"
       transform="matrix(1.1362206,0,0,1.1516568,19.229082,-20.489104)"
       style="font-style:normal;font-weight:normal;font-size:2.90202522px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#919282;fill-opacity:1;stroke:none;stroke-width:0.07255063"
       id="text817">
      <path
         d="m -129.98195,129.04927 q 0.0557,0 0.0557,0.0433 0,0.006 -0.006,0.0186 l -1.00294,1.88825 q -0.0186,0.0371 -0.0371,0.0371 -0.0186,0 -0.0371,-0.0371 l -1.00294,-1.88206 q 0,-0.0124 0,-0.0248 0,-0.0433 0.0619,-0.0433 z"
         style="font-size:6.19098759px;fill:#919282;fill-opacity:1;stroke-width:0.07255063"
         id="path4706"
         inkscape:connector-curvature="0" />
    </g>
  </g>
</svg>
}
          # combo-arrow-down-n
          set imgtype(combo-arrow-down-n) svg
          set imgdata(combo-arrow-down-n) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="16"
   height="27"
   viewBox="0 0 4.2333333 7.14375"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="combo-arrow-down-n.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="8.7407407"
     inkscape:cx="8"
     inkscape:cy="13.5"
     inkscape:document-units="mm"
     inkscape:current-layer="layer1"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:window-width="1029"
     inkscape:window-height="414"
     inkscape:window-x="45"
     inkscape:window-y="161"
     inkscape:window-maximized="0"
     units="px"
     showguides="false"
     scale-x="0.8"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(131.69759,-125.78318)">
    <rect
       style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.11302858;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect819"
       width="4.1379242"
       height="7.0760179"
       x="-131.65642"
       y="125.79185" />
    <g
       aria-label="⏷"
       transform="matrix(1.1362206,0,0,1.1516568,19.229082,-20.409724)"
       style="font-style:normal;font-weight:normal;font-size:2.90202522px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:none;stroke-width:0.07255063"
       id="text817">
      <path
         d="m -129.98195,129.04927 q 0.0557,0 0.0557,0.0433 0,0.006 -0.006,0.0186 l -1.00294,1.88825 q -0.0186,0.0371 -0.0371,0.0371 -0.0186,0 -0.0371,-0.0371 l -1.00294,-1.88206 q 0,-0.0124 0,-0.0248 0,-0.0433 0.0619,-0.0433 z"
         style="font-size:6.19098759px;fill:#ffffff;fill-opacity:1;stroke-width:0.07255063"
         id="path4706"
         inkscape:connector-curvature="0" />
    </g>
  </g>
</svg>
}
          # rb-sa
          set imgtype(rb-sa) svg
          set imgdata(rb-sa) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 64 64"
   sodipodi:docname="rb-sa.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.163119"
     inkscape:cx="8.6194534"
     inkscape:cy="8.5685999"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="241"
     inkscape:window-y="4"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#424a4d;fill-opacity:1;stroke:#000000;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="32.322948"
       cy="31.867752"
       r="30.200102" />
    <circle
       style="fill:#215d9c;fill-opacity:1;stroke:#215d9c;stroke-width:2.80060267;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4500"
       cx="32.322948"
       cy="31.867752"
       r="19.212624" />
  </g>
</svg>
}
          # rb-sd
          set imgtype(rb-sd) svg
          set imgdata(rb-sd) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   viewBox="0 0 64 64"
   sodipodi:docname="rb-sd.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.163119"
     inkscape:cx="1.0836625"
     inkscape:cy="8.4545221"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="45"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#2d3234;fill-opacity:1;stroke:#202425;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="32.013382"
       cy="32.295544"
       r="30.200102" />
    <circle
       style="fill:#224162;fill-opacity:1;stroke:#224162;stroke-width:2.80124985;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4500"
       cx="32.013382"
       cy="32.295544"
       r="19.212624" />
  </g>
</svg>
}
          # rb-sn-pad
          set imgtype(menu-rb-sn-pad) svg
          set imgdata(menu-rb-sn-pad) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="20"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 74.999996 64"
   sodipodi:docname="rb-sn-pad.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="22.3"
     inkscape:cx="10"
     inkscape:cy="8.5333338"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="241"
     inkscape:window-y="4"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/4.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="32.322948"
       cy="31.867752"
       r="30.200102" />
    <circle
       style="fill:#215d9c;fill-opacity:1;stroke:#215d9c;stroke-width:2.80060267;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4500"
       cx="32.322948"
       cy="31.867752"
       r="19.212624" />
  </g>
</svg>
}
          # rb-sn-small
          set imgtype(rb-sn-small) svg
          set imgdata(rb-sn-small) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 63.749997 64"
   sodipodi:docname="rb-sn-small.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="22.3"
     inkscape:cx="10"
     inkscape:cy="8.5333338"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="241"
     inkscape:window-y="4"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/4.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="31.874998"
       cy="32"
       r="30.200102" />
    <circle
       style="fill:#215d9c;fill-opacity:1;stroke:#215d9c;stroke-width:2.80060267;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4500"
       cx="31.874998"
       cy="32"
       r="19.212624" />
  </g>
</svg>
}
          # rb-sn
          set imgtype(rb-sn) svg
          set imgdata(rb-sn) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 64 64"
   sodipodi:docname="rb-sn.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.163119"
     inkscape:cx="8.6194534"
     inkscape:cy="8.5685999"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="241"
     inkscape:window-y="4"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="32.322948"
       cy="31.867752"
       r="30.200102" />
    <circle
       style="fill:#215d9c;fill-opacity:1;stroke:#215d9c;stroke-width:2.80060267;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4500"
       cx="32.322948"
       cy="31.867752"
       r="19.212624" />
  </g>
</svg>
}
          # rb-ua
          set imgtype(rb-ua) svg
          set imgdata(rb-ua) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 64 64"
   sodipodi:docname="rb-ua.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.163119"
     inkscape:cx="8.6194534"
     inkscape:cy="8.5685999"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="241"
     inkscape:window-y="4"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#424a4d;fill-opacity:1;stroke:#000000;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="32.322948"
       cy="31.867752"
       r="30.200102" />
  </g>
</svg>
}
          # rb-ud
          set imgtype(rb-ud) svg
          set imgdata(rb-ud) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 64 64"
   sodipodi:docname="rb-ud.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.163119"
     inkscape:cx="8.6194534"
     inkscape:cy="8.5685999"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="45"
     inkscape:window-y="0"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#2d3234;fill-opacity:1;stroke:#202425;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="32.322948"
       cy="31.867752"
       r="30.200102" />
  </g>
</svg>
}
          # rb-un-pad
          set imgtype(menu-rb-un-pad) svg
          set imgdata(menu-rb-un-pad) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="20"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 74.999996 64"
   sodipodi:docname="rb-un-pad.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="22.3"
     inkscape:cx="10"
     inkscape:cy="8.5333338"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="315"
     inkscape:window-y="29"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/4.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="32.322948"
       cy="31.867752"
       r="30.200102" />
  </g>
</svg>
}
          # rb-un-small
          set imgtype(rb-un-small) svg
          set imgdata(rb-un-small) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 63.749997 64"
   sodipodi:docname="rb-un-small.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="26.235294"
     inkscape:cx="8.5"
     inkscape:cy="8.5333338"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="315"
     inkscape:window-y="29"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/4.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/4.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="31.874998"
       cy="32"
       r="30.200102" />
  </g>
</svg>
}
          # rb-un
          set imgtype(rb-un) svg
          set imgdata(rb-un) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="17.066668"
   height="17.066668"
   id="svg4152"
   version="1.1"
   inkscape:version="0.92.1 r15371"
   viewBox="0 0 64 64"
   sodipodi:docname="rb-un.svg">
  <defs
     id="defs4154" />
  <sodipodi:namedview
     id="base"
     pagecolor="#c3c3c3"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="24.227283"
     inkscape:cx="8.6194534"
     inkscape:cy="8.5685999"
     inkscape:current-layer="layer1"
     showgrid="true"
     inkscape:document-units="px"
     inkscape:grid-bbox="true"
     inkscape:window-width="1002"
     inkscape:window-height="708"
     inkscape:window-x="315"
     inkscape:window-y="55"
     inkscape:window-maximized="0" />
  <metadata
     id="metadata4157">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
        <cc:license
           rdf:resource="http://creativecommons.org/licenses/by-sa/3.0/" />
      </cc:Work>
      <cc:License
         rdf:about="http://creativecommons.org/licenses/by-sa/3.0/">
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Reproduction" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#Distribution" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Notice" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#Attribution" />
        <cc:permits
           rdf:resource="http://creativecommons.org/ns#DerivativeWorks" />
        <cc:requires
           rdf:resource="http://creativecommons.org/ns#ShareAlike" />
      </cc:License>
    </rdf:RDF>
  </metadata>
  <g
     id="layer1"
     inkscape:label="Layer 1"
     inkscape:groupmode="layer">
    <circle
       style="fill:#252a2c;fill-opacity:1;stroke:#000000;stroke-width:3.65624976;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path4485"
       cx="32.322948"
       cy="31.867752"
       r="30.200102" />
  </g>
</svg>
}
          # scale-hd
          set imgtype(scale-hd) svg
          set imgdata(scale-hd) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="28"
   height="14"
   viewBox="0 0 7.4083338 3.7041668"
   version="1.1"
   id="svg8"
   sodipodi:docname="scale-hd.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="19.035714"
     inkscape:cx="6.4090055"
     inkscape:cy="7"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="41"
     inkscape:window-y="42"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px"
     showguides="false" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-97.353814,-139.48844)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#202425;stroke-width:0.29253346;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect815"
       width="3.4278965"
       height="7.1305251"
       x="139.61896"
       y="-104.60221"
       ry="0"
       transform="rotate(90)" />
    <g
       transform="matrix(1.0000127,0,0,1.0000127,0.22785452,-0.15966094)"
       id="g3071">
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.96384"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-99.875397"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-3"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-101.50807"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-6"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-102.05229"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-7"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.41962"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-5"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    </g>
  </g>
</svg>
}
          # scale-hn
          set imgtype(scale-hn) svg
          set imgdata(scale-hn) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="28"
   height="14"
   viewBox="0 0 7.4083338 3.7041669"
   version="1.1"
   id="svg8"
   sodipodi:docname="scale-hn.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="19.035714"
     inkscape:cx="6.4090055"
     inkscape:cy="7"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="41"
     inkscape:window-y="42"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px"
     showguides="false" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-97.353814,-139.48844)">
    <rect
       style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.29461741;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect815"
       width="3.4380579"
       height="7.1025405"
       x="139.6192"
       y="-104.59727"
       ry="0"
       transform="rotate(90)" />
    <g
       transform="matrix(1.0000127,0,0,1.0000127,0.22785457,-0.15966092)"
       id="g3071">
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.96384"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-99.875397"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-3"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-101.50807"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-6"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-102.05229"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-7"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.41962"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-5"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    </g>
  </g>
</svg>
}
          # scale-vd
          set imgtype(scale-vd) svg
          set imgdata(scale-vd) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="14"
   height="28"
   viewBox="0 0 3.7041666 7.4083333"
   version="1.1"
   id="svg8"
   sodipodi:docname="scale-vd.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="15.678571"
     inkscape:cx="-2.2164012"
     inkscape:cy="14"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="41"
     inkscape:window-y="42"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-99.488592,-137.94053)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#202425;stroke-width:0.29152358;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect815"
       width="3.4021287"
       height="7.1350117"
       x="-103.0423"
       y="-145.23125"
       ry="0"
       transform="scale(-1)" />
    <g
       id="g3071"
       transform="matrix(0,1.0000126,-1.0000126,0,242.84085,40.81458)">
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.96384"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-99.875397"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-3"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-101.50807"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-6"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-102.05229"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-7"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.41962"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-5"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    </g>
  </g>
</svg>
}
          # scale-vn
          set imgtype(scale-vn) svg
          set imgdata(scale-vn) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="14"
   height="28"
   viewBox="0 0 5.10412 10.20824"
   version="1.1"
   id="svg8"
   sodipodi:docname="scale-vn.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="15.657207"
     inkscape:cx="6.8912706"
     inkscape:cy="13.984623"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="44"
     inkscape:window-y="37"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px"
     scale-x="0.26458" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-99.48979,-137.92546)">
    <rect
       style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.40609768;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect815"
       width="4.7264309"
       height="9.8160715"
       x="-104.38871"
       y="-147.94322"
       ry="0"
       transform="scale(-1)" />
    <g
       id="g3071"
       transform="matrix(0,1.3779575,-1.6359752,0,333.5297,4.0917157)">
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.96384"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-99.875397"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-3"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-101.50807"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-6"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-102.05229"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-7"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.41962"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-5"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    </g>
  </g>
</svg>
}
          # sizegrip
          set imgtype(sizegrip) svg
          set imgdata(sizegrip) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="24"
   height="24"
   viewBox="0 0 6.9850001 6.9849998"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)"
   sodipodi:docname="sizegrip.svg">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="14.75"
     inkscape:cx="11.932203"
     inkscape:cy="12"
     inkscape:document-units="mm"
     inkscape:current-layer="g894"
     showgrid="true"
     inkscape:window-width="1214"
     inkscape:window-height="532"
     inkscape:window-x="96"
     inkscape:window-y="14"
     inkscape:window-maximized="0"
     scale-x="1.1"
     units="px">
    <inkscape:grid
       type="xygrid"
       id="grid843" />
  </sodipodi:namedview>
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(0,-291.615)">
    <g
       id="g894"
       transform="matrix(0.47669842,0,0,0.47989316,-0.27326329,156.43376)">
      <g
         id="g950">
        <circle
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79"
           cx="14.324424"
           cy="282.63419"
           r="0.69321305" />
        <ellipse
           style="opacity:1;fill:#215d9b;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-3"
           cx="12.721766"
           cy="284.22617"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-6"
           cx="11.119109"
           cy="285.81818"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-7"
           cx="9.5164518"
           cy="287.41016"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-5"
           cx="7.913794"
           cy="289.00214"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-35"
           cx="6.3111362"
           cy="290.59412"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-62"
           cx="4.7084789"
           cy="292.18613"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-9"
           cx="3.1058214"
           cy="293.77811"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-1"
           cx="1.5031636"
           cy="295.37009"
           rx="0.69321311"
           ry="0.69321305" />
      </g>
      <g
         id="g959"
         transform="translate(-0.53809974,-0.04111673)">
        <ellipse
           inkscape:transform-center-y="-2.5681986"
           inkscape:transform-center-x="-1.8183937"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-3-7"
           cx="14.967299"
           cy="285.89139"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="-1.8042036"
           inkscape:transform-center-x="-1.05441"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-6-0"
           cx="13.364642"
           cy="287.48337"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="-1.0402233"
           inkscape:transform-center-x="-0.29042529"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-7-9"
           cx="11.761985"
           cy="289.07538"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="-0.27624296"
           inkscape:transform-center-x="0.47355939"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-5-3"
           cx="10.159327"
           cy="290.66736"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="0.48773736"
           inkscape:transform-center-x="1.2375436"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-35-6"
           cx="8.5566683"
           cy="292.25934"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="1.2517323"
           inkscape:transform-center-x="2.0015276"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-62-0"
           cx="6.954011"
           cy="293.85135"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="2.0157126"
           inkscape:transform-center-x="2.7655121"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-9-6"
           cx="5.3513532"
           cy="295.44333"
           rx="0.69321311"
           ry="0.69321305" />
      </g>
      <g
         id="g1056"
         transform="translate(-0.28974602,-0.04111673)">
        <ellipse
           inkscape:transform-center-y="-1.8042036"
           inkscape:transform-center-x="-1.05441"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-6-0-8"
           cx="14.689195"
           cy="289.13831"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="-1.0402233"
           inkscape:transform-center-x="-0.29042529"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-7-9-7"
           cx="13.086537"
           cy="290.73032"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="-0.27624296"
           inkscape:transform-center-x="0.47355939"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-5-3-9"
           cx="11.48388"
           cy="292.3223"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="0.48773736"
           inkscape:transform-center-x="1.2375436"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-35-6-2"
           cx="9.8812218"
           cy="293.91428"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="1.2517323"
           inkscape:transform-center-x="2.0015276"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-62-0-0"
           cx="8.2785645"
           cy="295.50629"
           rx="0.69321311"
           ry="0.69321305" />
      </g>
      <g
         id="g1034"
         transform="translate(8.4854191,7.1543113)">
        <ellipse
           inkscape:transform-center-y="-1.0402233"
           inkscape:transform-center-x="-0.29042529"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-7-9-7-7"
           cx="5.9463682"
           cy="285.23096"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="-0.27624296"
           inkscape:transform-center-x="0.47355939"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-5-3-9-5"
           cx="4.3437109"
           cy="286.82294"
           rx="0.69321311"
           ry="0.69321305" />
        <ellipse
           inkscape:transform-center-y="0.48773736"
           inkscape:transform-center-x="1.2375436"
           style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="path841-79-35-6-2-9"
           cx="2.7410524"
           cy="288.41492"
           rx="0.69321311"
           ry="0.69321305" />
      </g>
      <ellipse
         ry="0.69321305"
         rx="0.69321311"
         cy="295.49088"
         cx="14.451189"
         id="path841-79-6-0-8-2"
         style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
         inkscape:transform-center-x="-1.05441"
         inkscape:transform-center-y="-1.8042036" />
    </g>
  </g>
</svg>
}
          # slider-hd
          set imgtype(slider-hd) svg
          set imgdata(slider-hd) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="28"
   height="14"
   viewBox="0 0 7.4083338 3.7041668"
   version="1.1"
   id="svg8"
   sodipodi:docname="slider-hd.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="19.035714"
     inkscape:cx="14"
     inkscape:cy="7"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="41"
     inkscape:window-y="42"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px"
     showguides="false" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-97.353814,-139.48844)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#202425;stroke-width:0.29253346;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect815"
       width="3.4278965"
       height="7.1305251"
       x="139.61896"
       y="-104.60221"
       ry="0"
       transform="rotate(90)" />
  </g>
</svg>
}
          # slider-h-grip
          set imgtype(slider-h-grip) svg
          set imgdata(slider-h-grip) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="9.2482166"
   height="7.8451266"
   viewBox="0 0 2.4468931 2.0756636"
   version="1.1"
   id="svg8"
   sodipodi:docname="slider-h-grip.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="44.169565"
     inkscape:cx="4.6023201"
     inkscape:cy="3.883272"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="41"
     inkscape:window-y="42"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px"
     scale-x="0.06458"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-99.605399,-140.46056)">
    <rect
       style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect1368"
       width="2.0756626"
       height="0.269997"
       x="140.46056"
       y="-100.96384"
       ry="0.1349985"
       transform="rotate(90)" />
    <rect
       style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect1368-3"
       width="2.0756626"
       height="0.269997"
       x="140.46056"
       y="-99.875397"
       ry="0.1349985"
       transform="rotate(90)" />
    <rect
       style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect1368-6"
       width="2.0756626"
       height="0.269997"
       x="140.46056"
       y="-101.50807"
       ry="0.1349985"
       transform="rotate(90)" />
    <rect
       style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect1368-7"
       width="2.0756626"
       height="0.269997"
       x="140.46056"
       y="-102.05229"
       ry="0.1349985"
       transform="rotate(90)" />
    <rect
       style="opacity:1;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect1368-5"
       width="2.0756626"
       height="0.269997"
       x="140.46056"
       y="-100.41962"
       ry="0.1349985"
       transform="rotate(90)" />
  </g>
</svg>
}
          # slider-hn
          set imgtype(slider-hn) svg
          set imgdata(slider-hn) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="28"
   height="14"
   viewBox="0 0 7.4083338 3.7041669"
   version="1.1"
   id="svg8"
   sodipodi:docname="slider-hn.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="19.035714"
     inkscape:cx="14"
     inkscape:cy="7"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="41"
     inkscape:window-y="42"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px"
     showguides="false" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-97.353814,-139.48844)">
    <rect
       style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.29461741;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect815"
       width="3.4380579"
       height="7.1025405"
       x="139.6192"
       y="-104.59727"
       ry="0"
       transform="rotate(90)" />
  </g>
</svg>
}
          # slider-vd
          set imgtype(slider-vd) svg
          set imgdata(slider-vd) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="14"
   height="28"
   viewBox="0 0 3.7041666 7.4083333"
   version="1.1"
   id="svg8"
   sodipodi:docname="slider-vd.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="15.678571"
     inkscape:cx="7"
     inkscape:cy="14"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="41"
     inkscape:window-y="42"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-99.488592,-137.94053)">
    <rect
       style="opacity:1;fill:#224162;fill-opacity:1;stroke:#202425;stroke-width:0.29152358;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect815"
       width="3.4021287"
       height="7.1350117"
       x="-103.0423"
       y="-145.23125"
       ry="0"
       transform="scale(-1)" />
  </g>
</svg>
}
          # slider-v-grip
          set imgtype(slider-v-grip) svg
          set imgdata(slider-v-grip) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="7.8451266"
   height="9.2482166"
   viewBox="0 0 2.0756636 2.4468932"
   version="1.1"
   id="svg8"
   sodipodi:docname="slider-v-grip.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="44.169565"
     inkscape:cx="3.9007484"
     inkscape:cy="4.5847944"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="41"
     inkscape:window-y="42"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px"
     scale-x="0.06458"
     inkscape:pagecheckerboard="true" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-99.791021,-140.27494)">
    <g
       id="g833"
       transform="rotate(90,100.82885,141.49839)">
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.96384"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-99.875397"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-3"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-101.50807"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-6"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-102.05229"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-7"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         transform="rotate(90)"
         ry="0.1349985"
         y="-100.41962"
         x="140.46056"
         height="0.269997"
         width="2.0756626"
         id="rect1368-5"
         style="opacity:1;fill:#000000;fill-opacity:1;stroke:#07090b;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    </g>
  </g>
</svg>
}
          # slider-vn
          set imgtype(slider-vn) svg
          set imgdata(slider-vn) {
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="14"
   height="28"
   viewBox="0 0 5.10412 10.20824"
   version="1.1"
   id="svg8"
   sodipodi:docname="slider-vn.svg"
   inkscape:version="0.92.4 (5da689c313, 2019-01-14)">
  <defs
     id="defs2" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="15.678571"
     inkscape:cx="7"
     inkscape:cy="14"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1315"
     inkscape:window-height="617"
     inkscape:window-x="44"
     inkscape:window-y="37"
     inkscape:window-maximized="0"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     units="px"
     scale-x="0.26458" />
  <metadata
     id="metadata5">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-99.48979,-137.92546)">
    <rect
       style="opacity:1;fill:#215d9c;fill-opacity:1;stroke:#000000;stroke-width:0.40609768;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect815"
       width="4.7264309"
       height="9.8160715"
       x="-104.38871"
       y="-147.94322"
       ry="0"
       transform="scale(-1)" />
  </g>
</svg>
}
          #E == svgdata ==
        }

        if { $vars(theme.name) eq "awlight" } {
          # convert all the svg colors to awlight specific colors
          if { $vars(have.tksvg) } {
            foreach {n} [array names ::ttk::theme::awdark::imgdata] {
              set imgdata($n) $::ttk::theme::awdark::imgdata($n)
              if { [string match *arrow* $n] } {
                set oc $::ttk::theme::awdark::colors(highlight.selectbg)
                set nc $colors(curr.base.lighter)
                regsub -all $oc $imgdata($n) $nc imgdata($n)
              }
              foreach {oc nc} [list \
                  $::ttk::theme::awdark::colors(base.dark) \
                  $colors(base.dark) \
                  $::ttk::theme::awdark::colors(base.disabledfg) \
                  $colors(base.disabledfg) \
                  $::ttk::theme::awdark::colors(base.disabledbg) \
                  $colors(base.disabledbg) \
                  $::ttk::theme::awdark::colors(base.disabledborder) \
                  $colors(base.disabledborder) \
                  $::ttk::theme::awdark::colors(base.bpress) \
                  $colors(base.bpress) \
                  $::ttk::theme::awdark::colors(highlight.selectbg) \
                  $colors(highlight.selectbg) \
                  $::ttk::theme::awdark::colors(highlight.selectdisabledbg) \
                  $colors(highlight.selectdisabledbg) \
                  $::ttk::theme::awdark::colors(base.border) \
                  $colors(base.border) \
                  $::ttk::theme::awdark::colors(base.arrow) \
                  $colors(base.arrow) \
                  ] {
                regsub -all $oc $imgdata($n) $nc imgdata($n)
              }
            }
          }
        }

        # convert all the svg colors to the current colors
        if { $vars(have.tksvg) } {
          foreach {n} [array names imgdata] {
            if { [string match *arrow* $n] } {
              set oc $colors(highlight.selectbg)
              set nc $colors(curr.highlight.selectbg)
              if { $nc ne $oc } {
                regsub -all $oc $imgdata($n) $nc imgdata($n)
              }
            }
            foreach {oc nc} [list \
                $colors(base.dark) \
                $colors(curr.base.dark) \
                $colors(base.disabledfg) \
                $colors(curr.base.disabledfg) \
                $colors(base.disabledbg) \
                $colors(curr.base.disabledbg) \
                $colors(base.disabledborder) \
                $colors(curr.base.disabledborder) \
                $colors(base.bpress) \
                $colors(curr.base.bpress) \
                $colors(highlight.selectbg) \
                $colors(curr.highlight.selectbg) \
                $colors(highlight.selectdisabledbg) \
                $colors(curr.highlight.selectdisabledbg) \
                $colors(base.border) \
                $colors(curr.base.border) \
                $colors(base.arrow) \
                $colors(curr.base.arrow) \
                ] {
              if { $nc ne $oc } {
                regsub -all $oc $imgdata($n) $nc imgdata($n)
              }
            }
          }
        }

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
      }

      proc _mkimage { n } {
        variable vars
        variable imgtype
        variable imgdata
        variable images

        if { $vars(have.tksvg) &&
            [info exists imgtype($n)] &&
            $imgtype($n) eq "svg" &&
            [info exists imgdata($n)] } {
          set images($n) [image create photo -data $imgdata($n) \
              -format "svg -scale [expr {round($vars(scale.factor))}]"]
        }
        if { ! [info exists images($n)] } {
          set images($n) [image create photo -data $imgdata($n)]
        }
      }

      proc _createTheme { } {
        variable imgtype
        variable imgdata
        variable images
        variable vars

        # only the styling is set here.
        # the colors are set in setStyledColors

        ttk::style theme create $vars(theme.name) -parent clam -settings {
        # menu

        foreach {n} {menu-cb-un-pad menu-cb-sn-pad menu-rb-un-pad menu-rb-sn-pad} {
          _mkimage $n
        }

        # sliders, arrows

        if { $vars(have.tksvg) && [info exists imgdata(arrow-bg-right-n)] } {
          foreach {n} {slider-vn slider-vd slider-hn slider-hd
              scale-vn scale-vd scale-hn scale-hd
              arrow-bg-up-n arrow-bg-down-n arrow-bg-right-n arrow-bg-left-n
              arrow-bg-up-d arrow-bg-down-d arrow-bg-right-d arrow-bg-left-d
              combo-arrow-down-n combo-arrow-down-d
              arrow-right-n arrow-down-n arrow-down-d
              slider-h-grip slider-v-grip
              sizegrip} {
            _mkimage $n
          }

          foreach {dir} {up down left right} {
            ttk::style element create ${dir}arrow image \
                [list $images(arrow-bg-${dir}-n) \
                disabled $images(arrow-bg-${dir}-d) \
                pressed $images(arrow-bg-${dir}-n) \
                active $images(arrow-bg-${dir}-n)] \
                -border 4 -sticky news
          }
        }

        # small checkbutton and radiobutton images

        foreach {n} {cb-un-small cb-sn-small rb-un-small rb-sn-small} {
          _mkimage $n
        }

        # button

        ttk::style configure TButton \
            -anchor {} \
            -width -8 \
            -padding {5 4} \
            -borderwidth 1 \
            -relief raised

        # checkbutton

        foreach {n} {cb-un cb-ud cb-sn cb-sd cb-sa cb-ua} {
          _mkimage $n
        }

        ttk::style element create Checkbutton.indicator image \
            [list $images(cb-un) \
            {hover selected !disabled} $images(cb-sa) \
            {hover !selected !disabled} $images(cb-ua) \
            {!selected disabled} $images(cb-ud) \
            {selected disabled} $images(cb-sd) \
            {selected !disabled} $images(cb-sn)]

        ttk::style layout TCheckbutton {
          Checkbutton.focus -side left -sticky w -children {
            Checkbutton.indicator -side left -sticky {}
            Checkbutton.padding -sticky nswe -children {
              Checkbutton.label -sticky nswe
            }
          }
        }

        ttk::style configure TCheckbutton \
            -padding {5 1 1 1} \
            -borderwidth 1 \
            -relief none \
            -focusthickness 4

        ttk::style element create Menu.Checkbutton.indicator image \
            [list $images(cb-un-small) \
            {selected !disabled} $images(cb-sn-small)]

        ttk::style layout Menu.TCheckbutton {
          Checkbutton.padding -sticky nswe -children {
            Menu.Checkbutton.indicator -side left -sticky {}
          }
        }

        ttk::style configure Menu.TCheckbutton \
            -padding {5 1 1 1} \
            -borderwidth 0 \
            -relief none \
            -focusthickness 0

        # combobox

        if { $vars(have.tksvg) && [info exists images(combo-arrow-down-n)] } {
          ttk::style element create Combobox.downarrow image \
              [list $images(combo-arrow-down-n) \
              disabled $images(combo-arrow-down-d)] \
              -sticky e -border {18 0 0 0}
        }

        ttk::style configure TCombobox \
            -padding {5 2} \
            -borderwidth 1 \
            -arrowsize 15 \
            -relief none

        bind ComboboxListbox <Map> \
            [list +::ttk::theme::${vars(theme.name)}::awCboxHandler %W]

        # entry

        ttk::style configure TEntry \
            -padding {5 2} \
            -borderwidth 1 \
            -relief none

        # labelframe

        ttk::style configure TLabelframe \
            -borderwidth 1 \
            -relief groove

        # menubutton

        if { $vars(have.tksvg) && [info exists images(arrow-down-n)] } {
          ttk::style element create Menubutton.indicator image \
              [list $images(arrow-down-n) \
              disabled $images(arrow-down-d)]
        }

        ttk::style configure TMenubutton \
            -padding {5 2} \
            -relief none

        # notebook

        _createNotebookStyle

        ttk::style configure TNotebook \
            -borderwidth 0
        ttk::style configure TNotebook.Tab \
            -padding {1 0 1 0} \
            -focusthickness 5 \
            -borderwidth 0

        # panedwindow

        ttk::style configure Sash \
            -sashthickness 8

        # progressbar

        if { $vars(have.tksvg) && [info exists images(slider-hn)] } {
          ttk::style element create Horizontal.Progressbar.pbar image \
              $images(slider-hn) \
              -border 4
          ttk::style element create Vertical.Progressbar.pbar image \
              $images(slider-vn) \
              -border 4
        }

        ttk::style configure TProgressbar \
            -borderwidth 1 \
            -pbarrelief none

        # radiobutton

        foreach {n} {rb-un rb-ud rb-sn rb-sd rb-ua rb-sa} {
          _mkimage $n
        }

        ttk::style element create Radiobutton.indicator image \
            [list $images(rb-un) \
            {hover selected !disabled} $images(rb-sa) \
            {hover !selected !disabled} $images(rb-ua) \
            {!selected disabled} $images(rb-ud) \
            {selected disabled} $images(rb-sd) \
            {selected !disabled} $images(rb-sn)]

        ttk::style layout TRadiobutton {
          Radiobutton.focus -side left -sticky w -children {
            Radiobutton.indicator -side left -sticky {}
            Radiobutton.padding -sticky nswe -children {
              Radiobutton.label -sticky nswe
            }
          }
        }

        ttk::style configure TRadiobutton \
            -padding {5 1 1 1} \
            -borderwidth 1 \
            -relief none \
            -focusthickness 4

        ttk::style element create Menu.Radiobutton.indicator image \
            [list $images(rb-un-small) \
            {selected} $images(rb-sn-small)]

        ttk::style layout Menu.TRadiobutton {
          Radiobutton.padding -sticky nswe -children {
            Menu.Radiobutton.indicator -side left -sticky {}
          }
        }

        ttk::style configure Menu.TRadiobutton \
            -padding {5 1 1 1} \
            -borderwidth 0 \
            -relief none \
            -focusthickness 0

        # scale

        if { $vars(have.tksvg) && [info exists images(scale-hn)] } {
          # using a separate image for the grip for the scale slider
          # does not work, unlike the scrollbar.
          ttk::style element create Horizontal.Scale.slider image \
              [list $images(scale-hn) \
              disabled $images(scale-hd)] \
              -sticky {}
          ttk::style element create Vertical.Scale.slider image \
              [list $images(scale-vn) \
              disabled $images(scale-vd)] \
              -sticky {}
        }

        ttk::style configure TScale \
            -borderwidth 1

        # scrollbar

        if { $vars(have.tksvg) && [info exists images(slider-vn)] } {
          ttk::style element create Vertical.Scrollbar.grip image \
              [list $images(slider-v-grip)] -sticky {}
          ttk::style element create Vertical.Scrollbar.thumb image \
              [list $images(slider-vn) \
              disabled $images(slider-vd) \
              pressed $images(slider-vn) \
              active $images(slider-vn)] \
              -border 4 -sticky ns

          ttk::style element create Horizontal.Scrollbar.grip image \
              [list $images(slider-h-grip)] -sticky {}
          ttk::style element create Horizontal.Scrollbar.thumb image \
              [list $images(slider-hn) \
              disabled $images(slider-hd) \
              pressed $images(slider-hn) \
              active $images(slider-hn)] \
              -border 4 -sticky ew

         ttk::style layout Vertical.TScrollbar {
            Vertical.Scrollbar.uparrow -side top -sticky {}
            Vertical.Scrollbar.downarrow -side bottom -sticky {}
            Vertical.Scrollbar.trough -sticky nsew -children {
              Vertical.Scrollbar.thumb -expand 1 -unit 1 -children {
                Vertical.Scrollbar.grip -sticky {}
              }
            }
          }

          ttk::style layout Horizontal.TScrollbar {
            Horizontal.Scrollbar.leftarrow -side left -sticky {}
            Horizontal.Scrollbar.rightarrow -side right -sticky {}
            Horizontal.Scrollbar.trough -sticky nsew -children {
              Horizontal.Scrollbar.thumb -expand 1 -unit 1 -children {
                Horizontal.Scrollbar.grip -sticky {}
              }
            }
          }
        }

        ttk::style configure TScrollbar \
            -borderwidth 0

        # sizegrip

        if { $vars(have.tksvg) && [info exists images(sizegrip)] } {
          ttk::style element create sizegrip image $images(sizegrip)
        }

        # spinbox

        if { $vars(have.tksvg) && [info exists images(arrow-bg-down-n)] } {
          ttk::style element create Spinbox.uparrow image \
              [list $images(arrow-bg-up-n) \
              disabled  $images(arrow-bg-up-d)]
          ttk::style element create Spinbox.downarrow image \
              [list $images(arrow-bg-down-n) \
              disabled  $images(arrow-bg-down-d)]
        }

        ttk::style configure TSpinbox \
            -padding {5 2} \
            -borderwidth 1 \
            -relief none \
            -arrowsize 15
        }

        # treeview

        if { $vars(have.tksvg) && [info exists images(arrow-down-n)] } {
          # Treeitem.indicator already exists for some reason.
          # A new name must be used and a new layout created for 'Item'.
          ttk::style element create $vars(theme.name).Treeitem.indicator image \
              [list $images(arrow-right-n) \
              user1 $images(arrow-down-n)] \
              -sticky w
          ttk::style layout Item [list \
            Treeitem.padding -sticky nswe -children [list \
              $vars(theme.name).Treeitem.indicator -side left -sticky {} \
              Treeitem.image -side left -sticky {} \
              Treeitem.focus -side left -sticky {} -children { \
                Treeitem.text -side left -sticky {} \
              } \
            ]
          ]
        }
      }

      proc _createNotebookStyle { } {
        variable colors
        variable images
        variable vars

        set tag "$colors(curr.base.tabhighlight)$colors(curr.base.tabinactive)$colors(curr.highlight.selectbg)"
        foreach {k bg} [list \
            indhover $colors(curr.base.tabhighlight) \
            indnotactive $colors(curr.base.tabinactive) \
            indselected $colors(curr.highlight.selectbg) \
            ] {
          if { ! [info exists images($k.$bg)] } {
            set images($k.$bg) [image create photo \
                -width $vars(nb.img.width) -height $vars(nb.img.height)]
            set row [lrepeat $vars(nb.img.width) $bg]
            set pix [list]
            for {set i 0} {$i < $vars(nb.img.height)} {incr i} {
              lappend pix $row
            }
            $images($k.$bg) put $pix
          }
          set images($k) $images($k.$bg)
        }

        if { ! [info exists vars(cache.nb.ind.${tag})] } {
          ttk::style element create \
             Notebook.indicator.${tag} image \
             [list $images(indnotactive) \
             {hover active !selected !disabled} $images(indhover) \
             {selected !disabled} $images(indselected)]
          set vars(cache.nb.ind.${tag}) true
        }

        ttk::style layout TNotebook.Tab [list \
          Notebook.tab -sticky nswe -children [list \
            Notebook.padding -side top -sticky nswe -children [list \
              Notebook.indicator.${tag} -side top -sticky we \
              Notebook.focus -side top -sticky nswe -children {
                Notebook.label -side top -sticky {} \
              } \
            ] \
          ] \
        ]
      }

      proc _setStyledColors { {theme {}} } {
        variable colors
        variable vars

        if { $theme eq {} } {
          set theme $vars(theme.name)
        }

        ttk::style theme settings $theme {
          # defaults
          ttk::style configure . \
              -background $colors(curr.base.frame) \
              -foreground $colors(curr.text.text) \
              -borderwidth 1 \
              -bordercolor $colors(curr.base.border) \
              -darkcolor $colors(curr.base.darkest) \
              -lightcolor $colors(curr.base.darkest) \
              -troughcolor $colors(curr.base.entrybg) \
              -selectbackground $colors(curr.highlight.selectbg) \
              -selectforeground $colors(curr.highlight.selectfg) \
              -selectborderwidth 0 \
              -fieldbackground $colors(curr.base.entrybg) \
              -focuscolor $colors(curr.highlight.selectbg) \
              -insertcolor $colors(curr.base.lightest) \
              -relief none
          ttk::style map . \
              -background [list disabled $colors(curr.base.frame)] \
              -foreground [list active $colors(curr.text.text) \
                  focus $colors(curr.text.text) \
                  disabled $colors(curr.base.disabledfg)] \
              -selectbackground [list !focus $colors(curr.base.darkest)] \
              -selectforeground [list !focus $colors(curr.base.lightest)] \
              -bordercolor [list disabled $colors(curr.base.disabledborder)]

          # button

          ttk::style configure TButton \
              -bordercolor $colors(curr.base.frame) \
              -background $colors(curr.base.dark) \
              -lightcolor $colors(curr.base.lighter) \
              -darkcolor $colors(curr.base.darker)
          ttk::style map TButton \
              -background [list {hover !pressed !disabled} $colors(curr.base.bpress) \
                  {active !pressed} $colors(curr.base.bpress) \
                  {selected !disabled} $colors(curr.base.dark) \
                  pressed $colors(curr.base.dark) \
                  disabled $colors(curr.base.disabledbg)] \
              -lightcolor [list pressed $colors(curr.base.darker)] \
              -darkcolor [list pressed $colors(curr.base.lighter)]

          # checkbutton

          ttk::style map TCheckbutton \
              -indicatorcolor [list selected $colors(curr.base.lightest)] \
              -darkcolor [list disabled $colors(curr.base.frame)] \
              -lightcolor [list disabled $colors(curr.base.frame)]

          # combobox

          ttk::style configure TCombobox \
              -bordercolor $colors(curr.base.border) \
              -lightcolor $colors(curr.base.dark) \
              -darkcolor $colors(curr.base.dark) \
              -arrowcolor $colors(curr.base.arrow)
          ttk::style map TCombobox \
              -lightcolor [list active $colors(curr.highlight.selectbg) \
                  focus $colors(curr.highlight.selectbg)] \
              -darkcolor [list active $colors(curr.highlight.selectbg) \
                  focus $colors(curr.highlight.selectbg)] \
              -arrowcolor [list disabled $colors(curr.base.arrow.disabled)] \
              -fieldbackground [list disabled $colors(curr.base.disabledbg)]
          if { $::tcl_platform(os) eq "Darwin" } {
            # mac os x has cross-platform incompatibilities
            ttk::style configure TCombobox \
                -background $colors(curr.base.dark)
            ttk::style map TCombobox \
                -background [list disabled $colors(curr.base.disabledbg)]
          }

          # entry

          ttk::style configure TEntry \
              -background $colors(curr.base.dark) \
              -bordercolor $colors(curr.base.border) \
              -lightcolor $colors(curr.base.dark)
          ttk::style map TEntry \
              -lightcolor [list active $colors(curr.highlight.selectbg) \
                  focus $colors(curr.highlight.selectbg)] \
              -fieldbackground [list disabled $colors(curr.base.disabledbg)]
          if { $::tcl_platform(os) eq "Darwin" } {
            # mac os x has cross-platform incompatibilities
            ttk::style configure TEntry \
                -background $colors(curr.base.dark)
            ttk::style map TEntry \
                -background [list disabled $colors(curr.base.disabledbg)]
          }

          # frame

          ttk::style configure TFrame \
              -bordercolor $colors(curr.base.frame) \
              -lightcolor $colors(curr.base.lighter) \
              -darkcolor $colors(curr.base.darker)

          # labelframe

          ttk::style configure TLabelframe \
              -bordercolor $colors(curr.base.frame) \
              -lightcolor $colors(curr.base.frame) \
              -darkcolor $colors(curr.base.frame)

          # menubutton

          ttk::style configure TMenubutton \
              -arrowcolor $colors(curr.base.arrow)
          ttk::style map TMenubutton \
              -background [list {active !disabled} $colors(curr.highlight.selectbg)] \
              -foreground [list {active !disabled} $colors(curr.highlight.selectfg) \
                  disabled $colors(curr.base.disabledfg)] \
              -arrowcolor [list disabled $colors(curr.base.arrow.disabled)]

          # notebook

          ttk::style configure TNotebook \
              -bordercolor $colors(curr.base.frame) \
              -lightcolor $colors(curr.base.lighter) \
              -darkcolor $colors(curr.base.darker)
          ttk::style configure TNotebook.Tab \
              -lightcolor $colors(curr.base.frame) \
              -darkcolor $colors(curr.base.frame) \
              -bordercolor $colors(curr.base.tabborder) \
              -background $colors(curr.base.dark)

          # panedwindow

          ttk::style configure TPanedwindow \
              -background $colors(curr.base.dark)
          ttk::style configure Sash \
              -lightcolor $colors(curr.highlight.darkhighlight) \
              -darkcolor $colors(curr.base.darkest) \
              -sashthickness [expr {round(10*$vars(scale.factor))}]

          # progressbar

          ttk::style configure TProgressbar \
              -background $colors(curr.highlight.darkhighlight) \
              -bordercolor $colors(curr.base.border.light) \
              -lightcolor $colors(curr.highlight.darkhighlight) \
              -darkcolor $colors(curr.highlight.darkhighlight)
          ttk::style map TProgressbar \
              -troughcolor [list disabled $colors(curr.base.dark)] \
              -darkcolor [list disabled $colors(curr.base.disabledbg)] \
              -lightcolor [list disabled $colors(curr.base.disabledbg)]

          # scale

          # background is used both for the background and
          # for the grip colors
          ttk::style configure TScale \
              -background $colors(curr.highlight.darkhighlight) \
              -bordercolor $colors(curr.base.border.light) \
              -lightcolor $colors(curr.highlight.darkhighlight) \
              -darkcolor $colors(curr.highlight.darkhighlight)
          ttk::style map TScale \
              -troughcolor [list disabled $colors(curr.base.dark)] \
              -darkcolor [list disabled $colors(curr.base.disabledbg)] \
              -lightcolor [list disabled $colors(curr.base.disabledbg)]

          # scrollbar

          ttk::style configure TScrollbar \
              -background $colors(curr.highlight.selectbg) \
              -bordercolor $colors(curr.base.border.light) \
              -lightcolor $colors(curr.highlight.selectbg) \
              -darkcolor $colors(curr.highlight.selectbg) \
              -arrowcolor $colors(curr.base.lightest)
          ttk::style map TScrollbar \
              -arrowcolor [list disabled $colors(curr.base.arrow.disabled)] \
              -darkcolor [list disabled $colors(curr.base.frame)] \
              -lightcolor [list disabled $colors(curr.base.frame)]

          # spinbox

          ttk::style configure TSpinbox \
              -bordercolor $colors(curr.base.border) \
              -lightcolor $colors(curr.base.dark) \
              -arrowcolor $colors(curr.base.arrow)
          ttk::style map TSpinbox \
              -lightcolor [list active $colors(curr.highlight.selectbg) \
                  focus $colors(curr.highlight.selectbg)] \
              -darkcolor [list active $colors(curr.highlight.selectbg) \
                  focus $colors(curr.highlight.selectbg)] \
              -arrowcolor [list disabled $colors(curr.base.arrow.disabled)] \
              -fieldbackground [list disabled $colors(curr.base.disabledbg)]
          if { $::tcl_platform(os) eq "Darwin" } {
            # mac os x has cross-platform incompatibilities
            ttk::style configure TSpinbox \
                -background $colors(curr.base.dark)
            ttk::style map TSpinbox \
                -background [list disabled $colors(curr.base.disabledbg)]
          }

          # treeview

          ttk::style configure Treeview \
              -fieldbackground $colors(curr.base.frame)
          ttk::style map Treeview \
              -background [list selected $colors(curr.highlight.selectbg)] \
              -foreground [list selected $colors(curr.highlight.selectfg)]
        }
      }

      proc setBackground { bcol } {
        variable colors
        variable vars

        if { ! [package present colorutils] } {
          return
        }

        foreach {k} [array names colors base.*] {
          regsub {^base} $k curr nk
          set tc [::colorutils::adjustColor $colors($k) $colors(base.frame) $bcol]
          set colors($nk) $tc
        }

        _setColors
      }

      proc setHighlight { hcol } {
        variable colors
        variable vars

        if { ! [package present colorutils] } {
          return
        }

        foreach {k} [array names colors highlight.*] {
          regsub {^highlight} $k curr nk
          set tc [::colorutils::adjustColor $colors($k) $colors(highlight.selectbg) $hcol]
          set colors($nk) $tc
        }

        _setColors
      }

      proc _setColors { } {
        variable vars

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

        _createNotebookStyle
      }

      proc setMenuColors { w } {
        variable colors
        variable images
        variable vars

        if { ! [dict exists $vars(cache.menu) $w] } {
          dict set vars(cache.menu) $w 1
        }

        $w configure -background $colors(curr.base.frame)
        $w configure -foreground $colors(curr.text.text)
        $w configure -activebackground $colors(curr.highlight.selectbg)
        $w configure -activeforeground $colors(curr.highlight.selectfg)
        $w configure -disabledforeground $colors(curr.base.disabledfg)
        $w configure -selectcolor $colors(curr.highlight.selectbg)

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
        } ; # using flexmenu? (has -mode)
      }

      proc setListboxColors { w } {
        variable colors
        variable images
        variable vars

        if { ! [dict exists $vars(cache.listbox) $w] } {
          dict set vars(cache.listbox) $w 1
        }

        $w configure -background $colors(curr.base.frame)
        $w configure -foreground $colors(curr.text.text)
        $w configure -disabledforeground $colors(curr.base.disabledfg)
        $w configure -selectbackground $colors(curr.highlight.selectbg)
        $w configure -selectforeground $colors(curr.highlight.selectfg)
        $w configure -borderwidth 1p
        $w configure -relief solid
      }

      proc setTextColors { w {useflag {}} } {
        variable colors
        variable images
        variable vars

        if { ! [dict exists $vars(cache.text) $w] } {
          dict set vars(cache.text) $w $useflag
        }

        if { $useflag eq "-entry" } {
          $w configure -background $colors(curr.base.entrybg)
        } elseif { $useflag eq "-dark" } {
          $w configure -background $colors(curr.base.dark)
        } else {
          $w configure -background $colors(curr.base.frame)
        }
        $w configure -foreground $colors(curr.text.text)
        $w configure -selectforeground $colors(curr.highlight.selectfg)
        $w configure -selectbackground $colors(curr.highlight.selectbg)
        $w configure -inactiveselectbackground $colors(curr.base.darkest)
        $w configure -borderwidth 1p
      }

      proc awCboxHandler { w } {
        variable vars
        variable colors

        set theme [ttk::style theme use]
        if { [info exists colors(curr.base.entrybg)] &&
            $theme eq $vars(theme.name) &&
            ! [dict exists $vars(cache.listbox) $w] } {
          ::ttk::theme::${vars(theme.name)}::setListboxColors $w
        }
      }

      init
    }
  }
}

awinit
unset -nocomplain ::awthemename
