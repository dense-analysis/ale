" Author: rudolf ordoyne <rudolfordoyne@protonmail.com>
" Description: Support for cljfmt https://github.com/weavejester/cljfmt

call ale#Set('clojure_cljfmt_executable', 'cljfmt')

function! ale#fixers#cljfmt#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'clojure_cljfmt_executable')

    return {
    \   'command': ale#Escape(l:executable) . ' fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction

