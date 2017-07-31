" Author: Mahmoud Mostafa <mah@moud.info>
" Description: Fixing files with stylelint.

call ale#Set('stylelint_executable', 'stylelint')
call ale#Set('stylelint_use_global', 0)

function! ale#fixers#stylelint#GetExecutable(buffer) abort
      return ale#node#FindExecutable(a:buffer, 'stylelint', [
          \   'node_modules/stylelint/bin/stylelint.js',
          \   'node_modules/.bin/stylelint',
          \])
endfunction


function! ale#fixers#stylelint#Fix(buffer) abort
    let l:executable = ale#fixers#stylelint#GetExecutable(a:buffer)

    if ale#Has('win32') && l:executable =~? 'stylelint\.js$'
        " For Windows, if we detect an stylelint.js script, we need to execute
        " it with node, or the file can be opened with a text editor.
        let l:head = 'node ' . ale#Escape(l:executable)
    else
        let l:head = ale#Escape(l:executable)
    endif

    return {
    \   'command': l:head
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction
