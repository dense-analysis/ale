" Author: w0rp <devw0rp@gmail.com>
" Description: Error handling for the format GHC outputs.

" Remember the directory used for temporary files for Vim.
let s:temp_dir = fnamemodify(tempname(), ':h')
" Build part of a regular expression for matching ALE temporary filenames.
let s:temp_regex_prefix =
\   '\M'
\   . substitute(s:temp_dir, '\\', '\\\\', 'g')
\   . '\.\{-}'

function! ale#handlers#haskell#HandleGHCFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    "Appoint/Lib.hs:8:1: warning:
    "Appoint/Lib.hs:8:1:
    let l:basename = expand('#' . a:buffer . ':t')
    " Build a complete regular expression for replacing temporary filenames
    " in Haskell error messages with the basename for this file.
    let l:temp_filename_regex = s:temp_regex_prefix . l:basename

    let l:pattern = '\v^\s*([a-zA-Z]?:?[^:]+):(\d+):(\d+):(.*)?$'
    let l:output = []

    let l:corrected_lines = []

    for l:line in a:lines
        if len(matchlist(l:line, l:pattern)) > 0
            call add(l:corrected_lines, l:line)
        elseif l:line is# ''
            call add(l:corrected_lines, l:line)
        else
            if len(l:corrected_lines) > 0
                let l:line = substitute(l:line, '\v^\s+', ' ', '')
                let l:corrected_lines[-1] .= l:line
            endif
        endif
    endfor

    for l:line in l:corrected_lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        if !ale#path#IsBufferPath(a:buffer, l:match[1])
            continue
        endif

        let l:errors = matchlist(l:match[4], '\v([wW]arning|[eE]rror): ?(.*)')

        if len(l:errors) > 0
          let l:ghc_type = l:errors[1]
          let l:text = l:errors[2]
        else
          let l:ghc_type = ''
          let l:text = l:match[4][:0] is# ' ' ? l:match[4][1:] : l:match[4]
        endif

        if l:ghc_type is? 'Warning'
            let l:type = 'W'
        else
            let l:type = 'E'
        endif

        " Replace temporary filenames in problem messages with the basename
        let l:text = substitute(l:text, l:temp_filename_regex, l:basename, 'g')

        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction
