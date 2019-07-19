" Author: suoto <andre820@gmail.com>
" Description: Handling of window LSP methods 

" Constants for message type codes
let s:LSP_MESSAGE_TYPE_ERROR = 1
let s:LSP_MESSAGE_TYPE_WARNING = 2
let s:LSP_MESSAGE_TYPE_INFORMATION = 3
let s:LSP_MESSAGE_TYPE_LOG = 4

function! s:showLSPErrorMessage(linter_name, message)
    let l:text = '[' . g:ale_echo_msg_error_str . '@' . a:linter_name . '] ' . a:message
    redraw | echohl ErrorMsg | echom l:text | echohl None
endfunction

function! s:showLSPWarningMessage(linter_name, message)
    let l:text = '[' . g:ale_echo_msg_warning_str . '@' . a:linter_name . '] ' . a:message
    redraw | echohl WarningMsg | echom l:text | echohl None
endfunction

function! s:showLSPInfoMessage(linter_name, message)
    let l:text = '[' . g:ale_echo_msg_info_str . '@' . a:linter_name . '] ' . a:message
    redraw | echom l:text
endfunction

function! ale#lsp#window#showMessage(linter_name, response) abort
    let l:message = a:response.params.message
    let l:type = a:response.params.type

    let l:warning = 2
    let l:info = 3
    let l:log = 4

    if l:type is# s:LSP_MESSAGE_TYPE_ERROR
        call s:showLSPErrorMessage(a:linter_name, l:message)
    elseif l:type is# s:LSP_MESSAGE_TYPE_WARNING
        call s:showLSPWarningMessage(a:linter_name, l:message)
    else
        " 'info' and 'log' will be shown as info
        call s:showLSPInfoMessage(a:linter_name, l:message)
    endif

endfunction


