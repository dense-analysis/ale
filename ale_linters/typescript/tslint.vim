" Author: Prashanth Chandra https://github.com/prashcr
" Description: tslint for TypeScript files

call ale#Set('typescript_tslint_executable', 'tslint')
call ale#Set('typescript_tslint_config_path', '')
call ale#Set('typescript_tslint_use_global', 0)

function! ale_linters#typescript#tslint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'typescript_tslint', [
    \   'node_modules/.bin/tslint',
    \])
endfunction

function! ale_linters#typescript#tslint#Handle(buffer, lines) abort
    let l:output = []

    for l:error in json_decode(join(a:lines, ''))
        if ale#path#IsBufferPath(a:buffer, l:error.name)
            call add(l:output, {
            \   'type': (get(l:error, 'ruleSeverity', '') ==# 'WARNING' ? 'W' : 'E'),
            \   'text': l:error.failure,
            \   'lnum': l:error.startPosition.line + 1,
            \   'col': l:error.startPosition.character + 1,
            \   'end_lnum': l:error.endPosition.line + 1,
            \   'end_col': l:error.endPosition.character + 1,
            \})
        endif
    endfor

    return l:output
endfunction

function! ale_linters#typescript#tslint#BuildLintCommand(buffer) abort
    let l:tslint_config_path = ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'tslint.json',
    \   ale#Var(a:buffer, 'typescript_tslint_config_path')
    \)

    let l:tslint_config_option = !empty(l:tslint_config_path)
    \   ? ' -c ' . ale#Escape(l:tslint_config_path)
    \   : ''

    return ale_linters#typescript#tslint#GetExecutable(a:buffer)
    \   . ' --format json'
    \   . l:tslint_config_option
    \   . ' %t'
endfunction

call ale#linter#Define('typescript', {
\   'name': 'tslint',
\   'executable_callback': 'ale_linters#typescript#tslint#GetExecutable',
\   'command_callback': 'ale_linters#typescript#tslint#BuildLintCommand',
\   'callback': 'ale_linters#typescript#tslint#Handle',
\})
