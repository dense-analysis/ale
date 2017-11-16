" Author: rhysd https://rhysd.github.io
" Description: Redpen, a proofreading tool (http://redpen.cc)

function! ale_linters#markdown#redpen#HandleErrors(buffer, lines) abort
    " Only one file was passed to redpen. So response array has only one
    " element.
    let l:res = json_decode(join(a:lines))[0]
    let l:errors = []
    for l:err in l:res.errors
        if has_key(l:err, 'startPosition')
            let l:lnum = l:err.startPosition.lineNum
            let l:col = l:err.startPosition.offset
        else
            let l:lnum = l:err.lineNum
            let l:col = l:err.sentenceStartColumnNum + 1
        endif
        call add(l:errors, {
        \   'lnum': l:lnum,
        \   'col': l:col,
        \   'text': l:err.message . ' (' . l:err.validator . ')',
        \   'type': 'W',
        \})
    endfor
    return l:errors
endfunction

call ale#linter#Define('markdown', {
\   'name': 'redpen',
\   'executable': 'redpen',
\   'command': 'redpen -r json %t',
\   'callback': 'ale_linters#markdown#redpen#HandleErrors',
\})
