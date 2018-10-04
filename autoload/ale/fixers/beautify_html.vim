" Author: @jpsouzasilva (joao.paulo.silvasouza@hotmail.com)
" Description: Integration of the JS-Beautify library for HTML and Vue files.

call ale#Set('beautify_html_executable', 'html-beautify')
call ale#Set('beautify_html_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('beautify_html_options', ' --type html ')

function! ale#fixers#beautify_html#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'beautify_html', [
    \   'node_modules/.bin/html-beautify',
    \   'node_modules/js-beautify/js/bin/html-beautify.js',
    \])
endfunction

function! ale#fixers#beautify_html#Fix(buffer) abort
    let l:config_path = ale#path#FindNearestFile(a:buffer, '.jsbeautifyrc')

    " Usage at https://github.com/beautify-web/js-beautify/blob/master/js/src/cli.js#L323
    return {
    \   'command': ale#fixers#beautify_html#GetExecutable(a:buffer)
    \       . (l:config_path ? (' --config ' . l:config_path) : '')
    \       . ale#Var(a:buffer, 'beautify_html_options')
    \}
endfunction
