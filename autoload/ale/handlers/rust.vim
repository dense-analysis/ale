" Author: Daniel Schemala <istjanichtzufassen@gmail.com>,
"   w0rp <devw0rp@gmail.com>
"
" Description: This file implements handlers specific to Rust.

if !exists('g:ale_rust_ignore_error_codes')
    let g:ale_rust_ignore_error_codes = []
endif

" returns: a list [lnum, col] with the location of the error or []
function! s:FindErrorInExpansion(span, file_name) abort
    if a:span.file_name ==# a:file_name
        return [a:span.line_start, a:span.line_end, a:span.byte_start, a:span.byte_end]
    endif

    if !empty(a:span.expansion)
        return s:FindErrorInExpansion(a:span.expansion.span, a:file_name)
    endif

    return []
endfunction

" A handler function which accepts a file name, to make unit testing easier.
function! ale#handlers#rust#HandleRustErrorsForFile(buffer, full_filename, lines) abort
    let l:filename = fnamemodify(a:full_filename, ':t')
    let l:output = []

    for l:errorline in a:lines
        " ignore everything that is not Json
        if l:errorline !~# '^{'
            continue
        endif

        let l:error = json_decode(l:errorline)

        if has_key(l:error, 'message') && type(l:error.message) == type({})
            let l:error = l:error.message
        endif

        if !has_key(l:error, 'code')
            continue
        endif

        if !empty(l:error.code) && index(g:ale_rust_ignore_error_codes, l:error.code.code) > -1
            continue
        endif

        for l:span in l:error.spans
            if (
            \   l:span.is_primary
            \   && (a:full_filename =~ (l:span.file_name . '$') || l:span.file_name ==# '<anon>')
            \)
                call add(l:output, {
                \   'lnum': l:span.line_start,
                \   'end_lnum': l:span.line_end,
                \   'col': l:span.byte_start,
                \   'end_col': l:span.byte_end,
                \   'text': empty(l:span.label) ? l:error.message : printf('%s: %s', l:error.message, l:span.label),
                \   'type': toupper(l:error.level[0]),
                \})
            else
                " when the error is caused in the expansion of a macro, we have
                " to bury deeper
                let l:root_cause = s:FindErrorInExpansion(l:span, l:filename)

                if !empty(l:root_cause)
                    call add(l:output, {
                    \   'lnum': l:root_cause[0],
                    \   'end_lnum': l:root_cause[1],
                    \   'col': l:root_cause[2],
                    \   'end_col': l:root_cause[3],
                    \   'text': l:error.message,
                    \   'type': toupper(l:error.level[0]),
                    \})
                endif
            endif
        endfor
    endfor

    return l:output
endfunction

" A handler for output for Rust linters.
function! ale#handlers#rust#HandleRustErrors(buffer, lines) abort
    return ale#handlers#rust#HandleRustErrorsForFile(a:buffer, bufname(a:buffer), a:lines)
endfunction
