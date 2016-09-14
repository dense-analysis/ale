if exists('g:loaded_ale_linters_javascript_jshint')
    finish
endif

let g:loaded_ale_linters_javascript_jshint = 1

" Set this to the location of the jshint configuration file
if !exists('g:ale_jshint_config_loc')
    let g:ale_jshint_config_loc = '.jshintrc'
endif

function! ale_linters#javascript#jshint#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " stdin:57:9: Missing name in function declaration.
    " stdin:60:5: Attempting to override 'test2' which is a constant.
    " stdin:57:10: 'test' is defined but never used.
    " stdin:57:1: 'function' is defined but never used.
    let pattern = '^.\+:\(\d\+\):\(\d\+\): \(.\+\)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[3]
        let marker_parts = l:match[4]

        if len(marker_parts) == 2
            let text = text . ' (' . marker_parts[1] . ')'
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('javascript', {
\   'executable': 'jshint',
\   'command': 'jshint --reporter unix --config ' . g:ale_jshint_config_loc . ' -',
\   'callback': 'ale_linters#javascript#jshint#Handle',
\})
