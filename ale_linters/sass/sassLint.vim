" Author: KabbAmine - https://github.com/KabbAmine

if exists('g:loaded_ale_linters_sass_sassLint')
    finish
endif

let g:loaded_ale_linters_sass_sassLint = 1

call ALEAddLinter('sass', {
\   'name': 'sassLint',
\   'executable': 'sass-lint',
\   'command': g:ale#util#stdin_wrapper . ' .sass sass-lint -v -q -f compact',
\   'callback': 'ale_linters#css#csslint#Handle',
\})
