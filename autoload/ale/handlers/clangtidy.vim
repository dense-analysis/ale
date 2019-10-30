" Author: Timur Celik https://github.com/clktmr
" Description: Handle errors for clang-tidy

function! ale#handlers#clangtidy#HandleClangTidyFormat(buffer, lines) abort
    let l:build_dir = ale#c#GetBuildDirectory(a:buffer)
    let l:items = ale#handlers#gcc#HandleGCCFormat(a:buffer, a:lines)

    for l:item in l:items
        let l:item['filename'] = ale#path#GetAbsPath(l:build_dir, l:item['filename'])
    endfor

    return l:items
endfunction

