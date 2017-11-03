" Author: Ben Reedy <https://github.com/breed808>
" Description: staticcheck for Go files

call ale#linter#Define('go', {
\   'name': 'staticcheck',
\   'executable': 'staticcheck',
\   'command': 'staticcheck %s',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\   'output_stream': 'both',
\   'lint_file': 1,
\})
