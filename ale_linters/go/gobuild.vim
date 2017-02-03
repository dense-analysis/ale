" Author: Joshua Rubin <joshua@rubixconsulting.com>
" Description: go build for Go files

" inspired by work from dzhou121 <dzhou121@gmail.com>

" This comes straight out of syntastic.
function! s:devnull() abort
    if has('unix')
      return '/dev/null'
    endif

    " assume windows
    return 'NUL'
endfunction

" get a list of all source directories from $GOPATH and $GOROOT
function! s:srcdirs()
  let l:srcdirs = []

  for val in systemlist('go env GOPATH GOROOT')
    if has('unix')
      let l:paths = split(val, ':')
    else
      let l:paths = split(val, ';')
    endif

    call extend(l:srcdirs, l:paths)
  endfor
 
  return l:srcdirs
endfunction

" figure out from a directory like `/home/user/go/src/some/package` that the
" import for that path is simply `some/package`
function! s:pkgimportpath(pkgdir)
  for path in s:srcdirs()
    let path = path . '/src/'
    if stridx(a:pkgdir, path) == 0
      return a:pkgdir[strlen(path):]
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

  for key in l:invalid
    if has_key(l:pkginfo, key) && !empty(l:pkginfo[key])
      " `go tool compile` will not work with this package
      return []
    endif
  endfor

  let l:files = []
  for key in [ 'GoFiles', 'TestGoFiles' ]
    if has_key(l:pkginfo, key)
      call extend(l:files, l:pkginfo[key])
    endif
  endfor

  " resolve the path of the file relative to the window directory
  return map(l:files, 'fnamemodify(resolve(l:pkginfo.Dir . "/" . v:val), ":.")')
endfunction

function! ale_linters#go#gobuild#GetCommand(buffer) abort
  let l:bufname = resolve(bufname(a:buffer))

  " get all files for the package
  let l:files = s:pkgfiles(fnamemodify(l:bufname, ':p:h'))

  " the package can't be compiled by `go tool compile`
  if empty(l:files)
    return ''
  endif

  " `go install` all dependencies so that `go tool compile` can work
  " TODO(jrubin) this would be good to chain
  call system('go test -i')

  " the basename of the go file
  let l:fname = fnamemodify(l:bufname, ':p:t')

  " filter out the buffer file itself from the list
  call filter(l:files, 'fnamemodify(v:val, '':t'') != l:fname')

  " e.g. linux_amd64
  let l:osarch = join(systemlist('go env GOOS GOARCH'), '_')
  let l:import_args = map(copy(s:srcdirs()), '"-I " . v:val . "/pkg/" . l:osarch')

  return g:ale#util#stdin_wrapper . ' .go go tool compile ' . join(l:import_args) . ' -o ' . s:devnull() . ' ' . join(l:files)
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'output_stream': 'stdout',
\   'executable': 'go',
\   'command_callback': 'ale_linters#go#gobuild#GetCommand',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
