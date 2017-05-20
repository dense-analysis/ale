" Author: w0rp <devw0rp@gmail.com>
" Description: eslint functions for handling and fixing errors.

let g:ale_javascript_eslint_executable =
\   get(g:, 'ale_javascript_eslint_executable', 'eslint')

function! ale#handlers#eslint#GetExecutable(buffer) abort
    if ale#Var(a:buffer, 'javascript_eslint_use_global')
        return ale#Var(a:buffer, 'javascript_eslint_executable')
    endif

    " Look for the kinds of paths that create-react-app generates first.
    let l:executable = ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/eslint/bin/eslint.js',
    \   ''
    \)

    if !empty(l:executable)
        return l:executable
    endif

    return ale#path#ResolveLocalPath(
    \   a:buffer,
    \   'node_modules/.bin/eslint',
    \   ale#Var(a:buffer, 'javascript_eslint_executable')
    \)
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
