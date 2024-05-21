
" don't replace the clipboard selection on pasting over a visual block
xnoremap p P

" always copy to system clipboard
set clipboard+=unnamedplus

" Sets how many lines of history VIM has to remember
set history=500

" add wl-copy pasting hack for VIM, if we're running on Wayland and has
" wl-copy installed
if empty($WAYLAND_DISPLAY) || !executable("wl-copy")
    finish
endif
xnoremap "+y y:call system("wl-copy", @")<cr>
nnoremap "+p :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g')<cr>p
nnoremap "*p :let @"=substitute(system("wl-paste --no-newline --primary"), '<C-v><C-m>', '', 'g')<cr>p
