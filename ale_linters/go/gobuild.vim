" Author: dzhou121 <dzhou121@gmail.com>, Ryan Norris <rynorris@gmail.com>
" Description: go build for Go files

let s:temp_file_pattern = 'ale\.[0-9]\+\..*\.go'

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

    " Write current buffer to a temporary file.
    let l:temp_file = s:TempFileName(a:buffer)
    if filereadable(l:temp_file)
      " File already exists.  Bail.
      return ''
    endif

    call writefile(getbufline(a:buffer, 1, '$'), l:temp_file)
    call ale#engine#ManageFile(a:buffer, l:temp_file)

    " Swap out the current file in the file listing for the temporary version.
    " Also filter out any other ale temporary files in the directory.
    let l:this_file = s:ThisFile(a:buffer)
    call filter(l:all_files, 'fnamemodify(v:val, '':t'') != l:this_file')
    call filter(l:all_files, 'fnamemodify(v:val, '':t'') !~# s:temp_file_pattern')
    call add(l:all_files, l:temp_file)

    " Prepare command.
    let l:file_args = join(map(l:all_files, 'fnameescape(v:val)'))
    return 'go test -c ' . ' -o /dev/null ' . l:file_args
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'executable': 'go',
\   'output_stream': 'stderr',
\   'read_buffer': 0,
\   'command_callback': 'ale_linters#go#gobuild#GetCommand',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
