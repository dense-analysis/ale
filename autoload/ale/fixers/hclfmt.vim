" Author: Peter Benjamin <petermbenjamin@kourouma.me>
" Description: Integration of hclfmt with ALE.

call ale#Set('hcl_hclfmt_executable', 'hclfmt')

function! ale#fixers#hclfmt#Fix(buffer) abort
  let l:executable = ale#Var(a:buffer, 'hcl_hclfmt_executable')

  return {
        \ 'command': ale#Escape(l:executable)
        \     . ' -w'
        \     . ' %t',
        \     'read_temporay_file': 1,
        \}
endfunction
