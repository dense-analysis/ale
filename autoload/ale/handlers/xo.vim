call ale#Set('javascript_xo_executable', 'xo')
call ale#Set('javascript_xo_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('javascript_xo_options', '')

call ale#Set('typescript_xo_executable', 'xo')
call ale#Set('typescript_xo_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('typescript_xo_options', '')

function! ale#handlers#xo#GetExecutable(buffer) abort
    let l:filetype = getbufvar(a:buffer, '&filetype')
    let l:type = ''

    if l:filetype =~# 'javascript'
        let l:type = 'javascript'
    elseif l:filetype =~# 'typescript'
        let l:type = 'typescript'
    endif

    return ale#node#FindExecutable(a:buffer, l:type . '_xo', [
    \   'node_modules/xo/cli.js',
    \   'node_modules/.bin/xo',
    \])
endfunction

function! ale#handlers#xo#GetLintCommand(buffer) abort
    return ale#Escape(ale#handlers#xo#GetExecutable(a:buffer))
    \   . ale#Pad(ale#handlers#xo#GetOptions(a:buffer))
    \   . ' --reporter json --stdin --stdin-filename %s'
endfunction

function! ale#handlers#xo#GetOptions(buffer) abort
    let l:filetype = getbufvar(a:buffer, '&filetype')
    let l:type = ''

    if l:filetype =~# 'javascript'
        let l:type = 'javascript'
    elseif l:filetype =~# 'typescript'
        let l:type = 'typescript'
    endif

    return ale#Var(a:buffer, l:type . '_xo_options')
endfunction

" xo uses eslint and the output format is the same
function! ale#handlers#xo#HandleJSON(buffer, lines) abort
    return ale#handlers#eslint#HandleJSON(a:buffer, a:lines)
endfunction
