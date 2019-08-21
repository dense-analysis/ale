" Author: vdeurzen <tim@kompiler.org>, w0rp <devw0rp@gmail.com>,
" gagbo <gagbobada@gmail.com>
" Description: clang-tidy linter for cpp files

call ale#Set('cpp_clangtidy_executable', 'clang-tidy')
" Set this option to check the checks clang-tidy will apply.
call ale#Set('cpp_clangtidy_checks', [])
" Set this option to manually set some options for clang-tidy to use as compile
" flags.
" This will disable compile_commands.json detection.
call ale#Set('cpp_clangtidy_options', '')
" Set this option to manually set options for clang-tidy directly.
call ale#Set('cpp_clangtidy_extra_options', '')
call ale#Set('c_build_dir', '')

" Set this to enable treating .h header files as C++
call ale#Set('cpp_clangtidy_h_is_hpp', 0)


function! ale_linters#cpp#clangtidy#GetCommand(buffer) abort
    let l:checks = join(ale#Var(a:buffer, 'cpp_clangtidy_checks'), ',')
    let l:build_dir = ale#c#GetBuildDirectory(a:buffer)

    " Get the extra options if we couldn't find a build directory.
    let l:options = empty(l:build_dir)
    \   ? ale#Var(a:buffer, 'cpp_clangtidy_options')
    \   : ''

    " Get the options to pass directly to clang-tidy
    let l:extra_options = ale#Var(a:buffer, 'cpp_clangtidy_extra_options')
    let l:enable_h_is_hpp = ale#Var(a:buffer, 'cpp_clangtidy_h_is_hpp')

    if l:enable_h_is_hpp && expand('#' . a:buffer . ':e') is? 'h'
        " for .h header files, passing -x to compiler to force cpp
        if empty(l:options)
            let l:options .= '-x c++'
        else
            let l:options .= ' -x c++'
        endif
    endif

    return '%e'
    \   . (!empty(l:checks) ? ' -checks=' . ale#Escape(l:checks) : '')
    \   . (!empty(l:extra_options) ? ' ' . ale#Escape(l:extra_options) : '')
    \   . ' %s'
    \   . (!empty(l:build_dir) ? ' -p ' . ale#Escape(l:build_dir) : '')
    \   . (!empty(l:options) ? ' -- ' . l:options : '')
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangtidy',
\   'output_stream': 'stdout',
\   'executable': {b -> ale#Var(b, 'cpp_clangtidy_executable')},
\   'command': function('ale_linters#cpp#clangtidy#GetCommand'),
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
