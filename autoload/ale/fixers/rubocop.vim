call ale#Set('ruby_rubocop_options', '')
call ale#Set('ruby_rubocop_auto_correct_all', 0)
call ale#Set('ruby_rubocop_executable', 'rubocop')

" Rubocop fixer outputs diagnostics first and then the fixed
" output. These are delimited by a "=======" string that we
" look for to remove everything before it.
function! ale#fixers#rubocop#PostProcess(buffer, output) abort
    let l:line = 0

    for l:output in a:output
        let l:line = l:line + 1

        if l:output =~# "^=\\+$"
            break
        endif
    endfor

    return a:output[l:line :]
endfunction

function! ale#fixers#rubocop#GetCommand(buffer, version) abort
    let l:executable = ale#Var(a:buffer, 'ruby_rubocop_executable')
    let l:options = ale#Var(a:buffer, 'ruby_rubocop_options')
    let l:auto_correct_all = ale#Var(a:buffer, 'ruby_rubocop_auto_correct_all')
    let l:editor_mode = ale#semver#GTE(a:version, [1, 61, 0])

    return ale#ruby#EscapeExecutable(l:executable, 'rubocop')
    \   . ale#Pad(l:options)
    \   . (l:auto_correct_all ? ' --auto-correct-all' : ' --auto-correct')
    \   . (l:editor_mode ? ' --editor-mode' : '')
    \   . ' --force-exclusion --stdin %s'
endfunction

function! ale#fixers#rubocop#GetCommandForVersion(buffer, version) abort
    return {
    \ 'command': ale#fixers#rubocop#GetCommand(a:buffer, a:version),
    \ 'process_with': 'ale#fixers#rubocop#PostProcess'
    \}
endfunction

function! ale#fixers#rubocop#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'ruby_rubocop_executable')
    let l:command = l:executable . ale#Pad('--version')

    return ale#semver#RunWithVersionCheck(
    \   a:buffer,
    \   l:executable,
    \   l:command,
    \   function('ale#fixers#rubocop#GetCommandForVersion'),
    \)
endfunction
