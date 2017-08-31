" Author: Prashanth Chandra <https://github.com/prashcr>, Jonathan Clem <https://jclem.net>
" Description: tslint for TypeScript files

call ale#Set('typescript_tslint_executable', 'tslint')
call ale#Set('typescript_tslint_config_path', '')
call ale#Set('typescript_tslint_rules_dir', '')
call ale#Set('typescript_tslint_use_global', 0)

function! ale_linters#typescript#tslint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'typescript_tslint', [
    \   'node_modules/.bin/tslint',
    \])
endfunction

function! ale_linters#typescript#tslint#Handle(buffer, lines) abort
    let l:dir = expand('#' . a:buffer . ':p:h')
    let l:output = []

    for l:error in ale#util#FuzzyJSONDecode(a:lines, [])
        call add(l:output, {
        \   'filename': ale#path#GetAbsPath(l:dir, l:error.name),
        \   'type': (get(l:error, 'ruleSeverity', '') is# 'WARNING' ? 'W' : 'E'),
        \   'text': has_key(l:error, 'ruleName')
        \       ? l:error.ruleName . ': ' . l:error.failure
        \       : l:error.failure,
        \   'lnum': l:error.startPosition.line + 1,
        \   'col': l:error.startPosition.character + 1,
        \   'end_lnum': l:error.endPosition.line + 1,
        \   'end_col': l:error.endPosition.character + 1,
        \})
    endfor

    return l:output
endfunction

function! ale_linters#typescript#tslint#GetCommand(buffer) abort
    let l:tslint_config_path = ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'tslint.json',
    \   ale#Var(a:buffer, 'typescript_tslint_config_path')
    \)
    let l:tslint_config_option = !empty(l:tslint_config_path)
    \   ? ' -c ' . ale#Escape(l:tslint_config_path)
    \   : ''

    let l:tslint_rules_dir = ale#Var(a:buffer, 'typescript_tslint_rules_dir')
    let l:tslint_rules_option = !empty(l:tslint_rules_dir)
    \  ? ' -r ' . ale#Escape(l:tslint_rules_dir)
    \  : ''

    return ale#path#BufferCdString(a:buffer)
    \   . ale_linters#typescript#tslint#GetExecutable(a:buffer)
    \   . ' --format json'
    \   . l:tslint_config_option
    \   . l:tslint_rules_option
    \   . ' %t'
endfunction

call ale#linter#Define('typescript', {
\   'name': 'tslint',
\   'executable_callback': 'ale_linters#typescript#tslint#GetExecutable',
\   'command_callback': 'ale_linters#typescript#tslint#GetCommand',
\   'callback': 'ale_linters#typescript#tslint#Handle',
\})
