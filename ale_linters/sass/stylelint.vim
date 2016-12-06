" Author: diartyz <diartyz@gmail.com>

call ale#linter#Define('sass', {
\   'name': 'stylelint',
\   'executable': 'stylelint',
\   'command': g:ale#util#stdin_wrapper . ' .sass stylelint',
\   'callback': 'ale#handlers#HandleStyleLintFormat',
\})
