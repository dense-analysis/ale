" Author: Eric Wolf <ericwolf42@gmail.com>, Daniel T. <daniel.t.dt@gmail.com>
" Description: ghc for Haskell files called with cabal exec

call ale#Set('haskell_cabal_ghc_executable', 'cabal')
call ale#Set('haskell_cabal_ghc_options', '-fno-code -v0')

function! ale_linters#haskell#cabal_ghc#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'haskell_cabal_ghc_executable')
endfunction

function! ale_linters#haskell#cabal_ghc#VersionCheck(buffer) abort
    let l:executable = ale_linters#haskell#cabal_ghc#GetExecutable(a:buffer)

    " Check the Vint version if we haven't checked it already.
    return !ale#semver#HasVersion(l:executable)
    \   ? ale#Escape(l:executable) . ' --numeric-version'
    \   : ''
endfunction

function! ale_linters#haskell#cabal_ghc#GetCommand(buffer, version_output) abort
    let l:executable = ale_linters#haskell#cabal_ghc#GetExecutable(a:buffer)
    let l:version = ale#semver#GetVersion(l:executable, a:version_output)

    let l:exec_cmd = ale#semver#GTE(l:version, [2, 0, 0])
    \   ? ' v1-exec'
    \   : ' exec'

    return ale#Escape(l:executable)
    \   . l:exec_cmd . ' -- ghc '
    \   . ale#Var(a:buffer, 'haskell_cabal_ghc_options')
    \   . ' %t'
endfunction

call ale#linter#Define('haskell', {
\   'name': 'cabal_ghc',
\   'aliases': ['cabal-ghc'],
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#haskell#cabal_ghc#GetExecutable'),
\   'command_chain': [
\       {'callback': 'ale_linters#haskell#cabal_ghc#VersionCheck'},
\       {'callback': 'ale_linters#haskell#cabal_ghc#GetCommand'},
\   ],
\   'callback': 'ale#handlers#haskell#HandleGHCFormat',
\})
