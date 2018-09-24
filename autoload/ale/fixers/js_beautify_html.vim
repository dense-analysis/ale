" Author: @jpsouzasilva (joao.paulo.silvasouza@hotmail.com)
" Description: Integration of the JS-Beautify library for HTML and Vue files.

let s:KnownTemplateDelimiters = {
\    'html': { 'opening': '<html>', 'closing': '</html>' },
\    'vue': { 'opening': '<template>', 'closing': '</template>' },
\    'javascript': { 'regex': 1, 'match_start': 'render(.*)\(\)', 'opening': 'return\(.*\)(', 'closing': '\(.*\))' }
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

function! s:TemplateLineRangeDelimiter(buffer, ...) abort
    let l:options = get(a:000, 0, {})
    let l:no_output = get(l:options, 'no_output')
    let l:buffer_lines = get(l:options, 'buffer_lines', getline(a:buffer, '$'))

    let l:template_delimiters = ale#Var(a:buffer, 'js_beautify_html_template_delimiters')
    let l:buffer_line_length = len(l:buffer_lines) - 1
    let l:initial_line = 0
    let l:ending_line = 0

    for key in keys(l:template_delimiters)
        if &filetype == key
            let l:extracting_opts = l:template_delimiters[key]

            if len(get(l:extracting_opts, 'regex', ''))
                for line_number in range(0, l:buffer_line_length, 1)
                    if l:buffer_lines[line_number] =~ l:extracting_opts['match_start']
                        let l:remaining_content = join(l:buffer_lines[line_number : ], " ")
                        let l:start = matchend(l:remaining_content, 'return\(.*\)(')
                        let l:ending = matchend(l:remaining_content, '\(.*\))') - 1

                        if l:start > -1 && l:ending > -1
                            let l:match = strpart(l:remaining_content, l:start, l:ending - l:start)

                            return {'initial_line': l:initial_line,
                                  \ 'ending_line': l:ending_line,
                                  \ 'output': l:no_output
                                  \         ? []
                                  \         : [l:match] }
                        endif
                    endif
                endfor
            else
                let l:tags_found = 0
                let l:opening_tag = l:extracting_opts['opening']
                let l:closing_tag = l:extracting_opts['closing']

                for line_number in range(0, l:buffer_line_length, 1)
                    if l:buffer_lines[line_number] == l:opening_tag
                        let l:initial_line = line_number
                        let l:tags_found += 1
                    endif

                    if l:buffer_lines[line_number] == l:closing_tag
                        let l:ending_line = line_number
                        let l:tags_found +=1
                    endif

                    if l:tags_found == 2
                        return {'initial_line': l:initial_line,
                              \ 'ending_line': l:ending_line,
                              \ 'output': l:no_output
                              \         ? []
                              \         : l:buffer_lines[l:first_line : l:last_line] }
                    endif
                endfor
            endif
        endif
    endfor

    return {'initial_line': l:initial_line,
          \ 'ending_line': l:ending_line,
          \ 'output': l:no_output
          \         ? []
          \         : l:buffer_lines[l:first_line : l:last_line] }
endfunction

function! ale#fixers#js_beautify_html#ProcessTemplateOutput(buffer, output) abort
    let [l:first_line, l:last_line] = s:TemplateLineRangeDelimiter(a:buffer)

    " Glue the beautified part back together in the middle.
    " Out-of-bounds positive indexes just yields an empty array so no worries.
    return (l:first_line == 0 ? [] : l:buffer_lines[:l:first_line - 1])
    \      + a:output
    \      + l:buffer_lines[l:last_line + 1:]
endfunction

function! ale#fixers#js_beautify_html#ExtractTemplateTag(options) abort
    let l:extracted = s:TemplateLineRangeDelimiter(
                    \   a:options['buffer'],
                    \   { 'buffer_lines': a:options['input'] }
                    \ )

    echo l:extracted

    return { 'input': l:extracted['output'] }
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
