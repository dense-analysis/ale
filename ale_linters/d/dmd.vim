" Author: w0rp <devw0rp@gmail.com>
" Description: "dmd for D files"

function! s:FindDUBConfig(buffer) abort
    " Find a DUB configuration file in ancestor paths.
    " The most DUB-specific names will be tried first.
    for l:possible_filename in ['dub.sdl', 'dub.json', 'package.json']
        let l:dub_file = ale#util#FindNearestFile(a:buffer, l:possible_filename)

        if !empty(l:dub_file)
            return l:dub_file
        endif
    endfor

    return ''
endfunction

function! ale_linters#d#dmd#DUBCommand(buffer) abort
    " If we can't run dub, then skip this command.
    if !executable('dub')
        " Returning an empty string skips to the DMD command.
        return ''
    endif

    let l:dub_file = s:FindDUBConfig(a:buffer)

    if empty(l:dub_file)
        return ''
    endif

    " To support older dub versions, we just change the directory to
    " the directory where we found the dub config, and then run `dub describe`
    " from that directory.
    return 'cd ' . fnameescape(fnamemodify(l:dub_file, ':h'))
    \   . ' && dub describe --import-paths'
endfunction

function! ale_linters#d#dmd#DMDCommand(buffer, dub_output) abort
    let l:import_list = []

    " Build a list of import paths generated from DUB, if available.
    for l:line in a:dub_output
        if !empty(l:line)
            " The arguments must be '-Ifilename', not '-I filename'
            call add(l:import_list, '-I' . fnameescape(l:line))
        endif
    endfor

    return 'dmd '. join(l:import_list) . ' -o- -vcolumns -c %t'
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
        \   'col': l:column,
        \   'text': l:text,
        \   'type': l:type ==# 'Warning' ? 'W' : 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('d', {
\   'name': 'dmd',
\   'executable': 'dmd',
\   'command_chain': [
\       {'callback': 'ale_linters#d#dmd#DUBCommand', 'output_stream': 'stdout'},
\       {'callback': 'ale_linters#d#dmd#DMDCommand', 'output_stream': 'stderr'},
\   ],
\   'callback': 'ale_linters#d#dmd#Handle',
\})
