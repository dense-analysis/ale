" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Description: rustc for rust files

function! ale_linters#rust#rustc#RustcCommand(buffer_number) abort
    " Try to guess the library search path. If the project is managed by cargo,
    " it's usually <project root>/target/debug/deps/ or
    " <project root>/target/release/deps/
    let l:cargo_file = ale#path#FindNearestFile(a:buffer_number, 'Cargo.toml')

    if l:cargo_file isnot# ''
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
\   'callback': 'ale#handlers#rust#HandleRustErrors',
\   'output_stream': 'stderr',
\})
