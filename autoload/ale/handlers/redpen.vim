" Author: rhysd https://rhysd.github.io
" Description: Redpen, a proofreading tool (http://redpen.cc)

function! ale#handlers#redpen#HandleRedpenOutput(buffer, lines) abort
    " Only one file was passed to redpen. So response array has only one
    " element.
    let l:res = json_decode(join(a:lines))[0]
    let l:output = []
    for l:err in l:res.errors
        let l:item = {
        \   'text': l:err.message,
        \   'type': 'W',
        \   'code': l:err.validator,
        \}
        if has_key(l:err, 'startPosition')
            let l:item.lnum = l:err.startPosition.lineNum
            let l:item.col = l:err.startPosition.offset + 1
            if has_key(l:err, 'endPosition')
                let l:item.end_lnum = l:err.endPosition.lineNum
                let l:item.end_col = l:err.endPosition.offset
            endif
        else
            " Fallback to a whole sentence region when a region is not
            " specified by the error.
            let l:item.lnum = l:err.lineNum
            let l:item.col = l:err.sentenceStartColumnNum + 1
        endif
        call add(l:output, l:item)
    endfor
    return l:output
endfunction

