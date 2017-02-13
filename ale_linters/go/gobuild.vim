" Author: dzhou121 <dzhou121@gmail.com>, Ryan Norris <rynorris@gmail.com>
" Description: go build for Go files

function! s:ThisFile(buffer) abort
    return fnamemodify(bufname(a:buffer), ':p:t')
endfunction

function! s:ThisPackage(buffer) abort
    return fnamemodify(bufname(a:buffer), ':p:h')
endfunction

function! s:TempFileName(buffer) abort
    return s:ThisPackage(a:buffer) . '/ale.' . expand('$PPID') . '.' . s:ThisFile(a:buffer)
endfunction

function! ale_linters#go#gobuild#GetCommand(buffer) abort
    " Get absolute path to the directory containing the current file.
    " This directory by definition contains all the files for this go package.
    let l:this_package = s:ThisPackage(a:buffer)

    " Get a listing of all go files in the directory.
    " TODO: Handle packages that contain c files.
    let l:all_files = globpath(l:this_package, '*.go', 1, 1)

    " Filter out the current file since we don't want to include it twice.
    " We'll then pass this list to go compile and stdin_wrapper will add on
    " the temporary version of the current file.
    let l:this_file = s:ThisFile(a:buffer)
    call filter(l:all_files, 'fnamemodify(v:val, '':t'') != l:this_file')
    call filter(l:all_files, 'fnamemodify(v:val, '':t'') !~# ''ale\.[0-9]\+\..*\.go''')

    " Write current buffer to a temporary file.
    let l:temp_file = s:TempFileName(a:buffer)
    if filereadable(l:temp_file)
      " File already exists.  Bail.
      return ''
    endif

    call writefile(getbufline(a:buffer, 1, '$'), l:temp_file)

    return 'go test -c ' . ' -o /dev/null ' . join(l:all_files) . ' ' . l:temp_file . '; rm ' . l:temp_file
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'output_stream': 'stderr',
\   'executable': 'go',
\   'command_callback': 'ale_linters#go#gobuild#GetCommand',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
