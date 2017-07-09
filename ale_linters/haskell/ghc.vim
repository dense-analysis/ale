" Author: w0rp <devw0rp@gmail.com>
" Description: ghc for Haskell files

call ale#linter#Define('haskell', {
\   'name': 'ghc',
\   'output_stream': 'stderr',
\   'executable': 'ghc',
\   'command': 'ghc -fno-code -v0 %t',
\   'callback': 'ale#handlers#haskell#HandleGHCFormat',
\})

call ale#linter#Define('haskell', {
\   'name': 'stack-ghc',
\   'output_stream': 'stderr',
\   'executable': 'stack',
\   'command': 'stack ghc -- -fno-code -v0 %t',
\   'callback': 'ale#handlers#haskell#HandleGHCFormat',
\})

call ale#linter#Define('haskell', {
\   'name': 'stack-build',
\   'output_stream': 'stderr',
\   'executable': 'stack',
\   'command': 'stack build',
\   'lint_file': 1,
\   'callback': 'ale#handlers#haskell#HandleGHCFormat',
\})
