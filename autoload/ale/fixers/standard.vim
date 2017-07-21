" Author: Sumner Evans <sumner.evans98@gmail.com>
" Description: Fixing files with Standard.

function! ale#fixers#standard#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_standard', [
    \   'node_modules/standard/bin/cmd.js',
    \   'node_modules/.bin/standard',
    \])
endfunction

function! ale#fixers#standard#Fix(buffer) abort
    let l:executable = ale#fixers#standard#GetExecutable(a:buffer)

    if ale#Has('win32') && l:executable =~? 'cmd\.js$'
        " For Windows, if we detect an standard.js script, we need to execute
        " it with node, or the file can be opened with a text editor.
        let l:head = 'node ' . ale#Escape(l:executable)
    else
        let l:head = ale#Escape(l:executable)
    endif

    return {
    \   'command': l:head
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction
