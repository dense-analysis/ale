" Author: w0rp <devw0rp@gmail.com>
" Description: "dmd for D files"

" A function for finding the dmd-wrapper script in the Vim runtime paths
function! s:FindWrapperScript() abort
    for l:parent in split(&runtimepath, ',')
        " Expand the path to deal with ~ issues.
        let l:path = expand(l:parent . '/' . 'dmd-wrapper')

        if filereadable(l:path)
            return l:path
        endif
    endfor
endfunction

function! ale_linters#d#dmd#GetCommand(buffer) abort
    let l:wrapper_script = s:FindWrapperScript()

    let l:command = l:wrapper_script . ' -o- -vcolumns -c'

    return l:command
endfunction

function! ale_linters#d#dmd#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    " /tmp/tmp.qclsa7qLP7/file.d(1): Error: function declaration without return type. (Note that constructors are always named 'this')
    " /tmp/tmp.G1L5xIizvB.d(8,8): Error: module weak_reference is in file 'dstruct/weak_reference.d' which cannot be read
    let l:pattern = '^[^(]\+(\([0-9]\+\)\,\?\([0-9]*\)): \([^:]\+\): \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            break
        endif

        let l:line = l:match[1] + 0
        let l:column = l:match[2] + 0
        let l:type = l:match[3]
        let l:text = l:match[4]

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': bufnr('%'),
        \   'lnum': l:line,
        \   'vcol': 0,
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('d', {
\   'name': 'dmd',
\   'output_stream': 'stderr',
\   'executable': 'dmd',
\   'command_callback': 'ale_linters#d#dmd#GetCommand',
\   'callback': 'ale_linters#d#dmd#Handle',
\})
