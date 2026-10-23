#!/usr/bin/env bash
# Renders the lockscreen clock as Pango markup so each part can be styled
# independently, like my SDDM "stellarium" theme:
#   HH  -> EB Garamond, warm ink (#cdd6f4)
#   :   -> EB Garamond, faint   (#7f849c)
#   MM  -> Newsreader italic, accent lavender (#b4befe)
H=$(date +%H)
M=$(date +%M)
printf '<span font_family="EB Garamond" foreground="#cdd6f4">%s</span><span font_family="EB Garamond" foreground="#7f849c">:</span><span font_family="Newsreader" style="italic" foreground="#b4befe">%s</span>' "$H" "$M"
