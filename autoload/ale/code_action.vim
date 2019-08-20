" Author: Jerko Steiner <jerko.steiner@gmail.com>
" Description: Code action support for LSP / tsserver

function! ale#code_action#HandleCodeAction(code_action) abort
    let l:current_buffer = bufnr('')
    let l:changes = a:code_action.changes

    for l:file_code_edit in l:changes
        let l:buf = bufwinnr(l:file_code_edit.fileName)

        if l:buf != -1
            if l:buf != l:current_buffer && getbufvar(l:buf, '&mod')
                call ale#util#Execute('echom ''Aborting action, file is unsaved''')
                " Open buffer in question
                " execute 'buffer ' . l:buf
                return
            endif
        endif
    endfor

    for l:file_code_edit in l:changes
        call ale#code_action#ApplyChanges(
        \ l:file_code_edit.fileName, l:file_code_edit.textChanges)
    endfor
endfunction

function! ale#code_action#ApplyChanges(filename, changes) abort
    let l:current_buffer = bufnr('')
    " The buffer is used to determine the fileformat, if available.
    let l:buffer = bufnr(a:filename)
    let l:is_current_buffer = l:buffer > 0 && l:buffer == l:current_buffer

    if l:buffer > 0
        let l:lines = getbufline(l:buffer, 1, '$')
        if getbufvar(l:buffer, '&mod')
            write
        endif
    else
        let l:lines = readfile(a:filename, 'b')
    endif

    if l:is_current_buffer
        let l:pos = getpos('.')[1:2]
    else
        let l:pos = [1, 1]
    endif

    " We have to keep track of how many lines we have added, and offset
    " changes accordingly.
    let l:line_offset = 0
    let l:column_offset = 0
    let l:last_end_line = 0

    echom 'start ' . string(l:lines)
    for l:code_edit in a:changes
        if l:code_edit.start.line isnot l:last_end_line
            let l:column_offset = 0
        endif

        let l:line = l:code_edit.start.line + l:line_offset
        let l:column = l:code_edit.start.offset + l:column_offset
        let l:end_line = l:code_edit.end.line + l:line_offset
        let l:end_column = l:code_edit.end.offset + l:column_offset
        let l:text = l:code_edit.newText

        let l:cur_line = l:pos[0]
        let l:cur_column = l:pos[1]

        let l:last_end_line = l:end_line

        " Adjust the ends according to previous edits.
        if l:end_line > len(l:lines)
            let l:end_line_len = 0
        else
            let l:end_line_len = len(l:lines[l:end_line - 1])
        endif

        let l:insertions = split(l:text, '\n', 1)

        if l:line is 1
            " Same logic as for column below. Vimscript's slice [:-1] will not
            " be an empty list.
            let l:start = []
        else
            let l:start = l:lines[: l:line - 2]
        endif

        if l:column is 1
            " We need to handle column 1 specially, because we can't slice an
            " empty string ending on index 0.
            let l:middle = [l:insertions[0]]
        else
            let l:middle = [l:lines[l:line - 1][: l:column - 2] . l:insertions[0]]
        endif

        call extend(l:middle, l:insertions[1:])
        let l:middle[-1] .= l:lines[l:end_line - 1][l:end_column - 1 :]

        echom 'middle ' . string(l:middle)

        let l:lines_before_change = len(l:lines)

        let l:lines = l:start + l:middle + l:lines[l:end_line :]

        echom 'change ' . string(l:lines)

        let l:line_offset += len(l:lines) - l:lines_before_change

        " echom 'lines after ' . string(l:lines)
        echom 'l:line ' . l:line
        echom 'l:line_offset ' . l:line_offset
        " echom 'index ' . (l:line + l:line_offset)
        let l:column_offset = len(l:middle[-1]) - l:end_line_len
        echom 'line offset ' . l:line_offset .   '  col offset ' . l:column_offset

        if l:end_line < l:cur_line
            " both start and end lines are before the cursor. only line offset
            " needs to be updated
            let l:cur_line += l:line_offset
        elseif l:end_line == l:cur_line
            " end line is at the same location as cursor
            if l:column <= l:cur_column
                " updates are happening either before or around the cursor
                if l:end_column < l:cur_column
                    " updates are happening before the cursor, update the
                    " column offset for cursor
                    let l:cur_column += l:column_offset
                else
                    " updates are happening around the cursor, move the cursor
                    " to the end of the changes
                    let l:cur_column = l:end_column + l:column_offset
                endif
            " else is not necessary, it means modifications are happening
            " after the cursor so no updates need to be done
            endif
        else
            " end line is behind the cursor
            if l:line <= l:cur_line
                " changes are happening around the cursor, move the cursor
                " to the end of the changes
                let l:cur_line = l:end_line + l:line_offset
                let l:cur_offset = l:end_column + l:column_offset
            " else is not necesary, it means modifications are happening
            " after the cursor so no updates need to be done
            endif
        endif

        echom 'l:pos pre  ' . string(l:pos)
        let l:pos = [l:cur_line, l:cur_column]
        echom 'l:pos post ' . string(l:pos)
    endfor

    if l:lines[-1] is# ''
        call remove(l:lines, -1)
    endif

    call ale#util#Writefile(l:buffer, l:lines, a:filename)

    if l:buffer > 0
        call ale#util#Execute(':e!')
    endif

    if l:is_current_buffer
        call setpos('.', [0, l:pos[0], l:pos[1], 0])
    endif
endfunction
