" Author: Roeland Moors - https://github.com/roelandmoors
" based on the ale ruumba linter
" Description: ERB Lint, support for https://github.com/Shopify/erb-lint

call ale#Set('eruby_erblint_executable', 'erblint')
call ale#Set('eruby_erblint_options', '')

function! ale_linters#eruby#erblint#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'eruby_erblint_executable')

    return ale#ruby#EscapeExecutable(l:executable, 'erblint')
    \   . ' --format json '
    \   . ale#Var(a:buffer, 'eruby_ruumba_options')
    \   . ' --stdin %s'
endfunction

function! ale_linters#eruby#erblint#Handle(buffer, lines) abort
    try
        let l:errors = json_decode(a:lines[0])
    catch
        return []
    endtry

    if !has_key(l:errors, 'summary')
    \|| l:errors['summary']['offenses'] == 0
    \|| empty(l:errors['files'])
        return []
    endif

    let l:output = []

    for l:error in l:errors['files'][0]['offenses']
        let l:start_col = l:error['location']['start_column'] + 0
        call add(l:output, {
        \   'lnum': l:error['location']['start_line'] + 0,
        \   'col': l:start_col,
        \   'end_col': l:start_col + l:error['location']['length'] - 1,
        \   'code': l:error['linter'],
        \   'text': l:error['message'],
        \   'type': 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('eruby', {
\   'name': 'erblint',
\   'executable': {b -> ale#Var(b, 'eruby_erblint_executable')},
\   'command': function('ale_linters#eruby#erblint#GetCommand'),
\   'callback': 'ale_linters#eruby#erblint#Handle',
\})
