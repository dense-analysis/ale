" Author: axhav <william@axhav.se>
call ale#Set('yaml_yq_executable', 'yq')
call ale#Set('yaml_yq_options', '')
call ale#Set('yaml_yq_filters', '.')

" Matches patterns like the following:
let s:pattern = '^Error\:.* line \(\d\+\)\: \(.\+\)$'

function! ale_linters#yaml#yq#Handle(buffer, lines) abort
    return ale#util#MapMatches(a:lines, s:pattern, {match -> {
    \   'lnum': match[1] + 0,
    \   'text': match[2],
    \}})
endfunction

call ale#linter#Define('yaml', {
\   'name': 'yq',
\   'executable': {b -> ale#Var(b, 'yaml_yq_executable')},
\   'output_stream': 'stderr',
\   'command': '%e',
\   'callback': 'ale_linters#yaml#yq#Handle',
\})
