" Author: Alexander Olofsson <alexander.olofsson@liu.se>
" Description: puppet-lint fixer

function! ale#fixers#puppetlint#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'puppet_puppetlint_executable')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' ' . ale#Var(a:buffer, 'puppet_puppetlint_options')
    \       . ' --fix'
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction
