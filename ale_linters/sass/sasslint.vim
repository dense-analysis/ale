" Author: KabbAmine - https://github.com/KabbAmine

call ale#linter#Define('sass', {
\   'name': 'sasslint',
\   'executable': 'sass-lint',
\   'command': g:ale#util#stdin_wrapper . ' .sass sass-lint -v -q -f compact',
\   'callback': 'ale#handlers#HandleCSSLintFormat',
\})
