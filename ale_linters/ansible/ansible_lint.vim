" Author: Bjorn Neergaard <bjorn@neersighted.com>
" Description: ansible-lint for ansible-yaml files

call ale#Set('ansible_ansible_lint_executable', 'ansible-lint')

function! ale_linters#ansible#ansible_lint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'ansible_ansible_lint_executable')
endfunction

function! ale_linters#ansible#ansible_lint#Handle(buffer, lines) abort
    for l:line in a:lines[:10]
        if match(l:line, '^Traceback') >= 0
            return [{
            \   'lnum': 1,
            \   'text': 'An exception was thrown. See :ALEDetail',
            \   'detail': join(a:lines, "\n"),
            \}]
        endif
    endfor

    let l:pattern = '\v^([^:]+):(\d+):%((\d+):)? ([-[:alnum:]]+) (.*)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if ale#path#IsBufferPath(a:buffer, l:match[1])
            call add(l:output, {
            \   'lnum': l:match[2] + 0,
            \   'col': l:match[3] + 0,
            \   'text': l:match[5],
            \   'code': l:match[4],
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('ansible', {
\   'name': 'ansible_lint',
\   'aliases': ['ansible', 'ansible-lint'],
\   'executable': function('ale_linters#ansible#ansible_lint#GetExecutable'),
\   'command': '%e -p -x yaml',
\   'callback': 'ale_linters#ansible#ansible_lint#Handle',
\})
