" Author: w0rp <devw0rp@gmail.com>
" Description: "dmd for D files"

function! s:GetDUBCommand(buffer) abort
    " If we can't run dub, then skip this command.
    if executable('dub')
        " Returning an empty string skips to the DMD command.
        let l:config = ale#d#FindDUBConfig(a:buffer)

        " To support older dub versions, we just change the directory to the
        " directory where we found the dub config, and then run `dub describe`
        " from that directory.
        if !empty(l:config)
            return [fnamemodify(l:config, ':h'), 'dub describe --import-paths']
        endif
    endif

    return ['', '']
endfunction

function! ale_linters#d#dmd#RunDUBCommand(buffer) abort
    let [l:cwd, l:command] = s:GetDUBCommand(a:buffer)

    if empty(l:command)
        " If we can't run DUB, just run DMD.
        return ale_linters#d#dmd#DMDCommand(a:buffer, [], {})
    endif

    return ale#command#Run(
    \   a:buffer,
    \   l:command,
    \   function('ale_linters#d#dmd#DMDCommand'),
    \   {'cwd': l:cwd},
    \)
endfunction

function! ale_linters#d#dmd#DMDCommand(buffer, dub_output, meta) abort
    let l:import_list = []

    " Build a list of import paths generated from DUB, if available.
    for l:line in a:dub_output
        if !empty(l:line)
            " The arguments must be '-Ifilename', not '-I filename'
            call add(l:import_list, '-I' . ale#Escape(l:line))
        endif
    endfor

    return 'dmd '. join(l:import_list) . ' -o- -wi -vcolumns -c %t'
endfunction

function! ale_linters#d#dmd#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    " /tmp/tmp.qclsa7qLP7/file.d(1): Error: function declaration without return type. (Note that constructors are always named 'this')
    " /tmp/tmp.G1L5xIizvB.d(8,8): Error: module weak_reference is in file 'dstruct/weak_reference.d' which cannot be read
    let l:pattern = '\v^(\f+)\((\d+)(,(\d+))?\): (\w+): (.+)$'
    let l:output = []
    let l:dir = expand('#' . a:buffer . ':p:h')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        " If dmd was invoked with relative path, match[1] is relative, otherwise it is absolute.
        " As we invoke dmd with the buffer path (in /tmp), this will generally be absolute already
        let l:fname = ale#path#GetAbsPath(l:dir, l:match[1])
        call add(l:output, {
        \   'filename': l:fname,
        \   'lnum': l:match[2],
        \   'col': l:match[4],
        \   'type': l:match[5] is# 'Warning' || l:match[5] is# 'Deprecation' ? 'W' : 'E',
        \   'text': l:match[6],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('d', {
\   'name': 'dmd',
\   'executable': 'dmd',
\   'command': function('ale_linters#d#dmd#RunDUBCommand'),
\   'callback': 'ale_linters#d#dmd#Handle',
\   'output_stream': 'stderr',
\})
