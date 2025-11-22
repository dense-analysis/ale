
call ale#Set('markdown_pymarkdown_executable', 'pymarkdown')
call ale#Set('markdown_pymarkdown_options', '')
call ale#Set('markdown_pymarkdown_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('markdown_pymarkdown_auto_pipenv', 0)
call ale#Set('markdown_pymarkdown_auto_poetry', 0)
call ale#Set('markdown_pymarkdown_auto_uv', 0)

function! ale_linters#markdown#pymarkdown#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'markdown_pymarkdown_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'markdown_pymarkdown_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'markdown_pymarkdown_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'markdown_pymarkdown', ['pymarkdown'])
endfunction

function! ale_linters#markdown#pymarkdown#GetCommand(buffer) abort
    let l:executable = ale_linters#markdown#pymarkdown#GetExecutable(a:buffer)

    let l:exec_args = l:executable =~? 'pipenv\|poetry\|uv$'
    \   ? ' run pymarkdown'
    \   : ''

    return ale#Escape(l:executable) . l:exec_args
    \   . ale#Pad(ale#Var(a:buffer, 'markdown_pymarkdown_options'))
    \   . ' scan-stdin'
endfunction

function! ale_linters#markdown#pymarkdown#Handle(buffer, lines) abort
    let l:pattern = '\v^(\S*):(\d+):(\d+): ([A-Z]+\d+): (.*)$'
    let l:output = []
    " lines are formatted as follows:
    " sample.md:1:1: MD022: Headings should be surrounded by blank lines. [Expected: 1; Actual: 0; Below] (blanks-around-headings,blanks-around-headers)

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if(l:match[4] is# 'MD009')
        \&& !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
            " Skip warnings for trailing whitespace if the option is off.
            continue
        endif

        let l:item = {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': l:match[4][0],
        \   'text': l:match[5],
        \   'code': l:match[4],
        \}

        call add(l:output, l:item)
    endfor

    return l:output
endfunction

call ale#linter#Define('markdown', {
\   'name': 'pymarkdown',
\   'executable': function('ale_linters#markdown#pymarkdown#GetExecutable'),
\   'command': function('ale_linters#markdown#pymarkdown#GetCommand'),
\   'callback': 'ale_linters#markdown#pymarkdown#Handle',
\})
