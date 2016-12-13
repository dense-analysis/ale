" Author: buffalocoder - https://github.com/buffalocoder
" Description: Elm linting in Ale. Closely follows the Syntastic checker in https://github.com/ElmCast/elm-vim.

function! ale_linters#elm#make#Handle(buffer, lines)
    let l:output = []
    for l:line in a:lines
        if l:line[0] ==# '['
            let l:errors = json_decode(l:line)

            for l:error in l:errors
                call add(l:output, {
                \    'bufnr': a:buffer,
                \    'lnum': l:error.region.start.line,
                \    'vcol': 0,
                \    'col': l:error.region.start.column,
                \    'type': (l:error.type ==? 'error') ? 'E' : 'W',
                \    'text': l:error.overview,
                \    'nr': -1,
                \})
            endfor
        endif
    endfor

    return l:output
endfunction

" Return the command to execute the linter in the projects directory.
" If it doesn't, then this will fail when imports are needed.
function! ale_linters#elm#make#GetCommand(buffer) abort
    let l:elm_package = ale#util#FindNearestFile(a:buffer, 'elm-package.json')
    if empty(l:elm_package)
        let l:dir_set_cmd = ''
    else
        let l:root_dir = fnamemodify(l:elm_package, ':p:h')
        let l:dir_set_cmd = 'cd ' . fnameescape(l:root_dir) . '; '
    endif

    let l:elm_cmd = 'elm-make --report=json --output='.shellescape(g:ale#util#nul_file)
    let l:stdin_wrapper = g:ale#util#stdin_wrapper . ' .elm'

    return l:dir_set_cmd . ' ' . l:stdin_wrapper . ' ' . l:elm_cmd
endfunction

call ale#linter#Define('elm', {
\    'name': 'make',
\    'executable': 'elm-make',
\    'output_stream': 'both',
\    'command_callback': 'ale_linters#elm#make#GetCommand',
\    'callback': 'ale_linters#elm#make#Handle'
\})

