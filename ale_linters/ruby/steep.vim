call ale#Set('ruby_steep_executable', 'steep')
call ale#Set('ruby_steep_options', '')

" Find the nearest dir containing a Steepfile
function! ale_linters#ruby#steep#FindRoot(buffer) abort
    for l:name in ['Steepfile']
        let l:dir = fnamemodify(
        \   ale#path#FindNearestFile(a:buffer, l:name),
        \   ':h'
        \)

        if l:dir isnot# '.' && isdirectory(l:dir)
            return l:dir
        endif
    endfor

    return ''
endfunction

function! ale_linters#ruby#steep#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'ruby_steep_executable')

    return ale#ruby#EscapeExecutable(l:executable, 'steep')
    \   . ' check '
    \   . ale#Var(a:buffer, 'ruby_steep_options')
    \   . ' %s'
endfunction

function! ale_linters#ruby#steep#GetType(severity) abort
    if a:severity is? 'warning'
    \|| a:severity is? 'information'
    \|| a:severity is? 'hint'
        return 'W'
    endif

    return 'E'
endfunction

" Handle output from steep
function! ale_linters#ruby#steep#HandleOutput(buffer, lines) abort
    let l:output = []

    let l:in = 0
    let l:item = {}
    for l:line in a:lines
        " Look for first line of a message block
        " If not in-message (l:in == 0) that's expected
        " If in-message (l:in > 0) that's less expected but let's recover
        let l:match = matchlist(l:line, '^\([^:]*\):\([0-9]*\):\([0-9]*\): \[\([^]]*\)\] \(.*\)')

        if len(l:match) > 0
            " Something is lingering: recover by pushing what is there
            if len(l:item) > 0
                call add(l:output, l:item)
                let l:item = {}
            endif

            let l:filename = l:match[1]

            let l:item = {
            \   'lnum': l:match[2],
            \   'col': l:match[3] + 1,
            \   'type': ale_linters#ruby#steep#GetType(l:match[4]),
            \   'text': l:match[5],
            \}

            " Done with this line, mark being in-message and go on with next line
            let l:in = 1
            continue
        endif

        " We're past the first line of a message block
        if l:in > 0
            " Look for code in subsequent lines of the message block
            if l:line =~# '^│ Diagnostic ID:'
                let l:match = matchlist(l:line, '^│ Diagnostic ID: \(.*\)')

                if len(l:match) > 0
                    let l:item.code = l:match[1]
                endif

                " Done with the line
                continue
            endif

            " Look for last line of the message block
            if l:line =~# '^└'
                " Done with the line, mark looking for underline and go on with the next line
                let l:in = 2
                continue
            endif

            " Look for underline right after last line
            if l:in == 2
                let l:match = matchlist(l:line, '\([~][~]*\)')

                if len(l:match) > 0
                    let l:item.end_col = l:item['col'] + len(l:match[1]) - 1
                endif

                call add(l:output, l:item)

                " Done with the line, mark looking for first line and go on with the next line
                let l:in = 0
                let l:item = {}
                continue
            endif
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('ruby', {
\   'name': 'steep',
\   'executable': {b -> ale#Var(b, 'ruby_steep_executable')},
\   'language': 'ruby',
\   'command': function('ale_linters#ruby#steep#GetCommand'),
\   'project_root': function('ale_linters#ruby#steep#FindRoot'),
\   'callback': 'ale_linters#ruby#steep#HandleOutput',
\})
