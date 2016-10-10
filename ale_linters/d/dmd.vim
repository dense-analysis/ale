" Author: w0rp <devw0rp@gmail.com>
" Description: "dmd for D files"

if exists('g:loaded_ale_linters_d_dmd')
    finish
endif

let g:loaded_ale_linters_d_dmd = 1

" A function for finding the dmd-wrapper script in the Vim runtime paths
function! s:FindWrapperScript()
    for parent in split(&runtimepath, ',')
        " Expand the path to deal with ~ issues.
        let path = expand(parent . '/' . 'dmd-wrapper')

        if filereadable(path)
            return path
        endif
    endfor
endfunction

function! ale_linters#d#dmd#GetCommand(buffer)
    let wrapper_script = s:FindWrapperScript()

    let command = wrapper_script . ' -o- -vcolumns -c'

    return command
endfunction

function! ale_linters#d#dmd#Handle(buffer, lines)
    " Matches patterns lines like the following:
    "
    " /tmp/tmp.G1L5xIizvB.d(8,8): Error: module weak_reference is in file 'dstruct/weak_reference.d' which cannot be read
    let pattern = '^[^(]\+(\([0-9]\+\),\([0-9]\+\)): \([^:]\+\): \(.\+\)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            break
        endif

        let line = l:match[1] + 0
        let column = l:match[2] + 0
        let type = l:match[3]
        let text = l:match[4]

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': bufnr('%'),
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': column,
        \   'text': text,
        \   'type': type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ale#linter#define('d', {
\   'name': 'dmd',
\   'output_stream': 'stderr',
\   'executable': 'dmd',
\   'command_callback': 'ale_linters#d#dmd#GetCommand',
\   'callback': 'ale_linters#d#dmd#Handle',
\})
