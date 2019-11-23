proc awthemeloadhelper { theme dir } {
  set ::awthemename $theme
  source [file join $dir awthemes.tcl]
}

package ifneeded awdark 6.0 \
    [list awthemeloadhelper awdark $dir]
package ifneeded awlight 6.0 \
    [list awthemeloadhelper awdark $dir]
package ifneeded black 6.0 \
    [list awthemeloadhelper black $dir]
package ifneeded winxpblue 6.0 \
    [list awthemeloadhelper black $dir]
package ifneeded colorutils 4.3 \
    [list source [file join $dir colorutils.tcl]] 
package ifneeded themeutils 2.3 \
    [list source [file join $dir themeutils.tcl]] 
