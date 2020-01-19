" File: CWson
" Author: lymslive
" Description: class for wson implement
" Create: 2020-01-12
" Modify: 2020-01-12

let g:wenyan#CWson#space = s:

let s:class = {}

let s:class.complex = 1   " syntax level
let s:class.pretty  = 0 " output pretty way
let s:class.simple  = 0 " use simplified chinise
let s:class.charset = v:null
let s:class.indent = 0
let s:class.json = ''
let s:class.wson = ''
let s:class.data = v:null

" Func: s:config_chs 
function! s:config_chs() abort
    let l:cfg = {}
    let l:cfg.HanNumber = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九']
    let l:cfg.UnitNumber = ['个', '十', '百', '千', '万', '亿', '兆']
    let l:cfg.NULL = '空'
    let l:cfg.TRUE = '阳'
    let l:cfg.FALSE = '阴'
    let l:cfg.NumberMinus = '负'
    let l:cfg.NumberPoint = '点'
    let l:cfg.DoubleQuote = ['“', '”']
    let l:cfg.MapType = {'number': '数', 'float': '数', 'string': '言', 'list': '列', 'dict': '表', 'bool': '爻', 'null': '空', }
    let l:cfg.ListBlock = {'begin': '列', 'end': '也'}
    let l:cfg.DictBlock = {'begin': '表', 'end': '也'}
    let l:cfg.ValueTip = '曰'
    let l:cfg.NameTip = '之'

    let l:cfg.Ingore = ["\t", "\n", "\r", ' ']
    return l:cfg
endfunction

" Func: s:config_cht 
function! s:config_cht() abort
    let l:cfg = s:config_chs()
    let l:cfg.TRUE = '陽'
    let l:cfg.FALSE = '陰'
    let l:cfg.NumberPoint = '点'
    let l:cfg.DoubleQuote = ['『', '』']
    return l:cfg
endfunction

let s:SCHAR = s:config_chs()
let s:TCHAR = s:config_cht()

" Method: new 
function! s:class.new(option) dict abort
    let l:obj = copy(s:class)
    if has_key(a:option, 'pretty')
        let l:obj.pretty = 0 + a:option.pretty
    endif
    if has_key(a:option, 'simple')
        let l:obj.simple = 0 + a:option.simple
    endif
    if l:obj.simple == 1
        let l:obj.charset = s:SCHAR
    else
        let l:obj.charset = s:TCHAR
    endif
    return l:obj
endfunction

" Method: encode_source 
" encode json string to wson string
function! s:class.encode_source(json) dict abort
    let self.json = a:json
    let l:json = json_decode(a:json)
    let self.data = l:json
    let self.wson = self.encode(l:json)
    return self.wson
endfunction

" Method: encode 
" encode internal viml data to wson string
function! s:class.encode(json) dict abort
    let l:json = a:json
    let l:type = type(l:json)
    if l:type == v:t_none
        return self.encode_null()
    elseif l:type == v:t_bool
        return self.encode_bool(l:json)
    elseif l:type == v:t_number
        return self.encode_number(l:json)
    elseif l:type == v:t_float
        return self.encode_float(l:json)
    elseif l:type == v:t_string
        return self.encode_string(l:json)
    elseif l:type == v:t_list
        return self.encode_list(l:json)
    elseif l:type == v:t_dict
        return self.encode_dict(l:json)
    else
        echoerr 'invalid json type'
        return ''
    endif
endfunction

" Method: encode_null 
function! s:class.encode_null() dict abort
    return self.charset.NULL
endfunction

" Method: encode_bool 
function! s:class.encode_bool(val) dict abort
    if a:val == v:false || empty(a:val)
        return self.charset.FALSE
    else
        return self.charset.TRUE
    endif
endfunction

" Method: encode_number 
function! s:class.encode_number(val) dict abort
    if type(a:val) == v:t_string
        let l:numstr = a:val
    elseif type(a:val) == v:t_number
        let l:numstr = json_encode(a:val)
    else
        echoerr 'expect number'
    endif

    let l:numbers = split(l:numstr, '\zs')
    let l:sign = ''
    if !empty(l:numbers)
        let l:first = l:numbers[0]
        if l:first ==# '-'
            let l:sign = self.charset.NumberMinus
            call remove(l:numbers, 0)
        endif
    endif
    call map(l:numbers, {idx, val -> self.charset.HanNumber[0+val]})
    return l:sign . join(l:numbers, '')
