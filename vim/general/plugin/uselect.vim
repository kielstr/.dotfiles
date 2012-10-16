" Vim plugin to exec fv/gv/lv from within vim itself
" Last Change: 17 Oct 2011
" Maintainer: Stephen Thirlwall <sdt@dr.com>

"-----------------------------------------------------------------------------
" Standard preamble
if exists("g:loaded_uselect")
    finish
endif
let g:loaded_uselect = 1

let s:save_cpo = &cpo
set cpo&vim

"-----------------------------------------------------------------------------
" Configuration variables
"
" g:uselect_bin - path to uselect binary (default "uselect")
"
if !exists("g:uselect_bin")
    let g:uselect_bin = "uselect"
endif

"-----------------------------------------------------------------------------
" :FV <pattern>
"
" Loads file selector for files with filename matching pattern.
" Search starts from current directory.

command -nargs=1 FV call s:doFV('<args>')
"cabbrev fv FV

function! s:doFV(pattern)
    let cmd='ack -a -f | fgrep -i ' . a:pattern . ' | sort | '. g:uselect_bin
    call s:LoadFilesFromCommand(cmd)
endfunction

"-----------------------------------------------------------------------------
" :GV <pattern>
"
" Loads file selector for files containing pattern.

command -nargs=1 GV call s:doGV('<args>')
"cabbrev gv GV

function! s:doGV(pattern)
    let cmd='ack --heading --break ' . a:pattern
    let cmd.= " | " . g:uselect_bin . " -i -m '^\\d+[:-]'"
    call s:LoadFilesFromCommand(cmd)
endfunction

"-----------------------------------------------------------------------------
" :LV <pattern>
"
" Like fv, but searches globally using locate.

command -nargs=1 LV call s:doLV('<args>')
"cabbrev lv LV

function! s:doLV(pattern)
    let cmd='locate ' . a:pattern . " | perl -nlE 'say if -f' | " . g:uselect_bin
    call s:LoadFilesFromCommand(cmd)
endfunction

"-----------------------------------------------------------------------------
" s:LoadFilesFromCommand(command)
"   command: shell command which returns a list of filenames, one per line
"
" Executes command, and opens each file in a new buffer. Files already opened
" are not re-opened.
"
function! s:LoadFilesFromCommand(command)
    let files=system(a:command)
    let filelist=split(files, '\n')
    for filename in filelist
        if ! bufloaded(filename)
            execute ':e ' . filename
        endif
    endfor
    " HACK: The command-line history is broken after executing uselect - the
    " up/down arrow keys don't work. This seems to fix it.
    execute ':!'
endfunction

"-----------------------------------------------------------------------------
" Standard postamble

let &cpo = s:save_cpo
