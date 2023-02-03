function! ale#handlers#deadnix#Handle(buffer, lines) abort
    let l:output = []

    for l:line in a:lines
        try
            let l:results = json_decode(l:line)['results']
        catch
            continue
        endtry

        for l:error in l:results
            try
                let l:ale_error = {
                \   'lnum': l:error['line'],
                \   'col': l:error['column'],
                \   'end_col': l:error['endColumn'],
                \   'text': l:error['message'],
                \   'type': 'W',
                \}
            catch
                continue
            endtry

            call add(l:output, l:ale_error)
        endfor
    endfor

    return l:output
endfunction
