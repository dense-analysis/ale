" Author: Vincent (wahrwolf [ät] wolfpit.net)
" Description: languagetool for markdown files

function! ale#handlers#languagetool#HandleOutput(buffer, lines) abort

    " Match lines like:
    " 1.) Line 5, column 1, Rule ID:
    let l:head_pattern = '^\v.+.\) Line (\d+), column (\d+), Rule ID. (.+)$'
    let l:head_matches = ale#util#GetMatches(a:lines, l:head_pattern)

    " Match lines like:
    " Message: Did you forget a comma after a conjunctive/linking adverb?
    let l:message_pattern = '^\vMessage. (.+)$'
    let l:message_matches = ale#util#GetMatches(a:lines, l:message_pattern)

    " Match lines like:
    "   ^^^^^ "
    let l:markers_pattern = '^\v *(\^+) *$'
    let l:markers_matches = ale#util#GetMatches(a:lines, l:markers_pattern)

    let l:output = []


    " Okay tbh I was to lazy to figure out a smarter solution here
    " We just assume that the arrays are same sized and merge everything
    " together
    let l:i = 0

    while l:i < len(l:head_matches) &&
    \   (
    \       (len(l:head_matches) == len(l:markers_matches)) &&
    \       (len(l:head_matches) == len(l:message_matches))
    \   )

        let l:item = {
        \   'lnum'    : str2nr(l:head_matches[l:i][1]),
        \   'col'     : str2nr(l:head_matches[l:i][2]),
        \   'end_col' : str2nr(l:head_matches[l:i][2]) + len(l:markers_matches[l:i][1])-1,
        \   'type'    : 'W',
        \   'code'    : l:head_matches[l:i][3],
        \   'text'    : l:message_matches[l:i][1]
        \}
        call add(l:output, l:item)
        let l:i+=1
    endwhile

    return l:output
endfunction
