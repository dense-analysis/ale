" Author: evnu - https://github.com/evnu
" Author: colbydehart - https://github.com/colbydehart
" Author: toupeira - https://github.com/toupeira
" Description: Mix compile checking for Elixir files

function! ale_linters#elixir#mix#Handle(buffer, lines) abort
    " Example output from Elixir 1.20.0:
    "
    "     warning: variable "a" is unused (if the variable is not meant to be used, prefix it with an underscore)
    "     │
    "  16 │     a = missing_var
    "     │     ~
    "     │
    "     └─ lib/foo.ex:16:5: Foo.hello/0
    "
    "     warning: variable "b" is unused (if the variable is not meant to be used, prefix it with an underscore)
    "     │
    "  17 │     b = another_missing_var
    "     │     ~
    "     │
    "     └─ lib/foo.ex:17:5: Foo.hello/0
    "
    "     error: undefined variable "another_missing_var"
    "     │
    "  17 │     b = another_missing_var
    "     │         ^^^^^^^^^^^^^^^^^^^
    "     │
    "     └─ lib/foo.ex:17:9: Foo.hello/0
    "
    "     error: undefined variable "missing_var"
    "     │
    "  16 │     a = missing_var
    "     │         ^^^^^^^^^^^
    "     │
    "     └─ lib/foo.ex:16:9: Foo.hello/0
    "
    "
    " == Compilation error in file lib/foo.ex ==
    " ** (CompileError) lib/foo.ex: cannot compile module Foo (errors have been logged)
    "
    " NOTE: The line with the error class is not captured because it always
    " seems to be either a `CompileError` or a `SyntaxError`, with a generic
    " message.
    "
    let l:pattern_text = '\v^    (warning|error): (.+)$'
    let l:pattern_file = '\v^    └─ ([^ :]+):([0-9]+):([0-9]+)?'

    let l:match_texts = ale#util#GetMatches(a:lines, l:pattern_text)
    let l:match_files = ale#util#GetMatches(a:lines, l:pattern_file)

    let l:output = []
    let l:index = 0

    " Always add the full output as detail
    let l:detail = join(a:lines, "\n")

    for l:match_text in l:match_texts
        let l:type = toupper(l:match_text[1][0])
        let l:match_file = get(l:match_files, l:index, [])

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'type': l:type,
        \   'detail': l:detail,
        \   'text': get(l:match_text, 2, v:null),
        \   'lnum': get(l:match_file, 2, v:null),
        \   'col': get(l:match_file, 3, v:null),
        \})

        let l:index += 1
    endfor

    return l:output
endfunction

call ale#linter#Define('elixir', {
\   'name': 'mix',
\   'executable': 'mix',
\   'cwd': function('ale#handlers#elixir#FindMixProjectRoot'),
\   'command': '%e compile',
\   'output_stream': 'stderr',
\   'callback': 'ale_linters#elixir#mix#Handle',
\   'lint_file': 1,
\})
