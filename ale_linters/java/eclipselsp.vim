" Author: Horacio Sanson <https://github.com/hsanson>
" Description: Support for the Eclipse language server https://github.com/eclipse/eclipse.jdt.ls

let s:version_cache = {}

call ale#Set('java_eclipselsp_path', ale#path#Simplify($HOME . '/eclipse.jdt.ls'))
call ale#Set('java_eclipselsp_config_path', '')
call ale#Set('java_eclipselsp_workspace_path', '')
call ale#Set('java_eclipselsp_executable', 'java')
call ale#Set('java_eclipselsp_javaagent', '')

function! ale_linters#java#eclipselsp#Executable(buffer) abort
    return ale#Var(a:buffer, 'java_eclipselsp_executable')
endfunction

function! ale_linters#java#eclipselsp#TargetPath(buffer) abort
    return ale#Var(a:buffer, 'java_eclipselsp_path')
endfunction

function! ale_linters#java#eclipselsp#JarPath(buffer) abort
    let l:path = ale_linters#java#eclipselsp#TargetPath(a:buffer)

    if has('win32')
        let l:platform = 'win32'
    elseif has('macunix')
        let l:platform = 'macosx'
    else
        let l:platform = 'linux'
    endif

    " Search jar file within repository path when manually built using mvn
    let l:files = globpath(l:path, '**/'.l:platform.'/**/plugins/org.eclipse.equinox.launcher_*\.jar', 1, 1)

    if len(l:files) >= 1
        return l:files[0]
    endif

    " Search jar file within VSCode extensions folder.
    let l:files = globpath(l:path, '**/'.l:platform.'/plugins/org.eclipse.equinox.launcher_*\.jar', 1, 1)

    if len(l:files) >= 1
        return l:files[0]
    endif

    " Search jar file within unzipped tar.gz file
    let l:files = globpath(l:path, 'plugins/org.eclipse.equinox.launcher_*\.jar', 1, 1)

    if len(l:files) >= 1
        return l:files[0]
    endif

    " Search jar file within system package path
    let l:files = globpath('/usr/share/java/jdtls/plugins', 'org.eclipse.equinox.launcher_*\.jar', 1, 1)

    if len(l:files) >= 1
        return l:files[0]
    endif

    return ''
endfunction

