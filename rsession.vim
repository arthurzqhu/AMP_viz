let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/AMP_viz
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +12 rampviz.m
badd +0 ramsvar.m
badd +52 rglobal_var.m
badd +1 loadrams.m
badd +1 rvar2phys.m
argglobal
%argdel
$argadd rampviz.m
$argadd ramsvar.m
$argadd rglobal_var.m
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit rampviz.m
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 106 + 105) / 210)
exe 'vert 2resize ' . ((&columns * 103 + 105) / 210)
argglobal
3argu
if bufexists(fnamemodify("rampviz.m", ":p")) | buffer rampviz.m | else | edit rampviz.m | endif
if &buftype ==# 'terminal'
  silent file rampviz.m
endif
balt rglobal_var.m
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 18 - ((17 * winheight(0) + 27) / 55)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 18
normal! 016|
wincmd w
argglobal
3argu
balt rampviz.m
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
65
normal! zo
let s:l = 80 - ((29 * winheight(0) + 27) / 55)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 80
normal! 032|
wincmd w
exe 'vert 1resize ' . ((&columns * 106 + 105) / 210)
exe 'vert 2resize ' . ((&columns * 103 + 105) / 210)
tabnext
edit loadrams.m
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 94 + 105) / 210)
exe 'vert 2resize ' . ((&columns * 115 + 105) / 210)
argglobal
1argu
if bufexists(fnamemodify("loadrams.m", ":p")) | buffer loadrams.m | else | edit loadrams.m | endif
if &buftype ==# 'terminal'
  silent file loadrams.m
endif
balt rvar2phys.m
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 18 - ((17 * winheight(0) + 27) / 55)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 18
normal! 0
wincmd w
argglobal
1argu
if bufexists(fnamemodify("rvar2phys.m", ":p")) | buffer rvar2phys.m | else | edit rvar2phys.m | endif
if &buftype ==# 'terminal'
  silent file rvar2phys.m
endif
balt loadrams.m
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 106 - ((46 * winheight(0) + 27) / 55)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 106
normal! 044|
wincmd w
exe 'vert 1resize ' . ((&columns * 94 + 105) / 210)
exe 'vert 2resize ' . ((&columns * 115 + 105) / 210)
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