endfunction

" Method: encode_float 
function! s:class.encode_float(val) dict abort
    let l:numstr = json_encode(a:val)
    let l:parts = split(l:numstr, '\.', 1)
    let l:number = l:parts[0]
    let l:float = ''
    if len(l:parts) > 0
        let l:float = l:parts[1]
    endif

    let l:left = self.charset.HanNumber[0]
    if !empty(l:number)
        let l:left = self.encode_number(l:number)
    endif
    let l:right = ''
    if !empty(l:float)
        let l:right = self.encode_number(l:float)
    endif

    if !empty(l:right)
        let l:point = self.charset.NumberPoint
        return l:left . l:point . l:right
    else
        return l:left
    endif
endfunction

" Method: encode_string 
function! s:class.encode_string(val) dict abort
    return self.quote_string(a:val)
endfunction

" Method: quote_string 
function! s:class.quote_string(val) dict abort
    let l:quote = self.charset.DoubleQuote
    return l:quote[0] . a:val . l:quote[1]
endfunction

" Method: indent_prefix 
function! s:class.indent_prefix() dict abort
    let l:indent = repeat("\t", self.indent)
    return l:indent
endfunction

" Method: encode_list 
function! s:class.encode_list(val) dict abort
    let l:begin = self.charset.ListBlock.begin
    let l:end = self.charset.ListBlock.end
    if empty(a:val)
        return l:begin . l:end
    endif

    if !empty(self.pretty)
        let self.indent += 1
        let l:indent = self.indent_prefix()
    endif

    let l:body = ''
    let l:ValueTip = self.charset.ValueTip
    for l:val in a:val
        let l:value = self.encode(l:val)
        let l:item = l:ValueTip . l:value
        if !empty(self.pretty)
            let l:item = "\n" . l:indent . l:item
        endif
        let l:body .= l:item
    endfor

    if !empty(self.pretty)
        let self.indent -= 1
        let l:indent = self.indent_prefix()
        return l:begin . l:body .  "\n" . l:indent . l:end
    else
        return l:begin . l:body . l:end
    endif
endfunction

" Method: encode_dict 
function! s:class.encode_dict(val) dict abort
    let l:begin = self.charset.DictBlock.begin
    let l:end = self.charset.DictBlock.end
    if empty(a:val)
        return l:begin . l:end
    endif

    if !empty(self.pretty)
        let self.indent += 1
        let l:indent = self.indent_prefix()
    endif

    let l:body = ''
    let l:ValueTip = self.charset.ValueTip
    let l:NameTip = self.charset.NameTip
    for [l:key, l:val] in items(a:val)
        let l:name = self.quote_string(l:key)
        let l:value = self.encode(l:val)
        let l:item = l:NameTip . l:name . l:ValueTip . l:value
        if !empty(self.pretty)
            let l:item = "\n" . l:indent . l:item
        endif
        let l:body .= l:item
        unlet l:key l:val
    endfor

    if !empty(self.pretty)
        let self.indent -= 1
        let l:indent = self.indent_prefix()
        return l:begin . l:body .  "\n" . l:indent . l:end
    else
        return l:begin . l:body . l:end
    endif
endfunction

" Method: decode_source 
" decode wson string to json string
function! s:class.decode_source(wson) dict abort
    let self.data = self.decode(a:wson)
    let self.json = json_encode(self.data)
    return self.json
endfunction

" Method: decode 
" decode wson string to internal viml data
function! s:class.decode(wson) dict abort
    if empty(a:wson) || type(a:wson) != v:t_string
        echoerr 'empty wson string'
        return v:null
    endif
    let self.wson = a:wson
    let self.char = split(self.wson, '\zs')
    let self.length = len(self.char)
    let self.cursor = 0
    let l:value = self.read_value()

    let self.cursor += 1
    call self.skip_ignore()
    if self.cursor < self.length
        echoerr 'bad data: tail character found'
    endif
    return l:value
endfunction

