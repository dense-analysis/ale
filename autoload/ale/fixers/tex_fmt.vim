" Author: https://github.com/Spixmaster
" Description: Fix LaTeX and bibliography files with tex-fmt.

call ale#Set('tex_tex_fmt_executable', 'tex-fmt')
call ale#Set('tex_tex_fmt_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('tex_tex_fmt_options', '')

function! ale#fixers#tex_fmt#Fix(buffer) abort
    let l:executable = ale#python#FindExecutable(
    \   a:buffer,
    \   'tex_tex_fmt',
    \   ['tex-fmt']
    \)

    let l:options = ale#Var(a:buffer, 'tex_tex_fmt_options')

    return {
    \   'command': ale#Escape(l:executable) . ' ' . l:options . ' -s',
    \}
endfunction
