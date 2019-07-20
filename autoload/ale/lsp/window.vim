" Author: suoto <andre820@gmail.com>
" Description: Handling of window/* LSP methods, although right now only
" handles window/showMessage

" Constants for message type codes
let s:LSP_MESSAGE_TYPE_ERROR = 1
let s:LSP_MESSAGE_TYPE_WARNING = 2
let s:LSP_MESSAGE_TYPE_INFORMATION = 3
let s:LSP_MESSAGE_TYPE_LOG = 4

function! s:echoError(text) abort
    call ale#util#Execute(
    \ 'redraw | echohl ErrorMsg | echomsg ''' . a:text . ''' | echohl None')
endfunction

function! s:echoWarning(text) abort
    call ale#util#Execute(
    \ 'redraw | echohl WarningMsg | echomsg ''' . a:text . ''' | echohl None')
endfunction

function! s:echoInfo(text) abort
    call ale#util#Execute('redraw | echomsg ''' . a:text . '''')
endfunction

function! s:isKeyValid(key) abort
    return matchstr(a:key, '[a-zA-Z][a-zA-Z0-9_]*') is# a:key
endfunction

" This formats string 'a:format' by replacing a:args keys by their respective
" values
" - format: base format, where keys are surrounded by '%' (e.g, %linter%)
" - args: dict defining values for each key inside format. Don't add extra '%'
"   to the keys, they'll be added automatically when replacing
function! ale#lsp#window#formatString(format, args) abort
    let l:string = a:format

    for [l:key, l:value] in items(a:args)
        if ! s:isKeyValid(l:key)
            throw 'Invalid argument ''' . l:key . '''. Arguments must follow ' .
            \ 'pattern [a-zA-Z][a-zA-Z0-9_]*'
        endif

        let l:string = substitute(l:string, '\V%' . l:key . '%', '\=l:value', 'g')
    endfor

    return l:string
endfunction

" Handle window/showMessage response.
" - details: dict containing linter name and format (g:ale_lsp_show_message_format)
" - params: dict with the params for the call in the form of {type: number, message: string}
function! ale#lsp#window#showMessage(linter_name, format, params) abort
    let l:message = a:params.message
    let l:type = a:params.type

    if l:type is# s:LSP_MESSAGE_TYPE_LOG
        " Discard log severity for now
        return
    endif

    " Common formatting arguments
    let l:format_args = {'linter': a:linter_name, 'text': l:message}

    " Severity will depend on the message type
    if l:type is# s:LSP_MESSAGE_TYPE_ERROR
        let l:format_args['severity'] = g:ale_echo_msg_error_str
        let l:Handler = funcref('s:echoError')
    elseif l:type is# s:LSP_MESSAGE_TYPE_WARNING
        let l:format_args['severity'] = g:ale_echo_msg_warning_str
        let l:Handler = funcref('s:echoWarning')
    elseif l:type is# s:LSP_MESSAGE_TYPE_INFORMATION
        let l:format_args['severity'] = g:ale_echo_msg_info_str
        let l:Handler = funcref('s:echoInfo')
    endif

    call l:Handler(ale#lsp#window#formatString(a:format, l:format_args))
endfunction
