" Author: Joshua Rubin <joshua@rubixconsulting.com>
" Description: go build for Go files

" inspired by work from dzhou121 <dzhou121@gmail.com>

function! ale_linters#go#gobuild#GoEnv(buffer) abort
  if exists('s:go_env')
    return ''
  endif

  return 'go env GOPATH GOROOT'
endfunction

let s:SplitChar = has('unix') ? ':' : ':'

" get a list of all source directories from $GOPATH and $GOROOT
function! s:SrcDirs() abort
  let l:paths = split(s:go_env.GOPATH, s:SplitChar)
  call add(l:paths, s:go_env.GOROOT)

  return l:paths
endfunction

" figure out from a directory like `/home/user/go/src/some/package` that the
" import for that path is simply `some/package`
function! s:PackageImportPath(buffer) abort
  let l:bufname = resolve(bufname(a:buffer))
  let l:pkgdir = fnamemodify(l:bufname, ':p:h')

  for l:path in s:SrcDirs()
    let l:path = l:path . '/src/'

    if stridx(l:pkgdir, l:path) == 0
      return l:pkgdir[strlen(l:path):]
    endif
  endfor

  return ''
endfunction

" get the package info data structure using `go list`
function! ale_linters#go#gobuild#GoList(buffer, goenv_output) abort
  if !empty(a:goenv_output)
    let s:go_env = {
    \ 'GOPATH': a:goenv_output[0],
    \ 'GOROOT': a:goenv_output[1],
    \}
  endif

  return 'go list -json ' . shellescape(s:PackageImportPath(a:buffer))
endfunction

let s:filekeys = [
\ 'GoFiles',
\ 'CgoFiles',
\ 'CFiles',
\ 'CXXFiles',
\ 'MFiles',
\ 'HFiles',
\ 'FFiles',
\ 'SFiles',
\ 'SwigFiles',
\ 'SwigCXXFiles',
\ 'SysoFiles',
\ 'TestGoFiles',
\ 'XTestGoFiles',
\]

" get the go and test go files from the package
" will return empty list if the package has any cgo or other invalid files
function! s:PkgFiles(pkginfo) abort
  let l:files = []

  for l:key in s:filekeys
    if has_key(a:pkginfo, l:key)
      call extend(l:files, a:pkginfo[l:key])
    endif
  endfor

  " resolve the path of the file relative to the window directory
  return map(l:files, 'shellescape(fnamemodify(resolve(a:pkginfo.Dir . ''/'' . v:val), '':p''))')
endfunction

function! ale_linters#go#gobuild#CopyFiles(buffer, golist_output) abort
  let l:tempdir = tempname()
  let l:temppkgdir = l:tempdir . '/src/' . s:PackageImportPath(a:buffer)
  call mkdir(l:temppkgdir, 'p', 0700)

  if empty(a:golist_output)
    return 'echo ' . shellescape(l:tempdir)
  endif

  " parse the output
  let l:pkginfo = json_decode(join(a:golist_output, "\n"))

  " get all files for the package
  let l:files = s:PkgFiles(l:pkginfo)

  " copy the files to a temp directory with $GOPATH structure
  return 'cp ' . join(l:files, ' ') . ' ' . shellescape(l:temppkgdir) . ' && echo ' . shellescape(l:tempdir)
endfunction

function! ale_linters#go#gobuild#GetCommand(buffer, copy_output) abort
  let l:tempdir = a:copy_output[0]
  let l:importpath = s:PackageImportPath(a:buffer)

  " write the a:buffer and any modified buffers from the package to the tempdir
  for l:bufnum in range(1, bufnr('$'))
    " ignore unloaded buffers (can't be a:buffer or a modified buffer)
    if !bufloaded(l:bufnum)
      continue
    endif

    " ignore non-Go buffers
    if getbufvar(l:bufnum, '&ft') !=# 'go'
      continue
    endif

    " only consider buffers other than a:buffer if they have the same import
    " path as a:buffer and are modified
    if l:bufnum != a:buffer
      if s:PackageImportPath(l:bufnum) !=# l:importpath
        continue
      endif

      if !getbufvar(l:bufnum, '&mod')
        continue
      endif
    endif

    call writefile(getbufline(l:bufnum, 1, '$'), l:tempdir . '/src/' . s:PkgFile(l:bufnum))
  endfor

  let l:gopaths = [ l:tempdir ]
  call extend(l:gopaths, split(s:go_env.GOPATH, s:SplitChar))

  return 'GOPATH=' . shellescape(join(l:gopaths, s:SplitChar)) . ' go test -c -o /dev/null ' . shellescape(l:importpath)
endfunction

function! s:PkgFile(buffer) abort
  let l:bufname = resolve(bufname(a:buffer))
  let l:importpath = s:PackageImportPath(a:buffer)
  let l:fname = fnamemodify(l:bufname, ':t')

  return l:importpath . '/' . l:fname
endfunction

function! s:FindBuffer(file) abort
  for l:buffer in range(1, bufnr('$'))
    if !buflisted(l:buffer)
      continue
    endif

    let l:pkgfile = s:PkgFile(l:buffer)

    if a:file =~ '/' . l:pkgfile . '$'
      return l:buffer
    endif
  endfor

  return -1
endfunction

let s:path_pattern = '[a-zA-Z]\?\\\?:\?[[:alnum:]/\.\-_]\+'
let s:handler_pattern = '^\(' . s:path_pattern . '\):\(\d\+\):\?\(\d\+\)\?: \(.\+\)$'

let s:multibuffer = 0

function! ale_linters#go#gobuild#Handler(buffer, lines) abort
  let l:output = []

  for l:line in a:lines
    let l:match = matchlist(l:line, s:handler_pattern)

    if len(l:match) == 0
      continue
    endif

    let l:buffer = s:FindBuffer(l:match[1])

    if l:buffer == -1
      continue
    endif

    if !s:multibuffer && l:buffer != a:buffer
      " strip lines from other buffers
      continue
    endif

    call add(l:output, {
    \   'bufnr': l:buffer,
    \   'lnum': l:match[2] + 0,
    \   'col': l:match[3] + 0,
    \   'text': l:match[4],
    \   'type': 'E',
    \})
  endfor

  return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'executable': 'go',
\   'command_chain': [
\     {'callback': 'ale_linters#go#gobuild#GoEnv', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#GoList', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#CopyFiles', 'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#GetCommand', 'output_stream': 'stderr'},
\   ],
\   'callback': 'ale_linters#go#gobuild#Handler',
\})
