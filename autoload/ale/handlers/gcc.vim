scriptencoding utf-8
" Author: w0rp <devw0rp@gmail.com>
" Description: This file defines a handler function which ought to work for
" any program which outputs errors in the format that GCC uses.

let s:pragma_error = '#pragma once in main file'

function! s:AddIncludedErrors(output, include_lnum, include_lines) abort
    if a:include_lnum > 0
        call add(a:output, {
        \   'lnum': a:include_lnum,
        \   'type': 'E',
        \   'text': 'Problems were found in the header (See :ALEDetail)',
        \   'detail': join(a:include_lines, "\n"),
        \})
    endif
endfunction

function! s:IsHeaderFile(filename) abort
    return a:filename =~? '\v\.(h|hpp)$'
endfunction

function! s:RemoveUnicodeQuotes(text) abort
    let l:text = a:text
    let l:text = substitute(l:text, '[`´‘’]', '''', 'g')
    let l:text = substitute(l:text, '\v\\u2018([^\\]+)\\u2019', '''\1''', 'g')
    let l:text = substitute(l:text, '[“”]', '"', 'g')

    return l:text
endfunction

function! ale#handlers#gcc#ParseGCCVersion(lines) abort
    for l:line in a:lines
        let l:match = matchstr(l:line, '\d\.\d\.\d')

        if !empty(l:match)
            return ale#semver#Parse(l:match)
        endif
    endfor

    return []
endfunction

function! ale#handlers#gcc#HandleGCCFormat(buffer, lines) abort
    let l:include_pattern = '\v^(In file included | *)from ([^:]*):(\d+)'
    let l:include_lnum = 0
    let l:include_lines = []
    let l:included_filename = ''
    " Look for lines like the following.
    "
    " <stdin>:8:5: warning: conversion lacks type at end of format [-Wformat=]
    " <stdin>:10:27: error: invalid operands to binary - (have ‘int’ and ‘char *’)
    " -:189:7: note: $/${} is unnecessary on arithmetic variables. [SC2004]
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):(\d+)?:? ([^:]+): (.+)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if empty(l:match)
            " Check for matches in includes.
            " We will keep matching lines until we hit the last file, which
            " is our file.
            let l:include_match = matchlist(l:line, l:include_pattern)

            if empty(l:include_match)
                " If this isn't another include header line, then we
                " need to collect it.
                call add(l:include_lines, l:line)
            else
                " GCC and clang return the lists of files in different orders,
                " so we'll only grab the line number from lines which aren't
                " header files.
                if !s:IsHeaderFile(l:include_match[2])
                    " Get the line number out of the parsed include line,
                    " and reset the other variables.
                    let l:include_lnum = str2nr(l:include_match[3])
                endif

                let l:include_lines = []
                let l:included_filename = ''
            endif
        elseif l:include_lnum > 0
        \&& (empty(l:included_filename) || l:included_filename is# l:match[1])
            " If we hit the first error after an include header, or the
            " errors below have the same name as the first filename we see,
            " then include these lines, and remember what that filename was.
            let l:included_filename = l:match[1]
            call add(l:include_lines, l:line)
        else
            " If we hit a regular error again, then add the previously
            " collected lines as one error, and reset the include variables.
            call s:AddIncludedErrors(l:output, l:include_lnum, l:include_lines)
            let l:include_lnum = 0
            let l:include_lines = []
            let l:included_filename = ''

            if s:IsHeaderFile(bufname(bufnr('')))
            \&& l:match[5][:len(s:pragma_error) - 1] is# s:pragma_error
                continue
            endif

            let l:item = {
            \   'lnum': str2nr(l:match[2]),
            \   'type': l:match[4] =~# 'error' ? 'E' : 'W',
            \   'text': s:RemoveUnicodeQuotes(l:match[5]),
            \}

            if !empty(l:match[3])
                let l:item.col = str2nr(l:match[3])
            endif

            call add(l:output, l:item)
        endif
    endfor

    " Add remaining include errors after we go beyond the last line.
    call s:AddIncludedErrors(l:output, l:include_lnum, l:include_lines)

    return l:output
endfunction
