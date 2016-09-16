if exists('g:loaded_ale_linters_d_dmd')
    finish
endif

let g:loaded_ale_linters_d_dmd = 1

" A function for finding the dmd-wrapper script in the Vim runtime paths
function! s:FindWrapperScript()
    for parent in split(&runtimepath, ',')
        let path = parent . '/' . 'dmd-wrapper'

        if filereadable(path)
            return path
        endif
    endfor
endfunction

function! ale_linters#d#dmd#GetDubImports(buffer)
    if !executable('dub')
        " If we don't have dub, then stop here.
        return []
    endif

    " Try to find dub.json
    let dub_path = findfile("dub.json", ",;")

    if dub_path == ''
        " Try to find package.json if that fails
        let dub_path = findfile("package.json", ",;")
    endif

    if dub_path == ''
        " We couldn't find the project root directory, so give up.
        return
    endif

    let dub_dir = fnamemodify(dub_path, ':h')
    let old_path = getcwd()

    try
        " Temporarily change to the project directory.
        execute 'cd' . fnameescape(dub_dir)

        return split(system('dub describe --import-paths'), '\n')
    finally
        " Change back to the old path.
        execute 'cd' . fnameescape(old_path)
    endtry
endfunction

function! ale_linters#d#dmd#GetCommand(buffer)
    let wrapper_script = s:FindWrapperScript()

    let command = wrapper_script . ' -o- -vcolumns -c'

    for path in ale_linters#d#dmd#GetDubImports(a:buffer)
        let command .= ' -I' . shellescape(path)
    endfor

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

call ALEAddLinter('d', {
\   'name': 'dmd',
\   'output_stream': 'stderr',
\   'executable': 'dmd',
\   'command_callback': 'ale_linters#d#dmd#GetCommand',
\   'callback': 'ale_linters#d#dmd#Handle',
\})
