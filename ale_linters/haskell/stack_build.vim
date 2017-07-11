" Author: Jake Zimmerman <jake@zimmerman.io>
" Description: Like stack-ghc, but for entire projects
"
" Note: Ideally, this would *only* typecheck. Right now, it also does codegen.
" See <https://github.com/commercialhaskell/stack/issues/977>.

call ale#linter#Define('haskell', {
\   'name': 'stack-build',
\   'output_stream': 'stderr',
\   'executable': 'stack',
\   'command': 'stack build',
\   'lint_file': 1,
\   'callback': 'ale#handlers#haskell#HandleGHCFormat',
\})
