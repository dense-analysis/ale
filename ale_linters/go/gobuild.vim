" Author: Joshua Rubin <joshua@rubixconsulting.com>, Ben Reedy <https://github.com/breed808>
" Description: go build for Go files

" inspired by work from dzhou121 <dzhou121@gmail.com>

function! ale_linters#go#gobuild#GoEnv(buffer) abort
  if exists('s:go_env')
    return ''
  endif

  return 'go env GOPATH GOROOT'
endfunction

function! ale_linters#go#gobuild#GetCommand(buffer, goenv_output) abort
  if !exists('s:go_env')
    let s:go_env = {
    \ 'GOPATH': a:goenv_output[0],
    \ 'GOROOT': a:goenv_output[1],
    \}
  endif

  return 'GOPATH=' . s:go_env.GOPATH . ' go test -c -o /dev/null %s'
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'executable': 'go',
\   'command_chain': [
\     {'callback': 'ale_linters#go#gobuild#GoEnv', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#GetCommand', 'output_stream': 'stderr'},
\   ],
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\   'lint_file': 1,
\})
