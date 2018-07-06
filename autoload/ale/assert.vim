function! s:GetLinter() abort
    let l:linters = ale#linter#GetLintersLoaded()
    let l:filetype_linters = get(values(l:linters), 0, [])

    if len(l:linters) is 0 || len(l:filetype_linters) is 0
        throw 'No linters were loaded'
    endif

    if len(l:linters) > 1 || len(l:filetype_linters) > 1
        throw 'More than one linter was loaded'
    endif

    return l:filetype_linters[0]
endfunction

" Load the currently loaded linter for a test case, and check that the command
" matches the given string.
function! ale#assert#Linter(expected_executable, expected_command) abort
    let l:buffer = bufnr('')
    let l:linter = s:GetLinter()
    let l:executable = ale#linter#GetExecutable(l:buffer, l:linter)

    if has_key(l:linter, 'command_chain')
        let l:command = []

        for l:chain_item in l:linter.command_chain
            if empty(l:command)
                call add(l:command, call(l:chain_item.callback, [l:buffer]))
            else
                call add(l:command, call(l:chain_item.callback, [l:buffer, []]))
            endif
        endfor
    else
        let l:command = ale#linter#GetCommand(l:buffer, l:linter)
        " Replace %e with the escaped executable, so tests keep passing after
        " linters are changed to use %e.
        let l:command = substitute(l:command, '%e', '\=ale#Escape(l:executable)', 'g')
    endif

    AssertEqual
    \   [a:expected_executable, a:expected_command],
    \   [l:executable, l:command]
endfunction

command! -nargs=+ AssertLinter :call ale#assert#Linter(<args>)

" A dummy function for making sure this module is loaded.
function! ale#assert#Init() abort
    call ale#linter#Reset()
endfunction
