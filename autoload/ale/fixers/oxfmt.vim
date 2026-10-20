" Author: Jeff Miccolis <jeff@miccolis.net>
" Description: Fixing files with oxlint.

call ale#Set('javascript_oxfmt_executable', 'oxfmt')
call ale#Set('javascript_oxfmt_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('javascript_oxfmt_options', '')

function! ale#fixers#oxfmt#GetExecutable(buffer) abort
    return ale#path#FindExecutable(a:buffer, 'javascript_oxfmt', [
    \   'node_modules/.bin/oxfmt',
    \])
endfunction

function! ale#fixers#oxfmt#Fix(buffer) abort
    let l:executable = ale#fixers#oxfmt#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'javascript_oxfmt_options')

    " Needs oxfmt with https://github.com/oxc-project/oxc/pull/16868
    return {
    \   'cwd': ale#fixers#oxfmt#GetCwd(a:buffer),
    \   'command': ale#Escape(l:executable)
    \       . ale#Pad(l:options)
    \       . ' --stdin-filepath %s',
    \}

endfunction

function! ale#fixers#oxfmt#GetCwd(buffer) abort
    let l:config = ale#path#FindNearestFile(a:buffer, '.oxfmtrc.json')

    " Fall back to the directory of the buffer
    return !empty(l:config) ? fnamemodify(l:config, ':h') : '%s:h'
endfunction

