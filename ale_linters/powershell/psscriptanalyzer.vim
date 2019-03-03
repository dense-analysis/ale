" Author: Jesse Harris - https://github.com/zigford
" Description: PowerShell MRI for PS1 files using PowerShell
" module PSScriptAnalyzer

call ale#Set('powershell_psscriptanalyzer_executable', 'pwsh')
call ale#Set('powershell_psscriptanalyzer_module', 'psscriptanalyzer')

function! ale_linters#powershell#psscriptanalyzer#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'powershell_psscriptanalyzer_executable')
endfunction

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

function! ale_linters#powershell#psscriptanalyzer#GetCommand(buffer, version_output) abort
    let l:cd_string = ale#path#BufferCdString(a:buffer)
    let l:executable = ale_linters#powershell#psscriptanalyzer#GetExecutable(a:buffer)
    let l:executable = ale#Escape(l:executable)
    let l:module = ale#Var(a:buffer, 'powershell_psscriptanalyzer_module')
    let l:version = ale#semver#GetVersion(l:executable, a:version_output)

    let l:exec_args = ale_linters#powershell#psscriptanalyzer#Escape(
    \   ' -NoProfile -Command "&{'
    \   . 'Invoke-ScriptAnalyzer %t | ForEach-object {'
    \   . '$_.Line;'
    \   . '$_.Severity;'
    \   . '$_.Message;'
    \   . '$_.RuleName'
    \   . '}}"')

    return l:cd_string
    \   . l:executable . l:exec_args
endfunction
" Handler {{{
" add every 4 lines to an item(Dict) and every item to a list
" return the list
function! ale_linters#powershell#psscriptanalyzer#Handle(buffer, lines) abort
    let l:output = []
    let l:lcount = 0
    let l:item = {}
    for l:line in a:lines

        if l:lcount ==# 0
            " the very first line
            let l:item['lnum'] = l:line
        elseif l:lcount ==# 1
            if l:line is# 'Error'
                let l:type = 'E'
            elseif l:line is# 'Information'
                let l:type = 'I'
            else
                let l:type = 'W'
            endif
            let l:item['type'] = l:type
        elseif l:lcount ==# 2
            let l:item['text'] = l:line
        elseif l:lcount ==# 3
            let l:item['code'] = l:line
        else
            " every 5th line is the first line of the next
            " item. Add the current item to the output list
            " reset the item,count and add the first line
            call add(l:output, l:item)
            let l:item = {'lnum' : l:line}
            let l:lcount = 0
        endif

        let l:lcount = l:lcount + 1

    endfor

    call add(l:output, l:item)
    return l:output
endfunction
" }}}

call ale#linter#Define('powershell', {
\   'name': 'psscriptanalyzer',
\   'executable_callback': ale#VarFunc('powershell_psscriptanalyzer_executable'),
\   'command_chain': [
\       {'callback': 'ale_linters#powershell#psscriptanalyzer#VersionCheck'},
\       {'callback': 'ale_linters#powershell#psscriptanalyzer#GetCommand', 'output_stream': 'stdout'},
\   ],
\   'callback': 'ale_linters#powershell#psscriptanalyzer#Handle',
\})
