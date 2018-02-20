" Author: Christian Gibbons <cgibbons@gmu.edu>
" Description: flawfinder linter for c files

call ale#Set('c_flawfinder_executable', 'flawfinder')
call ale#Set('c_flawfinder_options', '')

function! ale_linters#c#flawfinder#GetExecutable(buffer) abort
   return ale#Var(a:buffer, 'c_flawfinder_executable')
endfunction

function! ale_linters#c#flawfinder#GetCommand(buffer) abort

   " Set the minimum vulnerability level for flawfinder to bother with
   " Default to level 1 as that is flawfinder's default level
   let l:minlevel = ' --minlevel='
   if exists('b:ale_c_flawfinder_minlevel')
      let l:minlevel = l:minlevel . b:ale_c_flawfinder_minlevel
   elseif exists('g:ale_c_flawfinder_minlevel')
      let l:minlevel = l:minlevel . g:ale_c_flawfinder_minlevel
   else
      let l:minlevel = l:minlevel . '1'
   endif

   return ale#Escape(ale_linters#c#flawfinder#GetExecutable(a:buffer))
   \  . ' -CDQS'
   \  . ale#Var(a:buffer, 'c_flawfinder_options')
   \  . l:minlevel
   \  . ' %t'
endfunction
      
call ale#linter#Define('c', {
\  'name': 'flawfinder',
\  'output_stream': 'stdout',
\  'executable_callback': 'ale_linters#c#flawfinder#GetExecutable',
\  'command_callback': 'ale_linters#c#flawfinder#GetCommand',
\  'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
