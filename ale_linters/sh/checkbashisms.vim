" Author: Ross Williams <ross@ross-williams.net>
" Description: Lints sh files using checkbashisms
" URL: https://launchpad.net/ubuntu/+source/devscripts/
" Notes:      checkbashisms.pl can be downloaded from
"             http://debian.inode.at/debian/pool/main/d/devscripts/
"             as part of the devscripts package.

call ale#Set('sh_checkbashisms_executable', 'checkbashisms')
call ale#Set('sh_checkbashisms_options', '-fx')

function! ale_linters#sh#checkbashisms#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'sh_checkbashisms_executable')
endfunction

function! ale_linters#sh#checkbashisms#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'sh_checkbashisms_options')
    let l:executable = ale_linters#sh#checkbashisms#GetExecutable(a:buffer)

    return ale#Escape(l:executable) . ' ' . l:options . ' ' . '-'
endfunction

function! ale_linters#sh#checkbashisms#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " error: script.sh: unclosed parentheses, opened in line 2
    " error: script.sh: parsing failed
    " cannot open script script.sh for reading: invalid permissions
    " possible bashism in script.sh line 123 ('command' with option other than -p):
    let l:err_pattern  = '\v^(error): (.*): (.*)'
    let l:err_line_pattern  = '\v^(error): (.*): (.*), opened in line (\d+)'
    let l:warn_pattern = '\v^(possible bashism) in (.*) line (\d+) \((.*)\):'
    let l:fail_pattern = '\v^(cannot open) script (.*) for reading: (.*)'

    let l:output = []

    let l:curdir = expand('#' . a:buffer . ':p:h')

    for l:match in ale#util#GetMatches(a:lines, [l:err_pattern,l:err_line_pattern,l:warn_pattern,l:fail_pattern])
      if !empty(l:match[1])
        if l:match[1] ==# 'error'
          if !empty(l:match[4])
            call add(l:output, {
            \   'lnum': str2nr(l:match[4]),
            \   'text': l:match[3],
            \})
          else
            call add(l:output, {
            \   'lnum': 0,
            \   'text': l:match[3],
            \})
          endif
        elseif l:match[1] ==# 'cannot open'
          call add(l:output, {
          \   'lnum': 0,
          \   'text': 'cannot open script for reading: ' . l:match[3],
          \})
        elseif l:match[1] ==# 'possible bashism'
          call add(l:output, {
          \   'lnum': str2nr(l:match[3]),
          \   'text': l:match[1] . ': ' . l:match[4],
          \   'type': 'W',
          \})
        else
        endif
      endif
    endfor

    return l:output
endfunction

call ale#linter#Define('sh', {
\   'name': 'checkbashisms',
\   'output_stream': 'stderr',
\   'executable': function('ale_linters#sh#checkbashisms#GetExecutable'),
\   'command': function('ale_linters#sh#checkbashisms#GetCommand'),
\   'callback': 'ale_linters#sh#checkbashisms#Handle',
\})
