" Author: Christian Gibbons <cgibbons@gmu.edu>
" Description: flawfinder linter for c++ files

call ale#Set('cpp_flawfinder_executable', 'flawfinder')
call ale#Set('cpp_flawfinder_options', '')

function! ale_linters#cpp#flawfinder#GetExecutable(buffer) abort
   return ale#Var(a:buffer, 'cpp_flawfinder_executable')
endfunction

function! ale_linters#cpp#flawfinder#GetCommand(buffer) abort

   " Set the minimum vulnerability level for flawfinder to bother with
   " Default to level 1 as that is flawfinder's default level
   let l:minlevel = ' --minlevel='
   if exists('b:ale_cpp_flawfinder_minlevel')
      let l:minlevel = l:minlevel . b:ale_cpp_flawfinder_minlevel
   elseif exists('g:ale_cpp_flawfinder_minlevel')
      let l:minlevel = l:minlevel . g:ale_cpp_flawfinder_minlevel
   else
      let l:minlevel = l:minlevel . '1'
   endif

   return ale#Escape(ale_linters#cpp#flawfinder#GetExecutable(a:buffer))
   \  . ' -CDQS'
   \  . ale#Var(a:buffer, 'cpp_flawfinder_options')
   \  . l:minlevel
   \  . ' %t'
endfunction
      
call ale#linter#Define('cpp', {
\  'name': 'flawfinder',
\  'output_stream': 'stdout',
\  'executable_callback': 'ale_linters#cpp#flawfinder#GetExecutable',
\  'command_callback': 'ale_linters#cpp#flawfinder#GetCommand',
\  'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})

