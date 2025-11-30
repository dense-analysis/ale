call ale#Set('proselint_executable', 'proselint')

function! ale#proselint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'proselint_executable')
endfunction

function! ale#proselint#GetCommand(buffer, version) abort
    let l:executable = ale#proselint#GetExecutable(a:buffer)
    let l:escaped_exec = ale#Escape(l:executable)

    if ale#semver#GTE(a:version, [0, 16, 0])
        return l:escaped_exec . ' check %t'
    else
        return l:escaped_exec . ' %t'
    endif
endfunction

function! ale#proselint#GetCommandWithVersionCheck(buffer) abort
    return ale#semver#RunWithVersionCheck(
    \   a:buffer,
    \   ale#proselint#GetExecutable(a:buffer),
    \   '%e version --output-format json',
    \   function('ale#proselint#GetCommand')
    \)
endfunction
