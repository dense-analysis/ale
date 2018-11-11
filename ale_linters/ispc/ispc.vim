" Author: Martino Pilia <martino.pilia@gmail.com>
" Description: Lint ispc files with the Intel(R) SPMD Program Compiler

call ale#Set('ispc_ispc_executable', 'ispc')
call ale#Set('ispc_ispc_options', '')

" ISPC has no equivalent of gcc's -iquote argument, so use a -I for headers
" in the same directory. Not perfect, since now local headers are accepted
" by #include<> while they should not, but better than nothing.
function! ale_linters#ispc#ispc#GetCommand(buffer) abort
    return '%e '
    \   . '-I ' . ale#Escape(fnamemodify(bufname(a:buffer), ':p:h'))
    \   . ale#Pad(ale#c#IncludeOptions(ale#c#FindLocalHeaderPaths(a:buffer)))
    \   . ale#Pad(ale#Var(a:buffer, 'ispc_ispc_options')) . ' -'
endfunction

" Note that we ignore the two warnings in the beginning of the compiler output
" ('no output file specified' and 'no --target specified'), since they have
" nothing to do with linting.
function! ale_linters#ispc#ispc#Handle(buffer, lines) abort
    " Message format: <filename>:<lnum>:<col> <type>: <text>
    " As far as I know, <type> can be any of:
    "   'error', 'Error', 'fatal error', 'Warning', 'Performance Warning'
    let l:re = '\v(.+):([0-9]+):([0-9]+):\s+([^:]+):\s+(.+)\s*'
    let l:Trim = {s -> substitute(s, '^\s*\(.\{-}\)\s*$', '\1', '')}
    let l:line_count = len(a:lines)
    let l:output = []

    for l:index in range(l:line_count)
        let l:match = matchlist(a:lines[l:index], l:re)

        if l:match != []
            let l:text = l:Trim(l:match[5])

            " The text may continue over multiple lines.
            " Look for a full stop, question, or exclamation mark
            " ending the text.
            " Also, for some reason, 'file not found' messages are on
            " one line but not terminated by punctuation.
            while match(l:text, '[.?!]\s*$') == -1
                    \ && match(l:text, 'file not found') == -1
                    \ && l:index < l:line_count - 1
                let l:index += 1
                let l:text .= ' ' . l:Trim(a:lines[l:index])
            endwhile

            call add(l:output, {
            \   'filename': fnamemodify(l:match[1], ':p'),
            \   'bufnr': a:buffer,
            \   'lnum': str2nr(l:match[2]),
            \   'col': str2nr(l:match[3]),
            \   'type': l:match[4] =~? 'error' ? 'E' : 'W',
            \   'text': l:text,
            \})
            continue
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('ispc', {
\   'name': 'ispc',
\   'output_stream': 'stderr',
\   'executable_callback': ale#VarFunc('ispc_ispc_executable'),
\   'command_callback': 'ale_linters#ispc#ispc#GetCommand',
\   'callback': 'ale_linters#ispc#ispc#Handle',
\})
