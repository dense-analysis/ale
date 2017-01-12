" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Description: rustc invoked by cargo for rust files


function! ale_linters#rust#cargo#cargo_or_not_cargo(bufnr)
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
\   'executable_callback': 'ale_linters#rust#cargo#cargo_or_not_cargo',
\   'command': 'cargo rustc -- --error-format=json -Z no-trans',
\   'callback': 'ale_linters#rust#rustc#handle_rustc_errors',
\   'output_stream': 'stderr',
\})
