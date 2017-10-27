" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for using the shellcheck linter with
"   shell scripts.

" This global variable can be set with a string of comma-separated error
" codes to exclude from shellcheck. For example:
"
" let g:ale_sh_shellcheck_exclusions = 'SC2002,SC2004'
let g:ale_sh_shellcheck_exclusions =
\   get(g:, 'ale_sh_shellcheck_exclusions', get(g:, 'ale_linters_sh_shellcheck_exclusions', ''))

let g:ale_sh_shellcheck_executable =
\   get(g:, 'ale_sh_shellcheck_executable', 'shellcheck')

let g:ale_sh_shellcheck_options =
\   get(g:, 'ale_sh_shellcheck_options', '')

function! ale_linters#sh#shellcheck#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'sh_shellcheck_executable')
endfunction

function! ale_linters#sh#shellcheck#GetDialectArgument(buffer) abort
    let l:shell_type = ale#handlers#sh#GetShellType(a:buffer)

    if !empty(l:shell_type)
        " Use the dash dialect for /bin/ash, etc.
        if l:shell_type is# 'ash'
            return 'dash'
        endif

        return l:shell_type
    endif

    " If there's no hashbang, try using Vim's buffer variables.
    if getbufvar(a:buffer, 'is_bash', 0)
        return 'bash'
    elseif getbufvar(a:buffer, 'is_sh', 0)
        return 'sh'
    elseif getbufvar(a:buffer, 'is_kornshell', 0)
        return 'ksh'
    endif

    return ''
endfunction

function! ale_linters#sh#shellcheck#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'sh_shellcheck_options')
    let l:exclude_option = ale#Var(a:buffer, 'sh_shellcheck_exclusions')
    let l:dialect = ale_linters#sh#shellcheck#GetDialectArgument(a:buffer)

    return ale#path#BufferCdString(a:buffer)
    \   . ale#Escape(ale_linters#sh#shellcheck#GetExecutable(a:buffer))
    \   . (!empty(l:dialect) ? ' -s ' . l:dialect : '')
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . (!empty(l:exclude_option) ? ' -e ' . l:exclude_option : '')
    \   . ' -x -f gcc -'
endfunction

call ale#linter#Define('sh', {
\   'name': 'shellcheck',
\   'executable_callback': 'ale_linters#sh#shellcheck#GetExecutable',
\   'command_callback': 'ale_linters#sh#shellcheck#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
