" Author: diartyz <diartyz@gmail.com>, w0rp <devw0rp@gmail.com>

call ale#Set('stylus_stylelint_executable', 'stylelint')
call ale#Set('stylus_stylelint_options', '')
call ale#Set('stylus_stylelint_use_global', 0)

function! ale_linters#stylus#stylelint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'stylus_stylelint', [
    \   'node_modules/.bin/stylelint',
    \])
endfunction

function! ale_linters#stylus#stylelint#GetCommand(buffer) abort
    return ale_linters#stylus#stylelint#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'stylus_stylelint_options')
    \   . ' --stdin-filename %s'
endfunction

call ale#linter#Define('stylus', {
\   'name': 'stylelint',
\   'executable_callback': 'ale_linters#stylus#stylelint#GetExecutable',
\   'command_callback': 'ale_linters#stylus#stylelint#GetCommand',
\   'callback': 'ale#handlers#css#HandleStyleLintFormat',
\})
