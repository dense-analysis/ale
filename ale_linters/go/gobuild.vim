" Author: dzhou121 <dzhou121@gmail.com>
" Description: go build for Go files

function! s:FindGobuildScript() abort
    for l:parent in split(&runtimepath, ',')
        " Expand the path to deal with ~ issues.
        let l:path = expand(l:parent . '/' . 'stdin-gobuild')

        if filereadable(l:path)
            return l:path . ' %s'
        endif
    endfor
endfunction

let g:ale#util#stdin_gobuild = s:FindGobuildScript()

call ale#linter#Define('go', {
\   'name': 'go build',
\   'output_stream': 'stderr',
\   'executable': 'go',
\   'command': g:ale#util#stdin_gobuild,
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
