function! asyncomplete#sources#ale#get_source_options(...) abort
    let l:default = extend({
    \     'name': 'ale',
    \     'completor': function('asyncomplete#sources#ale#completor'),
    \     'whitelist': ['*'],
    \     'triggers': asyncomplete#sources#ale#get_triggers(),
    \ }, a:0 >= 1 ? a:1 : {})
    return extend(l:default, {'refresh_pattern': '\k\+$'})
endfunction

function! asyncomplete#sources#ale#get_triggers() abort
    let l:triggers = ale#completion#GetAllTriggers()
    let l:triggers['*'] = l:triggers['<default>']

    return l:triggers
endfunction

function! asyncomplete#sources#ale#completor(opts, ctx) abort
    let l:kw = matchstr(a:ctx.typed, '\w\+$')
    let l:kwlen = len(l:kw)
    let l:startcol = a:ctx.col - l:kwlen

    call ale#completion#GetCompletions('ale-callback', { 'callback': {completions ->
    \   asyncomplete#complete(a:options.name, a:context, l:startcol, completions)
    \ }})
endfunction
