" Author: @jpsouzasilva (joao.paulo.silvasouza@hotmail.com)
" Description: Integration of the JS-Beautify library for HTML and Vue files.

let s:KnownTemplateDelimiters = {
\    'html': { 'opening': '<html>', 'closing': '</html>' },
\    'vue': { 'opening': '<template>', 'closing': '</template>' }
\}

call ale#Set('js_beautify_html_executable', 'html-beautify')
call ale#Set('js_beautify_html_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('js_beautify_html_options', '')
call ale#Set('js_beautify_html_template_delimiters', s:KnownTemplateDelimiters)

function! ale#fixers#js_beautify_html#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'js_beautify_html', [
    \   'node_modules/.bin/html-beautify.js',
    \   'node_modules/js-beautify/js/bin/html-beautify.js',
    \])
endfunction

function! s:TemplateLineRangeDelimiter(buffer, buffer_lines) abort
    let l:template_delimiters = ale#Var(a:buffer, 'js_beautify_html_template_delimiters')
    let l:buffer_line_length = len(a:buffer_lines) - 1
    let l:initial_line = 0
    let l:ending_line = 0

    for key in keys(l:template_delimiters)
        if &filetype == key
            let l:tags_found = 0
            let l:tags_needed = len(l:template_delimiters[key])

            let l:opening_tag = get(l:template_delimiters[key], 'opening')
            let l:closing_tag = get(l:template_delimiters[key], 'closing')

            for line_number in range(0, l:buffer_line_length, 1)
                if a:buffer_lines[line_number] == l:opening_tag
                    let l:initial_line = line_number
                    let l:tags_found += 1
                endif

                if a:buffer_lines[line_number] == l:closing_tag
                    let l:ending_line = line_number
                    let l:tags_found +=1
                endif

                if l:tags_found == l:tags_needed
                    return [l:initial_line, l:ending_line]
                endif
            endfor
        endif
    endfor

    return [0 : l:buffer_line_length]
endfunction

function! ale#fixers#js_beautify_html#ProcessTemplateOutput(buffer, output) abort
    let l:buffer_lines = getline(a:buffer, '$')
    let [l:first_line, l:last_line] = s:TemplateLineRangeDelimiter(a:buffer, l:buffer_lines)

    " Glue the beautified part back together in the middle.
    " Check for negative indexes because it may get the array's tail instead.
    " Out-of-bounds positive indexes just yields an empty array so no worries.
    return ((l:first_line - 1 > 0) ? l:buffer_lines[:l:first_line - 1] : [])
    \    + a:output
    \    + l:buffer_lines[l:last_line + 1:]
endfunction

function! ale#fixers#js_beautify_html#ExtractTemplateTag(buffer, ...) abort
    let l:buffer_lines = getline(a:buffer, '$')
    let [l:first_line, l:last_line] = s:TemplateLineRangeDelimiter(a:buffer, l:buffer_lines)

    let l:template_tag = buffer_lines[l:first_line : l:last_line]

    return { 'input': l:template_tag }
endfunction

function! ale#fixers#js_beautify_html#Fix(buffer) abort
    let l:config_path = ale#path#FindNearestFile(a:buffer, '.jsbeautifyrc')

    " Usage at https://github.com/beautify-web/js-beautify/blob/master/js/src/cli.js#L323
    return {
    \   'command': ale#fixers#js_beautify_html#GetExecutable(a:buffer)
    \       . (l:config_path ? (" --config " . l:config_path) : "")
    \       . " --type html "
    \       . ale#Var(a:buffer, 'js_beautify_html_options'),
    \   'process_with': 'ale#fixers#js_beautify_html#ProcessTemplateOutput'
    \}
endfunction
