" Author: gagbo <gagbobada@gmail.com>
" Description: Functions for integrating with C-family linters.


let g:ale_c_build_dir_names = get(g:, 'ale_c_build_dir_names', [
\   'build',
\   'bin',
\])

" Given a buffer number, find the build subdirectory with compile commands
" The subdirectory is returned without the trailing /
function! ale#c#FindCompileCommands(buffer) abort
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        for l:dirname in ale#Var(a:buffer, 'c_build_dir_names')
            let l:c_build_dir = l:path . '/' . l:dirname

            if filereadable(l:c_build_dir . '/compile_commands.json')
                return l:c_build_dir
            endif
        endfor
    endfor

    return ''
endfunction
