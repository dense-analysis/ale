" Authors: ophirr33 <coghlan.ty@gmail.com>, rymdbar <https://rymdbar.x20.se/>
" Description: Perl::LanguageServer for perl, from cpan.org

" This should have the same value as in perl.vim
call ale#Set('perl_perl_executable', 'perl')
" Please note that perl_perl_options does not exist here.

call ale#Set('perl_languageserver_config', {})

function! s:get_lsp_config(buffer) abort
    " This tool doesn't kick in unless workspace/didChangeConfiguration is
    " called, thus this function returning a fallback dict when there is no
    " config.
    let l:lsp_config = ale#Var(a:buffer, 'perl_languageserver_config')

    return empty(l:lsp_config) ? { 'perl': { 'enable': 1 } } : l:lsp_config
endfunction

call ale#linter#Define('perl', {
\   'name': 'languageserver',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'perl_perl_executable')},
\   'command': '%e -MPerl::LanguageServer -ePerl::LanguageServer::run',
\   'lsp_config': {b -> s:get_lsp_config(b)},
\   'project_root': function('ale#handlers#perl#GetProjectRoot'),
\ })
