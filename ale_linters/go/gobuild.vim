" Author: Joshua Rubin <joshua@rubixconsulting.com>
" Description: go build for Go files

" inspired by work from dzhou121 <dzhou121@gmail.com>

" get a list of all source directories from $GOPATH and $GOROOT
function! s:srcdirs()
  if exists('s:src_dirs')
    return s:src_dirs
  endif

  let s:src_dirs = []
  for l:val in systemlist('go env GOPATH GOROOT')
    if has('unix')
      let l:paths = split(l:val, ':')
    else
      let l:paths = split(l:val, ';')
    endif

    call extend(s:src_dirs, l:paths)
  endfor

  return s:src_dirs
endfunction

function! s:osarch()
  if exists('s:os_arch')
    return s:os_arch
  endif

  let s:os_arch = join(systemlist('go env GOOS GOARCH'), '_')
  return s:os_arch
endfunction

" figure out from a directory like `/home/user/go/src/some/package` that the
" import for that path is simply `some/package`
function! s:pkgimportpath(pkgdir)
  for l:path in s:srcdirs()
    let l:path = l:path . '/src/'
    if stridx(a:pkgdir, l:path) == 0
      return a:pkgdir[strlen(l:path):]
    endif
  endfor
endfunction

python import vim
python import json

" get the package info data structure using `go list`
" TODO(jrubin) this would be good to chain
function! s:pkginfo(pkgdir)
  let l:importpath = s:pkgimportpath(a:pkgdir)
  let l:json = system('go list -json ' . l:importpath)
  return pyeval('json.loads(vim.eval("l:json"))')
endfunction

" get the go and test go files from the package
" will return empty list if the package has any cgo or other invalid files
function! s:pkgfiles(pkgdir)
  " get the package info data structure from `go list`
  let l:pkginfo = s:pkginfo(a:pkgdir)

  let l:invalid = [
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
        \ 'XTestGoFiles',
        \]

  for l:key in l:invalid
    if has_key(l:pkginfo, l:key) && !empty(l:pkginfo[l:key])
      " `go tool compile` will not work with this package
      return []
    endif
  endfor

  let l:files = []
  for l:key in [ 'GoFiles', 'TestGoFiles' ]
    if has_key(l:pkginfo, l:key)
      call extend(l:files, l:pkginfo[l:key])
    endif
  endfor

  " resolve the path of the file relative to the window directory
  return map(l:files, 'fnamemodify(resolve(l:pkginfo.Dir . "/" . v:val), ":.")')
endfunction

function! ale_linters#go#gobuild#GetCommand(buffer) abort
  let l:bufname = resolve(bufname(a:buffer))
  let l:pkgdir = fnamemodify(l:bufname, ':p:h')

  " get all files for the package
  let l:files = s:pkgfiles(l:pkgdir)

  " the package can't be compiled by `go tool compile`
  if empty(l:files)
    return ''
  endif

  " `go install` all dependencies so that `go tool compile` can work
  " TODO(jrubin) this would be good to chain
  call system('go test -i ' . s:pkgimportpath(l:pkgdir))

  " the basename of the go file
  let l:fname = fnamemodify(l:bufname, ':p:t')

  " filter out the buffer file itself from the list
  call filter(l:files, 'fnamemodify(v:val, '':t'') != l:fname')

  " e.g. linux_amd64
  let l:import_args = map(copy(s:srcdirs()), '"-I " . v:val . "/pkg/" . s:osarch()')

  return g:ale#util#stdin_wrapper . ' .go go tool compile ' . join(l:import_args) . ' -o /dev/null ' . join(l:files)
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'output_stream': 'stdout',
\   'executable': 'go',
\   'command_callback': 'ale_linters#go#gobuild#GetCommand',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
