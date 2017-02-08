" Author: Joshua Rubin <joshua@rubixconsulting.com>
" Description: go build for Go files

" inspired by work from dzhou121 <dzhou121@gmail.com>

function! ale_linters#go#gobuild#GoEnv(buffer) abort
  if exists('g:ale_linters#go#gobuild#go_env')
    return ''
  endif

  return 'go env GOPATH GOROOT'
endfunction

let s:SplitChar = has('unix') ? ':' : ':'

" get a list of all source directories from $GOPATH and $GOROOT
function! s:SrcDirs() abort
  let l:paths = split(g:ale_linters#go#gobuild#go_env.GOPATH, s:SplitChar)
  call add(l:paths, g:ale_linters#go#gobuild#go_env.GOROOT)

  return l:paths
endfunction

" figure out from a directory like `/home/user/go/src/some/package` that the
" import for that path is simply `some/package`
function! ale_linters#go#gobuild#PackageImportPath(buffer) abort
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

function! ale_linters#go#gobuild#ParentImportPaths(buffer) abort
  let l:bufname = resolve(bufname(a:buffer))
  let l:pkgdir = fnamemodify(l:bufname, ':p:h')
  let l:importpath = ale_linters#go#gobuild#PackageImportPath(a:buffer)
  let l:output = []

  while stridx(l:importpath, '/') >= 0
    call add(l:output, l:importpath)
    let l:importpath = fnamemodify(l:importpath, ':h')
  endwhile

  call add(l:output, l:importpath)

  return l:output
endfunction

" get the go and test go files from the package
" will return empty list if the package has any cgo or other invalid files
function! ale_linters#go#gobuild#PkgFiles(buffer) abort
  let l:bufname = resolve(bufname(a:buffer))
  let l:pkgdir = fnamemodify(l:bufname, ':p:h')
  let l:files = []

  while index(s:SrcDirs(), l:pkgdir) == -1
    call extend(l:files, glob(l:pkgdir . '/*', 1, 1))
    let l:pkgdir = fnamemodify(l:pkgdir, ':h')
  endwhile

  call map(l:files, 'fnamemodify(resolve(v:val), '':p'')')
  call filter(l:files, '!isdirectory(v:val)')

  return {
  \   'srcdir': l:pkgdir,
  \   'files': map(l:files, 's:StripSrcDir(l:pkgdir, v:val)'),
  \ }
endfunction

function! s:StripSrcDir(srcdir, path) abort
  return a:path[strlen(a:srcdir)+strlen('/src/'):]
endfunction

function! s:ModifiedPackageBuffers(buffer) abort
  let l:importpaths = ale_linters#go#gobuild#ParentImportPaths(a:buffer)
  let l:output = []

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

    " only consider buffers if they have the same import path as a:buffer and
    " are modified

    let l:bufpkg = ale_linters#go#gobuild#PackageImportPath(l:bufnum)
    if index(l:importpaths, l:bufpkg) == -1
      continue
    endif

    if !getbufvar(l:bufnum, '&mod')
      continue
    endif

    call add(l:output, l:bufnum)
  endfor

  return l:output
endfunction

function! s:SymlinkFilesCmd(srcdir, destdir, files) abort
  " symlink the files to a temp directory with $GOPATH structure
  let l:cmds = []

  for l:file in a:files
    " TODO(jrubin) this will not work on windows
    " TODO(jrubin) no idea if this works on windows or if this will work on
    " shells like csh, ksh, fish, etc.
    call add(l:cmds, 'ln -s ' . shellescape(a:srcdir . '/src/' . l:file) . ' ' . shellescape(a:destdir . '/src/' . l:file))
  endfor

  return join(l:cmds, ';')
endfunction

function! ale_linters#go#gobuild#CopyFiles(buffer, goenv_output) abort
  let l:tempdir = tempname()
  let l:temppkgdir = l:tempdir . '/src/' . ale_linters#go#gobuild#PackageImportPath(a:buffer)
  call mkdir(l:temppkgdir, 'p', 0700)

  " get all files for the package
  let l:files = ale_linters#go#gobuild#PkgFiles(a:buffer)

  " don't include files that will be copied from buffers
  for l:bufnum in s:ModifiedPackageBuffers(a:buffer)
    let l:file = s:StripSrcDir(l:files.srcdir, fnamemodify(resolve(bufname(l:bufnum)), ':p'))
    let l:idx = index(l:files.files, l:file)

    if l:idx >= 0
      call remove(l:files.files, l:idx)
    endif
  endfor

  " TODO(jrubin) test when a package depends on a child package

  " symlink the files to a temp directory with $GOPATH structure
  return s:SymlinkFilesCmd(l:files.srcdir, l:tempdir, l:files.files) . ' ; echo ' . shellescape(l:tempdir)
endfunction

function! ale_linters#go#gobuild#WriteBuffers(buffer, copy_output) abort
  let l:tempdir = a:copy_output[0]
  let l:importpath = ale_linters#go#gobuild#PackageImportPath(a:buffer)

  " write the a:buffer and any modified buffers from the package to the tempdir
  for l:bufnum in s:ModifiedPackageBuffers(a:buffer)
    call writefile(getbufline(l:bufnum, 1, '$'), l:tempdir . '/src/' . ale_linters#go#gobuild#PkgFile(l:bufnum))
  endfor

  return 'echo ' . shellescape(l:tempdir)
endfunction

function! ale_linters#go#gobuild#GoPathCmd(tempdir, cmd) abort
  let l:gopaths = [ a:tempdir ]
  let l:gopathenv = shellescape(join(extend(l:gopaths, split(g:ale_linters#go#gobuild#go_env.GOPATH, s:SplitChar)), s:SplitChar))

  return 'GOPATH=' . l:gopathenv . ' ' . a:cmd
endfunction

function! ale_linters#go#gobuild#Install(buffer, write_output) abort
  let l:tempdir = a:write_output[0]
  let l:importpath = shellescape(ale_linters#go#gobuild#PackageImportPath(a:buffer))

  return ale_linters#go#gobuild#GoPathCmd(l:tempdir, 'go test -i ' . l:importpath) . ' ; ' .
        \ 'echo ' . shellescape(l:tempdir)
endfunction

function! ale_linters#go#gobuild#GetCommand(buffer, install_output) abort
  let l:tempdir = a:install_output[0]
  let l:importpath = shellescape(ale_linters#go#gobuild#PackageImportPath(a:buffer))

  return ale_linters#go#gobuild#GoPathCmd(l:tempdir, 'go test -c -o /dev/null ' . l:importpath)
endfunction

function! ale_linters#go#gobuild#PkgFile(buffer) abort
  let l:bufname = resolve(bufname(a:buffer))
  let l:importpath = ale_linters#go#gobuild#PackageImportPath(a:buffer)
  let l:fname = fnamemodify(l:bufname, ':t')

  return l:importpath . '/' . l:fname
endfunction

function! ale_linters#go#gobuild#FindBuffer(file) abort
  for l:buffer in range(1, bufnr('$'))
    if !buflisted(l:buffer)
      continue
    endif

    let l:pkgfile = ale_linters#go#gobuild#PkgFile(l:buffer)

    if a:file =~ '/' . l:pkgfile . '$'
      return l:buffer
    endif
  endfor

  return -1
endfunction

let s:path_pattern = '[a-zA-Z]\?\\\?:\?[[:alnum:]/\.\-_]\+'
let s:handler_pattern = '^\(' . s:path_pattern . '\):\(\d\+\):\?\(\d\+\)\?: \(.\+\)$'

function! ale_linters#go#gobuild#Handler(buffer, lines) abort
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
    \   'text': l:match[4],
    \   'type': 'E',
    \   'nr': -1,
    \})
  endfor

  return l:output
endfunction

call ale#linter#Define('go', {
\   'name': 'go build',
\   'executable': 'go',
\   'command_chain': [
\     {'callback': 'ale_linters#go#gobuild#GoEnv'},
\     {'callback': 'ale_linters#go#gobuild#CopyFiles'},
\     {'callback': 'ale_linters#go#gobuild#WriteBuffers'},
\     {'callback': 'ale_linters#go#gobuild#Install'},
\     {'callback': 'ale_linters#go#gobuild#GetCommand', 'output_stream': 'stderr'},
\   ],
\   'callback': 'ale_linters#go#gobuild#Handler',
\})
