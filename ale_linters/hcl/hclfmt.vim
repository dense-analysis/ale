" Author: Peter Benjamin <petermbenjamin@gmail.com>
" Description: hclfmt for HCL files

call ale#linter#Define('hcl', {
\   'name': 'hclfmt',
\   'output_stream': 'stderr',
\   'executable': 'hclfmt',
\   'command': 'hclfmt -w %t',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
