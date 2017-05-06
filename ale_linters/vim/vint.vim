" Author: w0rp <devw0rp@gmail.com>, KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking Vim code with Vint.

" This flag can be used to change enable/disable style issues.
let g:ale_vim_vint_show_style_issues =
\   get(g:, 'ale_vim_vint_show_style_issues', 1)

let s:vint_version = ale#semver#Parse(system('vint --version'))
let s:can_use_no_color_flag = ale#semver#GreaterOrEqual(s:vint_version, [0, 3, 7])
let s:enable_neovim = has('nvim') ? ' --enable-neovim ' : ''
let s:format = '-f "{file_path}:{line_number}:{column_number}: {severity}: {description} (see {reference})"'

function! ale_linters#vim#vint#GetCommand(buffer) abort
    let l:warning_flag = ale#Var(a:buffer, 'vim_vint_show_style_issues') ? '-s' : '-w'

    return 'vint '
    \   . l:warning_flag . ' '
    \   . (s:can_use_no_color_flag ? '--no-color ' : '')
    \   . s:enable_neovim
    \   . s:format
    \   . ' %t'
endfunction

call ale#linter#Define('vim', {
\   'name': 'vint',
\   'executable': 'vint',
\   'command_callback': 'ale_linters#vim#vint#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
