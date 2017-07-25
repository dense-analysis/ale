" Author: Chris Weyl <cweyl@alumni.drew.edu>
" Description: Helper functions for proselint filters

" What: define a standard proselint linter via one function
function! ale#proselint#Define(filetype) abort

    call ale#linter#util#SetStandardVars(a:filetype.'_proselint', 'proselint')

    call ale#linter#Define(a:filetype, {
    \   'name':                'proselint',
    \   'executable_callback': { buffer -> ale#linter#util#GetBufExec(buffer, a:filetype.'_proselint') },
    \   'command_callback':    { buffer -> ale#linter#util#GetCommand(buffer, a:filetype.'_proselint') },
    \   'callback':            'ale#handlers#unix#HandleAsWarning',
    \})
endfunction
