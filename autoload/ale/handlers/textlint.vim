" Author: tokida https://rouger.info
" Description: Redpen, a proofreading tool (http://redpen.cc)

function! ale#handlers#textlint#HandleTextlintOutput(buffer, lines) abort
    let l:res = json_decode(join(a:lines))[0]
    let l:output = []
    for l:err in l:res.messages
        let l:item = {
        \   'text': l:err.message,
        \   'type': 'W',
        \   'code': l:err.ruleId,
        \}
        let l:item.lnum = l:err.line
        let l:item.col = l:err.column
        call add(l:output, l:item)
    endfor
    return l:output
endfunction
