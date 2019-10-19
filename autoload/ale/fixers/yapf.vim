" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing Python files with yapf.

call ale#Set('python_yapf_executable', 'yapf')
call ale#Set('python_yapf_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#fixers#yapf#Fix(buffer) abort
    let l:executable = ale#python#FindExecutable(
    \   a:buffer,
    \   'python_yapf',
    \   ['yapf'],
    \)

    if !executable(l:executable)
        return 0
    endif

    let l:buffer_filename = fnamemodify(bufname(a:buffer), ':p')
    let l:buffer_filename = fnameescape(l:buffer_filename)
    let l:yapfignore_path = ale#path#FindNearestFile(a:buffer, '.yapfignore')

    if !empty(l:yapfignore_path) && filereadable(l:yapfignore_path)
        for line in readfile(l:yapfignore_path)
            if l:buffer_filename =~ glob2regpat(line)
                return 0
            endif
        endfor
    endif

    let l:config = ale#path#FindNearestFile(a:buffer, '.style.yapf')
    let l:config_options = !empty(l:config)
    \   ? ' --no-local-style --style ' . ale#Escape(l:config)
    \   : ''

    return {
    \   'command': ale#Escape(l:executable) . l:config_options,
    \}
endfunction
