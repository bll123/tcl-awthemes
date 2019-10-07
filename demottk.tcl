#!/usr/bin/tclsh

package require Tk

if { [llength $::argv] < 1 } {
  puts "Usage: demottk.tcl <theme> [-scale <scale-factor>]"
  exit 1
}

set fn data/bll-tecra/tkscale.txt
if { [file exists $fn] } {
  set fh [open $fn r]
  set scale [gets $fh]
  close $fh
  tk scaling -displayof . $scale
}

set theme [lindex $::argv 0]
if { [llength $::argv] == 3 } {
  if { [lindex $::argv 1] eq "-scale" } {
    tk scaling [lindex $::argv 2]
  }
}

set calcdpi [expr {round([tk scaling]*72.0)}]
set scalefactor [expr {$calcdpi/100.0}]

# replace this block with your method of loading the theme
if { 0 } {
  set ap [file normalize [file join [file dirname [info script]] .. code]]
  if { $ap ni $::auto_path } {
    lappend ::auto_path $ap
  }
  unset ap
  package require themeloader
  themeloader::loadTheme $theme
} ; # if 0

set ttheme $theme
if { $theme eq "awdark" || $theme eq "awlight" } {
  set ttheme awthemes
}
if { [file exists $ttheme.tcl] } {
  source $ttheme.tcl
}

ttk::style theme use $theme

set val 55
set valb $theme
set off 0
set on 1

. configure -background [ttk::style lookup TFrame -background]

# Tk defaults to pixels.  Sigh.
# Use points so that the fonts scale.
font configure TkDefaultFont -size 11
font create TextFont
font configure TextFont -size 10
font create MenuFont
font configure MenuFont -size 9

menu .mb -font MenuFont
. configure -menu .mb

menu .mb.example -tearoff 0 -font MenuFont
.mb.example add command -label Menu-1
.mb.example add command -label Menu-2
.mb add cascade -label Example -menu .mb.example

menu .mb.b -tearoff 0 -font MenuFont
.mb add cascade -label {not in use} -menu .mb.b

menu .mb.widgets -tearoff 0 -font MenuFont
.mb.widgets add checkbutton -label checkA
.mb.widgets add checkbutton -label checkB
.mb.widgets add radiobutton -label radioA
.mb.widgets add radiobutton -label radioB
.mb.widgets add command -label widgets-2
.mb add cascade -label widgets -menu .mb.widgets

foreach {w} {.mb .mb.example .mb.widgets} {
  if { [info commands ::ttk::theme::${theme}::setMenuColors] ne {} } {
    ::ttk::theme::${theme}::setMenuColors $w
  } else {
    set c [ttk::style lookup . -background]
    if { $c ne {} } {
      $w configure -background $c
    }
    set c [ttk::style lookup . -foreground]
    if { $c ne {} } {
      $w configure -foreground $c
    }
    set c [ttk::style lookup TEntry -selectforeground focus]
    if { $c ne {} } {
      $w configure -activeforeground $c
    }
    set c [ttk::style lookup TEntry -selectbackground focus]
    if { $c ne {} } {
      $w configure -activebackground $c
    }
    set c [ttk::style lookup TEntry -foreground disabled]
    if { $c ne {} } {
      $w configure -disabledforeground $c
    }
  }
  $w configure -borderwidth 0
  $w configure -activeborderwidth 0
}

ttk::style configure TFrame -borderwidth 0

ttk::notebook .nb
pack .nb -side left -fill both -expand true
ttk::frame .one
ttk::labelframe .lfn -text " Normal "
ttk::labelframe .lfd -text " Disabled "
.nb add .one -text $theme
ttk::frame .two
.nb add .two -text {Text w/scroll}
ttk::frame .three
.nb add .three -text {Paned Window}
ttk::frame .four
.nb add .four -text {Treeview}
ttk::frame .five
.nb add .five -text {Menubutton}
ttk::frame .six
.nb add .six -text {Listbox}

