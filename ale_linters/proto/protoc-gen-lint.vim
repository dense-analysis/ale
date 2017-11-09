" Author: Jeff Willette <jrwillette88@gmail.com>
" Description: run the protoc-gen-lint plugin for the protoc binary

call ale#linter#Define('proto', {
\   'name': 'protoc-gen-lint',
\   'output_stream': 'stderr',
\   'lint_file': 1,
\   'executable': 'protoc',
\   'command': 'protoc -I $(dirname %s) --lint_out=. %s',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
