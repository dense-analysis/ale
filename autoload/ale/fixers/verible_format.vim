" Author: Nicolas Derumigny <https://github.com/nicolasderumigny>
" Description: verible formatter for verilog.

call ale#Set('verilog_verible_format_executable', 'verible-verilog-format')
call ale#Set('verilog_verible_format_options', '')

function! ale#fixers#verible_format#Fix(buffer) abort
    let l:executable = ale#Escape(ale#Var(a:buffer, 'verilog_verible_format_executable'))
    let l:command = l:executable
    let l:options = ale#Var(a:buffer, 'verilog_verible_format_options')

    if l:options isnot# ''
        let l:command .= ' ' . l:options
    endif

    return {'command': l:command . ' -'}
endfunction
