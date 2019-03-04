scriptencoding utf-8
" Author: Cameron Ackerman <cameron@cackerman.net>
" Description: Bazel build/Starlark file formatter.

call ale#Set('bzl_buildifier_executable', 'buildifier')
call ale#Set('bzl_buildifier_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#fixers#buildifier#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'bzl_buildifier', [
    \   'buildifier',
    \])
endfunction

function! ale#fixers#buildifier#Fix(buffer) abort
    return {
    \   'command': ale#Escape(ale#fixers#buildifier#GetExecutable(a:buffer)),
    \}
endfunction
