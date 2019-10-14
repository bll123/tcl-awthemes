
The following files are needed:
  awthemes.tcl, colorutils.tcl, themeutils.tcl, pkgIndex.tcl, i/

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
