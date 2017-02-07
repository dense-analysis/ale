" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Description: rustc invoked by cargo for rust files

function! ale_linters#rust#cargo#GetCargoExecutable(bufnr) abort
    if ale#util#FindNearestFile(a:bufnr, 'Cargo.toml') !=# ''
        return 'cargo'
    else
        " if there is no Cargo.toml file, we don't use cargo even if it exists,
        " so we return '', because executable('') apparently always fails
        return ''
    endif
endfunction

call ale#linter#Define('rust', {
\   'name': 'cargo',
\   'executable_callback': 'ale_linters#rust#cargo#GetCargoExecutable',
\   'command': 'cargo build --message-format=json -q',
\   'callback': 'ale#handlers#rust#HandleRustErrors',
\   'output_stream': 'stdout',
\})
