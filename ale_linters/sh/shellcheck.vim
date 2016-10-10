" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for using the shellcheck linter with
"   shell scripts.

if exists('g:loaded_ale_linters_sh_shellcheck')
    finish
endif

let g:loaded_ale_linters_sh_shellcheck = 1

" This global variable can be set with a string of comma-seperated error
" codes to exclude from shellcheck. For example:
"
" let g:ale_linters_sh_shellcheck_exclusions = 'SC2002,SC2004'
if !exists('g:ale_linters_sh_shellcheck_exclusions')
    let g:ale_linters_sh_shellcheck_exclusions = ''
endif

if g:ale_linters_sh_shellcheck_exclusions !=# ''
    let s:exclude_option = '-e ' .  g:ale_linters_sh_shellcheck_exclusions
else
    let s:exclude_option = ''
endif

call ale#linter#Define('sh', {
\   'name': 'shellcheck',
\   'executable': 'shellcheck',
\   'command': 'shellcheck ' . s:exclude_option . ' -f gcc -',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
