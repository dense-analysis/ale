" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for formatting command strings, running commands, and
"   managing files during linting and fixing cycles.

" This dictionary holds lists of files and directories to remove later.
if !exists('s:managed_data')
    let s:managed_data = {}
endif

" Used to get the data in tests.
function! ale#command#GetData() abort
    return deepcopy(s:managed_data)
endfunction

function! ale#command#ClearData() abort
    let s:managed_data = {}
endfunction

function! ale#command#ManageFile(buffer, file) abort
    if !has_key(s:managed_data, a:buffer)
        let s:managed_data[a:buffer] = {'file_list': [], 'directory_list': []}
    endif

    call add(s:managed_data[a:buffer].file_list, a:file)
endfunction

function! ale#command#ManageDirectory(buffer, directory) abort
    if !has_key(s:managed_data, a:buffer)
        let s:managed_data[a:buffer] = {'file_list': [], 'directory_list': []}
    endif

    call add(s:managed_data[a:buffer].directory_list, a:directory)
endfunction

function! ale#command#CreateFile(buffer) abort
    " This variable can be set to 1 in tests to stub this out.
    if get(g:, 'ale_create_dummy_temporary_file')
        return 'TEMP'
    endif

    let l:temporary_file = ale#util#Tempname()
    call ale#command#ManageFile(a:buffer, l:temporary_file)

    return l:temporary_file
endfunction

" Create a new temporary directory and manage it in one go.
function! ale#command#CreateDirectory(buffer) abort
    " This variable can be set to 1 in tests to stub this out.
    if get(g:, 'ale_create_dummy_temporary_file')
        return 'TEMP_DIR'
    endif

    let l:temporary_directory = ale#util#Tempname()
    " Create the temporary directory for the file, unreadable by 'other'
    " users.
    call mkdir(l:temporary_directory, '', 0750)
    call ale#command#ManageDirectory(a:buffer, l:temporary_directory)

    return l:temporary_directory
endfunction

function! ale#command#RemoveManagedFiles(buffer) abort
    let l:info = get(s:managed_data, a:buffer, {})

    if !empty(l:info)
    \&& (
    \   !exists('*ale#engine#IsCheckingBuffer')
    \   || !ale#engine#IsCheckingBuffer(a:buffer)
    \)
    \&& (
    \   !has_key(g:ale_fix_buffer_data, a:buffer)
    \   || g:ale_fix_buffer_data[a:buffer].done
    \)
        " We can't delete anything in a sandbox, so wait until we escape from
        " it to delete temporary files and directories.
        if ale#util#InSandbox()
            return
        endif

        " Delete files with a call akin to a plan `rm` command.
        for l:filename in l:info.file_list
            call delete(l:filename)
        endfor

        " Delete directories like `rm -rf`.
        " Directories are handled differently from files, so paths that are
        " intended to be single files can be set up for automatic deletion
        " without accidentally deleting entire directories.
        for l:directory in l:info.directory_list
            call delete(l:directory, 'rf')
        endfor

        call remove(s:managed_data, a:buffer)
    endif
endfunction

function! ale#command#CreateTempFile(buffer, temporary_file, input) abort
    if empty(a:temporary_file)
        " There is no file, so we didn't create anything.
        return 0
    endif

    " Use an existing list of lines of input if we have it, or get the lines
    " from the file.
    let l:lines = a:input isnot v:null ? a:input : getbufline(a:buffer, 1, '$')

    let l:temporary_directory = fnamemodify(a:temporary_file, ':h')
    " Create the temporary directory for the file, unreadable by 'other'
    " users.
    call mkdir(l:temporary_directory, '', 0750)
    " Automatically delete the directory later.
    call ale#command#ManageDirectory(a:buffer, l:temporary_directory)
    " Write the buffer out to a file.
    call ale#util#Writefile(a:buffer, l:lines, a:temporary_file)

    return 1
endfunction

function! s:TemporaryFilename(buffer) abort
    let l:filename = fnamemodify(bufname(a:buffer), ':t')

    if empty(l:filename)
        " If the buffer's filename is empty, create a dummy filename.
        let l:ft = getbufvar(a:buffer, '&filetype')
        let l:filename = 'file' . ale#filetypes#GuessExtension(l:ft)
    endif

    " Create a temporary filename, <temp_dir>/<original_basename>
    " The file itself will not be created by this function.
    return ale#util#Tempname() . (has('win32') ? '\' : '/') . l:filename
endfunction

" Given part of a command, replace any % with %%, so that no characters in
" the string will be replaced with filenames, etc.
function! ale#command#EscapeCommandPart(command_part) abort
    return substitute(a:command_part, '%', '%%', 'g')
endfunction

" Given a command string, replace every...
" %s -> with the current filename
" %t -> with the name of an unused file in a temporary directory
" %% -> with a literal %
function! ale#command#FormatCommand(buffer, executable, command, pipe_file_if_needed, input) abort
    let l:temporary_file = ''
    let l:command = a:command

    " First replace all uses of %%, used for literal percent characters,
    " with an ugly string.
    let l:command = substitute(l:command, '%%', '<<PERCENTS>>', 'g')

    " Replace %e with the escaped executable, if available.
    if !empty(a:executable) && l:command =~# '%e'
        let l:command = substitute(l:command, '%e', '\=ale#Escape(a:executable)', 'g')
    endif

    " Replace all %s occurrences in the string with the name of the current
    " file.
    if l:command =~# '%s'
        let l:filename = fnamemodify(bufname(a:buffer), ':p')
        let l:command = substitute(l:command, '%s', '\=ale#Escape(l:filename)', 'g')
    endif

    if a:input isnot v:false && l:command =~# '%t'
        " Create a temporary filename, <temp_dir>/<original_basename>
        " The file itself will not be created by this function.
        let l:temporary_file = s:TemporaryFilename(a:buffer)
        let l:command = substitute(l:command, '%t', '\=ale#Escape(l:temporary_file)', 'g')
    endif

    " Finish formatting so %% becomes %.
    let l:command = substitute(l:command, '<<PERCENTS>>', '%', 'g')

    if a:pipe_file_if_needed && empty(l:temporary_file)
        " If we are to send the Vim buffer to a command, we'll do it
        " in the shell. We'll write out the file to a temporary file,
        " and then read it back in, in the shell.
        let l:temporary_file = s:TemporaryFilename(a:buffer)
        let l:command = l:command . ' < ' . ale#Escape(l:temporary_file)
    endif

    let l:file_created = ale#command#CreateTempFile(
    \   a:buffer,
    \   l:temporary_file,
    \   a:input,
    \)

    return [l:temporary_file, l:command, l:file_created]
endfunction
