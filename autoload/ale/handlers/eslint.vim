" Author: w0rp <devw0rp@gmail.com>
" Description: eslint functions for handling and fixing errors.

call ale#Set('javascript_eslint_executable', 'eslint')
call ale#Set('javascript_eslint_use_global', 0)

function! ale#handlers#eslint#GetExecutable(buffer) abort
    if ale#Var(a:buffer, 'javascript_eslint_use_global')
        return ale#Var(a:buffer, 'javascript_eslint_executable')
    endif

    " Look for eslint_d first, then the path React uses, then the basic
    " eslint path.
    for l:path in [
    \   'node_modules/.bin/eslint_d',
    \   'node_modules/eslint/bin/eslint.js',
    \   'node_modules/.bin/eslint',
    \]
        let l:executable = ale#path#FindNearestFile(a:buffer, l:path)

        if !empty(l:executable)
            return l:executable
        endif
    endfor

    return ale#Var(a:buffer, 'javascript_eslint_executable')
endfunction

function! s:FindConfig(buffer) abort
    for l:filename in [
    \   '.eslintrc.js',
    \   '.eslintrc.yaml',
    \   '.eslintrc.yml',
    \   '.eslintrc.json',
    \   '.eslintrc',
    \]
        let l:config = ale#path#FindNearestFile(a:buffer, l:filename)

        if !empty(l:config)
            return l:config
        endif
    endfor

    return ''
endfunction

function! ale#handlers#eslint#Fix(buffer, lines) abort
    let l:config = s:FindConfig(a:buffer)

    if empty(l:config)
        return 0
    endif

    return {
    \   'command': ale#Escape(ale#handlers#eslint#GetExecutable(a:buffer))
    \       . ' --config ' . ale#Escape(l:config)
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction
