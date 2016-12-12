" Author: buffalocoder - https://github.com/buffalocoder

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

" This function was copied from from https://github.com/ElmCast/elm-vim.
" All credit goes to that project!
" Returns the closest parent with an elm-package.json file.
function! s:FindRootDirectory() abort
    let l:elm_root = getbufvar('%', 'elmRoot')
    if empty(l:elm_root)
        let l:current_file = expand('%:p')
        let l:dir_current_file = fnameescape(fnamemodify(l:current_file, ':h'))
        let l:match = findfile('elm-package.json', l:dir_current_file . ';')
        if empty(l:match)
            let l:elm_root = ''
        else
            let l:elm_root = fnamemodify(l:match, ':p:h')
        endif

        if !empty(l:elm_root)
            call setbufvar('%', 'elmRoot', l:elm_root)
        endif
    endif
    return l:elm_root
endfunction

" Return the command to execute the linter in the projects directory.
" If it doesn't, then this will fail when imports are needed.
function! ale_linters#elm#make#GetCommand(buffer) abort
    let l:root_dir = s:FindRootDirectory()
    let l:dir_set_cmd = 'cd' . fnameescape(l:root_dir)

    return l:dir_set_cmd . '; elm-make --report=json %s --output='.shellescape(g:ale#util#nul_file)
endfunction

call ale#linter#Define('elm', {
\    'name': 'make',
\    'executable': 'elm-make',
\    'output_stream': 'both',
\    'command_callback': 'ale_linters#elm#make#GetCommand',
\    'callback': 'ale_linters#elm#make#Handle'
\})

