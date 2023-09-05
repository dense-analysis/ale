" Close the ALEInfo preview window with the q key.
noremap <buffer> q :q!<CR>

" Explicitly use the default synmaxcol for ale-info.
setlocal synmaxcol=3000

function! ALEInfoOpenHelp() abort
    let l:variable = matchstr(getline('.'), '\v[gb]:ale_[a-z0-9_]+')

    if !empty(l:variable)
        execute('help ' . l:variable)
    endif
endfunction

" Press space to open :help for an ALE Variable
nnoremap <buffer> <silent> <space> :call ALEInfoOpenHelp()<CR>
