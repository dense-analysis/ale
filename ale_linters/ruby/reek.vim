" Author: Eddie Lebow https://github.com/elebow
" Description: Reek, a code smell detector for Ruby files

call ale#Set('ruby_reek_show_context', 0)
call ale#Set('ruby_reek_show_wiki_link', 0)

function! ale_linters#ruby#reek#Handle(buffer, lines) abort
    let l:output = []

    for l:error in ale#util#FuzzyJSONDecode(a:lines, [])
        for l:location in l:error.lines
            call add(l:output, {
            \    'lnum': l:location,
            \    'type': 'W',
            \    'text': s:BuildText(a:buffer, l:error),
            \})
        endfor
    endfor

    return l:output
endfunction

function! s:BuildText(buffer, error) abort
    let l:text = a:error.smell_type . ':'

    if ale#Var(a:buffer, 'ruby_reek_show_context')
        let l:text .= ' ' . a:error.context
    endif

    let l:text .= ' ' . a:error.message

    if ale#Var(a:buffer, 'ruby_reek_show_wiki_link')
        let l:text .= ' [' . a:error.wiki_link . ']'
    endif

    return l:text
endfunction

call ale#linter#Define('ruby', {
\    'name': 'reek',
\    'executable': 'reek',
\    'command': 'reek -f json --no-progress --no-color',
\    'callback': 'ale_linters#ruby#reek#Handle',
\})
