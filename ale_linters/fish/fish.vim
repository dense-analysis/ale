" Author: Niraj Thapaliya - https://github.com/nthapaliya
" Description: Lints fish files using fish -n

function! ale_linters#fish#fish#Handle(buffer, lines) abort
    " Matches patterns such as:
    "
    " home/.config/fish/functions/foo.fish (line 1): Missing end to balance this function definition
    " function foo
    " ^
    " <W> fish: Error while reading file .config/fish/functions/foo.fish
    let l:pattern = '^.* (line \(\d\+\)): \(.*\)$'
    let l:output = []

    let l:i = 0
    while l:i < len(a:lines)
      let l:match = matchlist(a:lines[l:i], l:pattern)
      if len(l:match) && len(l:match[2])
        call add(l:output, {
              \  'col': len(a:lines[l:i + 2]),
              \  'lnum': str2nr(l:match[1]),
              \  'text': l:match[2],
              \})
      endif
      let l:i += 1
    endwhile

    return l:output
endfunction

call ale#linter#Define('fish', {
\   'name': 'fish',
\   'output_stream': 'stderr',
\   'executable': 'fish',
\   'command': 'fish -n %t',
\   'callback': 'ale_linters#fish#fish#Handle',
\})
