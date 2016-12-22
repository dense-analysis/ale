" Author: dzhou121 <dzhou121@gmail.com>
" Description: go build for Go files

function! s:FindGobuildScript() abort
    return g:ale#util#stdin_wrapper . ' .go go build'
endfunction

let g:ale#util#stdin_gobuild = s:FindGobuildScript()

call ale#linter#Define('go', {
\   'name': 'go build',
\   'output_stream': 'stderr',
\   'executable': 'go',
\   'command': g:ale#util#stdin_gobuild,
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
