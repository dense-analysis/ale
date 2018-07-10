" Description: remark-lint for Markdown files
"
call ale#Set('remark_lint_executable', 'remark')
call ale#Set('remark_lint_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('remark_lint_options', '')

function! ale#handlers#remark_lint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'remark_lint', [
    \   'node_modules/.bin/remark',
    \])
endfunction

function! ale#handlers#remark_lint#GetCommand(buffer) abort
    let l:executable = ale#handlers#remark_lint#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'remark_lint_options')

    return ale#node#Executable(a:buffer, l:executable)
    \    . (!empty(l:options) ? ' ' . l:options : '')
    \    . ' --no-stdout --no-color'
endfunction

function! ale#handlers#remark_lint#Handle(buffer, lines) abort
    " matches: '  1:4  warning  Incorrect list-item indent: add 1 space  list-item-indent  remark-lint'
    " matches: '  18:71-19:1  error  Missing new line after list item  list-item-spacing  remark-lint',
    let l:pattern = '^ \+\(\d\+\):\(\d\+\)\(-\(\d\+\):\(\d\+\)\)\?  \(warning\|error\)  \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:item = {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'type': l:match[6] is# 'error' ? 'E' : 'W',
        \   'text': l:match[7],
        \}
        if l:match[3] isnot# ''
            let l:item.end_lnum = l:match[4] + 0
            let l:item.end_col = l:match[5] + 0
        endif
        call add(l:output, l:item)
    endfor

    return l:output
endfunction
