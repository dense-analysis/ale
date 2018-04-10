" Author: gagbo <gagbobada@gmail.com>
" Description: clang-check linter for c files

call ale#Set('c_clangcheck_executable', 'clang-check')
call ale#Set('c_clangcheck_options', '')
call ale#Set('c_build_dir', '')

function! ale_linters#c#clangcheck#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_clangcheck_executable')
endfunction

function! ale_linters#c#clangcheck#GetCommand(buffer) abort
    let l:user_options = ale#Var(a:buffer, 'c_clangcheck_options')

    " Try to find compilation database to link automatically
    let l:build_dir = ale#Var(a:buffer, 'c_build_dir')

    if empty(l:build_dir)
        let l:build_dir = ale#c#FindCompileCommands(a:buffer)
    endif

    " The extra arguments in the command are used to prevent .plist files from
    " being generated. These are only added if no build directory can be
    " detected.
    return ale#Escape(ale_linters#c#clangcheck#GetExecutable(a:buffer))
    \   . ' -analyze %s'
    \   . (empty(l:build_dir) ? ' -extra-arg -Xclang -extra-arg -analyzer-output=text' : '')
    \   . (!empty(l:user_options) ? ' ' . l:user_options : '')
    \   . (!empty(l:build_dir) ? ' -p ' . ale#Escape(l:build_dir) : '')
endfunction

call ale#linter#Define('c', {
\   'name': 'clangcheck',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#c#clangcheck#GetExecutable',
\   'command_callback': 'ale_linters#c#clangcheck#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
