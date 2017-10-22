" Author: Nick Yamane <nick.diego@gmail.com>
" Description: gitlint for git commit message files

let g:ale_gitcommit_gitlint_executable =
\   get(g:, 'ale_gitcommit_gitlint_executable', 'gitlint')

" Support an old setting as a fallback.
let s:default_options = get(g:, 'ale_gitcommit_gitlint_args', '')
let g:ale_gitcommit_gitlint_options =
\   get(g:, 'ale_gitcommit_gitlint_options', s:default_options)
let g:ale_gitcommit_gitlint_use_global = get(g:, 'ale_gitcommit_gitlint_use_global', 0)

" A map from Python executable paths to semver strings parsed for those
" executables, so we don't have to look up the version number constantly.
let s:version_cache = {}

function! s:UsingModule(buffer) abort
    return ale#Var(a:buffer, 'gitcommit_gitlint_options') =~# ' *-m gitlint'
endfunction

function! ale_linters#gitcommit#gitlint#GetExecutable(buffer) abort
    if !s:UsingModule(a:buffer)
        return ale#python#FindExecutable(a:buffer, 'gitcommit_gitlint', ['gitlint'])
    endif

    return ale#Var(a:buffer, 'gitlint_executable')
endfunction

function! ale_linters#gitcommit#gitlint#ClearVersionCache() abort
    let s:version_cache = {}
endfunction

function! ale_linters#gitcommit#gitlint#VersionCheck(buffer) abort
    let l:executable = ale_linters#gitcommit#gitlint#GetExecutable(a:buffer)

    " If we have previously stored the version number in a cache, then
    " don't look it up again.
    if ale#semver#HasVersion(l:executable)
        " Returning an empty string skips this command.
        return ''
    endif

    let l:executable = ale#Escape(ale_linters#gitcommit#gitlint#GetExecutable(a:buffer))
    let l:module_string = s:UsingModule(a:buffer) ? ' -m gitlint' : ''

    return l:executable . l:module_string . ' --version'
endfunction

function! ale_linters#gitcommit#gitlint#GetCommand(buffer, version_output) abort
    let l:options = ale#Var(a:buffer, 'gitcommit_gitlint_options')

    return ale#Escape(ale_linters#gitcommit#gitlint#GetExecutable(a:buffer))
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' lint'
endfunction

function! ale_linters#gitcommit#gitlint#Handle(buffer, lines) abort
    for l:line in a:lines[:10]
        if match(l:line, '^Traceback') >= 0
            return [{
            \   'lnum': 1,
            \   'text': 'An exception was thrown. See :ALEDetail',
            \   'detail': join(a:lines, "\n"),
            \}]
        endif
    endfor

    " Matches patterns line the following:
    let l:pattern = '\v^(\d+): (\w+) (.*)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:code = l:match[2]

        let l:item = {
        \   'lnum': l:match[1] + 0,
        \   'text': l:code . ': ' . l:match[3],
        \   'type': 'E',
        \}

        call add(l:output, l:item)
    endfor

    return l:output
endfunction

call ale#linter#Define('gitcommit', {
\   'name': 'gitlint',
\   'executable': 'gitlint',
\   'command_chain': [
\       {'callback': 'ale_linters#gitcommit#gitlint#VersionCheck'},
\       {'callback': 'ale_linters#gitcommit#gitlint#GetCommand', 'output_stream': 'both'},
\   ],
\   'callback': 'ale_linters#gitcommit#gitlint#Handle',
\})
