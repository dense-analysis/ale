" Author: Bartolomeo Stellato bartolomeo.stellato@gmail.com
" Description: Functions for integrating with Julia tools

" Find the nearest dir contining a git project as julia project
let g:__ale_julia_project_filenames = ['REQUIRE']

function! ale#julia#FindProjectRoot(buffer) abort
    for l:project_filename in g:__ale_julia_project_filenames
        let l:full_path = ale#path#FindNearestFile(a:buffer, l:project_filename)

        if !empty(l:full_path)
            let l:path = fnamemodify(l:full_path, ':p:h')
            return l:path
        endif

    endfor

    return ''

endfunction
