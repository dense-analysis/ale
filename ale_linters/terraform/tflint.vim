" Author: Nat Williams <nat.williams@gmail.com>
" Description: tflint for Terraform files
"
" See: https://www.terraform.io/
"      https://github.com/wata727/tflint

let g:ale_terraform_tflint_options = get(g:, 'ale_terraform_tflint_options' ,'-f json')
let g:ale_terraform_tflint_executable = get(g:, 'ale_terraform_tflint_executable', 'tflint')

function! ale_linters#terraform#tflint#Handle(buffer, lines) abort
    let l:output = []

    for l:error in ale#util#FuzzyJSONDecode(a:lines, [])
        if l:error.type is# 'ERROR'
            let l:type = 'E'
        elseif l:error.type is# 'NOTICE'
            let l:type = 'I'
        else
            let l:type = 'W'
        endif

        call add(l:output, {
        \   'lnum': l:error.line,
        \   'text': l:error.message,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

function! ale_linters#terraform#tflint#GetCommand(buffer) abort
    return printf('%s %s %%t',
    \   ale#Var(a:buffer, 'terraform_tflint_executable'),
    \   escape(ale#Var(a:buffer, 'terraform_tflint_options'), '~')
    \)
endfunction

call ale#linter#Define('terraform', {
\   'name': 'tflint',
\   'executable': 'tflint',
\   'command_callback': 'ale_linters#terraform#tflint#GetCommand',
\   'callback': 'ale_linters#terraform#tflint#Handle',
\})
