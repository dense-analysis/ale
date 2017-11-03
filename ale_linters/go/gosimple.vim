" Author: Ben Reedy <https://github.com/breed808>
" Description: gosimple for Go files

call ale#linter#Define('go', {
\   'name': 'gosimple',
\   'executable': 'gosimple',
\   'command': 'gosimple %s',
\   'callback': 'ale#handlers#unix#HandleAsWarning',
\   'output_stream': 'both',
\   'lint_file': 1,
\})
