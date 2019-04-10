" Author: Jesse Harris - https://github.com/zigford
" Description: This file adds support for lintng powershell scripts
"   using the PSScriptAnalyzer module.

" let g:ale_powershell_psscriptanalyzer_exclusions =
" \ 'PSAvoidUsingWriteHost,PSAvoidGlobalVars'
call ale#Set('powershell_psscriptanalyzer_exclusions', '')
call ale#Set('powershell_psscriptanalyzer_executable', 'pwsh')
call ale#Set('powershell_psscriptanalyzer_module',
\ 'psscriptanalyzer')

function! ale_linters#powershell#psscriptanalyzer#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'powershell_psscriptanalyzer_executable')
endfunction

" Write a powershell script to a temp file for execution
" return the command used to execute it
function! s:TemporaryPSScript(buffer, input) abort
    let l:filename = 'script.ps1'
    " Create a temp dir to house our temp .ps1 script
    " a temp dir is needed as powershell needs the .ps1
    " extension
    let l:tempdir = ale#util#Tempname() . (has('win32') ? '\' : '/')
    let l:tempscript = l:tempdir . l:filename
    " Create the temporary directory for the file, unreadable by 'other'
    " users.
    call mkdir(l:tempdir, '', 0750)
    " Automatically delete the directory later.
    call ale#command#ManageDirectory(a:buffer, l:tempdir)
    " Write the script input out to a file.
    call ale#util#Writefile(a:buffer, a:input, l:tempscript)

    return l:tempscript
endfunction

function! ale_linters#powershell#psscriptanalyzer#RunPowerShell(buffer, command) abort
    let l:executable = ale_linters#powershell#psscriptanalyzer#GetExecutable(
    \ a:buffer)
    let l:tempscript = s:TemporaryPSScript(a:buffer, a:command)

    return ale#Escape(l:executable)
    \ . ' -Exe Bypass -NoProfile -File '
    \ . ale#Escape(l:tempscript)
    \ . ' %t'
endfunction

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

call ale#linter#Define('powershell', {
\   'name': 'psscriptanalyzer',
\   'executable': function('ale_linters#powershell#psscriptanalyzer#GetExecutable'),
\   'command': function('ale_linters#powershell#psscriptanalyzer#GetCommand'),
\   'output_stream': 'stdout',
\   'callback': 'ale_linters#powershell#psscriptanalyzer#Handle',
\})
