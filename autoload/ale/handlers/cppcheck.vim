" Description: Handle errors for cppcheck.

function! ale#handlers#cppcheck#GetCdCommand(buffer) abort

    let l:cd_command = !empty(ale#handlers#cppcheck#GetCompileCommandsPath)
    \   ? ale#path#CdString(fnamemodify(l:compile_commmands_path, ':h'))
    \   : ''

    return l:cd_command
endfunction

function! ale#handlers#cppcheck#GetBufferPathIncludeOption(buffer) abort
    let l:buffer_path_include = ''

    let l:modified = getbufvar(a:buffer, '&modified')

    " if the buffer is modified or we haven't found compile_commands.json,
    " include the file's directory.
    if l:modified
      " Get path to this buffer so we can include it into cppcheck with -I
      " This could be expanded to get more -I directives from the compile
      " command in compile_commands.json, if it's found.
      let l:buffer_path = fnamemodify(bufname(a:buffer), ':p:h')
      let l:buffer_path_include = ' -I' . ale#Escape(l:buffer_path)
    endif
endfunction

function! ale#handlers#cppcheck#GetCompileCommandsPath(buffer) abort
    let l:compile_commmands_path = ''

    " If the current buffer is modified, using compile_commands.json does no
    " good, so include the file's directory instead. It's not quite as good as
    " using --project, but is at least equivalent to running cppcheck on this
    " file manually from the file's directory.
    let l:modified = getbufvar(a:buffer, '&modified')
    if !l:modified
      " Search upwards from the file for compile_commands.json.
      "
      " If we find it, we'll `cd` to where the compile_commands.json file is,
      " then use the file to set up import paths, etc.
      let l:compile_commmands_path = ale#path#FindNearestFile(a:buffer, 'compile_commands.json')
    endif

    return l:compile_commands_path
endfunction

function! ale#handlers#cppcheck#GetCompileCommandsOptions(buffer) abort

    let l:compile_commmands_path = ale#handlers#cppcheck#GetCompileCommandsPath(a:buffer)
    let l:compile_commands_option = !empty(l:compile_commmands_path)
    \   ? '--project=compile_commands.json '
    \   : ''

    return l:compile_commands_option
endfunction

function! ale#handlers#cppcheck#HandleCppCheckFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    " [test.cpp:5]: (error) Array 'a[10]' accessed at index 10, which is out of bounds
    let l:pattern = '\v^\[(.+):(\d+)\]: \(([a-z]+)\) (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if ale#path#IsBufferPath(a:buffer, l:match[1])
            call add(l:output, {
            \   'lnum': str2nr(l:match[2]),
            \   'type': l:match[3] is# 'error' ? 'E' : 'W',
            \   'text': l:match[4],
            \})
        endif
    endfor

    return l:output
endfunction
