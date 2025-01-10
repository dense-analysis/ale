" Author: Robert Liebowitz <rliebz@gmail.com>
" Description: https://github.com/johnnymorganz/stylua

call ale#Set('lua_stylua_executable', 'stylua')
call ale#Set('lua_stylua_options', '')

function! ale#fixers#stylua#GetCwd(buffer) abort
    for l:possible_configfile in ['stylua.toml', '.stylua.toml']
        let l:config = ale#path#FindNearestFile(a:buffer, l:possible_configfile)

        return !empty(l:config) ? fnamemodify(l:config, ':h') : '%s:h'
    endfor

    return ''
endfunction

function! ale#fixers#stylua#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'lua_stylua_executable')
    let l:options = ale#Var(a:buffer, 'lua_stylua_options')

    return {
    \   'cwd': ale#fixers#stylua#GetCwd(a:buffer),
    \   'command': ale#Escape(l:executable) . ale#Pad(l:options) . ' --stdin-filepath %s -',
    \}
endfunction
