" Author: suoto <andre820@gmail.com>
" Description: Handling of window/* LSP methods, although right now only
" handles window/showMessage

" Constants for message type codes
let s:LSP_MESSAGE_TYPE_ERROR = 1
let s:LSP_MESSAGE_TYPE_WARNING = 2
let s:LSP_MESSAGE_TYPE_INFORMATION = 3
let s:LSP_MESSAGE_TYPE_LOG = 4

" User configurable format
let g:ale_lsp_show_message_format = '%severity%:%linter%: %s'

" 
function! s:echoError(text)
  call ale#util#Execute(
        \ 'redraw | echohl ErrorMsg | echomsg ''' . a:text . ''' | echohl None')
endfunction

function! s:echoWarning(text)
    call ale#util#Execute(
          \ 'redraw | echohl WarningMsg | echomsg ''' . a:text . ''' | echohl None')
endfunction

function! s:echoInfo(text)
    call ale#util#Execute('redraw | echomsg ''' . a:text . '''')
endfunction

function! s:formatMessage(linter_name, severity, text)
    let l:fmt_text = g:ale_lsp_show_message_format
    " Replace special markers with certain information.
    " \=l:variable is used to avoid escaping issues.
    let l:fmt_text = substitute(l:fmt_text, '\V%severity%', '\=a:severity', 'g')
    let l:fmt_text = substitute(l:fmt_text, '\V%linter%', '\=a:linter_name', 'g')
    " Replace %s with the text.
    let l:fmt_text = substitute(l:fmt_text, '\V%s', '\=a:text', 'g')
    return l:fmt_text
endfunction

function! ale#lsp#window#showMessage(linter_name, response) abort
    let l:message = a:response.params.message
    let l:type = a:response.params.type

    if l:type is# s:LSP_MESSAGE_TYPE_ERROR
      let l:text = s:formatMessage(a:linter_name, g:ale_echo_msg_error_str, l:message)
      call s:echoError(l:text)
    elseif l:type is# s:LSP_MESSAGE_TYPE_WARNING
      let l:text = s:formatMessage(a:linter_name, g:ale_echo_msg_warning_str, l:message)
      call s:echoWarning(l:text)
    else
      let l:text = s:formatMessage(a:linter_name, g:ale_echo_msg_info_str, l:message)
      if l:type is# s:LSP_MESSAGE_TYPE_INFORMATION
        call s:echoInfo(l:text)
      else
        call s:echoInfo(l:text)
      endif
    endif

endfunction
