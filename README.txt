
Only the 'awthemes.tcl', 'colorutils.tcl' and 'pkgIndex.tcl' files
are necessary.  The other files are infrastructure files and only
needed for development.

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
