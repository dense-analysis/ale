" Author: Leo <thinkabit.ukim@gmail.com>
" Description: Fix policy violations found by apkbuild-lint

call ale#Set('apkbuild_apkbuild_fixer_executable', 'apkbuild-fixer')
call ale#Set('apkbuild_apkbuild_fixer_lint_executable', get(g:, 'ale_apkbuild_apkbuild_lint_executable'))
call ale#Set('apkbuild_apkbuild_fixer_options', '')

function! ale#fixers#apkbuild_fixer#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'apkbuild_apkbuild_fixer_executable')
    let l:options = ale#Var(a:buffer, 'apkbuild_apkbuild_fixer_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' -p ' . ale#Var(a:buffer, 'apkbuild_apkbuild_fixer_lint_executable')
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
