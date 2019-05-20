" Author: Bart Libert <bart.libert@gmail.com>
" Description: cppcheck linter for c files

call ale#Set('c_cppcheck_executable', 'cppcheck')
call ale#Set('c_cppcheck_options', '--enable=style')

function! ale_linters#c#cppcheck#GetCommand(buffer) abort
    let l:compile_commmands_path = ''
    let l:buffer_path_include = ''

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

    let l:cd_command = !empty(l:compile_commmands_path)
    \   ? ale#path#CdString(fnamemodify(l:compile_commmands_path, ':h'))
    \   : ''
    let l:compile_commands_option = !empty(l:compile_commmands_path)
    \   ? '--project=compile_commands.json '
    \   : ''

    " if the buffer is modified or we haven't found compile_commands.json,
    " include the file's directory.
    if l:modified || empty(l:compile_commmands_path)
      " Get path to this buffer so we can include it into cppcheck with -I
      " This could be expanded to get more -I directives from the compile
      " command in compile_commands.json, if it's found.
      let l:buffer_path = fnamemodify(bufname(a:buffer), ':p:h')
      let l:buffer_path_include = ' -I' . ale#Escape(l:buffer_path)
    endif

    return l:cd_command
    \   . '%e -q --language=c '
    \   . l:compile_commands_option
    \   . ale#Var(a:buffer, 'c_cppcheck_options')
    \   . l:buffer_path_include
    \   . ' %t'
endfunction

call ale#linter#Define('c', {
\   'name': 'cppcheck',
\   'output_stream': 'both',
\   'executable': {b -> ale#Var(b, 'c_cppcheck_executable')},
\   'command': function('ale_linters#c#cppcheck#GetCommand'),
\   'callback': 'ale#handlers#cppcheck#HandleCppCheckFormat',
\})
