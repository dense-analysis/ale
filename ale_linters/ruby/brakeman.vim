" Author: Eddie Lebow https://github.com/elebow
" Description: Brakeman, a static analyzer for Rails security

function! ale_linters#ruby#brakeman#Handle(buffer, lines) abort
    let l:result = json_decode(join(a:lines, ''))

    let l:output = []

    for l:warning in l:result.warnings
        " Brakeman always outputs paths relative to the Rails app root
        let l:rails_root = s:FindRailsRoot(a:buffer)
        let l:warning_file = l:rails_root . '/' . l:warning.file

        if !ale#path#IsBufferPath(a:buffer, l:warning_file)
          continue
        endif

        let l:text = l:warning.warning_type . ' ' . l:warning.message . ' (' . l:warning.confidence . ')'
        let l:line = l:warning.line != v:null ? l:warning.line : 1

        call add(l:output, {
        \    'lnum': l:line,
        \    'type': 'W',
        \    'text': l:text,
        \})
    endfor

    return l:output
endfunction

function! ale_linters#ruby#brakeman#GetCommand(buffer) abort
    let l:rails_root = s:FindRailsRoot(a:buffer)

    if l:rails_root ==? ''
        return ''
    endif

    return 'brakeman -f json -q -p ' . l:rails_root
endfunction

function! s:FindRailsRoot(buffer) abort
    " Find the nearest dir contining "app", "db", and "config", and assume it is
    " the root of a Rails app.

    let l:path = fnamemodify(bufname(a:buffer), ':p')

    while l:path !=? '/'
        if strlen(finddir('app', l:path)) > 0 &&
        \  strlen(finddir('db', l:path)) > 0 &&
        \  strlen(finddir('config', l:path)) > 0
            break
        endif

        let l:path = fnamemodify(l:path, ':h')
    endwhile

    " This is technically incorrect, since a valid Rails app could exist at the filesystem root.
    if l:path ==? '/'
        return ''
    else
        return l:path
    endif
endfunction

call ale#linter#Define('ruby', {
\    'name': 'brakeman',
\    'executable': 'brakeman',
\    'command_callback': 'ale_linters#ruby#brakeman#GetCommand',
\    'callback': 'ale_linters#ruby#brakeman#Handle',
\    'lint_file': 1,
\})
