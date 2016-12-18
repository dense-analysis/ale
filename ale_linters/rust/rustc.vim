" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Description: rustc for rust files

if !exists('g:ale_rust_ignore_error_codes')
    " set this e.g. to ['E0432', 'E0433'] to ignore some errors regarding
    " failed imports
    let g:ale_rust_ignore_error_codes = []
endif


function! ale_linters#rust#rustc#handle_rustc_errors(buffer_number, errorlines)
    let file_name = fnamemodify(bufname(a:buffer_number), ':t')
    let output = []
    for errorline in a:errorlines
        " ignore everything that is not Json
        if errorline !~# '^{'
            continue
        endif

        let error = json_decode(errorline)

        if !empty(error.code) && index(g:ale_rust_ignore_error_codes, error.code.code) > -1
            continue
        endif

        for span in error.spans 
            if span.is_primary && 
                \ (span.file_name ==# file_name || span.file_name ==# '<anon>')
                call add(output, {
                            \ 'bufnr': a:buffer_number,
                            \ 'lnum': span.line_start,
                            \ 'vcol': 0,
                            \ 'col': span.byte_start,
                            \ 'nr': -1,
                            \ 'text': error.message,
                            \ 'type': toupper(error.level[0]),
                            \ })
            else
                " when the error is caused in the expansion of a macro, we have
                " to bury deeper
                let root_cause = s:find_error_in_expansion(span, file_name)
                if !empty(root_cause)
                    call add(output, {
                                \ 'bufnr': a:buffer_number,
                                \ 'lnum': root_cause[0],
                                \ 'vcol': 0,
                                \ 'col': root_cause[1],
                                \ 'nr': -1,
                                \ 'text': error.message,
                                \ 'type': toupper(error.level[0]),
                                \ })
                endif
            endif
        endfor
    endfor
    return output
endfunction


" returns: a list [lnum, col] with the location of the error or []
function! s:find_error_in_expansion(span, file_name)
    if a:span.file_name ==# a:file_name
        return [a:span.line_start, a:span.byte_start]
    endif
    if !empty(a:span.expansion)
        return s:find_error_in_expansion(a:span.expansion.span, a:file_name)
    endif
    return []
endfunction


function! ale_linters#rust#rustc#rustc_command(buffer_number)
    " Try to guess the library search path. If the project is managed by cargo,
    " it's usually <project root>/target/debug/deps/ or
    " <project root>/target/release/deps/
    let cargo_file = ale#util#FindNearestFile(a:buffer_number, 'Cargo.toml')

    if cargo_file !=# ''
        let project_root = fnamemodify(cargo_file, ':h')
        let dependencies = '-L ' . project_root . '/target/debug/deps -L ' .
                    \ project_root . '/target/release/deps'
    else
        let dependencies = ''
    endif

    return 'rustc --error-format=json -Z no-trans ' . dependencies . ' -'
endfunction


call ale#linter#Define('rust', {
\   'name': 'rustc',
\   'executable': 'rustc',
\   'command_callback': 'ale_linters#rust#rustc#rustc_command',
\   'callback': 'ale_linters#rust#rustc#handle_rustc_errors',
\   'output_stream': 'stderr',
\})
