function! ale#code_action#HandleCodeAction(code_action) abort
    let l:current_buffer = bufnr('')
    let l:existing_buffers = {}
    let l:changes = a:code_action.changes

    for l:file_code_edit in l:changes
        let l:buf = bufwinnr(l:file_code_edit.fileName)
        if l:buf != -1
            let l:existing_buffers[l:buf] = 1
            if l:buf != l:current_buffer && getbufvar(l:buf, '&mod')
                call ale#util#Execute('echom ''Aborting action, file is modified''')
                " Open buffer in question
                execute 'buffer' l:buf
                return
            endif
        endif
    endfor

    for l:file_code_edit in l:changes
        let l:buf = bufwinnr(l:file_code_edit.fileName)
        if l:buf != -1
            execute 'buffer' l:buf
        else
            execute 'edit' l:file_code_edit.fileName
            let l:buf = bufnr('')
        endif
        let l:initial_pos = getpos('.')
        let l:line_diff = 0

        for l:code_edit in reverse(l:file_code_edit.textChanges)
            let l:start = l:code_edit.start
            let l:end = l:code_edit.end
            let l:new_text = l:code_edit.newText
            if l:start.line == l:end.line && l:start.offset == l:end.offset
                call cursor(l:start.line, l:end.offset)
                execute 'normal! i' . l:new_text
            else
                " set last visual mode to characterwise-visual
                execute 'normal! v'
                call setpos("'<", [l:buf, l:start.line, l:start.offset, 0])
                call setpos("'>", [l:buf, l:end.line, l:end.offset - 1, 0])
                execute 'normal! gvc' . l:new_text
            endif
            let l:line_after = getpos('.')[1]
            let l:line_diff += l:line_after - l:end.line
        endfor

        call cursor(l:initial_pos[1] + l:line_diff, l:initial_pos[2])

        write
        if !has_key(l:existing_buffers, l:buf)
            execute 'bd' l:buf
        endif
    endfor

    execute 'buffer' l:current_buffer
endfunction
