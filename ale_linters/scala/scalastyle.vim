" Author: Kevin Kays - https://github.com/okkays
" Description: Support for the scalastyle checker.

let g:ale_scala_scalastyle_options =
\   get(g:, 'ale_scala_scalastyle_options', '')

let g:ale_scalastyle_config_loc =
\   get(g:, 'ale_scalastyle_config_loc', '')

function! ale_linters#scala#scalastyle#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " warning file=/home/blurble/Doop.scala message=Missing or badly formed ScalaDoc: Extra @param foobles line=190

    let l:patterns = [
    \   '^\(.\+\) .\+ message=\(.\+\) line=\(\d\+\)$',
    \   '^\(.\+\) .\+ message=\(.\+\) line=\(\d\+\) column=\(\d\+\)$',
    \]
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:patterns)
        let l:args = {
        \   'lnum': l:match[3] + 0,
        \   'type': l:match[1] =~? 'error' ? 'E' : 'W',
        \   'text': l:match[2]
        \}

        if !empty(l:match[4])
            let l:args['col'] = l:match[4] + 1
        endif

        call add(l:output, l:args)
    endfor

    return l:output
endfunction

function! ale_linters#scala#scalastyle#GetCommand(buffer) abort
    " Search for scalastyle config in parent directories.
    let l:scalastyle_config = ''
    let l:potential_configs = [
    \   'scalastyle_config.xml',
    \   'scalastyle-config.xml'
    \]
    for l:config in l:potential_configs
        let l:scalastyle_config = ale#path#ResolveLocalPath(
        \   a:buffer,
        \   l:config,
        \   ''
        \)
        if !empty(l:scalastyle_config)
            break
        endif
    endfor

    " If all else fails, try the global config.
    if empty(l:scalastyle_config)
        let l:scalastyle_config = get(g:, 'ale_scalastyle_config_loc', '')
    endif

    " Build the command using the config file and additional options.
    let l:command = 'scalastyle'

    if !empty(l:scalastyle_config)
        let l:command .= ' --config ' . ale#Escape(l:scalastyle_config)
    endif

    if !empty(g:ale_scala_scalastyle_options)
        let l:command .= ' ' . g:ale_scala_scalastyle_options
    endif

    let l:command .= ' %t'

    return l:command
endfunction

call ale#linter#Define('scala', {
\   'name': 'scalastyle',
\   'executable': 'scalastyle',
\   'output_stream': 'stdout',
\   'command_callback': 'ale_linters#scala#scalastyle#GetCommand',
\   'callback': 'ale_linters#scala#scalastyle#Handle',
\})
