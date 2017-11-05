" Author: Daniel Schemala <istjanichtzufassen@gmail.com>
" Description: rustc invoked by cargo for rust files

call ale#Set('rust_cargo_use_check', 1)
call ale#Set('rust_cargo_check_all_targets', 1)

let s:version_cache = {}

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
    if has_key(s:version_cache, 'cargo')
        return ''
    endif

    return 'cargo --version'
endfunction

function! s:GetVersion(executable, output) abort
    let l:version = get(s:version_cache, a:executable, [])

    for l:match in ale#util#GetMatches(a:output, '\v\d+\.\d+\.\d+')
        let l:version = ale#semver#Parse(l:match[0])
        let s:version_cache[a:executable] = l:version
    endfor

    return l:version
endfunction

function! s:CanUseCargoCheck(buffer, version) abort
    " Allow `cargo check` to be disabled.
    if !ale#Var(a:buffer, 'rust_cargo_use_check')
        return 0
    endif

    return !empty(a:version)
    \   && ale#semver#GreaterOrEqual(a:version, [0, 17, 0])
endfunction

function! s:CanUseAllTargets(buffer, version) abort
    if !ale#Var(a:buffer, 'rust_cargo_use_check')
        return 0
    endif

    if !ale#Var(a:buffer, 'rust_cargo_check_all_targets')
        return 0
    endif

    return !empty(a:version)
    \   && ale#semver#GreaterOrEqual(a:version, [0, 22, 0])
endfunction

function! ale_linters#rust#cargo#GetCommand(buffer, version_output) abort
    let l:version = s:GetVersion('cargo', a:version_output)
    let l:command = s:CanUseCargoCheck(a:buffer, l:version)
    \   ? 'check'
    \   : 'build'
    let l:all_targets = s:CanUseAllTargets(a:buffer, l:version)
    \   ? ' --all-targets'
    \   : ''

    return 'cargo '
    \   . l:command
    \   . l:all_targets
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
