" Author: vdeurzen <tim@kompiler.org>, w0rp <devw0rp@gmail.com>,
" gagbo <gagbobada@gmail.com>
" Description: clang-tidy linter for cpp files

" Set this option to check the checks clang-tidy will apply.
let g:ale_cpp_clangtidy_checks = get(g:, 'ale_cpp_clangtidy_checks', ['*'])

" Set this option to manually set some options for clang-tidy.
" This will disable compile_commands.json detection.
let g:ale_cpp_clangtidy_options = get(g:, 'ale_cpp_clangtidy_options', '')

" Set this option to manually point to the build directory for clang-tidy.
" This will disable all the other clangtidy_options, since compilation
" flags are contained in the json
let g:ale_cpp_clangtidy_builddir = get(g:, 'ale_cpp_clangtidy_builddir', '')

let g:ale_cpp_clangtidy_builddirnames =
            \ get(g:, 'ale_cpp_clangtidy_builddirnames', ['build', 'bin'])

function! ale_linters#cpp#clangtidy#GetCommand(buffer) abort
    let l:check_list = ale#Var(a:buffer, 'cpp_clangtidy_checks')
    let l:check_option = !empty(l:check_list)
    \   ? '-checks=' . ale#Escape(join(l:check_list, ',')) . ' '
    \   : ''
    let l:user_options = ale#Var(a:buffer, 'cpp_clangtidy_options')
    let l:user_builddir = ale#Var(a:buffer, 'cpp_clangtidy_builddir')

    " Build directory has the priority if
    " both builddir and builddirnames options are defined
    if empty(l:user_builddir)
        let l:builddir_names = ale#Var(a:buffer, 'cpp_clangtidy_builddirnames')
        for l:name in l:builddir_names
            let l:candidates = finddir(l:name, expand('#' . a:buffer.':p:h') . ';', -1)
            for l:candidate in l:candidates
                if filereadable(l:candidate . '/compile_commands.json')
                    let l:user_builddir = l:candidate
                    break
                endif
            endfor
            if !empty(l:user_builddir)
                break
            endif
        endfor
    endif

    " We check again if user_builddir stayed empty after the builddirnames
    " check
    " If we found the compilation database we override the value of
    " l:extra_options
    if empty(l:user_builddir)
        let l:extra_options = !empty(l:user_options)
        \   ? ' -- ' . l:user_options
        \   : ''
    else
        let l:extra_options = ' -p ' . ale#Escape(l:user_builddir)
    endif

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
