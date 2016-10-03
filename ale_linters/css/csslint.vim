" Author: KabbAmine - https://github.com/KabbAmine

if exists('g:loaded_ale_linters_css_csslint')
    finish
endif

let g:loaded_ale_linters_css_csslint = 1

function! ale_linters#css#csslint#Handle(buffer, lines)
    " Matches patterns like the following example:
	" foo.css: line 5, col 1, Warning - Rule is empty. (empty-rules)

    let pattern = '.*:\sline\s\(\d\+\),\scol\s\(\d*\),\s\(.\+\)\s-\s\(.\+\)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = l:match[1] + 0
        let column = l:match[2] + 0
        let type = l:match[3] ==# 'Warning' ? 'W' : 'E'
        let text = l:match[3] . ': ' . l:match[4]

        " vcol is needed to indicate that the column is a character
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': column,
        \   'text': text,
        \   'type': type,
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('css', {
\   'name': 'csslint',
\   'executable': 'csslint',
\   'command': g:ale#util#stdin_wrapper . ' .css csslint --format=compact',
\   'callback': 'ale_linters#css#csslint#Handle',
\})
