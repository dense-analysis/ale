" Author: suoto <andre820@gmail.com>
" Description: Handling of window/* LSP methods, although right now only
" handles window/showMessage

" Constants for message type codes
let s:LSP_MESSAGE_TYPE_ERROR = 1
let s:LSP_MESSAGE_TYPE_WARNING = 2
let s:LSP_MESSAGE_TYPE_INFORMATION = 3
let s:LSP_MESSAGE_TYPE_LOG = 4

" Translate strings from the user config to a number so we can check
" severities
let s:CFG_TO_LSP_SEVERITY = {
\   'error': s:LSP_MESSAGE_TYPE_ERROR,
\   'warning': s:LSP_MESSAGE_TYPE_WARNING,
\   'information': s:LSP_MESSAGE_TYPE_INFORMATION,
\   'log': s:LSP_MESSAGE_TYPE_LOG
\}

" This formats string 'a:format' by replacing a:args keys by their respective
" values
" - format: base format, where keys are surrounded by '%' (e.g, %linter%)
" - args: dict defining values for each key inside format. Don't add extra '%'
"   to the keys, they'll be added automatically when replacing
function! ale#lsp#window#formatString(format, args) abort
    let l:string = a:format

    for [l:key, l:value] in items(a:args)
        let l:string = substitute(l:string, '\V' . l:key, '\=l:value', 'g')
    endfor

    return l:string
endfunction

" Handle window/showMessage response.
" - details: dict containing linter name and format (g:ale_lsp_show_message_format)
" - params: dict with the params for the call in the form of {type: number, message: string}
function! ale#lsp#window#HandleShowMessage(linter_name, format, params) abort
    let l:message = a:params.message
    let l:type = a:params.type

    " Discard log severity for now
    if l:type is# s:LSP_MESSAGE_TYPE_LOG
        return
    endif

    " Get the configured severity level threshold and check if the message
    " should be displayed or not
    let l:cfg_severity_threshold = s:CFG_TO_LSP_SEVERITY[tolower(get(g:, 'ale_lsp_show_message_severity', 'error'))]

    if l:type > l:cfg_severity_threshold
        return
    endif

    " Common formatting arguments
    let l:format_args = {'%linter%': a:linter_name, '%s': l:message}

    " Severity will depend on the message type
    if l:type is# s:LSP_MESSAGE_TYPE_ERROR
        let l:format_args['%severity%'] = g:ale_echo_msg_error_str
    elseif l:type is# s:LSP_MESSAGE_TYPE_WARNING
        let l:format_args['%severity%'] = g:ale_echo_msg_warning_str
    elseif l:type is# s:LSP_MESSAGE_TYPE_INFORMATION
        let l:format_args['%severity%'] = g:ale_echo_msg_info_str
    endif

    call ale#util#ShowMessage(ale#lsp#window#formatString(a:format, l:format_args))
endfunction
