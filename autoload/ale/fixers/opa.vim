" Author: Peter Benjamin <petermbenjamin@gmail.com>
 " Description: Integration of opa fmt (rego formatter) with ALE.

 call ale#Set('rego_opa_executable', 'opa fmt')
 call ale#Set('rego_opa_options', '')

 function! ale#fixers#regofmt#Fix(buffer) abort
     let l:executable = ale#Var(a:buffer, 'rego_opa_executable')
     let l:options = ale#Var(a:buffer, 'rego_opa_options')

     return {
     \   'command': ale#Escape(l:executable)
     \       . ' -l -w'
     \       . (empty(l:options) ? '' : ' ' . l:options)
     \}
 endfunction
