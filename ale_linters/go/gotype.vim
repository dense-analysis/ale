" Author: Jelte Fennema <github-public@jeltef.nl>
" Description: gotype for Go files

call ale#linter#Define('go', {
\   'name': 'gotype',
\   'output_stream': 'stderr',
\   'executable': 'gotype',
\   'command': 'gotype -e %t $(find $(dirname %s) -maxdepth 1 -name "*.go" | grep -v "^"%s"$")',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
