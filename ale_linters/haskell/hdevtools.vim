" Author: rob-b
" Description: hdevtools for Haskell files

call ale#linter#Define('haskell', {
\   'name': 'hdevtools',
\   'executable': 'hdevtools',
\   'command': 'hdevtools check -g -Wall -p %s %t',
\   'callback': 'ale#handlers#haskell#HandleGHCFormat',
\})