foreach {k} {n d} {
  set s !disabled
  if { $k eq "d" } {
    set s disabled
  }
  ttk::frame .bf$k
  ttk::label .lb$k -text $theme -state $s
  ttk::button .b$k -text $theme -state $s
  pack .lb$k .b$k -in .bf$k -side left -padx 3p

  ttk::combobox .combo$k -values \
      [list aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk lll mmm nnn ooo ppp] \
      -textvariable valb \
      -width 15 \
      -state $s \
      -height 5 \
      -font TkDefaultFont
  option add *TCombobox*Listbox.font TkDefaultFont

  ttk::frame .cbf$k
  ttk::checkbutton .cboff$k -text off -variable off -state $s
  ttk::checkbutton .cbon$k -text on -variable on -state $s
  pack .cboff$k .cbon$k -in .cbf$k -side left -padx 3p

  ttk::separator .sep$k

  ttk::frame .rbf$k
  ttk::radiobutton .rboff$k -text off -variable on -value 0 -state $s
  ttk::radiobutton .rbon$k -text on -variable on -value 1 -state $s
  pack .rboff$k .rbon$k -in .rbf$k -side left -padx 3p

  pack .bf$k .combo$k .cbf$k .sep$k .rbf$k \
      -in .lf$k -side top -anchor w -padx 3p -pady 3p
  pack configure .sep$k -fill x -expand true

  ttk::frame .hf$k
  ttk::scale .sc$k \
      -from 0 \
      -to 100 \
      -variable val \
      -length [expr {round(100*$scalefactor)}]
  .sc$k state $s
  ttk::progressbar .pb$k \
      -mode determinate \
      -variable val \
      -length [expr {round(100*$scalefactor)}]
  .pb$k state $s
  ttk::entry .ent$k -textvariable valb \
      -width 15 \
      -state $k \
      -font TkDefaultFont
  ttk::spinbox .sbox$k -textvariable val \
      -width 5 \
      -from 1 -to 100 -increment 0.1 \
      -state $k \
      -font TkDefaultFont
  pack .sc$k .pb$k .ent$k .sbox$k \
      -in .hf$k -side top -anchor w -padx 3p -pady 3p

  ttk::frame .vf$k
  ttk::scale .scv$k \
      -orient vertical \
      -from 0 -to 100 \
      -variable val \
      -length [expr {round(100*$scalefactor)}]
  .scv$k state $s
  ttk::progressbar .pbv$k -orient vertical \
      -mode determinate \
      -variable val \
      -length [expr {round(100*$scalefactor)}]
  .pbv$k state $s
  pack .scv$k .pbv$k -in .vf$k -side right -padx 3p -pady 3p

  pack .hf$k .vf$k -in .lf$k -side left -anchor e
}
pack .lfn .lfd -in .one -side left -padx 3p -pady 3p -expand 1 -fill both
ttk::sizegrip  .sg
pack .sg -in .one -side right -anchor se

proc twrap { } {
  set c [.text cget -wrap]
  if { $c eq "none" } {
    set c word
  } else {
    set c none
  }
  .text configure -wrap $c
}

ttk::button .wrap -text Wrap -command twrap
pack .wrap -in .two -side bottom -anchor se
if { $theme eq "aqua" } {
  ttk::scrollbar .sbv -command [list .text yview]
  ttk::scrollbar .sbh -orient horizontal -command [list .text xview]
} else {
  ttk::scrollbar .sbv -command [list .text yview] -style Vertical.TScrollbar
  ttk::scrollbar .sbh -orient horizontal -command [list .text xview] \
      -style Horizontal.TScrollbar
}
pack .sbv -in .two -side right -fill y -expand false
pack .sbh -in .two -side bottom -fill x -expand false
text .text \
    -xscrollcommand [list .sbh set] \
    -yscrollcommand [list .sbv set] \
    -wrap none \
    -relief flat \
    -borderwidth 0 \
    -height 10 \
    -width 50 \
    -highlightthickness 0 \
    -font TextFont
