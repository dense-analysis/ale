function ale#racket#FindProjectRoot(buffer) abort
  let l:nearest_init = ale#path#FindNearestFile(a:buffer, 'init.rkt')
  let l:cwd = expand('#' . a:buffer . ':p:h')
  return empty(l:nearest_init) ? l:cwd : l:nearest_init
endfunction
