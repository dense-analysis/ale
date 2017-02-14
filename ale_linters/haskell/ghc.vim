" Author: w0rp <devw0rp@gmail.com>
" Description: ghc for Haskell files

if exists('g:loaded_ale_linters_haskell_ghc')
    finish
endif

call ale#linter#Define('haskell', {
\   'name': 'ghc',
\   'output_stream': 'stderr',
\   'executable': 'ghc',
\   'command': 'ghc -fno-code -v0 %t',
\   'callback': 'ale#handlers#HandleGhcFormat',
\})

call ale#linter#Define('haskell', {
\   'name': 'stack-ghc',
\   'output_stream': 'stderr',
\   'executable': 'stack',
\   'command': 'stack ghc -- -fno-code -v0 %t',
\   'callback': 'ale#handlers#HandleGhcFormat',
\})
