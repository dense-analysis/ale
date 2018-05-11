" Author: Lin Wei, skywind3000(at)gmail.com
" Description: splint linter for c files

call ale#Set('c_splint_executable', 'splint')
call ale#Set('c_splint_options', '')

function! ale_linters#c#splint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_splint_executable')
endfunction


function! ale_linters#c#splint#GetCommand(buffer) abort
    " Search upwards from the file for .splintrc
    "
    " If we find it, we'll `cd` to where the .splintrc file is,
    " then use the file to set up import paths, etc.
    let l:splintrc_path = ale#path#FindNearestFile(a:buffer, '.splintrc')

    let l:cd_command = !empty(l:splintrc_path)
    \   ? ale#path#CdString(fnamemodify(l:splintrc_path, ':h'))
    \   : ''
    let l:splintrc_option = !empty(l:splintrc_path)
    \   ? '-f .splintrc '
    \   : ''

    return l:cd_command
    \   . ale#Escape(ale_linters#c#splint#GetExecutable(a:buffer))
    \   . ' -showfunc -hints +quiet -parenfileformat '
    \   . l:splintrc_option
    \   . ale#Var(a:buffer, 'c_splint_options')
    \   . ' ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p')) . ' '
endfunction

function! ale_linters#c#splint#Handler(buffer, lines) abort
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):?(\d+)?:? ?(.+)$'
    let l:output = []
    let l:dir = expand('#' . a:buffer . ':p:h')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'filename': ale#path#GetAbsPath(l:dir, l:match[1]),
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[4],
        \   'type': 'E',
        \})
    endfor
    return l:output
endfunction

call ale#linter#Define('c', {
\   'name': 'splint',
\   'output_stream': 'both',
\   'executable_callback': 'ale_linters#c#splint#GetExecutable',
\   'command_callback': 'ale_linters#c#splint#GetCommand',
\   'callback': 'ale_linters#c#splint#Handler',
\})


