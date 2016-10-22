" Author: KabbAmine - https://github.com/KabbAmine

call ale#linter#Define('scss', {
\   'name': 'sasslint',
\   'executable': 'sass-lint',
\   'command': g:ale#util#stdin_wrapper . ' .scss sass-lint -v -q -f compact',
\   'callback': 'ale#handlers#HandleCSSLintFormat',
\})
