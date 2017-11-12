" Author: w0rp <devw0rp@gmail.com>
" Description: Error handling for the format GHC outputs.

" Remember the directory used for temporary files for Vim.
let s:temp_dir = fnamemodify(tempname(), ':h')
" Build part of a regular expression for matching ALE temporary filenames.
let s:temp_regex_prefix =
\   '\M'
\   . substitute(s:temp_dir, '\\', '\\\\', 'g')
\   . '\.\{-}'


function! ale#handlers#haskell#ReplaceTempFilename(line, basename)
    let l:temp_filename_regex = s:temp_regex_prefix . a:basename
    return substitute(a:line, l:temp_filename_regex, a:basename, 'g')
endfunction

function! ale#handlers#haskell#HandleGHCFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    "Appoint/Lib.hs:8:1: warning:
    "Appoint/Lib.hs:8:1:
    let l:basename = expand('#' . a:buffer . ':t')
    " Build a complete regular expression for replacing temporary filenames
    " in Haskell error messages with the basename for this file.
    let l:temp_filename_regex = s:temp_regex_prefix . l:basename

    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):(\d+):(.*)?$'
    let l:output = []

    let l:corrected_lines = []
    let l:detail_lines = []

    for l:line in a:lines
        if len(matchlist(l:line, l:pattern)) > 0
            call add(l:corrected_lines, l:line)
            call add(l:detail_lines, l:line)
        elseif l:line is# ''
            call add(l:corrected_lines, l:line)
        else
            if len(l:corrected_lines) > 0
                let l:detail_lines[-1] .= "\n"
                let l:detail_lines[-1] .= l:line
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

        let l:detail = ''
        for l:detail_line in l:detail_lines
          let l:detail_match = matchlist(l:detail_line, l:pattern)
          if len(l:detail_match) > 0 && l:detail_match[2] == l:match[2]
            let l:detail .= (ale#handlers#haskell#ReplaceTempFilename(l:detail_line, l:basename) . "\n\n")
          endif
        endfor

        " Replace temporary filenames in problem messages with the basename
        let l:text = ale#handlers#haskell#ReplaceTempFilename(l:text, l:basename)

        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:text,
        \   'type': l:type,
        \   'detail': l:detail,
        \})
    endfor

    return l:output
endfunction
