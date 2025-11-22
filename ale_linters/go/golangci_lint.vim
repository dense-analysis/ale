" Author: Sascha Grunert <mail@saschagrunert.de>
" Description: Adds support of golangci-lint

call ale#Set('go_golangci_lint_options', '')
call ale#Set('go_golangci_lint_executable', 'golangci-lint')
call ale#Set('go_golangci_lint_package', 1)

function! ale_linters#go#golangci_lint#GetExecutable(buffer) abort
    let l:executable = ale#Var(a:buffer, 'go_golangci_lint_executable')

    return l:executable
endfunction

function! ale_linters#go#golangci_lint#GetCommand(buffer, version) abort
    let l:filename = expand('#' . a:buffer . ':t')
    let l:options = ale#Var(a:buffer, 'go_golangci_lint_options')
    let l:lint_package = ale#Var(a:buffer, 'go_golangci_lint_package')

    if ale#semver#GTE(a:version, [2, 0, 0])
        let l:options = l:options
        \ . ' --output.json.path stdout'
        \ . ' --output.text.path stderr'
        \ . ' --show-stats=0'
    else
        let l:options = l:options
        \   . ' --out-format=json'
        \   . ' --show-stats=0'
    endif

    if l:lint_package
        return ale#go#EnvString(a:buffer)
        \   . '%e run '
        \   .  l:options
    endif

    return ale#go#EnvString(a:buffer)
    \   . '%e run '
    \   . ale#Escape(l:filename)
    \   . ' ' . l:options
endfunction

function! ale_linters#go#golangci_lint#Handler(buffer, lines) abort
    let l:dir = expand('#' . a:buffer . ':p:h')
    let l:output = []

    let l:matches = ale#util#FuzzyJSONDecode(a:lines, [])

    if empty(l:matches)
        return []
    endif

    for l:match in l:matches['Issues']
        if l:match['FromLinter'] is# 'typecheck'
            let l:msg_type = 'E'
        else
            let l:msg_type = 'W'
        endif

        call add(l:output, {
        \   'filename': ale#path#GetAbsPath(l:dir, fnamemodify(l:match['Pos']['Filename'], ':t')),
        \   'lnum': l:match['Pos']['Line'] + 0,
        \   'col': l:match['Pos']['Column'] + 0,
        \   'type': l:msg_type,
        \   'text': match['FromLinter'] . ' - ' . l:match['Text'],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'golangci-lint',
\   'executable': function('ale_linters#go#golangci_lint#GetExecutable'),
\   'cwd': '%s:h',
\   'command': {buffer -> ale#semver#RunWithVersionCheck(
\       buffer,
\       ale_linters#go#golangci_lint#GetExecutable(buffer),
\       '%e --version',
\       function('ale_linters#go#golangci_lint#GetCommand'),
\   )},
\   'callback': 'ale_linters#go#golangci_lint#Handler',
\   'lint_file': 1,
\})
