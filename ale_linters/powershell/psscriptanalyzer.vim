" Author: Jesse Harris - https://github.com/zigford
" Description: This file adds support for lintng powershell scripts
"   using the PSScriptAnalyzer module.

" let g:ale_powershell_psscriptanalyzer_exclusions =
" \ 'PSAvoidUsingWriteHost,PSAvoidGlobalVars'
call ale#Set('powershell_psscriptanalyzer_exclusions',
\ get(g:,
\ 'ale_linters_powershell_psscriptanalyzer_exclusions', ''))
call ale#Set('powershell_psscriptanalyzer_executable', 'pwsh')
call ale#Set('powershell_psscriptanalyzer_module',
\ 'psscriptanalyzer')

" GetExecutable {{{
function! ale_linters#powershell#psscriptanalyzer#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'powershell_psscriptanalyzer_executable')
endfunction
" }}}

" PowerShell Escape {{{
" Powershell variables use $s, so they need to be escaped
" if being used from a unix shell
function! ale_linters#powershell#psscriptanalyzer#Escape(str) abort
    if fnamemodify(&shell, ':t') !~# '\(powershell\|cmd\|pwsh\)'
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
" Not used yet
function! ale_linters#powershell#psscriptanalyzer#VersionCheck(buffer) abort
    let l:executable =
    \ ale_linters#powershell#psscriptanalyzer#GetExecutable(a:buffer)
    let l:module = ale#Var(a:buffer, 'powershell_psscriptanalyzer_module')

    if ale#semver#HasVersion(l:module)
        return ''
    endif

    "let l:executable = ale#Escape(l:executable)
    let l:module_string = ale_linters#powershell#psscriptanalyzer#Escape(
    \ ' -NoProfile -Command "&{$m=Get-Module -ListAvailable '
    \ . l:module . ';$m.Version.ToString()}"')

    return l:executable . l:module_string
endfunction
 " }}}

" RunPowerShell {{{
" Write a powershell script to a temp file for execution
" return the command used to execute it
function! s:TemporaryPSScript(buffer, input) abort
    let l:filename = 'script.ps1'

    " Create a temporary filename, <temp_dir>/<original_basename>
    " The file itself will not be created by this function.
    let l:tempscript =
    \ ale#util#Tempname() . (has('win32') ? '\' : '/') . l:filename

    if ale#command#CreateTempFile(a:buffer, l:tempscript, a:input)
        return l:tempscript
    endif

    return v:null
endfunction

function! ale_linters#powershell#psscriptanalyzer#RunPowerShell(buffer, command) abort
    let l:executable = ale_linters#powershell#psscriptanalyzer#GetExecutable(
    \ a:buffer)
    let l:tempscript = s:TemporaryPSScript(a:buffer, a:command)

    return ale#Escape(l:executable)
    \ . ' -NoProfile -File '
    \ . ale#Escape(l:tempscript)
    \ . ' %t'
endfunction
"" }}}
"
" GetCommand {{{
" Run Invoke-ScriptAnalyzer and output each linting message as 4 seperate lines
" for each parsing

function! ale_linters#powershell#psscriptanalyzer#GetCommand(buffer) abort
    let l:exclude_option = ale#Var(
    \   a:buffer, 'powershell_psscriptanalyzer_exclusions')
    let l:module = ale#Var(
    \   a:buffer, 'powershell_psscriptanalyzer_module')
    let l:script = ['Param($Script);
    \   Invoke-ScriptAnalyzer "$Script" '
    \   . (!empty(l:exclude_option) ? '-Exclude ' . l:exclude_option : '')
    \   . '| ForEach-Object {
    \   $_.Line;
    \   $_.Severity;
    \   $_.Message;
    \   $_.RuleName}']

    return ale_linters#powershell#psscriptanalyzer#RunPowerShell(
    \   a:buffer, l:script)
endfunction
" }}}

" Handler {{{
" add every 4 lines to an item(Dict) and every item to a list
" return the list
function! ale_linters#powershell#psscriptanalyzer#Handle(buffer, lines) abort
    let l:output = []
    let l:lcount = 0

    for l:line in a:lines
        if l:lcount is# 0
            " the very first line
            let l:item = {'lnum': str2nr(l:line)}
        elseif l:lcount is# 1
            if l:line is# 'Error'
                let l:item['type'] = 'E'
            elseif l:line is# 'Information'
                let l:item['type'] = 'I'
            else
                let l:item['type'] = 'W'
            endif
        elseif l:lcount is# 2
            let l:item['text'] = l:line
        elseif l:lcount is# 3
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
\   'command_callback': 'ale_linters#powershell#psscriptanalyzer#GetCommand',
\   'output_stream': 'stdout',
\   'callback': 'ale_linters#powershell#psscriptanalyzer#Handle',
\})
