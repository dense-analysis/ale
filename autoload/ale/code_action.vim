" This method exists to make mocking in tests easier
function! ale#code_action#IsModified(buffer) abort
    return getbufvar(a:buffer, '&mod')
endfunction

function! ale#code_action#HandleCodeAction(code_action) abort
    let l:current_buffer = bufnr('')
    let l:existing_buffers = {}
    let l:changes = a:code_action.changes

    for l:file_code_edit in l:changes
        let l:buf = ale#util#GetBufferNumber(l:file_code_edit.fileName)

        if l:buf != -1
            let l:existing_buffers[l:buf] = 1

            if l:buf != l:current_buffer && ale#code_action#IsModified(l:buf)
                call ale#util#Execute('echom ''Aborting action, file is unsaved''')
                " Open buffer in question
                call ale#util#Execute('buffer ' .  l:buf)

                return
            endif
        endif
    endfor

    for l:file_code_edit in l:changes
        let l:buf = ale#util#GetBufferNumber(l:file_code_edit.fileName)

        if l:buf != -1
            call ale#util#Execute('buffer ' . l:buf)
        else
            call ale#util#Execute('edit ' .  l:file_code_edit.fileName)
            let l:buf = ale#util#GetBufferNumber(l:file_code_edit.fileName)
        endif

        let l:initial_pos = getpos('.')
        let l:line_diff = 0

        for l:code_edit in reverse(copy(l:file_code_edit.textChanges))
            let l:start = l:code_edit.start
            let l:end = l:code_edit.end
            let l:new_text = substitute(l:code_edit.newText, '\n', "\<CR>", 'g')

            " move visual selection to the top line if it is selecting the
            " first character in the next line. this is because VIM will
            " delete that first character.
            if l:end.line > l:start.line && l:end.offset == 1
                let l:end.line -= 1
                let l:end.offset = len(getline(l:end.line)) + 3
            endif

            if l:start.line == l:end.line && l:start.offset == l:end.offset
                call ale#util#Cursor(l:start.line, l:end.offset)
                call ale#util#Execute('normal! i' . l:new_text)
            else
                " set last visual mode to characterwise-visual
                call ale#util#Execute("normal! v\<Esc>")
                call ale#util#SetPos("'<", [l:buf, l:start.line, l:start.offset, 0])
                call ale#util#SetPos("'>", [l:buf, l:end.line, l:end.offset - 1, 0])
                call ale#util#Execute('normal! gvc' . l:new_text)
            endif

            let l:line_after = getpos('.')[1]
            let l:line_diff += l:line_after - l:end.line
        endfor

        call cursor(l:initial_pos[1] + l:line_diff, l:initial_pos[2])

        call ale#util#Execute('write')

        if !has_key(l:existing_buffers, l:buf)
            call ale#util#Execute('bd ' . l:buf)
        endif
    endfor

    call ale#util#Execute('buffer ' . l:current_buffer)
endfunction
