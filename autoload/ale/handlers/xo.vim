call ale#Set('javascript_xo_executable', 'xo')
call ale#Set('javascript_xo_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('javascript_xo_options', '')

call ale#Set('typescript_xo_executable', 'xo')
call ale#Set('typescript_xo_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('typescript_xo_options', '')

function! ale#handlers#xo#GetExecutable(buffer, type) abort
    return ale#node#FindExecutable(a:buffer, a:type . '_xo', [
    \   'node_modules/xo/cli.js',
    \   'node_modules/.bin/xo',
    \])
endfunction

function! ale#handlers#xo#GetLintCommand(buffer, type) abort
    return ale#Escape(ale#handlers#xo#GetExecutable(a:buffer, a:type))
    \   . ale#Pad(ale#handlers#xo#GetOptions(a:buffer, a:type))
    \   . ' --reporter json --stdin --stdin-filename %s'
endfunction

function! ale#handlers#xo#GetOptions(buffer, type) abort
    return ale#Var(a:buffer, a:type . '_xo_options')
endfunction

" xo uses eslint and the output format is the same
function! ale#handlers#xo#HandleJSON(buffer, lines) abort
    return ale#handlers#eslint#HandleJSON(a:buffer, a:lines)
endfunction
