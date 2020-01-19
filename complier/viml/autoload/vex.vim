" File: vex
" Author: lymslive
" Description: functions for vex and svex script
" Create: 2017-03-28
" Modify: 2020-01-16

command! -nargs=* ECHO call vex#echo(eval(<q-args>))
command! -nargs=* LOG call vex#log(eval(<q-args>))

" echo: add msg string to end of buffer and print it
" can used in 'ex -s' script to output something to stdout
function! vex#echo(msg) abort "{{{
    " call s:echo(type(a:msg))
    if type(a:msg) == v:t_string
        return s:echo(a:msg)
    elseif type(a:msg) == v:t_list
        for l:msg in a:msg
            call s:echo(l:msg)
        endfor
    else
        echoerr 'can only output string or list of string'
    endif
endfunction "}}}

function! vex#log(msg) abort
    if !empty(0 + $VEXLOG)
        return vex#echo(a:msg)
    endif
endfunction

" Func: s:echo 
function! s:echo(msg) abort
    call append('$', a:msg)
    $print
endfunction

" Func: #path 
function! vex#path(path) abort
    if empty(a:path)
        return
    endif
    let &rtp = a:path . ',' . &rtp
endfunction

" Func: #args 
function! vex#args() abort
    let l:argv = []
    for i in range(argc())
        let l:arg = argv(i)
        if i == 0 && l:arg ==# 'BUFFER.VEX'
            continue
        endif
        if l:arg =~# '^-V\d\+'
            let &g:verbose = 0 + matchstr(l:arg, '^-V\zs\d\+')
            continue
        endif
        call add(l:argv, l:arg)
    endfor
    return l:argv
endfunction

" Func: #options 
function! vex#options(cmdname) abort
    let l:obj = lib#Cmdopt#new(a:cmdname)
    return l:obj
endfunction