if { [info commands ::ttk::theme::${theme}::setTextColors] ne {} } {
  ::ttk::theme::${theme}::setTextColors .text
}
bind .text <MouseWheel> {%W yview scroll [expr {int(pow(-%D/240,3))}] units}
pack .text -in .two -fill both -expand true
.text insert end {
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis non velit aliquam, malesuada nisi blandit, pellentesque ligula. Pellentesque convallis pulvinar justo ac blandit. Praesent scelerisque, risus vitae rhoncus feugiat, metus ante feugiat leo, sit amet iaculis dui urna vitae purus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Mauris mollis libero at ipsum mollis, non aliquet nunc porta. Mauris auctor lobortis neque, at ullamcorper elit porttitor a. Aliquam eu porttitor ante. Sed arcu dolor, pretium non diam in, imperdiet pellentesque ipsum. Quisque sollicitudin nisl ex, sodales scelerisque nunc consequat volutpat. Vestibulum aliquet augue mauris, sit amet commodo urna consectetur interdum. Aenean dignissim tellus eu sollicitudin porta. Aliquam accumsan vel leo non iaculis. Sed pharetra, tortor non malesuada pellentesque, felis magna tempor turpis, nec tincidunt justo erat in justo. Aliquam congue, lectus nec pulvinar euismod, enim lorem venenatis tellus, vitae placerat magna ligula in leo. Praesent nisl lectus, ornare tristique consequat egestas, fermentum a urna. Morbi metus nulla, convallis ac orci a, imperdiet pretium purus.

Aenean tincidunt dui lacinia urna sagittis bibendum. Maecenas eu vestibulum tellus, viverra tincidunt mi. Sed sollicitudin mattis mi, quis pellentesque urna. Ut auctor ligula eu lectus imperdiet, sed tempus massa tristique. Curabitur ac eros euismod, pellentesque sapien eget, pretium justo. Aliquam quis turpis nec tellus vehicula maximus vel ac urna. Proin efficitur purus erat, sed tristique enim faucibus ac. Nullam hendrerit tempor tincidunt. Duis id dolor enim.

Quisque malesuada volutpat ex, id porta sem. Cras tristique tellus eget urna tincidunt ultrices. Nunc mollis consectetur odio a ultrices. Morbi sed imperdiet odio. In hac habitasse platea dictumst. Mauris tellus dui, pretium sed dolor sit amet, accumsan pretium est. Donec eu libero in felis suscipit ultrices et nec magna. Nunc accumsan quam sem, ut pharetra mauris dapibus id. Sed mi quam, consectetur eu iaculis luctus, viverra gravida neque. Proin vel maximus nunc.

Phasellus non ultricies mi. Aliquam erat volutpat. Ut sed mollis felis, nec imperdiet sapien. Etiam id lacus at augue tempus malesuada. Cras vel est ac metus tempus dictum. Aliquam metus tortor, rutrum nec blandit id, dapibus quis felis. Nulla viverra sit amet est ac gravida. Phasellus ac vestibulum turpis. Proin dictum viverra lobortis.

Pellentesque commodo tellus ut semper consectetur. Praesent lacus sem, porta sit amet ligula vel, varius mattis ipsum. Praesent erat nisl, vulputate ut ultricies quis, accumsan sit amet diam. Nulla tempor, nunc in malesuada venenatis, purus erat blandit lectus, sit amet pretium arcu arcu id erat. Donec ante eros, sagittis nec tellus eget, porta faucibus nisl. Integer a ex sed felis varius finibus. In hac habitasse platea dictumst. Proin et nisl orci. Fusce mauris nulla, feugiat sit amet commodo viverra, posuere sit amet augue. Vestibulum congue ligula nec dolor dapibus scelerisque. Proin enim sem, congue et nibh nec, suscipit cursus ligula.
}

ttk::panedwindow .pw -orient horizontal
pack .pw -in .three -fill both -expand true
ttk::frame .p1
ttk::frame .p2
.pw add .p1
.pw add .p2
ttk::label .pl1 -text {Pane 1}
ttk::label .pl2 -text {Pane 2}
pack .pl1 -in .p1 -anchor nw
pack .pl2 -in .p2 -anchor se

