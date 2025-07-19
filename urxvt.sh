cat >> /etc/X11/app-defaults/URxvt << "EOF"
! generic
*foreground:                  #cccccc
*background:                  #000000

! urxvt
urxvt.font:                   xft:xos4 Terminus:size=13:antialias=true:hinting=true
urxvt.url-launcher:           /usr/bin/xdg-open
urxvt.matcher.button:         1
urxvt.scrollBar:              false
urxvt.termName:               xterm-256color
urxvt.saveLines:              10000
urxvt.inheritPixmap:          true
urxvt.shading:                20
urxvt.clipboard.autocopy:     true
urxvt.perl-ext-common:        default,selection-to-clipboard,pasta,matcher,keyboard-select,resize-font,font
urxvt.keysym.M-u:             perl:url-select:select_next
urxvt.transparent:            true
urxvt.buffered:               true
urxvt.jumpScroll:             false
urxvt.scrollTtyKeypress:      true
urxvt.scrollTtyOutput:        false
urxvt.scrollWithBuffer:       false
urxvt.scrollstyle:            plain
urxvt.secondaryScroll:        false
urxvt.xftAntialias:           true
!urxvt.color4:                 RoyalBlue
urxvt.color12:                RoyalBlue
urxvt.matcher.rend.0:         Bold fg6
urxvt.cursorBlink:            false
urxvt.cursorColor:            RoyalBlue
urxvt.mapAlert:               true
urxvt.pointerBlank:           true
urxvt.resource:               value
urxvt.iso14755:               false
urxvt.iso14755_52:            false
URxvt.geometry:               80x28
EOF
cat >> /etc/X11/app-defaults/XTerm << "EOF"

EOF
