" Author: reisub0
" Description: Integration of dartfmt with ALE.

call ale#Set('dart_dartfmt_executable', 'dartfmt')
call ale#Set('dart_dartfmt_options', '')

function! FormatWithDartFmt(buffer) abort
    let l:executable = ale#Var(a:buffer, 'dart_dartfmt_executable')
    let l:options = ale#Var(a:buffer, 'dart_dartfmt_options')

    return {
    \   'command': ale#Escape(l:executable)
    \       . ' -w'
    \       . (empty(l:options) ? '' : ' ' . l:options)
    \       . ' %t',
    \   'read_temporary_file': 1,
    \}
endfunction

let b:ale_fixers = ['FormatWithDartFmt']
