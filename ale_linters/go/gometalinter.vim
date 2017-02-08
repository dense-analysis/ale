let s:SplitChar = has('unix') ? ':' : ':'

let g:ale_linters#go#gometalinter#args = get(g:, 'ale_linters#go#gometalinter#args', [
\   '--fast',
\   '--tests',
\ ])

function! s:Args() abort
  return join(map(copy(g:ale_linters#go#gometalinter#args), 'shellescape(v:val)'), ' ')
endfunction

function! ale_linters#go#gometalinter#GetCommand(buffer, copy_output) abort
  let l:tempdir = a:copy_output[0]
  let l:importpath = ale_linters#go#gobuild#PackageImportPath(a:buffer)
  let l:gopaths = [ l:tempdir ]
  call extend(l:gopaths, split(g:ale_linters#go#gobuild#go_env.GOPATH, s:SplitChar))

  return 'GOPATH=' . shellescape(join(l:gopaths, s:SplitChar)) . ' gometalinter ' . s:Args() . ' ' . shellescape(l:tempdir . '/src/' . l:importpath)
endfunction

let s:path_pattern = '[a-zA-Z]\?\\\?:\?[[:alnum:]/\.\-_]\+'
let s:handler_pattern = '^\(' . s:path_pattern . '\):\(\d\+\):\?\(\d\+\)\?:\?\([a-zA-Z]\+\): \(.\+\)$'

function! ale_linters#go#gometalinter#Handler(buffer, lines) abort
  let l:output = []

  for l:line in a:lines
    let l:match = matchlist(l:line, s:handler_pattern)

    if len(l:match) == 0
      continue
    endif

    let l:buffer = ale_linters#go#gobuild#FindBuffer(l:match[1])

    if l:buffer == -1
      continue
    endif

    if !get(g:, 'ale_experimental_multibuffer', 0) && l:buffer != a:buffer
      " strip lines from other buffers
      continue
    endif

    call add(l:output, {
    \   'bufnr': l:buffer,
    \   'lnum': l:match[2] + 0,
    \   'vcol': 0,
    \   'col': l:match[3] + 0,
    \   'text': l:match[5],
    \   'type': toupper(l:match[4][0]),
    \   'nr': -1,
    \})
  endfor

  return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'gometalinter',
\   'executable': 'gometalinter',
\   'command_chain': [
\     {'callback': 'ale_linters#go#gobuild#GoEnv', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#GoList', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#CopyFiles', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#WriteBuffers', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gometalinter#GetCommand', 'output_stream': 'stdout'},
\   ],
\   'callback': 'ale_linters#go#gometalinter#Handler',
\})
