" Author: @jpsouzasilva (joao.paulo.silvasouza@hotmail.com)
" Description: Integration of the JS-Beautify library for HTML and Vue files.

let s:KnownTemplateDelimiters = {
\    'html':       {
\                    'opening': '<html>',
\                    'closing': '</html>',
\                    'line_offset': 0
\                  },
\    'vue':        {
\                    'opening': '<template>',
\                    'closing': '</template>',
\                    'line_offset': 0
\                  },
\    'javascript': {
\                    'regex_starting_chain': ['render(.*)\(\)', 'return\(.*\)('],
\                    'regex_closing_chain': ['\s\+)'],
\                    'opening_line_offset': 1,
\                    'closing_line_offset': -1,
\                  }
\}

call ale#Set('beautify_template_executable', 'html-beautify')
call ale#Set('beautify_template_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('beautify_template_options', ' --type html -S keep ')
call ale#Set('beautify_template_delimiters', s:KnownTemplateDelimiters)

function! ale#fixers#beautify_template#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'beautify_template', [
    \   'node_modules/.bin/html-beautify',
    \   'node_modules/js-beautify/js/bin/html-beautify.js',
    \])
endfunction

function! s:TemplateLineRangeDelimiter(buffer, ...) abort
    let l:options = get(a:000, 0, {})
    let l:buffer_lines = get(l:options, 'buffer_lines', getline(a:buffer, '$'))

    let l:template_delimiters = ale#Var(a:buffer, 'beautify_template_delimiters')
    let l:buffer_line_count = len(l:buffer_lines) - 1
    let l:starting_line = 0
    let l:ending_line = 0

    for key in keys(l:template_delimiters)
        if &filetype == key
            let l:extracting_opts = l:template_delimiters[key]
            let l:indent_size = 0

            if len(get(l:extracting_opts, 'regex_starting_chain', []))
                let l:regex_starting_chain = l:extracting_opts['regex_starting_chain']
                let l:regex_closing_chain = l:extracting_opts['regex_closing_chain']
                let l:regex_starting_chain_length = len(l:regex_starting_chain)
                let l:regex_closing_chain_length = len(l:regex_closing_chain)
                let l:regex_starting_chain_index = 0
                let l:regex_closing_chain_index = 0

                for l:line_number in range(0, l:buffer_line_count, 1)
                    if l:regex_starting_chain_index < l:regex_starting_chain_length
                  \ && l:buffer_lines[l:line_number] =~ l:regex_starting_chain[l:regex_starting_chain_index]
                        let l:regex_starting_chain_index += 1
                        let l:starting_line = l:line_number
                        let l:indent_size = match(l:buffer_lines[l:line_number], '\S') + &shiftwidth
                    endif

                    if l:buffer_lines[l:line_number] =~ l:regex_closing_chain[l:regex_closing_chain_index]
                        let l:ending_line = l:line_number
                        let l:regex_closing_chain_index += 1
                    endif

                    if l:regex_starting_chain_index == l:regex_starting_chain_length
                  \ && l:regex_closing_chain_index == l:regex_closing_chain_length
                        let l:ending_line += l:extracting_opts['closing_line_offset']
                        let l:starting_line += l:extracting_opts['opening_line_offset']
                        let l:output = l:buffer_lines[l:starting_line : l:ending_line]

                        return {
                              \ 'starting_line': l:starting_line,
                              \ 'ending_line': l:ending_line,
                              \ 'output': l:output,
                              \ 'indent_size': l:indent_size
                              \}
                    endif
                endfor
            else
                let l:tags_found = 0
                let l:opening_tag = l:extracting_opts['opening']
                let l:closing_tag = l:extracting_opts['closing']

                for l:line_number in range(0, l:buffer_line_count, 1)
                    if l:buffer_lines[l:line_number] == l:opening_tag
                        let l:starting_line = l:line_number
                        let l:tags_found += 1
                    endif

                    if l:buffer_lines[l:line_number] == l:closing_tag
                        let l:ending_line = l:line_number
                        let l:tags_found += 1
                    endif

                    if l:tags_found == 2
                        return {
                              \ 'starting_line': l:starting_line,
                              \ 'ending_line': l:ending_line,
                              \ 'output': l:buffer_lines[l:starting_line : l:ending_line],
                              \ 'indent_size': l:indent_size
                              \}
                    endif
                endfor
            endif
        endif
    endfor

    return {'starting_line': l:starting_line,
          \ 'ending_line': l:buffer_line_count,
          \ 'output': l:buffer_lines[l:starting_line : l:buffer_line_count]
          \ 'indent_size': l:indent_size
          \ }
endfunction

function! s:PadOutput(output, indent_size) abort
    if !a:indent_size
        return output
    endif

    let l:tab_size = !&expandtab ? (&softtabstop || &tabstop) : 0
    let l:indent_size = a:indent_size
    let l:indent_string = ""
    let l:padded_output = []

    if l:tab_size
        let l:indent_size = l:indent_size/l:tab_size

        for i in range(1, l:indent_size, 1)
            let l:indent_string .= "\x9"
        endfor
    else
        for i in range(1, l:indent_size, 1)
            let l:indent_string .= " "
        endfor
    endif

    for line in a:output
        call add(l:padded_output, l:indent_string . line)
    endfor

    return l:padded_output
endfunction

function! ale#fixers#beautify_template#ProcessTemplateOutput(buffer, output) abort
    let l:buffer_lines = getline(a:buffer, '$')
    let l:extracted = s:TemplateLineRangeDelimiter(a:buffer)
    let l:first_line = l:extracted['starting_line']
    let l:last_line = l:extracted['ending_line']
    let l:output = a:output

    if l:extracted['indent_size']
        let l:output = s:PadOutput(a:output, l:extracted['indent_size'])
    endif

    " Glue the beautified part back together in the middle.
    " Out-of-bounds positive indexes just yields an empty array so no worries.
    return (l:first_line == 0 ? [] : l:buffer_lines[:l:first_line - 1])
    \      + l:output
    \      + l:buffer_lines[l:last_line + 1:]
endfunction

function! ale#fixers#beautify_template#ExtractTemplateTag(options) abort
    let l:extracted = s:TemplateLineRangeDelimiter(
                    \   a:options['buffer'],
                    \   { 'buffer_lines': a:options['input'] }
                    \ )

    return { 'input': l:extracted['output'] }
endfunction

function! ale#fixers#beautify_template#Fix(buffer) abort
    let l:config_path = ale#path#FindNearestFile(a:buffer, '.jsbeautifyrc')

    " Usage at https://github.com/beautify-web/js-beautify/blob/master/js/src/cli.js#L323
    return {
    \   'command': ale#fixers#beautify_template#GetExecutable(a:buffer)
    \       . (l:config_path ? (" --config " . l:config_path) : "")
    \       . ale#Var(a:buffer, 'beautify_template_options'),
    \   'process_with': 'ale#fixers#beautify_template#ProcessTemplateOutput'
    \}
endfunction
