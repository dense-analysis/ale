" Author: buffalocoder - https://github.com/buffalocoder, soywod - https://github.com/soywod
" Description: Elm linting in Ale. Closely follows the Syntastic checker in https://github.com/ElmCast/elm-vim.

call ale#Set('elm_executable', 'elm')
call ale#Set('elm_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#elm#make#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'elm', [
    \   'node_modules/.bin/elm',
    \])
endfunction

function! ale_linters#elm#make#Handle(buffer, lines) abort
    let l:output = []
    let l:unparsed_lines = []

    for l:line in a:lines
        if l:line[0] is# '{'
            let l:report = json_decode(l:line)

            if l:report.type is? 'error'
                " General problem
                let l:details = map(copy(l:report.message), 'ale_linters#elm#make#ParseMessageItem(v:val)')

                call add(l:output, {
                            \    'lnum': 1,
                            \    'type': 'E',
                            \    'text': l:report.title,
                            \    'detail': join(l:details, '')
                            \})
            else
                " Compilation errors
                for l:error in l:report.errors
                    let l:file_is_buffer = ale_linters#elm#make#FileIsBuffer(l:error.path)

                    for l:problem in l:error.problems
                        let l:details = map(copy(l:problem.message), 'ale_linters#elm#make#ParseMessageItem(v:val)')

                        if l:file_is_buffer
                            " Buffer module has problems
                            call add(l:output, {
                                        \    'lnum': l:problem.region.start.line,
                                        \    'col': l:problem.region.start.column,
                                        \    'end_lnum': l:problem.region.end.line,
                                        \    'end_col': l:problem.region.end.column,
                                        \    'type': 'E',
                                        \    'text': l:problem.title,
                                        \    'detail': join(l:details, '')
                                        \})
                        else
                            " Imported module has problems
                            let l:location = l:error.path .':'. l:problem.region.start.line
                            call add(l:output, {
                                        \    'lnum': 1,
                                        \    'type': 'E',
                                        \    'text': l:location .' - '. l:problem.title,
                                        \    'detail':  l:location ." -------\n\n" . join(l:details, '')
                                        \})
                        endif
                    endfor
                endfor
            endif
        else
            call add(l:unparsed_lines, l:line)
        endif
    endfor

    if len(l:unparsed_lines) > 0
        call add(l:output, {
        \    'lnum': 1,
        \    'type': 'E',
        \    'text': l:unparsed_lines[0],
        \    'detail': join(l:unparsed_lines, "\n")
        \})
    endif

    return l:output
endfunction

function! ale_linters#elm#make#FileIsBuffer(path) abort
    let l:is_windows = has('win32')
    let l:temp_dir = l:is_windows ? $TMP : $TMPDIR

    if has('win32')
        return a:path[0:len(l:temp_dir) - 1] is? l:temp_dir
    else
        return a:path[0:len(l:temp_dir) - 1] is# l:temp_dir
    endif
endfunction

function! ale_linters#elm#make#ParseMessageItem(item) abort
    if type(a:item) == type('')
        return a:item
    else
        return a:item.string
    endif
endfunction

" Return the command to execute the linter in the projects directory.
" If it doesn't, then this will fail when imports are needed.
function! ale_linters#elm#make#GetCommand(buffer) abort
    let l:elm_json = ale#path#FindNearestFile(a:buffer, 'elm.json')
    let l:elm_exe = ale_linters#elm#make#GetExecutable(a:buffer)

    if empty(l:elm_json)
        let l:dir_set_cmd = ''
    else
        let l:root_dir = fnamemodify(l:elm_json, ':p:h')
        let l:dir_set_cmd = 'cd ' . ale#Escape(l:root_dir) . ' && '
    endif

    " The elm compiler, at the time of this writing, uses '/dev/null' as
    " a sort of flag to tell the compiler not to generate an output file,
    " which is why this is hard coded here.
    " Source: https://github.com/elm-lang/elm-compiler/blob/19d5a769b30ec0b2fc4475985abb4cd94cd1d6c3/builder/src/Generate/Output.hs#L253
    let l:elm_cmd = ale#Escape(l:elm_exe)
    \   . ' make'
    \   . ' --report=json'
    \   . ' --output=/dev/null'

    return l:dir_set_cmd . ' ' . l:elm_cmd . ' %t'
endfunction

call ale#linter#Define('elm', {
\    'name': 'make',
\    'executable_callback': 'ale_linters#elm#make#GetExecutable',
\    'output_stream': 'both',
\    'command_callback': 'ale_linters#elm#make#GetCommand',
\    'callback': 'ale_linters#elm#make#Handle'
\})
