" Author: Eric Zhao <21zhaoe@protonmail.com>
" Description: Format Pandoc markdown with pandoc.

call ale#Set('markdown_pandoc_executable', 'pandoc')
call ale#Set('markdown_pandoc_input_flags', [])
call ale#Set('markdown_pandoc_target_flags', [])
call ale#Set('markdown_pandoc_options', [])

function! ale#fixers#pandoc#Var(buffer, name) abort
    return ale#Var(a:buffer, 'markdown_pandoc_' . a:name)
endfunction

function! ale#fixers#pandoc#Fix(buffer) abort
    let l:executable = ale#fixers#pandoc#Var(a:buffer, 'executable')
    let l:filename = ale#Escape(bufname(a:buffer))

    let l:input_flags = ale#fixers#pandoc#Var(a:buffer, 'input_flags')
    let l:target_flags = ale#fixers#pandoc#Var(a:buffer, 'target_flags')
    let l:options = ale#fixers#pandoc#Var(a:buffer, 'options')

    let l:command = ale#Escape(l:executable)
    \   . ' -f markdown' . join(l:input_flags, '')
    \   . ' -t markdown' . join(l:target_flags, '')
    \   . ' -s '
    \   . join(l:options, ' ')
    \   . ' '
    \   . l:filename

    return {
    \   'command': l:command
    \}
endfunction
