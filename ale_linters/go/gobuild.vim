" Author: dzhou121 <dzhou121@gmail.com>, Ryan Norris <rynorris@gmail.com>
" Description: go build for Go files

function! ale_linters#go#gobuild#GetCommand(buffer) abort
    " Get absolute path to the directory containing the current file.
    " This directory by definition contains all the files for this go package.
    let l:this_package = expand('%:p:h')

    " Get a listing of all go files in the directory.
    " TODO: Handle packages that contain c files.
    let l:all_files = globpath(l:this_package, '*.go', 1, 1)

    " Filter out the current file since we don't want to include it twice.
    " We'll then pass this list to go compile and stdin_wrapper will add on
    " the temporary version of the current file.
    let l:this_file = expand('%:p:t')
    call filter(l:all_files, 'fnamemodify(v:val, ":t") != l:this_file')

    " We're also going to need the system information in order to find the
    " correct import directory.  We'll pull these from go itself since then
    " we're guaranteed they'll match what it's looking for.
    " The version string is of the form "go version go1.6.2 darwin/amd64".
    let l:go_version_string = system('go version')
    let l:version_part = substitute(l:go_version_string, '.* ', '', '')
    let l:goos = substitute(l:version_part, '/.*', '', '')
    let l:goarch = substitute(l:version_part, '.*/', '', '')

    " goarch comes with a troublesome trailing newline,  so strip that off.
    let l:goarch = substitute(l:goarch, '\n\+$', '', '')

    " Finally build the import path.
    " TODO: Handle GOPATHs that contain multiple directories.
    let l:gopath = $GOPATH
    let l:import_path = l:gopath . '/pkg/' . l:goos . '_' . l:goarch

    return g:ale#util#stdin_wrapper . ' .go go tool compile -I ' . l:import_path . ' -o /dev/null ' . join(l:all_files)
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'output_stream': 'stdout',
\   'executable': 'go',
\   'command_callback': 'ale_linters#go#gobuild#GetCommand',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
