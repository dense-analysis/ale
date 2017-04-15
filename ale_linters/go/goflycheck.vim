" Author: dzhou121 <dzhou121@gmail.com>
" Description: goflycheck for Go files

call ale#linter#Define('go', {
\   'name': 'goflycheck',
\   'executable': 'goflycheck',
\   'command': 'goflycheck %s',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