ttk::style configure Treeview \
    -rowheight [expr {[font metrics TkDefaultFont -linespace] + 2}]
ttk::treeview .tv -columns {a b c}
pack .tv -in .four -fill both -expand true
.tv heading #0 -text #0
.tv heading a -text AAA
.tv heading b -text BBB
.tv heading c -text CCC
set id [.tv insert {} 0 -text {item 0} -values {a b c}]
.tv insert $id 0 -text {subitem 0-1} -values {aa bb cc}
.tv insert $id 1 -text {subitem 0-2} -values {dd ee ff}
.tv insert $id 2 -text {subitem 0-3} -values {gg hh ii}
set id [.tv insert {} 1 -text {item 1} -values {j k l}]
.tv insert $id 0 -text {subitem 1-1} -values {mm nn oo}
.tv insert $id 1 -text {subitem 1-2} -values {pp qq rr}
.tv insert $id 2 -text {subitem 1-3} -values {ss tt uu}
set id [.tv insert {} 2 -text {item 2} -values {v w x}]
.tv insert $id 0 -text {subitem 2-1} -values {y y y}
.tv insert $id 1 -text {subitem 2-2} -values {z z z}
.tv insert $id 2 -text {subitem 2-3} -values {& & &}

ttk::frame .menubar -borderwidth 0 -takefocus 0
pack .menubar -in .five -side top -fill x

ttk::menubutton .menubar.file -text File \
    -underline 0 -menu .menubar.file.m
ttk::menubutton .menubar.edit -text Edit \
    -underline 0 -menu .menubar.edit.m
ttk::menubutton .menubar.dis -text Disabled \
    -underline 0 -menu .menubar.dis.m -state disabled

menu .menubar.file.m -tearoff 0  -font MenuFont
.menubar.file.m add command -label "Exit" \
    -underline 1 -command exit
if { [info commands ::ttk::theme::${theme}::setMenuColors] ne {} } {
  ::ttk::theme::${theme}::setMenuColors .menubar.file.m
}

menu .menubar.edit.m -tearoff 0  -font MenuFont
.menubar.edit.m add command -label "Cut" \
    -underline 2 \
    -command {event generate [focus] <<Cut>>}
.menubar.edit.m add command -label "Copy" \
    -underline 0 \
    -command {event generate [focus] <<Copy>>}
.menubar.edit.m add command -label "Paste" \
    -command {event generate [focus] <<Paste>>}
if { [info commands ::ttk::theme::${theme}::setMenuColors] ne {} } {
  ::ttk::theme::${theme}::setMenuColors .menubar.edit.m
}

menu .menubar.dis.m -tearoff 0 -font MenuFont
.menubar.dis.m add command -label "xyzzy"
.menubar.dis.m add command -label "plugh"
if { [info commands ::ttk::theme::${theme}::setMenuColors] ne {} } {
  ::ttk::theme::${theme}::setMenuColors .menubar.dis.m
}

pack .menubar.file .menubar.edit .menubar.dis -side left

if { $theme eq "aqua" } {
  ttk::scrollbar .sblbox -command [list .lbox yview]
} else {
  ttk::scrollbar .sblbox -command [list .lbox yview] -style Vertical.TScrollbar
}
set ::lbox [list aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk lll mmm nnn ooo ppp qqq rrr sss ttt uuu vvv www xxx yyy zzz]
listbox .lbox \
    -listvariable ::lbox \
    -yscrollcommand [list .sblbox set] \
    -highlightthickness 0 \
    -font TextFont

if { [info commands ::ttk::theme::${theme}::setListboxColors] ne {} } {
  ::ttk::theme::${theme}::setListboxColors .lbox
}
pack .sblbox -in .six -side right -padx 0 -pady 3p -fill y
pack .lbox -in .six -padx 3p -pady 3p -expand true -fill both
