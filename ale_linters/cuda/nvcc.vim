" Author: blahgeek <i@blahgeek.com>
" Description: NVCC linter for cuda files

call ale#Set('cuda_nvcc_executable', 'nvcc')
call ale#Set('cuda_nvcc_options', '-std=c++11')

function! ale_linters#cuda#nvcc#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cuda_nvcc_executable')
endfunction

function! ale_linters#cuda#nvcc#GetCommand(buffer) abort
    return ale#Escape(ale_linters#cuda#nvcc#GetExecutable(a:buffer))
    \   . ' -cuda '
    \   . ale#c#IncludeOptions(ale#c#FindLocalHeaderPaths(a:buffer))
    \   . ale#Var(a:buffer, 'cuda_nvcc_options') . ' %s'
endfunction

function! ale_linters#cuda#nvcc#HandleNVCCFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    " test.cu(8): error: argument of type "void *" is incompatible with parameter of type "int *"
    let l:pattern = '\v^([^:\(\)]+):?\(?(\d+)\)?:(\d+)?:?\s*\w*\s*(error|warning): (.+)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if !empty(l:match)
            " Ignore errors that is not for this file
            if !(fnamemodify(l:match[1], ":p:.") ==# bufname(bufnr('')))
                continue
            endif

            let l:item = {
            \   'lnum': str2nr(l:match[2]),
            \   'type': l:match[4] =~# 'error' ? 'E' : 'W',
            \   'text': l:match[5],
            \}

            if !empty(l:match[3])
                let l:item.col = str2nr(l:match[3])
            endif

            call add(l:output, l:item)
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('cuda', {
\   'name': 'nvcc',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#cuda#nvcc#GetExecutable',
\   'command_callback': 'ale_linters#cuda#nvcc#GetCommand',
\   'callback': 'ale_linters#cuda#nvcc#HandleNVCCFormat',
\   'lint_file': 1,
\})
