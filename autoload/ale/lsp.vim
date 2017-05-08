" Author: w0rp <devw0rp@gmail.com>
" Description: Language Server Protocol client code

let s:address_info_map = {}
let g:ale_lsp_next_message_id = 1

function! ale#lsp#GetNextMessageID() abort
    " Use the current ID
    let l:id = g:ale_lsp_next_message_id

    " Increment the ID variable.
    let g:ale_lsp_next_message_id += 1

    " When the ID overflows, reset it to 1. By the time we hit the initial ID
    " again, the messages will be long gone.
    if g:ale_lsp_next_message_id < 1
        let g:ale_lsp_next_message_id = 1
    endif

    return l:id
endfunction

" Given a List of one or two items, [method_name] or [method_name, params],
" return a List containing [message_id, message_data]
function! ale#lsp#CreateMessageData(message) abort
    let l:is_notification = a:message[0]

    let l:obj = {
    \   'id': v:null,
    \   'jsonrpc': '2.0',
    \   'method': a:message[1],
    \}

    if !l:is_notification
        let l:obj.id = ale#lsp#GetNextMessageID()
    endif

    if len(a:message) > 2
        let l:obj.params = a:message[2]
    endif

    let l:body = json_encode(l:obj)
    let l:data = 'Content-Length: ' . strlen(l:body) . "\r\n\r\n" . l:body

    return [l:is_notification ? 0 : l:obj.id, l:data]
endfunction

function! ale#lsp#ReadMessageData(data) abort
    let l:response_list = []
    let l:remainder = a:data

    while 1
        " Look for the end of the HTTP headers
        let l:body_start_index = matchend(l:remainder, "\r\n\r\n")

        if l:body_start_index < 0
            " No header end was found yet.
            break
        endif

        " Parse the Content-Length header.
        let l:header_data = l:remainder[:l:body_start_index - 4]
        let l:length_match = matchlist(
        \   l:header_data,
        \   '\vContent-Length: *(\d+)'
        \)

        if empty(l:length_match)
            throw "Invalid JSON-RPC header:\n" . l:header_data
        endif

        " Split the body and the remainder of the text.
        let l:remainder_start_index = l:body_start_index + str2nr(l:length_match[1])

        if len(l:remainder) < l:remainder_start_index
            " We don't have enough data yet.
            break
        endif

        let l:body = l:remainder[l:body_start_index : l:remainder_start_index - 1]
        let l:remainder = l:remainder[l:remainder_start_index :]

        " Parse the JSON object and add it to the list.
        call add(l:response_list, json_decode(l:body))
    endwhile

    return [l:remainder, l:response_list]
endfunction

function! s:HandleMessage(channel, message) abort
    let l:channel_info = ch_info(a:channel)
    let l:address = l:channel_info.hostname . ':' . l:channel_info.port
    let l:info = s:address_info_map[l:address]
    let l:info.data .= a:message

    " Parse the objects now if we can, and keep the remaining text.
    let [l:info.data, l:response_list] = ale#lsp#ReadMessageData(l:info.data)

    " Call our callbacks.
    for l:response in l:response_list
        let l:callback = l:info.callback_map.pop(l:response.id)
        call ale#util#GetFunction(l:callback)(l:response)
    endfor
endfunction

" Send a message to the server.
" A callback can be registered to handle the response.
" Notifications do not need to be handled.
" (address, message, callback?)
function! ale#lsp#SendMessage(address, message, ...) abort
    if a:0 > 1
        throw 'Too many arguments!'
    endif

    if !a:message[0] && a:0 == 0
        throw 'A callback must be set for messages which are not notifications!'
    endif

    let [l:id, l:data] = ale#lsp#CreateMessageData(a:message)

    let l:info = get(s:address_info_map, a:address, {})

    if empty(l:info)
        let l:info = {
        \   'data': '',
        \   'callback_map': {},
        \}
        let s:address_info_map[a:address] = l:info
    endif

    " The ID is 0 when the message is a Notification, which is a JSON-RPC
    " request for which the server must not return a response.
    if l:id != 0
        " Add the callback, which the server will respond to later.
        let l:info.callback_map[l:id] = a:1
    endif

    if !has_key(l:info, 'channel') || ch_status(l:info.channel) !=# 'open'
        let l:info.channnel = ch_open(a:address, {
        \   'mode': 'raw',
        \   'waittime': 0,
        \   'callback': 's:HandleMessage',
        \})
    endif

    if ch_status(l:info.channnel) ==# 'fail'
        throw 'Failed to open channel for: ' . a:address
    endif

    " Send the message to the server
    call ch_sendraw(l:info.channel, l:data)
endfunction
