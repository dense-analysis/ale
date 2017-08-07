" Author: Adrian Zalewski <aazalewski@hotmail.com>
" Description: Ember-template-lint for checking Handlebars files

call ale#Set('handlebars_embertemplatelint_executable', 'ember-template-lint')
call ale#Set('handlebars_embertemplatelint_use_global', 0)

function! ale_linters#handlebars#embertemplatelint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'handlebars_embertemplatelint', [
    \   'node_modules/.bin/ember-template-lint',
    \])
endfunction

function! ale_linters#handlebars#embertemplatelint#GetCommand(buffer) abort
    return ale_linters#handlebars#embertemplatelint#GetExecutable(a:buffer)
    \   . ' --json %t'
endfunction

function! ale_linters#handlebars#embertemplatelint#Handle(buffer, lines) abort
    let l:output = []
    let l:json = ale#util#FuzzyJSONDecode(a:lines, {})

    for l:error in get(values(l:json), 0, [])
        if has_key(l:error, 'fatal')
            call add(l:output, {
            \   'bufnr': a:buffer,
            \   'lnum': 1,
            \   'col': 1,
            \   'text': l:error.message,
            \   'type': l:error.severity == 1 ? 'W' : 'E',
            \})
        else
            call add(l:output, {
            \   'bufnr': a:buffer,
            \   'lnum': l:error.line,
            \   'col': l:error.column,
            \   'text': l:error.rule . ': ' . l:error.message,
            \   'type': l:error.severity == 1 ? 'W' : 'E',
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('handlebars', {
\   'name': 'ember-template-lint',
\   'executable_callback': 'ale_linters#handlebars#embertemplatelint#GetExecutable',
\   'command_callback': 'ale_linters#handlebars#embertemplatelint#GetCommand',
\   'callback': 'ale_linters#handlebars#embertemplatelint#Handle',
\})
