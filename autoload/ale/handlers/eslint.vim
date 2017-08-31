" Author: w0rp <devw0rp@gmail.com>
" Description: Functions for working with eslint, for checking or fixing files.

call ale#Set('javascript_eslint_options', '')
call ale#Set('javascript_eslint_executable', 'eslint')
call ale#Set('javascript_eslint_use_global', 0)
call ale#Set('javascript_eslint_suppress_eslintignore', 0)

function! ale#handlers#eslint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'javascript_eslint', [
    \   'node_modules/.bin/eslint_d',
    \   'node_modules/eslint/bin/eslint.js',
    \   'node_modules/.bin/eslint',
    \])
endfunction

function! ale#handlers#eslint#GetCommand(buffer) abort
    let l:executable = ale#handlers#eslint#GetExecutable(a:buffer)

    let l:options = ale#Var(a:buffer, 'javascript_eslint_options')

    return ale#node#Executable(a:buffer, l:executable)
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' -f unix --stdin --stdin-filename %s'
endfunction

let s:col_end_patterns = [
\   '\vParsing error: Unexpected token (.+) ',
\   '\v''(.+)'' is not defined.',
\   '\v%(Unexpected|Redundant use of) [''`](.+)[''`]',
\   '\vUnexpected (console) statement',
\]

function! s:AddHintsForTypeScriptParsingErrors(output) abort
    for l:item in a:output
        let l:item.text = substitute(
        \   l:item.text,
        \   '^\(Parsing error\)',
        \   '\1 (You may need configure typescript-eslint-parser)',
        \   '',
        \)
    endfor
endfunction

function! ale#handlers#eslint#Handle(buffer, lines) abort
    let l:config_error_pattern = '\v^ESLint couldn''t find a configuration file'
    \   . '|^Cannot read config file'
    \   . '|^.*Configuration for rule .* is invalid'
    \   . '|^ImportDeclaration should appear'

    " Look for a message in the first few lines which indicates that
    " a configuration file couldn't be found.
    for l:line in a:lines[:10]
        if len(matchlist(l:line, l:config_error_pattern)) > 0
            return [{
            \   'lnum': 1,
            \   'text': 'eslint configuration error (type :ALEDetail for more information)',
            \   'detail': join(a:lines, "\n"),
            \}]
        endif
    endfor

    " Matches patterns line the following:
    "
    " /path/to/some-filename.js:47:14: Missing trailing comma. [Warning/comma-dangle]
    " /path/to/some-filename.js:56:41: Missing semicolon. [Error/semi]
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\) \[\(.\+\)\]$'
    " This second pattern matches lines like the following:
    "
    " /path/to/some-filename.js:13:3: Parsing error: Unexpected token
    let l:parsing_pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, [l:pattern, l:parsing_pattern])
        let l:type = 'Error'
        let l:text = l:match[3]

        if ale#Var(a:buffer, 'javascript_eslint_suppress_eslintignore')
            if l:text is# 'File ignored because of a matching ignore pattern. Use "--no-ignore" to override.'
                continue
            endif
        endif

        " Take the error type from the output if available.
        if !empty(l:match[4])
            let l:type = split(l:match[4], '/')[0]
            let l:text .= ' [' . l:match[4] . ']'
        endif

        let l:obj = {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': l:type is# 'Warning' ? 'W' : 'E',
        \}

        for l:col_match in ale#util#GetMatches(l:text, s:col_end_patterns)
            let l:obj.end_col = l:obj.col + len(l:col_match[1]) - 1
        endfor

        call add(l:output, l:obj)
    endfor

    if expand('#' . a:buffer . ':t') =~? '\.tsx\?$'
        call s:AddHintsForTypeScriptParsingErrors(l:output)
    endif

    return l:output
endfunction
