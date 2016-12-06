" Author: diartyz <diartyz@gmail.com>

call ale#linter#Define('scss', {
\   'name': 'stylelint',
\   'executable': 'stylelint',
\   'command': g:ale#util#stdin_wrapper . ' .scss stylelint',
\   'callback': 'ale#handlers#HandleStyleLintFormat',
\})
