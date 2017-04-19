" Author: Eddie Lebow https://github.com/elebow
" Description: Reek, a code smell detector for Ruby files

function! ale_linters#ruby#reek#Handle(buffer, lines) abort
    if len(a:lines) == 0
        return []
    endif

    let l:errors = json_decode(a:lines[0])

    let l:output = []

    for l:error in l:errors
        for l:location in l:error.lines
            call add(l:output, {
            \    'bufnr': a:buffer,
            \    'lnum': l:location,
            \    'type': 'W',
            \    'text': s:BuildText(l:error),
            \})
        endfor
    endfor

    return l:output
endfunction

function! s:BuildText(error) abort
    let l:text = a:error.smell_type . ':'

    if get(g:, 'ale_ruby_reek_show_context', 0)
        let l:text .= ' ' . a:error.context
    endif

    let l:text .= ' ' . a:error.message

    if get(g:, 'ale_ruby_reek_show_wiki_link', 0)
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
