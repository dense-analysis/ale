" Author: Mikhail f. Shiryaev <mr.felixoid@gmail.com
" Description: Integration of `cargo fmt` with ALE.

call ale#Set('rust_cargo_fmt_executable', 'cargo-fmt')
call ale#Set('rust_cargo_fmt_options', '')

function! ale#fixers#cargo_fmt#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'rust_cargo_fmt_executable')
    let l:options = ale#Var(a:buffer, 'rust_cargo_fmt_options')

    return {
    \   'command': ale#Escape(l:executable) . ' -- '
    \       . (empty(l:options) ? '' : ' ' . l:options),
    \}
endfunction

