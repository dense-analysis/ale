" Author: Lucas Kolstad
" Description: clang linter for cuda files

let g:ale_cuda_clang_options = get(g:, 'ale_cuda_clang_options', '-Wall')


function! ale_linters#cuda#clang#GetCommand(buffer) abort
    return 'clang++ -x cuda -fsyntax-only '
    \   . '-iquote ' . fnameescape(fnamemodify(bufname(a:buffer), ':p:h'))
    \   . ' ' . g:ale_cuda_clang_options . ' -'
endfunction

call ale#linter#Define('cuda', {
\   'name': 'clang',
\   'output_stream': 'stderr',
\   'executable': 'clang++',
\   'command_callback': 'ale_linters#cuda#clang#GetCommand',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
