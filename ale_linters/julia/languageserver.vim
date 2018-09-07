" Author: Bartolomeo Stellato <bartolomeo.stellato@gmail.com>
" Description: A language server for Julia

function! ale_linters#julia#languageserver#GetCommand(buffer) abort
    let l:julia_executable = ale#Var(a:buffer, 'julia_executable')
    return ale#Escape(l:julia_executable) . ale#Escape("--startup-file=no --history-file=no -e 'using LanguageServer; server = LanguageServer.LanguageServerInstance(STDIN, STDOUT, false); server.runlinter = true; run(server);'")
endfunction

call ale#linter#Define('julia', {
\   'name': 'languageserver',
\   'lsp': 'stdio',
\   'executable_callback': ale#VarFunc('julia_executable'),
\   'command_callback': 'ale_linters#julia#languageserver#GetCommand',
\   'language': 'julia',
\   'project_root_callback': 'ale#julia#FindProjectRoot',
\})
