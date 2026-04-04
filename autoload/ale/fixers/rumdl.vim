scriptencoding utf-8

" Author: Evan Chen <evan@evanchen.cc>
" Description: Fast Markdown linter and formatter written in Rust


call ale#Set('markdown_rumdl_executable', 'rumdl')
call ale#Set('markdown_rumdl_options', '--silent')

function! ale#fixers#rumdl#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'markdown_rumdl_executable')
    let l:options = ale#Var(a:buffer, 'markdown_rumdl_options')

    return {
    \   'command': ale#Escape(l:executable) . ' fmt -'
    \       . ale#Pad(l:options),
    \}
endfunction
