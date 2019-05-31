scriptencoding utf-8
" Author: ObserverOfTime <chronobserver@disroot.org>
" Description: Fixing C/C++ files with clang-tidy.

call ale#Set('c_clangtidy_executable', 'clang-tidy')
call ale#Set('c_clangtidy_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('c_clangtidy_checks', [])
call ale#Set('c_clangtidy_options', '')
call ale#Set('c_clangtidy_fix_errors', 1)
call ale#Set('c_build_dir', '')

function! ale#fixers#clangtidy#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'c_clangtidy', [
    \   'clang-tidy',
    \])
endfunction

function! ale#fixers#clangtidy#GetCommand(buffer) abort
    let l:checks = join(ale#Var(a:buffer, 'c_clangtidy_checks'), ',')
    let l:build_dir = ale#c#GetBuildDirectory(a:buffer)
    let l:options = empty(l:build_dir)
    \   ? ale#Var(a:buffer, 'c_clangtidy_options') : ''
    let l:fix_errors = ale#Var(a:buffer, 'c_clangtidy_fix_errors')

    return ' -fix' . (l:fix_errors ? ' -fix-errors' : '')
    \   . (empty(l:checks) ? '' : ' -checks=' . ale#Escape(l:checks))
    \   . (empty(l:build_dir) ? '' : ' -p ' . ale#Escape(l:build_dir))
    \   . ' %t' . (empty(l:options) ? '' : ' -- ' . l:options)
endfunction

function! ale#fixers#clangtidy#Fix(buffer) abort
    let l:executable = ale#fixers#clangtidy#GetExecutable(a:buffer)
    let l:command = ale#fixers#clangtidy#GetCommand(a:buffer)

    return {
    \   'command': ale#Escape(l:executable) . l:command,
    \   'read_temporary_file': 1,
    \}
endfunction
