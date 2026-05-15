#!/usr/bin/env sh
# Challenger Deep theme for fzf
# Palette: https://github.com/challenger-deep-theme/themes
#
# Two ways to use this file:
#
# 1. Source it from ~/.zshrc AFTER your existing FZF_DEFAULT_OPTS line:
#        export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
#        . ~/.config/themes/fzf-challengerdeep.sh
#    The snippet appends --color=... to whatever FZF_DEFAULT_OPTS already holds,
#    so your existing flags are preserved.
#
# 2. Or copy the FZF_CHALLENGERDEEP_COLORS value below and paste it directly
#    into your FZF_DEFAULT_OPTS string.
#
# bg and gutter are -1 (transparent) so the theme inherits your terminal bg —
# replace with #1b182c if you want the theme to be self-contained.

FZF_CHALLENGERDEEP_COLORS='--color='\
'fg:#cbe3e7,bg:-1,hl:#ffe9aa,'\
'fg+:#cbe3e7,bg+:#3b3470,hl+:#ffb378,'\
'gutter:-1,'\
'border:#3b3470,separator:#3b3470,scrollbar:#3b3470,label:#a6b3cc,'\
'info:#a6b3cc,prompt:#906cff,pointer:#c991e1,marker:#62d196,'\
'spinner:#906cff,header:#63f2f1,query:#cbe3e7,disabled:#5a5475,'\
'preview-fg:#cbe3e7,preview-bg:-1,preview-border:#3b3470,'\
'preview-scrollbar:#3b3470,preview-label:#a6b3cc'

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }$FZF_CHALLENGERDEEP_COLORS"
