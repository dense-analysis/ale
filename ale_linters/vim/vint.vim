" Author: w0rp <devw0rp@gmail.com>, KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking Vim code with Vint.

if exists('g:loaded_ale_linters_vim_vint')
    finish
endif

let g:loaded_ale_linters_vim_vint = 1

" This flag can be used to change enable/disable style issues.
let g:ale_vim_vint_show_style_issues =
\   get(g:, 'ale_vim_vint_show_style_issues', 1)

let s:warning_flag = g:ale_vim_vint_show_style_issues ? '-s' : '-w'
let s:format = '-f "{file_path}:{line_number}:{column_number}: {severity}: {description} (see {reference})"'

call ale#linter#Define('vim', {
\   'name': 'vint',
\   'executable': 'vint',
\   'command': g:ale#util#stdin_wrapper
\       . ' .vim vint '
\       . s:warning_flag
\       . ' --no-color '
\       . s:format,
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
