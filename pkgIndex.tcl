package ifneeded awdark 4.2 {
    set ::awthemename awdark
    source [file join $dir awthemes.tcl]
}
package ifneeded awlight 4.2 {
    set ::awthemename awlight
    source [file join $dir awthemes.tcl]
}
package ifneeded black 4.2 {
    set ::awthemename black
    source [file join $dir awthemes.tcl]
}
package ifneeded colorutils 4.3 \
    [list source [file join $dir colorutils.tcl]] 
package ifneeded themeutils 2.0 \
    [list source [file join $dir themeutils.tcl]] 
