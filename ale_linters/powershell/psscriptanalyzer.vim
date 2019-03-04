" Author: Jesse Harris - https://github.com/zigford
" Description: This file adds support for lintng powershell scripts
"   using the PSScriptAnalyzer module.

" let g:ale_powershell_psscriptanalyzer_exclusions = 'PSAvoidUsingWriteHost,PSAvoidGlobalVars'
call ale#Set('powershell_psscriptanalyzer_exclusions', get(g:, 'ale_linters_powershell_psscriptanalyzer_exclusions', ''))
call ale#Set('powershell_psscriptanalyzer_executable', 'pwsh')
call ale#Set('powershell_psscriptanalyzer_module', 'psscriptanalyzer')

" GetExecutable {{{
function! ale_linters#powershell#psscriptanalyzer#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'powershell_psscriptanalyzer_executable')
endfunction
" }}}

" PowerShell Escape {{{
" Powershell variables use $s, so they need to be escaped
" if being used from a unix shell
function! ale_linters#powershell#psscriptanalyzer#Escape(str) abort

    if fnamemodify(&shell, ':t') =~# 'sh'
        " Powershell commands use $ for variables and must be 
        " escaped in bash
        return substitute(
        \   a:str,
        \   '\$',
        \   '\\$',
        \   'g'
        \)
    endif

    return a:str
endfunction
" }}}

" VersionCheck {{{
" return the module version
function! ale_linters#powershell#psscriptanalyzer#VersionCheck(buffer) abort
    let l:executable = ale_linters#powershell#psscriptanalyzer#GetExecutable(a:buffer)
    let l:module = ale#Var(a:buffer, 'powershell_psscriptanalyzer_module')

    if ale#semver#HasVersion(l:module)
        return ''
    endif

    let l:executable = ale#Escape(l:executable)
    let l:module_string = ale_linters#powershell#psscriptanalyzer#Escape(
    \ ' -NoProfile -Command "&{$m=Get-Module -ListAvailable '
    \ . l:module . ';$m.Version.ToString()}"')

    return l:executable . l:module_string
endfunction
" }}}

" GetCommand {{{
" Invoke-ScriptAnalyzer and output each lint as 4 seperate lines
" for each parsing
function! ale_linters#powershell#psscriptanalyzer#GetCommand(buffer, version_output) abort
    let l:cd_string = ale#path#BufferCdString(a:buffer)
    let l:executable = ale_linters#powershell#psscriptanalyzer#GetExecutable(a:buffer)
    let l:executable = ale#Escape(l:executable)
    let l:exclude_option = ale#Var(a:buffer, 'powershell_psscriptanalyzer_exclusions')
    let l:module = ale#Var(a:buffer, 'powershell_psscriptanalyzer_module')
    let l:version = ale#semver#GetVersion(l:executable, a:version_output)

    let l:exec_args = ale_linters#powershell#psscriptanalyzer#Escape(
    \   ' -NoProfile -Command "&{'
    \   . 'Invoke-ScriptAnalyzer %t '
    \   . (!empty(l:exclude_option) ? '-Exclude ' . l:exclude_option : '')
    \   . '| ForEach-object {'
    \   . '$_.Line;'
    \   . '$_.Severity;'
    \   . '$_.Message;'
    \   . '$_.RuleName'
    \   . '}}"')

    return l:cd_string
    \   . l:executable . l:exec_args
endfunction
" }}}

" Handler {{{
" add every 4 lines to an item(Dict) and every item to a list
" return the list
function! ale_linters#powershell#psscriptanalyzer#Handle(buffer, lines) abort
    let l:output = []
    let l:lcount = 0
    for l:line in a:lines

        if l:lcount ==# 0
            " the very first line
            let l:item = {'lnum': l:line}
        elseif l:lcount ==# 1
            if l:line is# 'Error'
                let l:item['type'] = 'E'
            elseif l:line is# 'Information'
                let l:item['type'] = 'I'
            else
                let l:item['type'] = 'W'
            endif
        elseif l:lcount ==# 2
            let l:item['text'] = l:line
        elseif l:lcount ==# 3
            let l:item['code'] = l:line
            call add(l:output, l:item)
            let l:lcount = -1
        endif

        let l:lcount = l:lcount + 1

    endfor

    return l:output
endfunction
" }}}

" Definition {{{
call ale#linter#Define('powershell', {
\   'name': 'psscriptanalyzer',
\   'executable_callback': 'ale_linters#powershell#psscriptanalyzer#GetExecutable',
\   'command_chain': [
\       {'callback': 'ale_linters#powershell#psscriptanalyzer#VersionCheck'},
\       {'callback': 'ale_linters#powershell#psscriptanalyzer#GetCommand', 'output_stream': 'stdout'},
\   ],
\   'callback': 'ale_linters#powershell#psscriptanalyzer#Handle',
\})
" }}}
