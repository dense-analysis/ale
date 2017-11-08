" Author: Jeff Willette <jrwillette88@gmail.com>
" Description: run the protoc-gen-lint plugin for the protoc binary

call ale#linter#Define('proto', {
\   'name': 'protoc-gen-lint',
\   'output_stream': 'stderr',
\   'executable': 'protoc',
\   'command': 'protoc --lint_out=. *.proto',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
