#! /usr/bin/env vex

set nocp
set rtp^=$PWD

let s:Wson = v:null
let s:dOption = {'simple':0, 'pretty':0}

" Func: s:get_wson_complier 
function! s:get_wson_complier() abort
    if empty(s:Wson)
        let l:CWson = g:wenyan#CWson#space.class
        let s:Wson = l:CWson.new(s:dOption)
    endif
    return s:Wson
endfunction

" Func: s:encode_json_file 
function! s:encode_json_file(path) abort
    let l:path = expand(a:path)
    if !filereadable(l:path)
        return ''
    endif
    let l:lines = readfile(l:path)
    let l:text = join(l:lines, '')
    let l:wson = s:encode_json_text(l:text)
    let l:file = s:saveas_file(l:path, 'wson')
    if 0 != writefile(split(l:wson, "\n"), l:file)
        LOG 'Error: fail to save wson to: ' . l:file
        return ''
    endif
    return l:file
endfunction

" Func: s:encode_json_text 
" json text -> wson text
function! s:encode_json_text(text) abort
    let l:jWson = s:get_wson_complier()
    return l:jWson.encode_source(a:text)
endfunction

" Func: s:saveas_file 
" find a suitable filename to save as with another extention
" no overwrite solve confict by add .1 .2 before extention
function! s:saveas_file(old, ext) abort
    let l:fileroot = fnamemodify(a:old, ':p:r')
    let l:filename = l:fileroot . '.' . a:ext
    let l:number = 0
    while filereadable(l:filename)
        let l:number += 1
        let l:filename = printf('%s_%d.%s', l:fileroot, l:number, a:ext)
    endwhile
    return l:filename
endfunction

" Func: s:main 
function! s:main(args) abort
    let l:option = vex#options('wenyan-encode')
    call l:option.addoption('pretty', 'p', 'print wson in pretty way')
    call l:option.addoption('simple', 's', 'use simplified chinese')
    " call l:option.addoption('outfile', 'o', 'output to file instead of stdout')
    call l:option.addargument('json', 'json text or file')

    LOG a:args
    let l:input = l:option.parse(a:args)
    if empty(l:input) || empty(l:input.arguments)
        return vex#echo(l:option.usage())
    endif

    if has_key(l:input, 'pretty')
        let s:dOption.pretty = l:input.pretty
        LOG l:input.pretty
    endif
    if has_key(l:input, 'simple')
        let s:dOption.simple = l:input.simple
        LOG l:input.simple
    endif

    let l:json = l:input.arguments[0]
    if l:json =~? '\.json'
        let l:file = s:encode_json_file(l:json)
        if empty(l:file)
            ECHO '[ERR] Fail to encode: ' . l:json
        else
            call vex#echo(l:file)
        endif
    else
        let l:wson = s:encode_json_text(l:json)
        if !empty(l:wson)
            call vex#echo(split(l:wson, "\n"))
        else
            call vex#echo('[ERR] Fail to encode to wson')
        endif
    endif

endfunction

call s:main(vex#args())
finish
