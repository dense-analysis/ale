if !exists('g:ale_cs_netcore_options')
    let g:ale_cs_netcore_options = ''
endif

call ale#linter#Define('cs',{
\ 'name': 'netcore',
\ 'output_stream': 'stderr',
\ 'executable': 'dotnet',
\ 'command': 'dotnet build' . g:ale_cs_netcore_options,
\ 'callback': 'ale#handlers#HandleDotnetFormat',
\ })