" Method: function_name 
function! s:class.read_value() dict abort
    call self.skip_ignore()
    let l:current = self.char[self.cursor]
    if l:current ==# self.charset.ListBlock.begin
        let l:value = self.read_list()
    elseif l:current ==# self.charset.DictBlock.begin
        let l:value = self.read_dict()
    elseif l:current ==# self.charset.NULL
        let l:value = self.read_null()
    elseif l:current ==# self.charset.TRUE
        let l:value = self.read_bool(v:true)
    elseif l:current ==# self.charset.FALSE
        let l:value = self.read_bool(v:false)
    elseif l:current ==# self.charset.DoubleQuote[0]
        let l:value = self.read_string()
    else
        let l:value = self.read_number()
    endif

    return l:value
endfunction

" Method: skip_ignore 
function! s:class.skip_ignore() dict abort
    while 1 && self.cursor < self.length
        let l:current = self.char[self.cursor]
        if char2nr(l:current) <= 32 " char2nr(' ')
            let self.cursor += 1
        else
            break
        endif
    endwhile
endfunction

" Method: read_null 
function! s:class.read_null() dict abort
    " let self.cursor += 1
    return v:null
endfunction

" Method: read_bool 
function! s:class.read_bool(bool) dict abort
    " let self.cursor += 1
    return a:bool
endfunction

" Method: read_string 
function! s:class.read_string() dict abort
    let l:string = []
    let l:start = self.cursor
    while 1 && self.cursor < self.length
        let self.cursor += 1
        let l:current = self.char[self.cursor]
        if l:current ==# '\'
            let self.cursor += 1
            if self.cursor >= self.length
                echoerr 'bad data end with slash?'
            endif
            let l:current = self.char[self.cursor]
            call add(l:string, l:current)
            continue
        endif
        if l:current ==# self.charset.DoubleQuote[1]
            break
        endif
        call add(l:string, l:current)
    endwhile
    return join(l:string, '')
endfunction

" Method: read_number 
function! s:class.read_number() dict abort
    let l:string = []
    let l:start = self.cursor
    let l:point = 0
    while 1 && self.cursor < self.length
        let l:current = self.char[self.cursor]
        let l:digit = index(self.charset.HanNumber, l:current)
        if l:current ==# self.charset.NumberMinus
            if len(l:string) > 0
                echoerr 'the - sign can only prefix number once'
            endif
            call add(l:string, '-')
        elseif l:current ==# self.charset.NumberPoint
            if l:point > 0
                echoerr 'the float point can only appear once'
            endif
            call add(l:string, '.')
            let l:point = 1
        elseif l:digit >= 0
            call add(l:string, l:digit)
        else
            break
        endif
        let self.cursor += 1
    endwhile

    if empty(l:string)
        echoerr 'bad data: no value but expected'
        return 0
    endif

    " adopt for list/dict loop
    let self.cursor -= 1

    let l:numstr = join(l:string, '')
    if l:point > 1
        return str2float(l:numstr)
    else
        return str2nr(l:numstr)
    endif
endfunction

" Method: read_list 
function! s:class.read_list() dict abort
    let l:value = []
    while 1 && self.cursor < self.length
        let self.cursor += 1
        call self.skip_ignore()
        let l:current = self.char[self.cursor]
        if l:current ==# self.charset.ListBlock.end
            break
        endif
        if l:current ==# self.charset.ValueTip
            let self.cursor += 1
            let l:item = self.read_value()
            call add(l:value, l:item)
        else
            echoerr 'bad data in array'
        endif
    endwhile
    return l:value
endfunction

" Method: read_dict 
function! s:class.read_dict() dict abort
    let l:value = {}
    while 1 && self.cursor < self.length
        let self.cursor += 1
        call self.skip_ignore()
        let l:current = self.char[self.cursor]
        if l:current ==# self.charset.DictBlock.end
            break
        endif
        if l:current ==# self.charset.NameTip
            let self.cursor += 1
            call self.skip_ignore()
            let l:key = ''
            let l:current = self.char[self.cursor]
            if l:current ==# self.charset.DoubleQuote[0]
                let l:key = self.read_string()
            else
                echoerr 'bad data: expect a key name'
            endif

            if empty(l:key)
                echoerr 'bad data: expect a non-empty name'
            endif

            let self.cursor += 1
            call self.skip_ignore()
            let l:current = self.char[self.cursor]
            if l:current ==# self.charset.ValueTip
                let self.cursor += 1
                let l:item = self.read_value()
                let l:value[l:key] = l:item
            else
                echoerr 'bad data in dict'
            endif
        else
            echoerr 'bad data in dist'
        endif
    endwhile
    return l:value
endfunction
