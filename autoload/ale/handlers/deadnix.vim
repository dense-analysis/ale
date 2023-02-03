function! ale#handlers#deadnix#Handle(buffer, lines) abort
    let l:output = []

    for l:line in a:lines
        try
            let l:file = json_decode(l:line)
        catch
            continue
        endtry

        for l:error in l:file['results']
            call add(l:output, {
            \   'lnum': l:error['line'],
            \   'col': l:error['column'],
            \   'end_col': l:error['endColumn'],
            \   'text': l:error['message'],
            \   'type': 'W',
            \})
        endfor
    endfor

    return l:output
endfunction
