" Author: KabbAmine <amine.kabb@gmail.com>, David Sierra <https://github.com/davidsierradz>

call ale#Set('json_jsonlint_executable', 'jsonlint')
call ale#Set('json_jsonlint_arguments', get(g:, 'ale_json_jsonlint_arguments', '--compact'))
call ale#Set('json_jsonlint_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#json#jsonlint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'json_jsonlint', [
    \   'node_modules/.bin/jsonlint',
    \   'node_modules/jsonlint/lib/cli.js',
    \])
endfunction

function! ale_linters#json#jsonlint#GetCommand(buffer) abort
    let l:executable  = ale_linters#json#jsonlint#GetExecutable(a:buffer)
    let l:arguments   = ale#Var(a:buffer, 'json_jsonlint_arguments')
    let l:schema_file = expand('%:p:h') . '/schema.json'

    if filereadable(l:schema_file) && (l:schema_file != expand('%:p'))
      let l:arguments = l:arguments . ' --validate "' . l:schema_file . '" '
    endif

    return ale#node#Executable(a:buffer, l:executable)
    \   . ' ' . l:arguments . ' -'
endfunction

function! ale_linters#json#jsonlint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " line 2, col 15, found: 'STRING' - expected: 'EOF', '}', ',', ']'.
    let l:pattern = '^line \(\d\+\), col \(\d*\), \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('json', {
\   'name': 'jsonlint',
\   'executable': function('ale_linters#json#jsonlint#GetExecutable'),
\   'output_stream': 'stderr',
\   'command': function('ale_linters#json#jsonlint#GetCommand'),
\   'callback': 'ale_linters#json#jsonlint#Handle',
\})
