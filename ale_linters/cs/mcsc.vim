" general mcs options which are likely to stay constant across
" source trees like -pkg:dotnet
let g:ale_cs_mcsc_options = get(g:, 'ale_cs_mcsc_options', '')

" path string pointing the linter to the base path of the
" source tree to check
let g:ale_cs_mcsc_source = get(g:, 'ale_cs_mcsc_source','.')

" list of search paths for additional assemblies to consider
let g:ale_cs_mcsc_assembly_path = get(g:, 'ale_cs_mcsc_assembly_path',[])

" list of assemblies to consider
let g:ale_cs_mcsc_assemblies = get(g:, 'ale_cs_mcsc_assemblies',[])
function! ale_linters#cs#mcsc#GetCommand(buffer) abort

    " if list of assembly search paths is not empty convert it to
    " appropriate -lib: parameter of mcs
    let l:path = ale#Var(a:buffer, 'cs_mcsc_assembly_path')

    if !empty(l:path)
         let l:path = '-lib:"' . join(l:path, '","') .'"'
    else
        let l:path =''
    endif

    " if list of assemblies to link is not empty convert it to the
    " appropriate -r: parameter of mcs
    let l:assemblies = ale#Var(a:buffer, 'cs_mcsc_assemblies')

    if !empty(l:assemblies)
        let l:assemblies = '-r:"' . join(l:assemblies, '","') . '"'
    else
        let l:assemblies =''
    endif

    " register temporary module target file with ale
    let l:out = tempname()
    call ale#engine#ManageFile(a:buffer, l:out)

    " assemble linter command string to be executed by ale
    " implicitly set -unsafe mcs flag set compilation
    " target to module (-t:module), direct mcs output to
    " temporary file (-out)
    "
    return 'cd "' . ale#Var(a:buffer, 'cs_mcsc_source') . '";'
    \    . 'mcs -unsafe'
    \    . ' ' . ale#Var(a:buffer, 'cs_mcsc_options')
    \    . ' ' . l:path
    \    . ' ' . l:assemblies
    \    . ' -out:' . l:out
    \    . ' -t:module'
    \    . ' -recurse:"*.cs"'
endfunction

function! ale_linters#cs#mcsc#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " Tests.cs(12,29): error CSXXXX: ; expected
    "
    " NOTE: pattern also captures file name as linter compiles all
    " files within the source tree rooted at the specified source
    " path and not just the file loaded in the buffer
    let l:pattern = '^\v(.+\.cs)\((\d+),(\d+)\)\: ([^ ]+) ([^ ]+): (.+)$'
    let l:output = []
    let l:source = ale#Var(a:buffer, 'cs_mcsc_source')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'filename': fnamemodify(l:source . '/' . l:match[1], ':p'),
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': l:match[4] is# 'error' ? 'E' : 'W',
        \   'code': l:match[5],
        \   'text': l:match[6],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('cs',{
\   'name': 'mcsc',
\   'output_stream': 'stderr',
\   'executable': 'mcs',
\   'command_callback': 'ale_linters#cs#mcsc#GetCommand',
\   'callback': 'ale_linters#cs#mcsc#Handle',
\   'lint_file': 1
\})
