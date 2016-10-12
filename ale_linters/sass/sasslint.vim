" Author: KabbAmine - https://github.com/KabbAmine

if exists('g:loaded_ale_linters_sass_sasslint')
    finish
endif

let g:loaded_ale_linters_sass_sasslint = 1

call ale#linter#Define('sass', {
\   'name': 'sasslint',
\   'executable': 'sass-lint',
\   'command': g:ale#util#stdin_wrapper . ' .sass sass-lint -v -q -f compact',
\   'callback': 'ale#handlers#HandleCSSLintFormat',
\})
