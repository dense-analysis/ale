" Author: vdeurzen <tim@kompiler.org>, w0rp <devw0rp@gmail.com>,
" gagbo <gagbobada@gmail.com>, phcerdan <pablo.hernandez.cerdan@outlook.com>
" Description: clang-tidy linter for cpp files

call ale#Set('cpp_clangtidy_executable', 'clang-tidy')
" Set this option to check the checks clang-tidy will apply.
call ale#Set('cpp_clangtidy_checks', ['*'])
" Set this option to manually set some options for clang-tidy.
" This will disable compile_commands.json detection.
call ale#Set('cpp_clangtidy_options', '')
call ale#Set('c_build_dir', '')
" TODO: This can be common to all clang checkers requiring .cpp files.
call ale#Set('cpp_clangtidy_header_suffixes', ['h', 'hpp', 'hxx', 'tcc'])
" Set this option to handle options in case of header files.
call ale#Set('cpp_clangtidy_header_sourcefile', '')
" Set this option to set manually what file suffix is consider a header.
" Set this option to manually set some options for clang-tidy.

function! ale_linters#cpp#clangtidy#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_clangtidy_executable')
endfunction

function! ale_linters#cpp#clangtidy#IsHeader(buffer) abort
    let l:search = '\v\.(' . join(ale#Var(a:buffer,'cpp_clangtidy_header_suffixes'), '|') . ')$'
    if expand('#' . a:buffer) =~# l:search
        return 1
    endif

    return 0
endfunction

function! s:GetBuildDirectory(buffer) abort
    let l:build_dir = ale#Var(a:buffer, 'c_build_dir')

    " c_build_dir has the priority if defined
    if !empty(l:build_dir)
        return l:build_dir
    endif

    return ale#c#FindCompileCommands(a:buffer)
endfunction

function! ale_linters#cpp#clangtidy#GetCommand(buffer) abort
    let l:checks = join(ale#Var(a:buffer, 'cpp_clangtidy_checks'), ',')
    let l:build_dir = s:GetBuildDirectory(a:buffer)
    " Get the extra options if we couldn't find a build directory.
    let l:options = empty(l:build_dir)
                \   ? ale#Var(a:buffer, 'cpp_clangtidy_options')
                \   : ''

    if !ale_linters#cpp#clangtidy#IsHeader(a:buffer)
        return ale#Escape(ale_linters#cpp#clangtidy#GetExecutable(a:buffer))
        \   . (!empty(l:checks) ? ' -checks=' . ale#Escape(l:checks) : '')
        \   . ' %s'
        \   . (!empty(l:build_dir) ? ' -p ' . ale#Escape(l:build_dir) : '')
        \   . (!empty(l:options) ? ' -- ' . l:options : '')
    else
        let l:header_sourcefile = ale#Var(a:buffer, 'cpp_clangtidy_header_sourcefile')
        " If no specific header options provided by user:
        " Don't include build directory for header files, as compile_commands.json
        " files don't consider headers to be translation units, and provide no
        " commands for compiling header files.
        " Use the same command as non-header files.
        if empty(l:header_sourcefile)
            let l:build_dir = ''
            let l:options = ale#Var(a:buffer, 'cpp_clangtidy_options')
            return ale#Escape(ale_linters#cpp#clangtidy#GetExecutable(a:buffer))
            \   . (!empty(l:checks) ? ' -checks=' . ale#Escape(l:checks) : '')
            \   . ' %s'
            \   . (!empty(l:build_dir) ? ' -p ' . ale#Escape(l:build_dir) : '')
            \   . (!empty(l:options) ? ' -- ' . l:options : '')
        " If header_sourcefile: Don't use the current buffer as input! The user has to
        " provide a source file (.cpp) to run the checker on it when editing
        " the header.
        " The build_dir is kept if present, the provided source file must be
        " in the database.
        else
            return ale#Escape(ale_linters#cpp#clangtidy#GetExecutable(a:buffer))
            \   . (!empty(l:checks) ? ' -checks=' . ale#Escape(l:checks) : '')
            \   . (!empty(l:header_sourcefile) ? ' ' . ale#Escape(l:header_sourcefile) : '')
            \   . (!empty(l:build_dir) ? ' -p ' . ale#Escape(l:build_dir) : '')
            \   . (!empty(l:options) ? ' -- ' . l:options : '')
        endif
    endif
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangtidy',
\   'output_stream': 'stdout',
\   'executable_callback': 'ale_linters#cpp#clangtidy#GetExecutable',
\   'command_callback': 'ale_linters#cpp#clangtidy#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
