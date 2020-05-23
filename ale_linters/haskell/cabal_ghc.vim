" Author: Eric Wolf <ericwolf42@gmail.com>
" Description: ghc for Haskell files called with cabal exec
"
" Modified to search for the cabal file so that it is not necessary to work from
" the project root
"
" Correct exec command

call ale#Set('haskell_cabal_ghc_options', '-fno-code -v0')

function! ale_linters#haskell#cabal_ghc#GetProjectRoot(buffer) abort
    " Search all of the paths except for the root filesystem path.
    let l:paths = join(
    \   ale#path#Upwards(expand('#' . a:buffer . ':p:h'))[:-2],
    \   ','
    \)

    let l:project_file = globpath(l:paths, '*.cabal')

    " If we can't find one, use the current file.
    if empty(l:project_file)
        let l:project_file = expand('#' . a:buffer . ':p')
    endif

    return fnamemodify(l:project_file, ':h')
endfunction

function! ale_linters#haskell#cabal_ghc#GetCommand(buffer) abort
    return 'cabal v2-exec ghc -- '
    \   . ale#Var(a:buffer, 'haskell_cabal_ghc_options')
    \   . ' %t'
endfunction

call ale#linter#Define('haskell', {
\   'name': 'cabal_ghc',
\   'aliases': ['cabal-ghc'],
\   'output_stream': 'stderr',
\   'executable': 'cabal',
\   'command': function('ale_linters#haskell#cabal_ghc#GetCommand'),
\   'callback': 'ale#handlers#haskell#HandleGHCFormat',
\   'project_root': function('ale_linters#haskell#cabal_ghc#GetProjectRoot'),
\})
