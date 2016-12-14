" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Description: rustc for rust files


function! ale_linters#rust#rustc#handle_rustc_errors(buffer_number, errorlines)
    let output = []
    for errorline in a:errorlines
        if errorline !~# '^{'
            continue
        endif
        let error = json_decode(errorline)
        for span in error.spans 
            if span.is_primary
                call add(output, {
                            \ 'bufnr': a:buffer_number,
                            \ 'lnum': span.line_start,
                            \ 'vcol': 0,
                            \ 'col': span.byte_start,
                            \ 'nr': -1,
                            \ 'text': error.message,
                            \ 'type': toupper(error.level[0]),
                            \ })
            endif
        endfor
    endfor
    return output
endfunction


function! ale_linters#rust#rustc#rustc_command(buffer_number)
    " Try to guess the library search path. If the project is managed by cargo,
    " it's usually <project root>/target/debug/deps/ or
    " <project root>/target/release/deps/
    let cargo_file = ale#util#FindNearestFile(a:buffer_number, 'Cargo.toml')

    let dependencies = ''
    if cargo_file !=# ''
        let project_root = fnamemodify(cargo_file, ':h')
        let dependencies = '-L ' . project_root . '/target/debug/deps -L ' .
                    \ project_root . '/target/release/deps'
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
