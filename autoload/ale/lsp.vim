" Author: w0rp <devw0rp@gmail.com>
" Description: Language Server Protocol client code

" A List of connections, used for tracking servers which have been connected
" to, and programs which are run.
let s:connections = []
let g:ale_lsp_next_message_id = 1

function! s:NewConnection() abort
    " id: The job ID as a Number, or the server address as a string.
    " data: The message data received so far.
    " executable: An executable only set for program connections.
    " open_documents: A list of buffers we told the server we opened.
    let l:conn = {
    \   'id': '',
    \   'data': '',
    \   'open_documents': [],
    \}

    call add(s:connections, l:conn)

    return l:conn
endfunction

function! s:FindConnection(key, value) abort
    for l:conn in s:connections
        if has_key(l:conn, a:key) && get(l:conn, a:key) == a:value
            return l:conn
        endif
    endfor

    return {}
endfunction

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

" TypeScript messages use a different format.
function! s:CreateTSServerMessageData(message) abort
    let l:is_notification = a:message[0]

    let l:obj = {
    \   'seq': v:null,
    \   'type': 'request',
    \   'command': a:message[1][3:],
    \}

    if !l:is_notification
        let l:obj.seq = ale#lsp#GetNextMessageID()
    endif

    if len(a:message) > 2
        let l:obj.arguments = a:message[2]
    endif

    let l:data = json_encode(l:obj) . "\n"
    return [l:is_notification ? 0 : l:obj.seq, l:data]
endfunction

" Given a List of one or two items, [method_name] or [method_name, params],
" return a List containing [message_id, message_data]
function! ale#lsp#CreateMessageData(message) abort
    if a:message[1] =~# '^ts@'
        return s:CreateTSServerMessageData(a:message)
    endif

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

function! ale#lsp#HandleMessage(conn, message) abort
    let a:conn.data .= a:message

    " Parse the objects now if we can, and keep the remaining text.
    let [a:conn.data, l:response_list] = ale#lsp#ReadMessageData(a:conn.data)

    " Call our callbacks.
    for l:response in l:response_list
        if has_key(a:conn, 'callback')
            call ale#util#GetFunction(a:conn.callback)(l:response)
        endif
    endfor
endfunction

function! s:HandleChannelMessage(channel, message) abort
    let l:info = ch_info(a:channel)
    let l:address = l:info.hostname . l:info.address
    let l:conn = s:FindConnection('id', l:address)

    call ale#lsp#HandleMessage(l:conn, a:message)
endfunction

function! s:HandleCommandMessage(job_id, message) abort
    let l:conn = s:FindConnection('id', a:job_id)

    call ale#lsp#HandleMessage(l:conn, a:message)
endfunction

" Start a program for LSP servers which run with executables.
"
" The job ID will be returned for for the program if it ran, otherwise
" 0 will be returned.
function! ale#lsp#StartProgram(executable, command, callback) abort
    if !executable(a:executable)
        return 0
    endif

    let l:conn = s:FindConnection('executable', a:executable)

    " Get the current connection or a new one.
    let l:conn = !empty(l:conn) ? l:conn : s:NewConnection()
    let l:conn.executable = a:executable

    if !has_key(l:conn, 'id') || !ale#job#IsRunning(l:conn.id)
        let l:options = {
        \   'mode': 'raw',
        \   'out_cb': function('s:HandleCommandMessage'),
        \}
        let l:job_id = ale#job#Start(a:command, l:options)
    else
        let l:job_id = l:conn.id
    endif

    if l:job_id <= 0
        return 0
    endif

    let l:conn.id = l:job_id
    let l:conn.callback = a:callback

    return l:job_id
endfunction

" Connect to an address and set up a callback for handling responses.
function! ale#lsp#ConnectToAddress(address, callback) abort
    let l:conn = s:FindConnection('id', a:address)
    " Get the current connection or a new one.
    let l:conn = !empty(l:conn) ? l:conn : s:NewConnection()

    if !has_key(l:conn, 'channel') || ch_status(l:conn.channel) !=# 'open'
        let l:conn.channnel = ch_open(a:address, {
        \   'mode': 'raw',
        \   'waittime': 0,
        \   'callback': function('s:HandleChannelMessage'),
        \})
    endif

    if ch_status(l:conn.channnel) ==# 'fail'
        return 0
    endif

    let l:conn.id = a:address
    let l:conn.callback = a:callback

    return 1
endfunction

" Send a message to an LSP server.
" Notifications do not need to be handled.
"
" Returns -1 when a message is sent, but no response is expected
"          0 when the message is not sent and
"          >= 1 with the message ID when a response is expected.
function! ale#lsp#Send(conn_id, message) abort
    let l:conn = s:FindConnection('id', a:conn_id)
    let [l:id, l:data] = ale#lsp#CreateMessageData(a:message)

    if has_key(l:conn, 'executable')
        call ale#job#SendRaw(l:conn.id, l:data)
    elseif has_key(l:conn, 'channel') && ch_status(l:conn.channnel) ==# 'open'
        " Send the message to the server
        call ch_sendraw(l:conn.channel, l:data)
    else
        return 0
    endif

    return l:id == 0 ? -1 : l:id
endfunction

function! ale#lsp#OpenTSServerDocumentIfNeeded(conn_id, buffer) abort
    let l:conn = s:FindConnection('id', a:conn_id)
    let l:opened = 0

    if !empty(l:conn) && index(l:conn.open_documents, a:buffer) < 0
        call ale#lsp#Send(a:conn_id, ale#lsp#tsserver_message#Open(a:buffer))
        call add(l:conn.open_documents, a:buffer)
        let l:opened = 1
    endif

    return l:opened
endfunction
