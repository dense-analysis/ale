" Author: J. Handsel <jennpbc@posteo.net>, Thyme-87 <thyme-87@posteo.me>
" Description: use checkov for providing warnings for cloudformation via ale

call ale#Set('cloudformation_checkov_executable', 'checkov')
call ale#Set('cloudformation_checkov_options', '')

function! ale_linters#cloudformation#checkov#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cloudformation_checkov_executable')
endfunction

function! ale_linters#cloudformation#checkov#GetCommand(buffer) abort
    return '%e ' . '-f %t -o json --quiet --framework cloudformation ' . ale#Var(a:buffer, 'cloudformation_checkov_options')
endfunction

function! ale_linters#cloudformation#checkov#Handle(buffer, lines) abort
    let l:output = []

    let l:results = get(get(ale#util#FuzzyJSONDecode(a:lines, {}), 'results', []), 'failed_checks', [])

    for l:violation in l:results
        call add(l:output, {
        \   'filename': l:violation['file_path'],
        \   'lnum': l:violation['file_line_range'][0],
        \   'end_lnum': l:violation['file_line_range'][1],
        \   'text': l:violation['check_name'] . ' [' . l:violation['check_id'] . ']',
        \   'detail': l:violation['check_id'] . ': ' . l:violation['check_name'] . "\n" .
        \             'For more information, see: '. l:violation['guideline'],
        \   'type': 'W',
        \   })
    endfor

    return l:output
endfunction

call ale#linter#Define('cloudformation', {
\   'name': 'checkov',
\   'output_stream': 'stdout',
\   'executable': function('ale_linters#cloudformation#checkov#GetExecutable'),
\   'command': function('ale_linters#cloudformation#checkov#GetCommand'),
\   'callback': 'ale_linters#cloudformation#checkov#Handle',
\})
