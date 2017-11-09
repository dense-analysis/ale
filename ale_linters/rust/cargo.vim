" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Description: rustc invoked by cargo for rust files

call ale#Set('rust_cargo_use_check', 1)
call ale#Set('rust_cargo_check_all_targets', 1)

function! ale_linters#rust#cargo#GetCargoExecutable(bufnr) abort
    if ale#path#FindNearestFile(a:bufnr, 'Cargo.toml') isnot# ''
        return 'cargo'
    else
        " if there is no Cargo.toml file, we don't use cargo even if it exists,
        " so we return '', because executable('') apparently always fails
        return ''
    endif
endfunction

function! ale_linters#rust#cargo#VersionCheck(buffer) abort
    return !ale#semver#HasVersion('cargo')
    \   ? 'cargo --version'
    \   : ''
endfunction

function! ale_linters#rust#cargo#GetCommand(buffer, version_output) abort
    let l:version = ale#semver#GetVersion('cargo', a:version_output)

    let l:use_check = ale#Var(a:buffer, 'rust_cargo_use_check')
    \   && ale#semver#GTE(l:version, [0, 17, 0])
    let l:use_all_targets = l:use_check
    \   && ale#Var(a:buffer, 'rust_cargo_check_all_targets')
    \   && ale#semver#GTE(l:version, [0, 22, 0])

    return 'cargo '
    \   . (l:use_check ? 'check' : 'build')
    \   . (l:use_all_targets ? ' --all-targets' : '')
    \   . ' --frozen --message-format=json -q'
endfunction

call ale#linter#Define('rust', {
\   'name': 'cargo',
\   'executable_callback': 'ale_linters#rust#cargo#GetCargoExecutable',
\   'command_chain': [
\       {'callback': 'ale_linters#rust#cargo#VersionCheck'},
\       {'callback': 'ale_linters#rust#cargo#GetCommand'},
\   ],
\   'callback': 'ale#handlers#rust#HandleRustErrors',
\   'output_stream': 'both',
\   'lint_file': 1,
\})
