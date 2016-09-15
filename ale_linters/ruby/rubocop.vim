if exists('g:loaded_ale_linters_ruby_rubocop')
    finish
endif

let g:loaded_ale_linters_ruby_rubocop = 1

function! ale_linters#ruby#rubocop#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " <text>:47:14: Missing trailing comma. [Warning/comma-dangle]
    " <text>:56:41: Missing semicolon. [Error/semi]
    " let pattern = '.*_:\(\d\+\):\(\d\+\): \(.\) \(.\+\)'
    let pattern = '\v_:(\d+):(\d+): (.): (.+)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[4]
        let type = l:match[3]

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': type ==# 'C' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('ruby', {
\   'executable': 'rubocop',
\   'command': 'rubocop --format emacs --stdin _',
\   'callback': 'ale_linters#ruby#rubocop#Handle',
\})

