" Author: Vincent (wahrwolf [ät] wolfpit.net)
" Description: languagetool for markdown files

" Example output
" 1.) Line 5, column 1, Rule ID:
" SENT_START_CONJUNCTIVE_LINKING_ADVERB_COMMA[1]
" Message: Did you forget a comma after a conjunctive/linking adverb?
" Suggestion: Therefore,
function! ale_linters#markdown#languagetool#Handle(buffer, lines) abort
    let l:head_pattern = '^\v.+.\) Line (\d+), column (\d+), Rule ID. (.+)$'
    let l:message_pattern = '^\vMessage. (.+)$'
    let l:output = []

    " Extract the header line first
    let l:head_matches = []
    call extend(l:head_matches, ale#util#GetMatches(a:lines, l:head_pattern))

    " Extract all messages
    let l:message_matches = []
    call extend(l:message_matches, ale#util#GetMatches(a:lines, l:message_pattern))

    " Okay tbh I was to lazy to figure out a smarter solution here
    " We just assume that the arrays are same sized and merge everything
    " together
    let l:i = 0

    while l:i < len(l:head_matches)
        let l:item = {
            \   'lnum': str2nr(l:head_matches[l:i][1]),
            \   'col' : str2nr(l:head_matches[l:i][2]),
            \   'type': 'W',
            \   'code': l:head_matches[l:i][3],
            \   'text': l:message_matches[l:i][1]
            \}
        call add(l:output, l:item)
        let l:i+=1
    endwhile

    return l:output
endfunction

call ale#linter#Define('markdown', {
            \   'name': 'languagetool',
            \   'executable': 'languagetool',
            \   'command': 'languagetool %s ',
            \   'output_stream': 'stdout',
            \   'callback': 'ale_linters#markdown#languagetool#Handle',
            \   'lint_file': 1,
            \})
