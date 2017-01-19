" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Description: rustc for rust files

if !exists('g:ale_rust_ignore_error_codes')
    let g:ale_rust_ignore_error_codes = []
endif


function! ale_linters#rust#rustc#HandleRustcErrors(buffer_number, errorlines) abort
    let l:file_name = fnamemodify(bufname(a:buffer_number), ':t')
    let l:output = []

    for l:errorline in a:errorlines
        " ignore everything that is not Json
        if l:errorline !~# '^{'
            continue
        endif

        let l:error = json_decode(l:errorline)

        if !empty(l:error.code) && index(g:ale_rust_ignore_error_codes, l:error.code.code) > -1
            continue
        endif

        for l:span in l:error.spans
            if l:span.is_primary &&
                \   (l:span.file_name ==# l:file_name || l:span.file_name ==# '<anon>')
                call add(l:output, {
                \   'bufnr': a:buffer_number,
                \   'lnum': l:span.line_start,
                \   'vcol': 0,
                \   'col': l:span.byte_start,
                \   'nr': -1,
                \   'text': l:error.message,
                \   'type': toupper(l:error.level[0]),
                \})
            else
                " when the error is caused in the expansion of a macro, we have
                " to bury deeper
                let l:root_cause = s:FindErrorInExpansion(l:span, l:file_name)

                if !empty(l:root_cause)
                    call add(l:output, {
                    \   'bufnr': a:buffer_number,
                    \   'lnum': l:root_cause[0],
                    \   'vcol': 0,
                    \   'col': l:root_cause[1],
                    \   'nr': -1,
                    \   'text': l:error.message,
                    \   'type': toupper(l:error.level[0]),
                    \})
                endif
            endif
        endfor
    endfor

    return l:output
endfunction


" returns: a list [lnum, col] with the location of the error or []
function! s:FindErrorInExpansion(span, file_name) abort
    if a:span.file_name ==# a:file_name
        return [a:span.line_start, a:span.byte_start]
    endif

    if !empty(a:span.expansion)
        return s:FindErrorInExpansion(a:span.expansion.span, a:file_name)
    endif

    return []
endfunction


function! ale_linters#rust#rustc#RustcCommand(buffer_number) abort
    " Try to guess the library search path. If the project is managed by cargo,
    " it's usually <project root>/target/debug/deps/ or
    " <project root>/target/release/deps/
    let l:cargo_file = ale#util#FindNearestFile(a:buffer_number, 'Cargo.toml')

    if l:cargo_file !=# ''
        let l:project_root = fnamemodify(l:cargo_file, ':h')
        let l:dependencies = '-L ' . l:project_root . '/target/debug/deps -L ' .
        \   l:project_root . '/target/release/deps'
    else
        let l:dependencies = ''
    endif

    return 'rustc --error-format=json -Z no-trans ' . l:dependencies . ' -'
endfunction


call ale#linter#Define('rust', {
\   'name': 'rustc',
\   'executable': 'rustc',
\   'command_callback': 'ale_linters#rust#rustc#RustcCommand',
\   'callback': 'ale_linters#rust#rustc#HandleRustcErrors',
\   'output_stream': 'stderr',
\})
