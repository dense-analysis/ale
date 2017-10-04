" Author: rhysd <https://rhysd.github.io>
" Description: Support for checking LLVM IR with llc

call ale#Set('llvm_llc_command', 'llc')

function! ale_linters#llvm#llc#GetCommand(buffer) abort
    return ale#Var(a:buffer, 'llvm_llc_command')
    \   . ' -filetype=null -o='
    \   . ale#Escape(g:ale#util#nul_file)
    \   . ' %s'
endfunction

function! ale_linters#llvm#llc#HandleErrors(buffer, lines) abort
    " Handle '{path}: {file}:{line}:{col}: error: {message}' format
    let l:pattern = '\v^[a-zA-Z]?:?[^:]+: [^:]+:(\d+):(\d+): (.+)$'
    let l:matches = ale#util#GetMatches(a:lines, l:pattern)

    return map(l:matches, "{
    \   'lnum': str2nr(v:val[1]),
    \   'col': str2nr(v:val[2]),
    \   'text': v:val[3],
    \   'type': 'E',
    \}")
endfunction

call ale#linter#Define('llvm', {
\   'name': 'llc',
\   'executable': g:ale_llvm_llc_command,
\   'output_stream': 'stderr',
\   'command_callback': 'ale_linters#llvm#llc#GetCommand',
\   'callback': 'ale_linters#llvm#llc#HandleErrors',
\})
