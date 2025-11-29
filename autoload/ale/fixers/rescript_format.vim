" Author: John Jackson <john@johnridesa.bike>
" Description: Fix ReScript files with the ReScript formatter.

call ale#Set('rescript_format_executable', 'rescript')
call ale#Set(
\   'rescript_format_use_global',
\   get(g:, 'ale_use_global_executables', v:false)
\ )

function! s:GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'rescript_format', [
    \   'node_modules/.bin/rescript',
    \])
endfunction

function! s:FixWithVersion(buffer, version) abort
    let l:exe = ale#Escape(s:GetExecutable(a:buffer))
    let l:stdin = ale#semver#GTE(a:version, [12, 0, 0]) ? ' --stdin' : ' -stdin'
    let l:ext = fnamemodify(bufname(a:buffer), ':e') is? 'resi'
    \   ? ' .resi'
    \   : ' .res'

    return {'command': l:exe . ' format' . l:stdin . l:ext}
endfunction

function! ale#fixers#rescript_format#Fix(buffer) abort
    return ale#semver#RunWithVersionCheck(
    \   a:buffer,
    \   s:GetExecutable(a:buffer),
    \   '%e --version',
    \   function('s:FixWithVersion'),
    \)
endfunction
