" Author: hauleth - https://github.com/hauleth
" Author: archseer - https://github.com/archSeer

function! ale_linters#elixir#credo#GetType(category) abort
  if a:category is# 'consistency'
    return 'E'
  else
    return 'W'
  endif
endfunction

function! ale_linters#elixir#credo#Handle(buffer, lines) abort
    try
        let l:errors = json_decode(join(a:lines, ''))
    catch
        return []
    endtry

    let l:output = []

    for l:error in l:errors['issues']
      echo(l:error)
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:error['line_no'] + 0,
        \   'col': l:error['column'] + 0,
        \   'end_col': l:error['column_end'] - 1,
        \   'code': l:error['check'],
        \   'text': l:error['message'],
        \   'type': ale_linters#elixir#credo#GetType(l:error['category']),
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('elixir', {
\   'name': 'credo',
\   'executable': 'mix',
\   'command': 'mix help credo && mix credo suggest --format=json --read-from-stdin %s',
\   'callback': 'ale_linters#elixir#credo#Handle',
\})
