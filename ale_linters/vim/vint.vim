" Author: w0rp <devw0rp@gmail.com>, KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking Vim code with Vint.

if exists('g:loaded_ale_linters_vim_vint')
    finish
endif

let g:loaded_ale_linters_vim_vint = 1

let s:format = '-f "{file_path}:{line_number}:{column_number}: {severity}: {description} (see {reference})'

call ALEAddLinter('vim', {
\   'name': 'vint',
\   'executable': 'vint',
\   'command': g:ale#util#stdin_wrapper . ' .vim vint -w --no-color ' . s:format,
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
