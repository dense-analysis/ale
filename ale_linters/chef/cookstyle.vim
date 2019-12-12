" Author: Raphael Hoegger - https://github.com/pfuender
" Description: Cookstyle (RuboCop based), a code style analyzer for Ruby files

call ale#Set('chef_cookstyle_executable', 'cookstyle')
call ale#Set('chef_cookstyle_options', '')

function! ale_linters#chef#cookstyle#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'chef_cookstyle_options')

    return '%e' . ale#Pad(escape(l:options, '~')) . ' --force-exclusion --format json --stdin ' . ' %s'
endfunction

function! ale_linters#chef#cookstyle#Handle(buffer, lines) abort
    if len(a:lines) == 0
        return []
    endif

    let l:errors = ale#util#FuzzyJSONDecode(a:lines[0], {})

    if !has_key(l:errors, 'summary')
    \|| l:errors['summary']['offense_count'] == 0
    \|| empty(l:errors['files'])
        return []
    endif

    let l:output = []

    for l:error in l:errors['files'][0]['offenses']
        let l:start_col = l:error['location']['column'] + 0
        call add(l:output, {
        \   'lnum': l:error['location']['line'] + 0,
        \   'col': l:start_col,
        \   'end_col': l:start_col + l:error['location']['length'] - 1,
        \   'code': l:error['cop_name'],
        \   'text': l:error['message'],
        \   'type': l:error['severity'] is? 'convention' ? 'W' : 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('chef', {
\   'name': 'cookstyle',
\   'executable': {b -> ale#Var(b, 'chef_cookstyle_executable')},
\   'command': function('ale_linters#chef#cookstyle#GetCommand'),
\   'callback': 'ale_linters#chef#cookstyle#Handle',
\})
