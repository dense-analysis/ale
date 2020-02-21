scriptencoding utf-8
" Author: chen yuanyuan <cyyever@outlook.com>
" Description: Fixing PowerShell files with PSScriptAnalyzer.

call ale#Set('powershell_psscriptanalyzer_executable', 'pwsh')

function! ale#fixers#psscriptanalyzer#GetCommand(buffer) abort
    let l:script = ['Param($Script);
    \   Invoke-Formatter -ScriptDefinition (Get-Content -Path "$Script" -Raw).TrimEnd()']
    return ale#powershell#RunPowerShell(
    \   a:buffer,
    \   'powershell_psscriptanalyzer',
    \   l:script)
endfunction

function! ale#fixers#psscriptanalyzer#Fix(buffer) abort
    return {
    \   'command': ale#fixers#psscriptanalyzer#GetCommand(a:buffer),
    \   'output_stream': 'stdout',
    \}
endfunction
