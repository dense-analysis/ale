if exists('g:loaded_ale_cursor')
    finish
endif

let g:loaded_ale_cursor = 1

" This function will perform a binary search to find a message from the
" loclist to echo when the cursor moves.
function! s:BinarySearch(loclist, line, column)
    let min = 0
    let max = len(a:loclist) - 1
    let last_column_match = -1

    while 1
        if max < min
            return last_column_match
        endif

        let mid = (min + max) / 2
        let obj = a:loclist[mid]

        " Binary search to get on the same line
        if a:loclist[mid]['lnum'] < a:line
            let min = mid + 1
        elseif a:loclist[mid]['lnum'] > a:line
            let max = mid - 1
        else
            let last_column_match = mid

            " Binary search to get the same column, or near it
            if a:loclist[mid]['col'] < a:column
                let min = mid + 1
            elseif a:loclist[mid]['col'] > a:column
                let max = mid - 1
            else
                return mid
            endif
        endif
    endwhile
endfunction

function! ale#cursor#TruncatedEcho(message)
    let message = a:message
    " Change tabs to spaces.
    let message = substitute(message, "\t", ' ', 'g')
    " Remove any newlines in the message.
    let message = substitute(message, "\n", '', 'g')

    let truncated_message = join(split(message, '\zs')[:&columns - 2], '')

    " Echo the message truncated to fit without creating a prompt.
    echo truncated_message
endfunction

function! ale#cursor#EchoCursorWarning()
    let buffer = bufnr('%')

    if !has_key(g:ale_buffer_loclist_map, buffer)
        return
    endif

    let loclist = g:ale_buffer_loclist_map[buffer]

    let pos = getcurpos()

    let index = s:BinarySearch(loclist, pos[1], pos[2])

    if index >= 0
        call ale#cursor#TruncatedEcho(loclist[index]['text'])
    else
        echo
    endif
endfunction

if g:ale_echo_cursor
    augroup ALECursorGroup
        autocmd!
        autocmd CursorMoved * call ale#cursor#EchoCursorWarning()
    augroup END
endif
