" Author: KabbAmine - https://github.com/KabbAmine
" Description: Coffee for checking coffee files

if exists('g:loaded_ale_linters_coffee_coffee')
    finish
endif

let g:loaded_ale_linters_coffee_coffee = 1

call ale#linter#Define('coffee', {
\   'name': 'coffee',
\   'executable': 'coffee',
\   'command': 'coffee -cp -s',
\   'output_stream': 'stderr',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})

