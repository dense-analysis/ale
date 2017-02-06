" Author: w0rp <devw0rp@gmail.com>
" Description: flake8 for python files

let g:ale_python_flake8_executable =
\   get(g:, 'ale_python_flake8_executable', 'flake8')

let g:ale_python_flake8_args =
\   get(g:, 'ale_python_flake8_args', '')

" A map from Python executable paths to semver strings parsed for those
" executables, so we don't have to look up the version number constantly.
let s:version_cache = {}

function! ale_linters#python#flake8#GetExecutable(buffer) abort
    return g:ale_python_flake8_executable
endfunction

function! ale_linters#python#flake8#VersionCheck(buffer) abort
    let l:executable = ale_linters#python#flake8#GetExecutable(a:buffer)

    " If we have previously stored the version number in a cache, then
    " don't look it up again.
    if has_key(s:version_cache, l:executable)
        " Returning an empty string skips this command.
        return ''
    endif

    return ale_linters#python#flake8#GetExecutable(a:buffer) . ' --version'
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
    \   ? '--stdin-display-name %s'
    \   : ''

    return ale_linters#python#flake8#GetExecutable(a:buffer)
    \   . ' ' . g:ale_python_flake8_args . ' ' . l:display_name_args . ' -'
endfunction

call ale#linter#Define('python', {
\   'name': 'flake8',
\   'executable_callback': 'ale_linters#python#flake8#GetExecutable',
\   'command_chain': [
\       {'callback': 'ale_linters#python#flake8#VersionCheck'},
\       {'callback': 'ale_linters#python#flake8#GetCommand'},
\   ],
\   'callback': 'ale#handlers#HandlePEP8Format',
\})
