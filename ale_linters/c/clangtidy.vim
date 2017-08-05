" Author: vdeurzen <tim@kompiler.org>, w0rp <devw0rp@gmail.com>,
" gagbo <gagbobada@gmail.com>, Andrej Radovic <r.andrej@gmail.com>
" Description: clang-tidy linter for c files

call ale#Set('c_clangtidy_executable', 'clang-tidy')
" Set this option to check the checks clang-tidy will apply.
" The number of checks that can be applied to C files is limited in contrast to
" C++
"
" Here is an incomplete list of C-compatible checks for clang-tidy version 6:
" bugprone-suspicious-memset-usage
" cert-env33-c
" cert-err34-c
" cert-flp30-c
" google-runtime-int
" llvm-header-guard
" llvm-include-order
" misc-argument-comment
" misc-assert-side-effect
" misc-bool-pointer-implicit-conversion
" misc-definitions-in-headers
" misc-incorrect-roundings
" misc-macro-parentheses
" misc-macro-repeated-side-effects
" misc-misplaced-const
" misc-misplaced-widening-cast
" misc-multiple-statement-macro
" misc-non-copyable-objects
" misc-redundant-expression
" misc-sizeof-expression
" misc-static-assert
" misc-string-literal-with-embedded-nul
" misc-suspicious-enum-usage
" misc-suspicious-missing-comma
" misc-suspicious-semicolon
" misc-suspicious-string-compare
" misc-swapped-arguments
" modernize-redundant-void-arg
" modernize-use-bool-literals
" performance-type-promotion-in-math-fn
" readability-braces-around-statements
" readability-else-after-return
" readability-function-size
" readability-identifier-naming
" readability-implicit-bool-cast
" readability-inconsistent-declaration-parameter-name
" readability-misleading-indentation
" readability-misplaced-array-index
" readability-named-parameter
" readability-non-const-parameter
" readability-redundant-control-flow
" readability-redundant-declaration
" readability-redundant-function-ptr-dereference
" readability-simplify-boolean-expr

call ale#Set('c_clangtidy_checks', ['*'])
" Set this option to manually set some options for clang-tidy.
" This will disable compile_commands.json detection.
call ale#Set('c_clangtidy_options', '')
call ale#Set('c_build_dir', '')

function! ale_linters#c#clangtidy#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'c_clangtidy_executable')
endfunction

function! s:GetBuildDirectory(buffer) abort
    " Don't include build directory for header files, as compile_commands.json
    " files don't consider headers to be translation units, and provide no
    " commands for compiling header files.
    if expand('#' . a:buffer) =~# '\v\.(h|hpp)$'
        return ''
    endif

    let l:build_dir = ale#Var(a:buffer, 'c_build_dir')

    " c_build_dir has the priority if defined
    if !empty(l:build_dir)
        return l:build_dir
    endif

    return ale#c#FindCompileCommands(a:buffer)
endfunction

function! ale_linters#c#clangtidy#GetCommand(buffer) abort
    let l:checks = join(ale#Var(a:buffer, 'c_clangtidy_checks'), ',')
    let l:build_dir = s:GetBuildDirectory(a:buffer)

    " Get the extra options if we couldn't find a build directory.
    let l:options = empty(l:build_dir)
    \   ? ale#Var(a:buffer, 'c_clangtidy_options')
    \   : ''

    return ale#Escape(ale_linters#c#clangtidy#GetExecutable(a:buffer))
    \   . (!empty(l:checks) ? ' -checks=' . ale#Escape(l:checks) : '')
    \   . ' %s'
    \   . (!empty(l:build_dir) ? ' -p ' . ale#Escape(l:build_dir) : '')
    \   . (!empty(l:options) ? ' -- ' . l:options : '')
endfunction

call ale#linter#Define('c', {
\   'name': 'clangtidy',
\   'output_stream': 'stdout',
\   'executable_callback': 'ale_linters#c#clangtidy#GetExecutable',
\   'command_callback': 'ale_linters#c#clangtidy#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
