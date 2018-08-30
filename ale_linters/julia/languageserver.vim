" Author: Bartolomeo Stellato <bartolomeo.stellato@gmail.com>
" Description: A language server for Julia

call ale#Set('julia_languageserver_executable', 'julia')
call ale#Set('julia_languageserver_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#julia#languageserver#GetExecutable(buffer) abort
        let l:binary = ale#Var(a:buffer, 'julia_languageserver_executable')
        return ale#Escape(l:binary)
endfunction

function! ale_linters#julia#languageserver#GetCommand(buffer) abort
    let l:executable = ale_linters#julia#languageserver#GetExecutable(a:buffer)
    let l:options = '--startup-file=no --history-file=no -e ' . '"
\       using LanguageServer;
\       server = LanguageServer.LanguageServerInstance(STDIN, STDOUT, false);
\       server.runlinter = true;
\       run(server);"'

    return ale#Escape(l:executable) . ale#Escape(l:options)

endfunction

call ale#linter#Define('julia', {
\   'name': 'languageserver',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#julia#languageserver#GetExecutable',
\   'command_callback': 'ale_linters#julia#languageserver#GetCommand',
\   'project_root_callback': 'ale#julia#FindProjectRoot',
\})
