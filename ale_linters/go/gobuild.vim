" Author: Joshua Rubin <joshua@rubixconsulting.com>
" Description: go build for Go files

" inspired by work from dzhou121 <dzhou121@gmail.com>

function! s:goenv()
  if exists('s:go_env')
    return s:go_env
  endif

  let l:env = systemlist('go env GOPATH GOROOT')

  let s:go_env = {
  \ 'GOPATH': l:env[0],
  \ 'GOROOT': l:env[1],
  \}

  return s:go_env
endfunction

let s:splitchar = ':'
if !has('unix')
  let s:splitchar = ';'
endif

" get a list of all source directories from $GOPATH and $GOROOT
function! s:srcdirs()
  let l:env = s:goenv()
  let l:paths = split(l:env.GOPATH, s:splitchar)
  call add(l:paths, l:env.GOROOT)
  return l:paths
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

" get the package info data structure using `go list`
function! ale_linters#go#gobuild#GoList(buffer) abort
  let l:bufname = resolve(bufname(a:buffer))
  let l:pkgdir = fnamemodify(l:bufname, ':p:h')
  return 'go list -json ' . s:pkgimportpath(l:pkgdir)
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
function! s:pkgfiles(pkginfo)
  let l:files = []
  for l:key in s:filekeys
    if has_key(a:pkginfo, l:key)
      call extend(l:files, a:pkginfo[l:key])
    endif
  endfor

  " resolve the path of the file relative to the window directory
  return map(l:files, 'shellescape(fnamemodify(resolve(a:pkginfo.Dir . "/" . v:val), ":p"))')
endfunction

function! ale_linters#go#gobuild#CopyFiles(buffer, golist_output) abort
  " concatenate the output
  let l:pkginfo = json_decode(join(a:golist_output, "\n"))

  " get all files for the package
  let l:files = s:pkgfiles(l:pkginfo)

  " copy the files to a temp directory with $GOPATH structure
  let l:tempdir = tempname()
  let l:temppkgdir = l:tempdir . '/src/' . s:pkgimportpath(l:pkginfo.Dir)
  call mkdir(l:temppkgdir, "p", 0700)

  return 'cp ' . join(l:files, ' ') . ' ' . shellescape(l:temppkgdir) . ' && echo ' . shellescape(l:tempdir)
endfunction

function! ale_linters#go#gobuild#GetCommand(buffer, copy_output) abort
  let l:tempdir = a:copy_output[0]
  let l:bufname = resolve(bufname(a:buffer))
  let l:pkgdir = fnamemodify(l:bufname, ':p:h')
  let l:importpath = s:pkgimportpath(l:pkgdir)
  let l:temppkgdir = l:tempdir . '/src/' . l:importpath

  " the basename of the go file
  let l:fname = fnamemodify(l:bufname, ':t')

  " write the buffer to the tempdir
  call writefile(getbufline(a:buffer, 1, '$'), l:temppkgdir . '/' . l:fname)

  return 'GOPATH="' . l:tempdir . ':${GOPATH}" go test -c -o /dev/null ' . l:importpath
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'executable': 'go',
\   'command_chain': [
\     {'callback': 'ale_linters#go#gobuild#GoList',     'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#CopyFiles',  'output_stream': 'stdout'},
\     {'callback': 'ale_linters#go#gobuild#GetCommand', 'output_stream': 'stderr'},
\   ],
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
