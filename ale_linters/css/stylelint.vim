" Author: diartyz <diartyz@gmail.com>

call ale#linter#Define('css', {
\   'name': 'stylelint',
\   'executable': 'stylelint',
\   'command': g:ale#util#stdin_wrapper . ' .css stylelint',
\   'callback': 'ale#handlers#HandleStyleLintFormat',
\})
