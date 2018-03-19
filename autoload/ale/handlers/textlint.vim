" Author: tokida https://rouger.info, Yasuhiro Kiyota <yasuhiroki.duck@gmail.com>
" Description: textlint, a proofreading tool (https://textlint.github.io/)

call ale#Set('textlint_executable', 'textlint')
call ale#Set('textlint_use_global', 0)
call ale#Set('textlint_options', '')

function! ale#handlers#textlint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'textlint', [
    \   'node_modules/.bin/textlint',
    \   'node_modules/textlint/bin/textlint.js',
    \])
endfunction

function! ale#handlers#textlint#GetCommand(buffer) abort
    let l:cmd_path = ale#path#FindNearestFile(a:buffer, '.textlintrc')
    let l:options = ale#Var(a:buffer, 'textlint_options')

    if !empty(l:cmd_path)
        return 'textlint'
        \    . ' -c '
        \    . l:cmd_path
        \    . (!empty(l:options) ? ' ' . l:options : '')
        \    . ' -f json %t'
    endif

    return 'textlint'
    \    . (!empty(l:options) ? ' ' . l:options : '')
    \    . ' -f json %t'
endfunction


function! ale#handlers#textlint#HandleTextlintOutput(buffer, lines) abort
    let l:res = get(ale#util#FuzzyJSONDecode(a:lines, []), 0, {'messages': []})
    let l:output = []

    for l:err in l:res.messages
        call add(l:output, {
        \   'text': l:err.message,
        \   'type': 'W',
        \   'code': l:err.ruleId,
        \   'lnum': l:err.line,
        \   'col' : l:err.column
        \})
    endfor

    return l:output
endfunction
