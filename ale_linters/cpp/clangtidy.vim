" Author: vdeurzen <tim@kompiler.org>, w0rp <devw0rp@gmail.com>
" Description: clang-tidy linter for cpp files

" Set this option to check the checks clang-tidy will apply.
let g:ale_cpp_clangtidy_checks = get(g:, 'ale_cpp_clangtidy_checks', ['*'])

" Set this option to manually set some options for clang-tidy.
" This will disable compile_commands.json detection.
let g:ale_cpp_clangtidy_options = get(g:, 'ale_cpp_clangtidy_options', '')

function! ale_linters#cpp#clangtidy#GetCommand(buffer) abort
    let l:check_list = ale#Var(a:buffer, 'cpp_clangtidy_checks')
    let l:check_option = !empty(l:check_list)
    \   ? '-checks=' . ale#Escape(join(l:check_list, ',')) . ' '
    \   : ''
    let l:user_options = ale#Var(a:buffer, 'cpp_clangtidy_options')
    let l:extra_options = !empty(l:user_options)
    \   ? ' -- ' . l:user_options
    \   : ''

    return 'clang-tidy ' . l:check_option . '%s' . l:extra_options
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangtidy',
\   'output_stream': 'stdout',
\   'executable': 'clang-tidy',
\   'command_callback': 'ale_linters#cpp#clangtidy#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
