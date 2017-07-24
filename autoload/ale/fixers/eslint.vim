" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing files with eslint.

function! s:FindConfig(buffer) abort
    for l:filename in [
    \   '.eslintrc.js',
    \   '.eslintrc.yaml',
    \   '.eslintrc.yml',
    \   '.eslintrc.json',
    \   '.eslintrc',
    \   'package.json',
    \]
        let l:config = ale#path#FindNearestFile(a:buffer, l:filename)

        if !empty(l:config)
            return l:config
        endif
    endfor

    return ''
endfunction

function! ale#fixers#eslint#Fix(buffer) abort
    let l:executable = ale#handlers#eslint#GetExecutable(a:buffer)
    let l:config = s:FindConfig(a:buffer)

    if empty(l:config)
        return 0
    endif

    if ale#Has('win32') && l:executable =~? 'eslint\.js$'
        " For Windows, if we detect an eslint.js script, we need to execute
        " it with node, or the file can be opened with a text editor.
        let l:head = 'node ' . ale#Escape(l:executable)
    else
        let l:head = ale#Escape(l:executable)
    endif

    return {
    \   'command': l:head
    \       . ' --config ' . ale#Escape(l:config)
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction
