" Author: w0rp <devw0rp@gmail.com>
" Description: flake8 for python files

let g:ale_python_flake8_executable =
\   get(g:, 'ale_python_flake8_executable', 'flake8')

" Support an old setting as a fallback.
let s:default_options = get(g:, 'ale_python_flake8_args', '')
let g:ale_python_flake8_options =
\   get(g:, 'ale_python_flake8_options', s:default_options)
let g:ale_python_flake8_use_global = get(g:, 'ale_python_flake8_use_global', 0)

" A map from Python executable paths to semver strings parsed for those
" executables, so we don't have to look up the version number constantly.
let s:version_cache = {}

function! s:UsingModule(buffer) abort
    return ale#Var(a:buffer, 'python_flake8_options') =~# ' *-m flake8'
endfunction

function! ale_linters#python#flake8#GetExecutable(buffer) abort
    if !s:UsingModule(a:buffer) && !ale#Var(a:buffer, 'python_flake8_use_global')
        let l:virtualenv = ale#python#FindVirtualenv(a:buffer)

        if !empty(l:virtualenv)
            let l:ve_flake8 = l:virtualenv . '/bin/flake8'

            if executable(l:ve_flake8)
                return l:ve_flake8
            endif
        endif
    endif

    return ale#Var(a:buffer, 'python_flake8_executable')
endfunction

function! ale_linters#python#flake8#ClearVersionCache() abort
    let s:version_cache = {}
endfunction

function! ale_linters#python#flake8#VersionCheck(buffer) abort
    let l:executable = ale_linters#python#flake8#GetExecutable(a:buffer)

    " If we have previously stored the version number in a cache, then
    " don't look it up again.
    if has_key(s:version_cache, l:executable)
        " Returning an empty string skips this command.
        return ''
    endif

    let l:executable = ale#Escape(ale_linters#python#flake8#GetExecutable(a:buffer))
    let l:module_string = s:UsingModule(a:buffer) ? ' -m flake8' : ''

    return l:executable . l:module_string . ' --version'
endfunction

" Get the flake8 version from the output, or the cache.
function! s:GetVersion(buffer, version_output) abort
    let l:executable = ale_linters#python#flake8#GetExecutable(a:buffer)
    let l:version = []

    " Get the version from the cache.
    if has_key(s:version_cache, l:executable)
        return s:version_cache[l:executable]
    endif

    if !empty(a:version_output)
        " Parse the version string, and store it in the cache.
        let l:version = ale#semver#Parse(a:version_output[0])
        let s:version_cache[l:executable] = l:version
    endif

    return l:version
endfunction

" flake8 versions 3 and up support the --stdin-display-name argument.
function! s:SupportsDisplayName(version) abort
    return !empty(a:version) && ale#semver#GreaterOrEqual(a:version, [3, 0, 0])
endfunction

function! ale_linters#python#flake8#GetCommand(buffer, version_output) abort
    let l:version = s:GetVersion(a:buffer, a:version_output)

    " Only include the --stdin-display-name argument if we can parse the
    " flake8 version, and it is recent enough to support it.
    let l:display_name_args = s:SupportsDisplayName(l:version)
    \   ? ' --stdin-display-name %s'
    \   : ''

    let l:options = ale#Var(a:buffer, 'python_flake8_options')

    return ale#Escape(ale_linters#python#flake8#GetExecutable(a:buffer))
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . l:display_name_args . ' -'
endfunction

call ale#linter#Define('python', {
\   'name': 'flake8',
\   'executable_callback': 'ale_linters#python#flake8#GetExecutable',
\   'command_chain': [
\       {'callback': 'ale_linters#python#flake8#VersionCheck'},
\       {'callback': 'ale_linters#python#flake8#GetCommand', 'output_stream': 'both'},
\   ],
\   'callback': 'ale#handlers#python#HandlePEP8Format',
\})
