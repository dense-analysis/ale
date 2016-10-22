" Author: w0rp <devw0rp@gmail.com>
" Description: ghc for Haskell files

call ale#linter#Define('haskell', {
\   'name': 'ghc',
\   'output_stream': 'stderr',
\   'executable': 'ghc',
\   'command': g:ale#util#stdin_wrapper . ' .hs ghc -fno-code -v0',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})

call ale#linter#Define('haskell', {
\   'name': 'stack-ghc',
\   'output_stream': 'stderr',
\   'executable': 'stack',
\   'command': g:ale#util#stdin_wrapper . ' .hs stack ghc -- -fno-code -v0',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
