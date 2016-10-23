" Author: farenjihn <farenjihn@gmail.com>
" Description: Lints java files using javac

if exists('g:loaded_ale_linters_java_javac')
    finish
endif

let g:loaded_ale_linters_java_javac = 1
let g:ale_java_javac_classpath = ''

let s:eclipse_classpath = ''
let s:tmppath = '/tmp/java_ale/'

function! ale_linters#java#javac#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " Main.java:13: warning: [deprecation] donaught() in Testclass has been deprecated
    " Main.java:16: error: ';' expected

    let l:pattern = '^.*\:\(\d\+\):\ \(.*\):\(.*\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:output, {
            \   'bufnr': a:buffer,
            \   'lnum': l:match[1] + 0,
            \   'vcol': 0,
            \   'col': 1,
            \   'text': l:match[2] . ':' . l:match[3],
            \   'type': l:match[2] ==# 'error' ? 'E' : 'W',
            \   'nr': -1,
            \})
    endfor

    return l:output
endfunction

function! ale_linters#java#javac#ParseEclipseClasspath()
python << EOF

import xml.etree.ElementTree as ET, vim
tree = ET.parse(".classpath")
root = tree.getroot()

classpath = ''

for child in root:
    classpath += child.get("path")
    classpath += ':'

vim.command("let l:eclipse_classpath = '%s'" % classpath);

EOF

let s:eclipse_classpath = l:eclipse_classpath
endfunction

function! ale_linters#java#javac#CheckEclipseClasspath()
	" Eclipse .classpath parsing through python
	if file_readable('.classpath')
		let l:eclipse_classpath = ale_linters#java#javac#ParseEclipseClasspath()
endif

endfunction

function! ale_linters#java#javac#GetCommand(buffer)
    let l:path = s:tmppath . expand('%:p:h')
    let l:file = expand('%:t')
    let l:buf = getline(1, '$')

    " Javac cannot compile files from stdin so we move a copy into /tmp instead
    call mkdir(l:path, 'p')
    call writefile(l:buf, l:path . '/' . l:file)

    return 'javac '
        \ . '-Xlint '
        \ . '-cp ' . s:eclipse_classpath . g:ale_java_javac_classpath . ':. '
        \ . g:ale_java_javac_options
        \ . ' ' . l:path . '/' . l:file
endfunction

function! ale_linters#java#javac#CleanupTmp()
    call delete(s:tmppath, 'rf')
endfunction

autocmd! BufEnter *.java call ale_linters#java#javac#CheckEclipseClasspath()
autocmd! BufLeave *.java call ale_linters#java#javac#CleanupTmp()

call ale_linters#java#javac#CheckEclipseClasspath()
call ale#linter#Define('java', {
\   'name': 'javac',
\   'output_stream': 'stderr',
\   'executable': 'javac',
\   'command_callback': 'ale_linters#java#javac#GetCommand',
\   'callback': 'ale_linters#java#javac#Handle',
\})
