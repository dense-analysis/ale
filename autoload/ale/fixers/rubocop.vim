function! ale#fixers#rubocop#Fix(buffer) abort
  let l:executable = ale_linters#ruby#rubocop#GetExecutable(a:buffer)

  echo l:executable

  return {
        \   'command': ale#Escape(l:executable)
        \       . ' --auto-correct %t',
        \   'read_temporary_file': 1,
        \}
endfunction
