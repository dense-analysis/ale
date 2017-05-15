let g:ale_cpp_cpplint_filter = get(g:, 'ale_cpp_cpplint_filter', [])
let g:ale_cpp_cpplint_verbose = get(g:, 'ale_cpp_cpplint_verbose', 1)
let g:ale_cpp_cpplint_linelength = get(g:, 'ale_cpp_cpplint_linelength', 80)

function! ale_linters#cpp#cpplint#HandleCpplintFormat(buffer, lines) abort
    let l:pattern = '^\(.\+\):\(\d\+\):\s\(.\+\)\s\(\[.\+\]\)\s\(\[.\+\]\)$'
    let l:output = []
    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)
        if !empty(l:match)
            call add(l:output, {
                        \'text': match[3] . ' ' . match[4],
                        \'lnum': match[2] + 0,
                        \'col': 0,
                        \'type': 'W',
                        \})
        endif
    endfor
    return l:output
endfunction

function! s:to_option(key, value)
    if empty(a:value)
        return ''
    endif

    return '--' . a:key . '=' . a:value
endfunction

function! ale_linters#cpp#cpplint#GetCommand(buffer) abort
    let l:filter = s:to_option('filter', join(ale#Var(a:buffer, 'cpp_cpplint_filter'), ','))
    let l:verbose = s:to_option('verbose', ale#Var(a:buffer, 'cpp_cpplint_verbose'))
    let l:linelength = s:to_option('linelength', ale#Var(a:buffer, 'cpp_cpplint_linelength'))
    return 'cpplint --quiet ' . l:filter . ' ' . l:verbose . ' ' . l:linelength . ' -'
endfunction

call ale#linter#Define('cpp', {
\   'name': 'cpplint',
\   'output_stream': 'stderr',
\   'executable': 'cpplint',
\   'callback': 'ale_linters#cpp#cpplint#HandleCpplintFormat',
\   'command_callback': 'ale_linters#cpp#cpplint#GetCommand',
\})

