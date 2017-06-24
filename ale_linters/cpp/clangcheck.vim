" Author: gagbo <gagbobada@gmail.com>
" Description: clang-check linter for cpp files

" Set this option to manually set some options for clang-check.
let g:ale_cpp_clangcheck_options = get(g:, 'ale_cpp_clangcheck_options', '')

" Set this option to manually point to the build directory for clang-tidy.
" This will disable all the other clangtidy_options, since compilation
" flags are contained in the json
let g:ale_c_build_dir = get(g:, 'ale_c_build_dir', '')

function! ale_linters#cpp#clangcheck#GetCommand(buffer) abort
    let l:user_options = ale#Var(a:buffer, 'cpp_clangcheck_options')
    let l:extra_options = !empty(l:user_options)
    \   ? l:user_options
    \   : ''

    " Try to find compilation database to link automatically
    let l:user_build_dir = ale#Var(a:buffer, 'c_build_dir')
    if empty(l:user_build_dir)
        let l:user_build_dir = ale#c#FindCompileCommands(a:buffer)
    endif
    let l:build_options = !empty(l:user_build_dir)
    \   ? ' -p ' . ale#Escape(l:user_build_dir)
    \   : ''

    return 'clang-check -analyze ' . '%s' . l:extra_options . l:build_options
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangcheck',
\   'output_stream': 'stderr',
\   'executable': 'clang-check',
\   'command_callback': 'ale_linters#cpp#clangcheck#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
