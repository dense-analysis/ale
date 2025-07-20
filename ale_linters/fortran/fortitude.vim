" Author: gomfol12
" Desciption: A linter for fortran using fortitude.

call ale#Set('fortran_fortitude_executable', 'fortitude')
call ale#Set('fortran_fortitude_options', '')

let s:severity_map = {
\   'E': 'E',
\   'C': 'W',
\   'OB': 'I',
\   'MOD': 'I',
\   'S': 'I',
\   'PORT': 'I',
\   'FORT': 'I',
\}

function! ale_linters#fortran#fortitude#Handle(buffer, lines) abort
    let l:output = []

    for l:error in ale#util#FuzzyJSONDecode(a:lines, [])
        let l:prefix = matchstr(l:error['code'], '^\a\+')
        let l:type = get(s:severity_map, l:prefix, 'I')

        call add(l:output, {
        \   'lnum': l:error['location']['row'],
        \   'end_lnum': l:error['end_location']['row'],
        \   'col': l:error['location']['column'],
        \   'end_col': l:error['end_location']['column'],
        \   'text': l:error['message'],
        \   'type': l:type,
        \   'code': l:error['code'],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('fortran', {
\   'name': 'fortitude',
\   'output_stream': 'stdout',
\   'executable': {b -> ale#Var(b, 'fortran_fortitude_executable')},
\   'command': {b ->
\       '%e' . ' check --output-format json' . ale#Pad(ale#Var(b, 'fortran_fortitude_options')) . ' %s'
\   },
\   'callback': 'ale_linters#fortran#fortitude#Handle',
\   'lint_file': 1,
\})
