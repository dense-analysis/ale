" Author: @jpsouzasilva (joao.paulo.silvasouza@hotmail.com)
" Description: Integration of the JS-Beautify library for HTML and Vue files.

let s:KnownTemplateDelimiters = {
\    'html': { 'opening': '<html>', 'closing': '</html>' },
\    'vue': { 'opening': '<template>', 'closing': '</template>' }
\}

call ale#Set('js-beautify-html_executable', 'html-beautify.js')
call ale#Set('js-beautify-html_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('js-beautify-html_options', '')
call ale#Set('js-beautify-html_template-delimiters', s:KnownTemplateDelimiters)

function! ale#fixers#jsBeautifyHTML#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_js-beautify-html', [
    \   'node_modules/.bin/html-beautify.js',
    \   'node_modules/js-beautify/js/bin/html-beautify.js',
    \])
endfunction

function! ale#fixer#jsBeautifyHTML#ExtractHTMLPortion(buffer) abort
    let l:template_delimiters = ale#Var('js-beautify-html_template-delimiters')
    let l:buffer_lines = getline(a:buffer, '$')
    let l:initial_line = 0
    let l:ending_line = 0

    for key in keys(l:template_delimiters)
        if &filetype == key
            let l:opening_tag = get(l:template_delimiters[key], 'opening')
            let l:closing_tag = get(l:template_delimiters[key], 'closing')

            for line_number in length(l:buffer_lines)
                if l:buffer_lines[line_number] == l:opening_tag
                    let l:initial_line = line_number
                endif

                if l:buffer_lines[line_number] == l:closing_tag
                    let l:ending_line = line_number
                endif

                if l:initial_line && l:ending_line
                    return execute "join(l:buffer_lines[" l:initial_line - 1 ":" l:ending_line - 1 "], \"\\\n\")"
                endif
            break
        endif
    endfor

    return l:buffer_lines
endfunction

function! ale#fixer#jsBeautifyHTML#ProcessHTMLPortion(buffer, output) abort
   echo a:output
endfunction

function! ale#fixers#jsBeautifyHTML#Fix(buffer) abort
    let l:executable = ale#fixers#jsBeautifyHTML#GetExecutable(a:buffer)

    " Usage at https://github.com/beautify-web/js-beautify/blob/master/js/src/cli.js#L323
    return {
    \   'command': ale#node#Executable(a:buffer, l:executable)
    \       . ' --config ' . ale#Escape(l:config)
    \       . ' -r --type="html" - '
    \   'input': ale#fixer#jsBeautifyHTML#ExtractHTMLPortion(a:buffer)
    \   'process_with': 'ale#fixer#jsBeautifyHTML#ProcessHTMLPortion'
    \   'read_temporary_file': 1,
    \}
endfunction
