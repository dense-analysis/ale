" Author: Adrian Zalewski <aazalewski@hotmail.com>
" Description: Ember-template-lint for checking Handlebars files

let g:ale_handlebars_embertemplatelint_executable =
\   get(g:, 'ale_handlebars_embertemplatelint_executable', 'ember-template-lint')

let g:ale_handlebars_embertemplatelint_use_global =
\   get(g:, 'ale_handlebars_embertemplatelint_use_global', 0)

function! ale_linters#handlebars#embertemplatelint#GetExecutable(buffer) abort
    if ale#Var(a:buffer, 'handlebars_embertemplatelint_use_global')
        return ale#Var(a:buffer, 'handlebars_embertemplatelint_executable')
    endif

    return ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/ember-template-lint',
    \   ale#Var(a:buffer, 'handlebars_embertemplatelint_executable')
    \)
endfunction

function! ale_linters#handlebars#embertemplatelint#GetCommand(buffer) abort
    return ale_linters#handlebars#embertemplatelint#GetExecutable(a:buffer)
    \   . ' --json %t'
endfunction

function! ale_linters#handlebars#embertemplatelint#Handle(buffer, lines) abort
    if len(a:lines) == 0
      return []
    endif

    let l:output = []

    let l:input_json = json_decode(join(a:lines, ''))
    let l:file_errors = values(l:input_json)[0]

    for l:error in l:file_errors
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:error.line,
        \   'col': l:error.column,
        \   'text': l:error.rule . ': ' . l:error.message,
        \   'type': l:error.severity == 1 ? 'W' : 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('handlebars', {
\   'name': 'ember-template-lint',
\   'executable_callback': 'ale_linters#handlebars#embertemplatelint#GetExecutable',
\   'command_callback': 'ale_linters#handlebars#embertemplatelint#GetCommand',
\   'callback': 'ale_linters#handlebars#embertemplatelint#Handle',
\})