function! ale_linters#java#eclipselsp#ConfigurationPath(buffer) abort
    let l:path = fnamemodify(ale_linters#java#eclipselsp#JarPath(a:buffer), ':p:h:h')
    let l:config_path = ale#Var(a:buffer, 'java_eclipselsp_config_path')

    if !empty(l:config_path)
        return ale#path#Simplify(l:config_path)
    endif

    if has('win32')
        let l:path = l:path . '/config_win'
    elseif has('macunix')
        let l:path = l:path . '/config_mac'
    else
        let l:path = l:path . '/config_linux'
    endif

    return ale#path#Simplify(l:path)
endfunction

function! ale_linters#java#eclipselsp#VersionCheck(version_lines) abort
    return s:GetVersion('', a:version_lines)
endfunction

function! s:GetVersion(executable, version_lines) abort
    let l:version = []

    for l:line in a:version_lines
        let l:match = matchlist(l:line, '\(\d\+\)\.\(\d\+\)\.\(\d\+\)')

        if !empty(l:match)
            let l:version = [l:match[1] + 0, l:match[2] + 0, l:match[3] + 0]
            let s:version_cache[a:executable] = l:version
            break
        endif
    endfor

    return l:version
endfunction

function! ale_linters#java#eclipselsp#CommandWithVersion(buffer, version_lines, meta) abort
    let l:executable = ale_linters#java#eclipselsp#Executable(a:buffer)
    let l:version = s:GetVersion(l:executable, a:version_lines)

    return ale_linters#java#eclipselsp#Command(a:buffer, l:version)
endfunction

function! ale_linters#java#eclipselsp#WorkspacePath(buffer) abort
    let l:wspath = ale#Var(a:buffer, 'java_eclipselsp_workspace_path')

    if !empty(l:wspath)
        return l:wspath
    endif

    return ale#path#Dirname(ale#java#FindProjectRoot(a:buffer))
endfunction

function! ale_linters#java#eclipselsp#Javaagent(buffer) abort
    let l:rets = []
    let l:raw = ale#Var(a:buffer, 'java_eclipselsp_javaagent')

    if empty(l:raw)
        return ''
    endif

    let l:jars = split(l:raw)

    for l:jar in l:jars
        call add(l:rets, ale#Escape('-javaagent:' . l:jar))
    endfor

    return join(l:rets, ' ')
endfunction

function! ale_linters#java#eclipselsp#Command(buffer, version) abort
    let l:path = ale#Var(a:buffer, 'java_eclipselsp_path')

    let l:executable = ale_linters#java#eclipselsp#Executable(a:buffer)

    let l:cmd = [ ale#Escape(l:executable),
    \ ale_linters#java#eclipselsp#Javaagent(a:buffer),
    \ '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    \ '-Dosgi.bundles.defaultStartLevel=4',
    \ '-Declipse.product=org.eclipse.jdt.ls.core.product',
    \ '-Dlog.level=ALL',
    \ '-noverify',
    \ '-Xmx1G',
    \ '-jar',
    \ ale#Escape(ale_linters#java#eclipselsp#JarPath(a:buffer)),
    \ '-configuration',
    \ ale#Escape(ale_linters#java#eclipselsp#ConfigurationPath(a:buffer)),
    \ '-data',
    \ ale#Escape(ale_linters#java#eclipselsp#WorkspacePath(a:buffer))
    \ ]

    if ale#semver#GTE(a:version, [1, 9])
        call add(l:cmd, '--add-modules=ALL-SYSTEM')
        call add(l:cmd, '--add-opens java.base/java.util=ALL-UNNAMED')
        call add(l:cmd, '--add-opens java.base/java.lang=ALL-UNNAMED')
    endif

    return join(l:cmd, ' ')
endfunction

function! ale_linters#java#eclipselsp#RunWithVersionCheck(buffer) abort
    let l:executable = ale_linters#java#eclipselsp#Executable(a:buffer)

    if empty(l:executable)
        return ''
    endif

    let l:cache = s:version_cache

    if has_key(s:version_cache, l:executable)
        return ale_linters#java#eclipselsp#Command(a:buffer, s:version_cache[l:executable])
    endif

    let l:command = ale#Escape(l:executable) . ' -version'

    return ale#command#Run(
    \ a:buffer,
    \ l:command,
    \ function('ale_linters#java#eclipselsp#CommandWithVersion'),
    \ { 'output_stream': 'both' }
    \)
endfunction

function! s:JDTToPath(uri) abort
    let l:uri = ale#uri#Decode(a:uri)

    let l:scheme = a:uri[:5]
    let l:auth_path = a:uri[6:stridx(a:uri, '?')-1]
    let l:query = a:uri[stridx(a:uri, '?')+1:]

    " do not allow ["*:<>?|] in authority and path sections
    let l:auth_path = substitute(l:auth_path, '\(["*:<>?|]\)', '\=printf("%%%x", char2nr(submatch(1)))', 'g')
    " do not allow ["*:<>|?\/] in query section
    let l:query = substitute(l:query, '\(["*:<>?|\\/]\)', '\=printf("%%%x", char2nr(submatch(1)))', 'g')

    let l:path = l:scheme . l:auth_path . '%3f' . l:query

    return l:path
endfunction

function! s:PathToJDT(path) abort
    let l:uri = substitute(a:path, '%3f', '?', 'g')

    return l:uri
endfunction

function! s:OpenJDTLink(root, filename, line, column, options, result) abort
    " Display java file from jar library as part of current project.
    if has_key(a:result, 'error')
        echoerr a:result.error.message
        return
    endif

    let l:contents = a:result['result']

    if type(l:contents) ==# type(v:null)
        echoerr 'File content not found'
    endif

    call ale#util#Open(a:filename, a:line, a:column, a:options)

    if !empty(getbufvar(bufnr(''), 'ale_lsp_root', ''))
        return
    endif

    let b:ale_lsp_root = a:root
    set filetype=java
    call setline(1, split(l:contents, '\n'))
    call cursor(a:line, a:column)
    normal! zz

    setlocal buftype=nofile nomodified nomodifiable readonly
endfunction

function! ale_linters#java#eclipselsp#HandleJdt(root, line, column, options, uri)
    " load new buffer with contents of 'l:uri'
    let l:filename = s:JDTToPath(a:uri)
    call ale#lsp_linter#SendRequest(
                \   bufnr(''),
                \   'eclipselsp',
                \   [0, 'java/classFileContents', {'uri': s:PathToJDT(l:filename)}],
                \       function('s:OpenJDTLink', [a:root, l:filename, a:line, a:column, a:options]))
endfunction

call ale#linter#Define('java', {
\   'name': 'eclipselsp',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#java#eclipselsp#Executable'),
\   'command': function('ale_linters#java#eclipselsp#RunWithVersionCheck'),
\   'language': 'java',
\   'project_root': function('ale#java#FindProjectRoot'),
\   'uri_handlers': {
\       'jdt': function('ale_linters#java#eclipselsp#HandleJdt')
\   },
\   'initialization_options': {
\     'extendedClientCapabilities': {
\       'classFileContentsSupport': v:true
\     }
\   }
\})
