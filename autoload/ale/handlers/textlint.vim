" Author: tokida https://rouger.info
" Description: Redpen, a proofreading tool (http://redpen.cc)

function! ale#handlers#textlint#HandleTextlintOutput(buffer, lines) abort
    let l:res = get(ale#util#FuzzyJSONDecode(a:lines, []), 0, {'messages': []})
    let l:output = []

    for l:err in l:res.messages
        call add(l:output, {
        \   'text': l:err.message,
        \   'type': 'W',
        \   'code': l:err.ruleId,
        \   'lnum': l:err.line,
        \   'col' : l:err.column
        \})
    endfor

    return l:output
endfunction
