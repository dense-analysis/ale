" Author: w0rp <devw0rp@gmail.com>
" Description: flake8 for python files

let g:ale_python_flake8_executable =
\   get(g:, 'ale_python_flake8_executable', 'flake8')

" Support an old setting as a fallback.
let s:default_options = get(g:, 'ale_python_flake8_args', '')
let g:ale_python_flake8_options =
\   get(g:, 'ale_python_flake8_options', s:default_options)

" E999: Synax Error
"
" F601: dictionary key name repeated with different values
" F602: dictionary key variable name repeated with different values
" F621: too many expressions in an assignment with star-unpacking
" F622: two or more starred expressions in an assignment (a, *b, *c = d)
" F631: assertion test is a tuple, which are always True
"
" F701: a break statement outside of a while or for loop
" F702: a continue statement outside of a while or for loop
" F703: a continue statement in a finally block in a loop
" F704: a yield or yield from statement outside of a function
" F705: a return statement with arguments inside a generator
" F706: a return statement outside of a function/method
" F707: an except: block as not the last exception handler
"
" F811: redefinition of unused name from line N
" F821: undefined name name
" F822: undefined name name in __all__
" F823: local variable name ... referenced before assignment
let g:ale_python_flake8_error_codes =
\   get(g:, 'python_flake8_error_codes', [
\     'E999',
\     'F601', 'F602', 'F621', 'F622', 'F631',
\     'F701', 'F702', 'F703', 'F704', 'F705', 'F706', 'F707',
\     'F811', 'F821', 'F823', 'F831',
\   ])

" A map from Python executable paths to semver strings parsed for those
" executables, so we don't have to look up the version number constantly.
let s:version_cache = {}

function! ale_linters#python#flake8#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'python_flake8_executable')
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
    \   . ' ' . ale#Var(a:buffer, 'python_flake8_options')
    \   . ' ' . l:display_name_args . ' -'
endfunction

call ale#linter#Define('python', {
\   'name': 'flake8',
\   'executable_callback': 'ale_linters#python#flake8#GetExecutable',
\   'command_chain': [
\       {'callback': 'ale_linters#python#flake8#VersionCheck'},
\       {'callback': 'ale_linters#python#flake8#GetCommand'},
\   ],
\   'callback': 'ale#handlers#HandleFlake8Format',
\})
