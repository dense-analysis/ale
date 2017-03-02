" Author: buffalocoder - https://github.com/buffalocoder
" Description: Elm linting in Ale. Closely follows the Syntastic checker in https://github.com/ElmCast/elm-vim.

function! ale_linters#elm#make#Handle(buffer, lines) abort
    let l:output = []
    let l:is_windows = has('win32')
    let l:temp_dir = l:is_windows ? $TMP : $TMPDIR
    for l:line in a:lines
        if l:line[0] ==# '['
            let l:errors = json_decode(l:line)

            for l:error in l:errors
                " Check if file is from the temp directory.
                " Filters out any errors not related to the buffer.
                if l:is_windows
                    let l:file_is_buffer = l:error.file[0:len(l:temp_dir) - 1] ==? l:temp_dir
                else
                    let l:file_is_buffer = l:error.file[0:len(l:temp_dir) - 1] ==# l:temp_dir
                endif

                if l:file_is_buffer
                    call add(l:output, {
                    \    'bufnr': a:buffer,
                    \    'lnum': l:error.region.start.line,
                    \    'col': l:error.region.start.column,
                    \    'type': (l:error.type ==? 'error') ? 'E' : 'W',
                    \    'text': l:error.overview,
                    \    'detail': l:error.overview . "\n\n" . l:error.details
                    \})
                endif
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
        let l:dir_set_cmd = 'cd ' . fnameescape(l:root_dir) . ' && '
    endif

    " The elm-make compiler, at the time of this writing, uses '/dev/null' as
    " a sort of flag to tell the compiler not to generate an output file,
    " which is why this is hard coded here.
    " Source: https://github.com/elm-lang/elm-make/blob/master/src/Flags.hs
    let l:elm_cmd = 'elm-make --report=json --output='.shellescape('/dev/null')

    return l:dir_set_cmd . ' ' . l:elm_cmd . ' %t'
endfunction

call ale#linter#Define('elm', {
\    'name': 'make',
\    'executable': 'elm-make',
\    'output_stream': 'both',
\    'command_callback': 'ale_linters#elm#make#GetCommand',
\    'callback': 'ale_linters#elm#make#Handle'
\})

