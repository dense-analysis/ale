" Handle output from ruumba and linters that depend on it
function! ale#eruby#HandleRuumbaOutput(buffer, lines) abort
    try
        let l:errors = json_decode(a:lines[0])
    catch
        return []
    endtry

    if !has_key(l:errors, 'summary')
    \|| l:errors['summary']['offense_count'] == 0
    \|| empty(l:errors['files'])
        return []
    endif

    let l:output = []

    for l:error in l:errors['files'][0]['offenses']
        let l:start_col = l:error['location']['column'] + 0
        call add(l:output, {
        \   'lnum': l:error['location']['line'] + 0,
        \   'col': l:start_col,
        \   'end_col': l:start_col + l:error['location']['length'] - 1,
        \   'code': l:error['cop_name'],
        \   'text': l:error['message'],
        \   'type': ale_linters#eruby#ruumba#GetType(l:error['severity']),
        \})
    endfor

    return l:output
endfunction

function! ale#eruby#EscapeExecutable(executable, bundle_exec) abort
    let l:exec_args = a:executable =~? 'bundle'
    \   ? ' exec ' . a:bundle_exec
    \   : ''

    return ale#Escape(a:executable) . l:exec_args
endfunction
