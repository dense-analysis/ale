" Author: Michiel Westerbeek <happylinks@gmail.com>
" Author: Christian Höltje <docwhat@gerf.org>
" Description: Linter for GraphQL Schemas
scriptencoding 'utf-8'

call ale#Set('graphql_gqlint_executable', 'gqlint')
call ale#Set('graphql_gqlint_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#graphql#gqlint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'graphql_gqlint', [
    \   'node_modules/.bin/gqlint',
    \])
endfunction

function! ale_linters#graphql#gqlint#GetCommand(buffer) abort
    let l:exe = ale#Escape(ale_linters#graphql#gqlint#GetExecutable(a:buffer))

    return ale#path#BufferCdString(a:buffer)
    \   . l:exe
    \   . ' --reporter=simple %t'
endfunction

call ale#linter#Define('graphql', {
\   'name': 'gqlint',
\   'executable': function('ale_linters#graphql#gqlint#GetExecutable'),
\   'command': function('ale_linters#graphql#gqlint#GetCommand'),
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\})
