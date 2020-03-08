
The following files are needed:
  awthemes.tcl, colorutils.tcl, pkgIndex.tcl,
  awblack.tcl, awdark.tcl, awlight.tcl, awwinxpblue.tcl,
  i/
Demonstration scripts:
  demottk.tcl, demoscaled.tcl

Try:
  # application scaling
  tclsh demottk.tcl winxpblue -fontscale 1.2
  # tk scaling only
  tclsh demottk.tcl winxpblue -ttkscale 2.0
  # user with high dpi, smaller font
  tclsh demottk.tcl winxpblue -ttkscale 2.0 -fontscale 0.7
  # scaled styling
  tclsh demoscaled.tcl winxpblue

7.8 (2020-3-8)
   - fix highlight background/color for text/label widgets.

7.7 (2020-1-17)
   - fix crash when tksvg not present.
   - improve awdark border colors.

7.6 (2019-12-7)
   - better grip design

7.5 (2019-12-4)
   - reworked all .svg files.
   - cleaned up notebook colors.
   - fixed scaling issue with scaled style scaling.
   - fixed combobox scaling.
   - fixed scrollbar arrows.
   - scaled combobox listbox scrollbar.

7.4 (2019-12-3)
   - added hasImage routine for use by checkButtonToggle
   - Fix menu highlight color

7.3 (2019-12-2)
   - fix spinbox scaled styling

7.2 (2019-12-2)
   - setBackground will not do anything if the background color is unchanged.
   - fixed a bug with graphical buttons.
   - make setbackground more robust.

7.1 (2019-12-1)
   - fix border/padding scaling, needed for rounded buttons/tabs.

7.0 (2019-11-30)
   - clean up .svg files to use alpha channel for disabled colors.
   - calculate some disabled colors.
   - fix doc.
   - split out theme specific code into separate files.
   - Fix scaledStyle set of treeview indicator.
   - make the tab topbar a generalized option.
   - merge themeutils package
   - clean up notebook tabs.
   - winxpcblue: notebook tab graphics.
   - winxpcblue: disabled images.
   - black: disabled cb/rb images.
   - black: add labelframe color.
6.0  (2019-11-23)
   - fix !focus colors
   - slider border color
   - various styling fixes and improvements
   - separate scrollbar color
   - optional scrollbar grip
   - button images are now supported
   - added winxpblue scalable theme
   - fixed missing awdark and awlight labelframe

awthemes 5.1 (2019-11-20)
   - add more colors to support differing spinbox and scroll arrow colors.
   - awlight, awdark, black theme cleanup
   - rename menubutton arrow .svg files.
   - menubutton styling fixes

awthemes 5.0
   - rewrite so that the procedures are no longer duplicated.
   - rewrite set of arrow height/width and combobox arrow height.
   - Add scaledStyle procedure to add a scaled style to the theme.
   - Added a user configurable scaling factor.

awthemes 4.2.1
   - fix pkgIndex.tcl to be able to load the themes

awthemes 4.2
   - fix scaling of images.
   - size menu radiobutton and checkbutton images.
   - add support for flexmenu.

awthemes 4.1
   - breaking change: renamed tab.* color names to base.tab.*
   - fix bugs in setBackground and setHighlight caused by the color
       renaming.
   - fix where the hover color for check and radio buttons is set.

awthemes 4.0
   - added support for other clam based themes.
   - breaking change: the .svg files are now loaded from the filesystem
       in order to support multiple themes.
   - breaking change: All of the various colors and derived colors have
       been renamed.
   - awdark/awlight: Fixed empty treeview indicator.
   - added scalable 'black' theme.

awthemes 3.1
  - Added themeutils.tcl.
      ::themeutils::setThemeColors awdark color-name color ...
    allows the colors to be set.  The graphical colors will be
    changed when tksvg is in use.  See themeutils.tcl for a list
    of color names.

awthemes 3.0
  - Breaking change: The package name has been renamed so
    that 'package require awdark' works.

  - Support for tksvg has been added.
    New graphics have been added to support tksvg, and the graphics
    will scale according to the 'tk scaling' setting.

    'tk scaling' must be set prior to the package require statement.

  - demottk.tcl has been updated to have scalable fonts.
    The 'tk scaling' factor may be specified on the command line:
      demottk.tcl <theme> [-scale <tk-scaling>]
